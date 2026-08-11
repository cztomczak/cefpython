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
    # After src/: platform-generated CEF headers not vendored in src/include.
    "${CEFPYTHON_CEF_ROOT}"
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

if(APPLE)
    # Chromium selects process-specific helpers by replacing " Helper" in the
    # generic helper name with one of the suffixes below. All five bundles are
    # therefore required even though browser_subprocess_path points only at the
    # generic helper executable.
    set(_cefpython_subprocess_targets
        cefpython_subprocess
        cefpython_subprocess_alerts
        cefpython_subprocess_gpu
        cefpython_subprocess_plugin
        cefpython_subprocess_renderer
    )
    foreach(_target IN LISTS _cefpython_subprocess_targets)
        add_executable(${_target} MACOSX_BUNDLE ${_exe_sources})
    endforeach()
else()
    set(_cefpython_subprocess_targets cefpython_subprocess)
    add_executable(cefpython_subprocess ${_exe_sources})
    set_target_properties(cefpython_subprocess PROPERTIES OUTPUT_NAME "subprocess")
endif()

foreach(_target IN LISTS _cefpython_subprocess_targets)
    add_dependencies(${_target} cefpython_headers)
    target_include_directories(${_target} PRIVATE
        "${CEFPYTHON_SRC_DIR}"
        "${CEFPYTHON_SRC_DIR}/common"
        "${CEFPYTHON_PYX_STAGE_DIR}"
        ${Python_INCLUDE_DIRS}
        # After src/: platform-generated CEF headers not vendored in src/include.
        "${CEFPYTHON_CEF_ROOT}"
    )
endforeach()

# Export the complete target list so the top-level install rule includes every
# macOS helper bundle while Windows and Linux keep their single flat executable.
set(CEFPYTHON_SUBPROCESS_TARGETS
    ${_cefpython_subprocess_targets}
    PARENT_SCOPE
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
    # Match CEF 147's declared CEF_TARGET_SDK and official helper plist.
    set(_macos_ver_min 12.0)

    function(_configure_cefpython_helper _target _output_name _bundle_id_suffix)
        # Generate a concrete plist per target. Pointing
        # MACOSX_BUNDLE_INFO_PLIST directly at a shared template would let
        # target-agnostic CMake variables give all variants the same name.
        set(CEFPYTHON_HELPER_EXECUTABLE "${_output_name}")
        set(CEFPYTHON_HELPER_BUNDLE_ID_SUFFIX "${_bundle_id_suffix}")
        set(CEFPYTHON_HELPER_MINIMUM_SYSTEM_VERSION "${_macos_ver_min}")
        set(_helper_info_plist
            "${CMAKE_CURRENT_BINARY_DIR}/${_target}-Info.plist")
        configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/helper-Info.plist.in"
            "${_helper_info_plist}"
            @ONLY
        )

        set_target_properties(${_target} PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST "${_helper_info_plist}"
            OUTPUT_NAME "${_output_name}"
        )
        target_compile_options(${_target} PRIVATE -DNDEBUG -O3)
        target_compile_definitions(${_target} PRIVATE
            CEFPYTHON_API_H_FILE="${MODULE_NAME}.h")
        target_link_options(${_target} PRIVATE
            -mmacosx-version-min=${_macos_ver_min}
            -Wl,-search_paths_first
            "-F${CEFPYTHON_CEF_ROOT}/bin"
            "-framework" "Chromium Embedded Framework"
            # Contents/MacOS -> bundle -> cefpython3 package root, where the
            # Chromium Embedded Framework.framework directory is installed.
            "-Wl,-rpath,@loader_path/../../../"
        )
        target_link_libraries(${_target} PRIVATE
            "${CEFPYTHON_CEF_ROOT}/lib/libcef_dll_wrapper.a"
        )
    endfunction()

    _configure_cefpython_helper(
        cefpython_subprocess "cefpython Helper" "")
    _configure_cefpython_helper(
        cefpython_subprocess_alerts "cefpython Helper (Alerts)" ".alerts")
    _configure_cefpython_helper(
        cefpython_subprocess_gpu "cefpython Helper (GPU)" ".gpu")
    _configure_cefpython_helper(
        cefpython_subprocess_plugin "cefpython Helper (Plugin)" ".plugin")
    _configure_cefpython_helper(
        cefpython_subprocess_renderer "cefpython Helper (Renderer)" ".renderer")
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
