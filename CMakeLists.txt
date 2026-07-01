cmake_minimum_required(VERSION 3.21)

# Read the CEF major version from the version header for the platform being
# built, so each platform uses its own CEF version (the values may differ
# across platforms). This runs before project() sets WIN32/APPLE/UNIX, and
# builds are always native (no cross-compiling), so select by host platform.
if(CMAKE_HOST_WIN32)
    set(_cef_version_header "src/version/cef_version_win.h")
elseif(CMAKE_HOST_APPLE)
    set(_cef_version_header "src/version/cef_version_macarm64.h")
else()
    set(_cef_version_header "src/version/cef_version_linux.h")
endif()
file(STRINGS "${_cef_version_header}" _ver_line
     REGEX "^#define CHROME_VERSION_MAJOR ")
string(REGEX REPLACE "^#define CHROME_VERSION_MAJOR ([0-9]+).*" "\\1" _chrome_major "${_ver_line}")
# Full CEF version string, e.g. "147.0.10+gd58e84d+chromium-147.0.7727.118".
# Used to select the matching prebuilt CEF directory under build/ so a leftover
# directory from a different CEF version is never picked up by accident.
file(STRINGS "${_cef_version_header}" _cef_version_line
     REGEX "^#define CEF_VERSION ")
string(REGEX REPLACE "^#define CEF_VERSION \"([^\"]+)\".*" "\\1" _cef_version "${_cef_version_line}")
message(STATUS "CEF version header: ${_cef_version_header} -> ${_cef_version} (major ${_chrome_major})")

project(cefpython3 VERSION "${_chrome_major}.0" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ---- Python -----------------------------------------------------------------
find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)

# "310" for Python 3.10, "314" for Python 3.14, etc.
string(CONCAT PYVERSION "${Python_VERSION_MAJOR}" "${Python_VERSION_MINOR}")
set(MODULE_NAME "cefpython_py${PYVERSION}")
message(STATUS "Python ${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} -> module: ${MODULE_NAME}")

# ---- Cython -----------------------------------------------------------------
find_program(CYTHON_EXECUTABLE NAMES cython cython3 REQUIRED)
message(STATUS "Cython: ${CYTHON_EXECUTABLE}")

option(ENABLE_PROFILING    "Cython: enable cProfile instrumentation (profile=True)"   OFF)
option(ENABLE_LINE_TRACING "Cython: enable line-level tracing/coverage (linetrace=True)" OFF)

set(_cython_directive_args "")
if(ENABLE_PROFILING)
    list(APPEND _cython_directive_args --directive profile=True)
endif()
if(ENABLE_LINE_TRACING)
    list(APPEND _cython_directive_args --directive linetrace=True)
endif()

# ---- CEF location -----------------------------------------------------------
if(NOT CEF_ROOT)
    # Auto-detect: build/cef*_win64 (versioned dir created by automate.py)
    if(WIN32)
        set(_cef_glob_pat "${CMAKE_SOURCE_DIR}/build/cef*_win64")
    elseif(APPLE)
        set(_cef_glob_pat "${CMAKE_SOURCE_DIR}/build/cef*_macarm64")
    else()
        set(_cef_glob_pat "${CMAKE_SOURCE_DIR}/build/cef*_linux64")
    endif()
    file(GLOB _cef_candidates LIST_DIRECTORIES true "${_cef_glob_pat}")
    # Select the directory matching the exact CEF version from the header, so a
    # leftover prebuilt dir for a different CEF version in build/ is never picked
    # up by accident. string(FIND) is a literal substring search (the version
    # contains regex-special chars like '+' and '.', so MATCHES is unsafe here).
    foreach(_d IN LISTS _cef_candidates)
        if(IS_DIRECTORY "${_d}")
            string(FIND "${_d}" "${_cef_version}" _ver_match)
            if(NOT _ver_match EQUAL -1)
                set(CEF_ROOT "${_d}")
                break()
            endif()
        endif()
    endforeach()
    if(NOT CEF_ROOT)
        message(FATAL_ERROR
            "CEF_ROOT not set and no prebuilt CEF ${_cef_version} found under "
            "build/ (matching ${_cef_glob_pat}). "
            "Download and prepare CEF first (python tools/download_cef.py && "
            "python tools/automate.py --prebuilt-cef), or pass -DCEF_ROOT=<path>.")
    endif()
endif()
message(STATUS "CEF_ROOT: ${CEF_ROOT}")

set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(PYX_STAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/pyx_stage")

# ---- Prepare .pyx files -----------------------------------------------------
# Copies src/*.pyx + src/handlers/*.pyx to PYX_STAGE_DIR, flattening the
# include paths and injecting version variables into the main file.
if(WIN32)
    set(_cef_ver_header "${SRC_DIR}/version/cef_version_win.h")
elseif(APPLE)
    set(_cef_ver_header "${SRC_DIR}/version/cef_version_macarm64.h")
else()
    set(_cef_ver_header "${SRC_DIR}/version/cef_version_linux.h")
endif()

file(GLOB _pyx_src_files
    "${SRC_DIR}/*.pyx"
    "${SRC_DIR}/handlers/*.pyx"
)
set(MAIN_PYX "${PYX_STAGE_DIR}/${MODULE_NAME}.pyx")

add_custom_command(
    OUTPUT "${MAIN_PYX}"
    COMMAND "${Python_EXECUTABLE}"
            "${CMAKE_SOURCE_DIR}/tools/cmake_prepare_pyx.py"
            --src "${SRC_DIR}"
            --out "${PYX_STAGE_DIR}"
            --pyversion "${PYVERSION}"
            --cef-version-header "${_cef_ver_header}"
    DEPENDS
        ${_pyx_src_files}
        "${CMAKE_SOURCE_DIR}/tools/cmake_prepare_pyx.py"
    COMMENT "Preparing .pyx files -> ${PYX_STAGE_DIR}"
    VERBATIM
)
add_custom_target(cefpython_pyx DEPENDS "${MAIN_PYX}")

# ---- Transpile pyx -> cpp ----------------------------------------------------
set(CEFPYTHON_CPP "${PYX_STAGE_DIR}/${MODULE_NAME}.cpp")
set(CEFPYTHON_H   "${PYX_STAGE_DIR}/${MODULE_NAME}.h")

set(_cython_inc_args
    -I "${SRC_DIR}"
    -I "${SRC_DIR}/common"
    -I "${SRC_DIR}/extern"
    -I "${SRC_DIR}/extern/cef"
)

add_custom_command(
    OUTPUT "${CEFPYTHON_CPP}" "${CEFPYTHON_H}"
    COMMAND "${CYTHON_EXECUTABLE}"
            --cplus --3str
            ${_cython_inc_args}
            ${_cython_directive_args}
            -o "${CEFPYTHON_CPP}"
            "${MAIN_PYX}"
    DEPENDS "${MAIN_PYX}"
    COMMENT "Cython: ${MODULE_NAME}.pyx -> C++"
    VERBATIM
)

# ---- Cython API header ------------------------------------------------------
# C++ sources include the Cython-generated public API header directly via the
# CEFPYTHON_API_H_FILE define (= "${MODULE_NAME}.h"); it sits in PYX_STAGE_DIR
# which is on each target's include path. No post-processing is needed: the
# C4190 warning is suppressed by the /wd4190 compile flag (and the renderer
# subprocess, which lacks that flag, doesn't include the header at all).
# cefpython_headers gates C++ compilation on the header being generated.
add_custom_target(cefpython_headers DEPENDS "${CEFPYTHON_H}")

# ---- Static C++ libraries ---------------------------------------------------
# All three libs share these settings so pass them via cache variables that
# the subdirectory CMakeLists files can read.
set(CEFPYTHON_PYX_STAGE_DIR "${PYX_STAGE_DIR}" CACHE INTERNAL "")
set(CEFPYTHON_CEF_ROOT      "${CEF_ROOT}"       CACHE INTERNAL "")
set(CEFPYTHON_SRC_DIR       "${SRC_DIR}"        CACHE INTERNAL "")
set(CEFPYTHON_CEF_VERSION   "${_cef_version}"   CACHE INTERNAL "")

# Windows API target level. Match upstream CEF, which builds for Windows 10
# (see cef_variables.cmake: WINVER/_WIN32_WINNT=0x0A00, NTDDI_WIN10_FE).
# Chromium 147 only runs on Windows 10+, so targeting an older Windows here
# would just hide newer Win32 APIs without buying real backward compatibility.
# Defined once and consumed by both cefpython_common_flags (browser-process
# targets) and the subprocess executable so the value can't drift between files.
set(CEFPYTHON_WIN_TARGET_DEFS
    WINVER=0x0A00 _WIN32_WINNT=0x0A00 NTDDI_VERSION=NTDDI_WIN10_FE
    CACHE INTERNAL "Windows API target level (matches upstream CEF: Windows 10)")

# Shared compile settings for the browser-process C++ targets (the Python
# extension module, client_handler, cpp_utils, cefpython_app). These flags
# were previously duplicated verbatim in every CMake file - in particular the
# Windows definition block with the NTDDI_VERSION/WINVER/_WIN32_WINNT triple.
# Define them once here as an INTERFACE library that those targets link.
#
# NOTE: the subprocess executable is a *renderer*-process target with different
# settings (RENDERER_PROCESS, static /MT CRT, _HAS_EXCEPTIONS=0, no /EHsc) and
# deliberately does NOT use this. BROWSER_PROCESS only affects
# src/subprocess/cefpython_app.cpp; it is a no-op for the other sources.
add_library(cefpython_common_flags INTERFACE)
target_compile_definitions(cefpython_common_flags INTERFACE
    BROWSER_PROCESS
    CEFPYTHON_API_H_FILE="${MODULE_NAME}.h"
)
if(WIN32)
    target_compile_options(cefpython_common_flags INTERFACE /EHsc /wd4190)
    target_compile_definitions(cefpython_common_flags INTERFACE
        WIN32 _WIN32 _WINDOWS
        ${CEFPYTHON_WIN_TARGET_DEFS}
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS NOMINMAX
    )
else()
    target_compile_options(cefpython_common_flags INTERFACE -DNDEBUG -O3)
endif()

# Filter a list of source files for the current platform: drop *_win.cpp,
# *_linux.cpp, *_mac.cpp/.mm, x11.cpp and gtk* files that don't belong on the
# OS being built. Shared by the client_handler and subprocess CMakeLists so the
# rules live in one place. IN_LIST is the *name* of the input list variable;
# the result is written to the variable named by OUT_VAR in the caller's scope.
function(filter_sources IN_LIST OUT_VAR)
    set(_result "")
    foreach(_f IN LISTS ${IN_LIST})
        get_filename_component(_name "${_f}" NAME)
        set(_skip FALSE)
        if(_name MATCHES "_win\\.cpp$"   AND NOT WIN32)
            set(_skip TRUE)
        endif()
        if(_name MATCHES "_linux\\.cpp$" AND NOT (CMAKE_SYSTEM_NAME STREQUAL "Linux"))
            set(_skip TRUE)
        endif()
        if(_name MATCHES "_mac\\.(cpp|mm)$" AND NOT APPLE)
            set(_skip TRUE)
        endif()
        if(_name MATCHES "^x11\\.cpp$"   AND NOT (CMAKE_SYSTEM_NAME STREQUAL "Linux"))
            set(_skip TRUE)
        endif()
        if(_name MATCHES "gtk"           AND NOT (CMAKE_SYSTEM_NAME STREQUAL "Linux"))
            set(_skip TRUE)
        endif()
        if(NOT _skip)
            list(APPEND _result "${_f}")
        endif()
    endforeach()
    set(${OUT_VAR} "${_result}" PARENT_SCOPE)
endfunction()

add_subdirectory("${SRC_DIR}/client_handler"
                 "${CMAKE_CURRENT_BINARY_DIR}/client_handler")
add_subdirectory("${SRC_DIR}/subprocess"
                 "${CMAKE_CURRENT_BINARY_DIR}/subprocess_build")
add_subdirectory("${SRC_DIR}/cpp_utils"
                 "${CMAKE_CURRENT_BINARY_DIR}/cpp_utils")

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
endif()

# ---- Python extension -------------------------------------------------------
Python_add_library(${MODULE_NAME} MODULE "${CEFPYTHON_CPP}")
add_dependencies(${MODULE_NAME} cefpython_headers)

target_include_directories(${MODULE_NAME} PRIVATE
    "${SRC_DIR}"
    "${SRC_DIR}/common"
    "${SRC_DIR}/extern"
    "${SRC_DIR}/extern/cef"
    "${PYX_STAGE_DIR}"
)

if(ENABLE_LINE_TRACING)
    target_compile_definitions(${MODULE_NAME} PRIVATE CYTHON_TRACE=1)
endif()

# Common browser-process flags come from cefpython_common_flags; only the
# module-specific extras are listed per platform below.
target_link_libraries(${MODULE_NAME} PRIVATE cefpython_common_flags)

if(WIN32)
    target_include_directories(${MODULE_NAME} PRIVATE "${SRC_DIR}/windows")
    target_compile_options(${MODULE_NAME} PRIVATE /wd4305)
    target_link_libraries(${MODULE_NAME} PRIVATE
        cefpython_app
        client_handler
        cpp_utils
        "${CEF_ROOT}/lib/libcef.lib"
        "${CEF_ROOT}/lib/VS2015/libcef_dll_wrapper_MD.lib"
        User32
    )
    target_link_options(${MODULE_NAME} PRIVATE /ignore:4217)
elseif(APPLE)
    target_compile_options(${MODULE_NAME} PRIVATE
        -Wno-return-type-c-linkage -Wno-constant-logical-operand
        -stdlib=libc++ -fno-strict-aliasing -fno-rtti
        -fno-threadsafe-statics -fobjc-call-cxx-cdtors
        -fvisibility=hidden -fvisibility-inlines-hidden
    )
    target_link_options(${MODULE_NAME} PRIVATE
        -mmacosx-version-min=11.0
        -Wl,-search_paths_first -Wl,-dead_strip
        "-F${CEF_ROOT}/bin" "-framework" "Chromium Embedded Framework"
        "-Wl,-rpath,@loader_path/"
    )
    target_link_libraries(${MODULE_NAME} PRIVATE
        c++ c++abi
        cefpython_app client_handler cpp_utils
        "${CEF_ROOT}/lib/libcef_dll_wrapper.a"
    )
else()
    target_compile_options(${MODULE_NAME} PRIVATE
        -flto -fdata-sections -ffunction-sections
        -Wno-stringop-overflow
    )
    target_include_directories(${MODULE_NAME} PRIVATE
        ${GTK3_INCLUDE_DIRS}
    )
    target_link_options(${MODULE_NAME} PRIVATE
        -flto -Wl,--gc-sections
        -Wno-stringop-overflow
    )
    target_link_libraries(${MODULE_NAME} PRIVATE
        X11 ${GTK3_LIBRARIES}
        cefpython_app client_handler cpp_utils
        "${CEF_ROOT}/lib/libcef_dll_wrapper.a"
    )
endif()

# ---- Install ----------------------------------------------------------------
# The extension module itself
install(TARGETS ${MODULE_NAME}
    LIBRARY DESTINATION "cefpython3"
    RUNTIME DESTINATION "cefpython3"
)

# subprocess executable (OUTPUT_NAME "subprocess" is set in src/subprocess/CMakeLists.txt)
install(TARGETS cefpython_subprocess
    RUNTIME DESTINATION "cefpython3"
)

# CEF runtime files (DLLs, .pak, .dat, locales/, etc.)
# Sample apps (cefclient, cefsimple, ceftests) are excluded.
if(WIN32)
    install(DIRECTORY "${CEF_ROOT}/bin/"
        DESTINATION "cefpython3"
        PATTERN "cefclient*"    EXCLUDE
        PATTERN "cefsimple*"    EXCLUDE
        PATTERN "ceftests*"     EXCLUDE
    )
elseif(APPLE)
    install(DIRECTORY "${CEF_ROOT}/bin/"
        DESTINATION "cefpython3"
        PATTERN "cefclient*"   EXCLUDE
        PATTERN "cefsimple*"   EXCLUDE
        PATTERN "ceftests*"    EXCLUDE
    )
else()
    install(DIRECTORY "${CEF_ROOT}/bin/"
        DESTINATION "cefpython3"
        PATTERN "cefclient*"   EXCLUDE
        PATTERN "cefsimple*"   EXCLUDE
        PATTERN "ceftests*"    EXCLUDE
        # chrome-sandbox is a Linux-only setuid sandbox helper. It is excluded
        # here because a pip wheel cannot install a chown-root + chmod-4755
        # binary; cefpython runs with --no-sandbox instead (see
        # _linux_apply_initialize_defaults). On Windows/macOS CEF ships no such
        # file, so the exclude is only needed on Linux.
        PATTERN "chrome-sandbox" EXCLUDE
    )
endif()
