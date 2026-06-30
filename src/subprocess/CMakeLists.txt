file(GLOB _all_cpp "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB _mml_cpp "${CMAKE_CURRENT_SOURCE_DIR}/main_message_loop/*.cpp")
if(APPLE)
    file(GLOB _mm_files "${CMAKE_CURRENT_SOURCE_DIR}/*.mm")
    list(APPEND _all_cpp ${_mm_files})
    file(GLOB _mml_mm "${CMAKE_CURRENT_SOURCE_DIR}/main_message_loop/*.mm")
    list(APPEND _mml_cpp ${_mml_mm})
endif()

# filter_sources() is defined in the top-level CMakeLists and shared with
# client_handler so the platform skip rules live in one place.
filter_sources(_all_cpp _filtered_all)
filter_sources(_mml_cpp _filtered_mml)

# ---- cefpython_app (browser-process static library) -------------------------
# All subprocess/*.cpp except main.cpp, plus main_message_loop/*.cpp
set(_app_sources "")
foreach(_f IN LISTS _filtered_all)
    get_filename_component(_name "${_f}" NAME)
    if(NOT _name STREQUAL "main.cpp")
        list(APPEND _app_sources "${_f}")
    endif()
endforeach()
list(APPEND _app_sources ${_filtered_mml})

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
    pkg_check_modules(GTK3_UNIXPRINT REQUIRED gtk+-unix-print-3.0)
endif()

add_library(cefpython_app STATIC ${_app_sources})
add_dependencies(cefpython_app cefpython_headers)

target_include_directories(cefpython_app PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_include_directories(cefpython_app PRIVATE
        ${GTK3_INCLUDE_DIRS}
        ${GTK3_UNIXPRINT_INCLUDE_DIRS}
    )
endif()

# Common browser-process flags (matches the other browser-process targets)
# come from cefpython_common_flags defined in the top-level CMakeLists.
target_link_libraries(cefpython_app PRIVATE cefpython_common_flags)

# ---- subprocess executable (renderer-process) -------------------------------
# All subprocess/*.cpp except print_handler_gtk.cpp (already filtered above on non-Linux).
# Note: does NOT include main_message_loop sources — that is browser-process only.
set(_exe_sources "")
foreach(_f IN LISTS _filtered_all)
    get_filename_component(_name "${_f}" NAME)
    if(NOT _name MATCHES "print_handler_gtk")
        list(APPEND _exe_sources "${_f}")
    endif()
endforeach()

if(WIN32)
    # Locate CEF's stock compatibility.manifest from the unpacked binary
    # distribution. `tools/download_cef.py` extracts the distrib to
    # build/cef_binary_<full-version>_windows64/; this is always present
    # when a from-source build runs (automate.py --prebuilt-cef requires
    # the same directory).
    file(GLOB _cef_binary_candidates LIST_DIRECTORIES true
         "${CMAKE_SOURCE_DIR}/build/cef_binary_*_windows64")
    # Select the distrib matching the exact CEF version (CEFPYTHON_CEF_VERSION is
    # set by the top-level CMakeLists), so a leftover distrib for a different CEF
    # version in build/ is never picked up by accident.
    set(_cef_binary_distrib "")
    foreach(_d IN LISTS _cef_binary_candidates)
        if(IS_DIRECTORY "${_d}")
            string(FIND "${_d}" "${CEFPYTHON_CEF_VERSION}" _ver_match)
            if(NOT _ver_match EQUAL -1)
                set(_cef_binary_distrib "${_d}")
                break()
            endif()
        endif()
    endforeach()
    set(_cef_compat_manifest
        "${_cef_binary_distrib}/tests/cefsimple/win/compatibility.manifest")
    if(NOT EXISTS "${_cef_compat_manifest}")
        message(FATAL_ERROR
            "compatibility.manifest not found for CEF ${CEFPYTHON_CEF_VERSION} "
            "under build/cef_binary_*_windows64/.\n"
            "Run `python tools/download_cef.py` to extract the CEF distribution.")
    endif()
    message(STATUS "Subprocess manifest input: ${_cef_compat_manifest}")
endif()

add_executable(cefpython_subprocess ${_exe_sources})
add_dependencies(cefpython_subprocess cefpython_headers)
set_target_properties(cefpython_subprocess PROPERTIES OUTPUT_NAME "subprocess")

target_include_directories(cefpython_subprocess PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
)

if(WIN32)
    # Static CRT (/MT) required for the subprocess executable
    set_property(TARGET cefpython_subprocess PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded")
    target_compile_options(cefpython_subprocess PRIVATE /std:c++20)
    target_compile_definitions(cefpython_subprocess PRIVATE
        WIN32 _WIN32 _WINDOWS
        ${CEFPYTHON_WIN_TARGET_DEFS}
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS
        NOMINMAX UNICODE _UNICODE WIN32_LEAN_AND_MEAN
        "_HAS_EXCEPTIONS=0"
        RENDERER_PROCESS
        CEFPYTHON_API_H_FILE="${MODULE_NAME}.h"
    )
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef.lib"
        "${CEFPYTHON_CEF_ROOT}/lib/VS2015/libcef_dll_wrapper_MT.lib"
    )
    # Embed CEF's compatibility.manifest as RT_MANIFEST so Chromium's
    # ANGLE D3D11 GPU process init does not crash with STATUS_BREAKPOINT
    # (exit_code=-2147483645). The linker merges /MANIFESTINPUT with its
    # auto-generated trustInfo block and embeds the result as resource
    # id 1, identical to a hand-written subprocess.rc but driven by CMake.
    target_link_options(cefpython_subprocess PRIVATE
        /MANIFEST:EMBED
        "/MANIFESTINPUT:${_cef_compat_manifest}"
        /LARGEADDRESSAWARE /SUBSYSTEM:WINDOWS
    )
elseif(APPLE)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
        set(_macos_ver_min 11.0)
    else()
        set(_macos_ver_min 10.9)
    endif()
    target_compile_options(cefpython_subprocess PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_subprocess PRIVATE
        CEFPYTHON_API_H_FILE="${MODULE_NAME}.h")
    target_link_options(cefpython_subprocess PRIVATE
        -mmacosx-version-min=${_macos_ver_min}
        -Wl,-search_paths_first
        "-F${CEFPYTHON_CEF_ROOT}/bin"
        "-framework" "Chromium Embedded Framework"
        "-Wl,-rpath,@loader_path/"
        # Embed Info.plist so CFBundleGetMainBundle() returns CFBundleIdentifier
        # = "org.cefpython", matching the service name the browser process
        # registers with MachPortRendezvousServer.
        "-sectcreate" "__TEXT" "__info_plist"
        "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
    )
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef_dll_wrapper.a"
    )
else()
    target_compile_options(cefpython_subprocess PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_subprocess PRIVATE
        CEFPYTHON_API_H_FILE="${MODULE_NAME}.h")
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef_dll_wrapper.a"
        "${CEFPYTHON_CEF_ROOT}/bin/libcef.so"
    )
    # Use $ORIGIN so the installed subprocess finds libcef.so from its own
    # directory (cefpython3/) instead of the build-time CEF path which
    # contains chrome-sandbox — a setuid binary that can't work on nosuid
    # filesystems (e.g. VMware HGFS).
    set_target_properties(cefpython_subprocess PROPERTIES
        BUILD_RPATH "$ORIGIN"
        INSTALL_RPATH "$ORIGIN"
    )
endif()
