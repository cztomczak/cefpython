cmake_minimum_required(VERSION 3.21)

# Read CEF major version from the Windows header (used on all platforms at
# configure time; the per-platform header values are identical for this field).
file(STRINGS "src/version/cef_version_win.h" _ver_line
     REGEX "^#define CHROME_VERSION_MAJOR ")
string(REGEX REPLACE "^#define CHROME_VERSION_MAJOR ([0-9]+).*" "\\1" _chrome_major "${_ver_line}")

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
        set(_cef_glob_pat "${CMAKE_SOURCE_DIR}/build/cef*_mac64")
    else()
        set(_cef_glob_pat "${CMAKE_SOURCE_DIR}/build/cef*_linux64")
    endif()
    file(GLOB _cef_candidates LIST_DIRECTORIES true "${_cef_glob_pat}")
    # Prefer the versioned directory over cef_<os> fallback
    foreach(_d IN LISTS _cef_candidates)
        if(IS_DIRECTORY "${_d}")
            set(CEF_ROOT "${_d}")
            break()
        endif()
    endforeach()
    if(NOT CEF_ROOT)
        message(FATAL_ERROR
            "CEF_ROOT not set and cannot be auto-detected. "
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
    set(_cef_ver_header "${SRC_DIR}/version/cef_version_mac.h")
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

# ---- Fix Cython API header --------------------------------------------------
# Generates:
#   cefpython_pyXX_fixed.h  – original .h with #pragma warning(disable:4190)
#   cefpython_api_fixed.h   – stable single-name wrapper for cefpython_public_api.h
set(CEFPYTHON_H_FIXED  "${PYX_STAGE_DIR}/${MODULE_NAME}_fixed.h")
set(CEF_API_FIXED_H    "${PYX_STAGE_DIR}/cefpython_api_fixed.h")

add_custom_command(
    OUTPUT "${CEFPYTHON_H_FIXED}" "${CEF_API_FIXED_H}"
    COMMAND "${Python_EXECUTABLE}"
            "${CMAKE_SOURCE_DIR}/tools/cmake_fix_header.py"
            "${CEFPYTHON_H}"
            "${CEFPYTHON_H_FIXED}"
            "${CEF_API_FIXED_H}"
            "${MODULE_NAME}"
    DEPENDS "${CEFPYTHON_H}" "${CMAKE_SOURCE_DIR}/tools/cmake_fix_header.py"
    COMMENT "Generating ${MODULE_NAME}_fixed.h + cefpython_api_fixed.h"
    VERBATIM
)
add_custom_target(cefpython_headers
    DEPENDS "${CEFPYTHON_H_FIXED}" "${CEF_API_FIXED_H}")

# ---- Static C++ libraries ---------------------------------------------------
# All three libs share these settings so pass them via cache variables that
# the subdirectory CMakeLists files can read.
set(CEFPYTHON_PYX_STAGE_DIR "${PYX_STAGE_DIR}" CACHE INTERNAL "")
set(CEFPYTHON_CEF_ROOT      "${CEF_ROOT}"       CACHE INTERNAL "")
set(CEFPYTHON_SRC_DIR       "${SRC_DIR}"        CACHE INTERNAL "")

add_subdirectory("${SRC_DIR}/client_handler"
                 "${CMAKE_CURRENT_BINARY_DIR}/client_handler")
add_subdirectory("${SRC_DIR}/subprocess"
                 "${CMAKE_CURRENT_BINARY_DIR}/subprocess_build")
add_subdirectory("${SRC_DIR}/cpp_utils"
                 "${CMAKE_CURRENT_BINARY_DIR}/cpp_utils")

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

if(WIN32)
    target_include_directories(${MODULE_NAME} PRIVATE "${SRC_DIR}/windows")
    target_compile_options(${MODULE_NAME} PRIVATE /EHsc /wd4305 /wd4190)
    target_compile_definitions(${MODULE_NAME} PRIVATE
        WIN32 _WIN32 _WINDOWS
        NTDDI_VERSION=0x06010000 WINVER=0x0601 _WIN32_WINNT=0x0601
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS NOMINMAX
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
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
        -std=gnu++11 -DNDEBUG -O3
        -Wno-return-type-c-linkage -Wno-constant-logical-operand
        -stdlib=libc++ -fno-strict-aliasing -fno-rtti
        -fno-threadsafe-statics -fobjc-call-cxx-cdtors
        -fvisibility=hidden -fvisibility-inlines-hidden
    )
    target_compile_definitions(${MODULE_NAME} PRIVATE
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
    target_link_options(${MODULE_NAME} PRIVATE
        -mmacosx-version-min=10.9
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
        -std=gnu++11 -DNDEBUG -O3
        -flto -fdata-sections -ffunction-sections
    )
    target_compile_definitions(${MODULE_NAME} PRIVATE
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
    target_link_options(${MODULE_NAME} PRIVATE
        -flto -Wl,--gc-sections
    )
    target_link_libraries(${MODULE_NAME} PRIVATE
        X11 gobject-2.0 glib-2.0 gtk-x11-2.0 gdk-x11-2.0
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
        PATTERN "chrome-sandbox" EXCLUDE
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
        PATTERN "chrome-sandbox" EXCLUDE
    )
endif()
