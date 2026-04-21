file(GLOB _all_cpp "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB _mml_cpp "${CMAKE_CURRENT_SOURCE_DIR}/main_message_loop/*.cpp")
if(APPLE)
    file(GLOB _mm_files "${CMAKE_CURRENT_SOURCE_DIR}/*.mm")
    list(APPEND _all_cpp ${_mm_files})
    file(GLOB _mml_mm "${CMAKE_CURRENT_SOURCE_DIR}/main_message_loop/*.mm")
    list(APPEND _mml_cpp ${_mml_mm})
endif()

# Helper: filter a list of source files for the current platform.
# Sets the result in the variable named by OUT_VAR.
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

if(WIN32)
    target_compile_options(cefpython_app PRIVATE /EHsc /wd4190)
    target_compile_definitions(cefpython_app PRIVATE
        WIN32 _WIN32 _WINDOWS
        NTDDI_VERSION=0x06010000 WINVER=0x0601 _WIN32_WINNT=0x0601
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS NOMINMAX
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
elseif(APPLE)
    target_compile_options(cefpython_app PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_app PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
else()
    target_compile_options(cefpython_app PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_app PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
endif()

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
        NTDDI_VERSION=0x06010000 WINVER=0x0601 _WIN32_WINNT=0x0601
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS
        NOMINMAX UNICODE _UNICODE WIN32_LEAN_AND_MEAN
        "_HAS_EXCEPTIONS=0"
        RENDERER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef.lib"
        "${CEFPYTHON_CEF_ROOT}/lib/VS2015/libcef_dll_wrapper_MT.lib"
    )
    target_link_options(cefpython_subprocess PRIVATE
        /MANIFEST:NO /LARGEADDRESSAWARE /SUBSYSTEM:WINDOWS
    )
elseif(APPLE)
    target_compile_options(cefpython_subprocess PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_subprocess PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
    target_link_options(cefpython_subprocess PRIVATE
        -mmacosx-version-min=10.9
        "-F${CEFPYTHON_CEF_ROOT}/bin"
        "-framework" "Chromium Embedded Framework"
    )
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef_dll_wrapper.a"
    )
else()
    target_compile_options(cefpython_subprocess PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cefpython_subprocess PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
    target_link_libraries(cefpython_subprocess PRIVATE
        "${CEFPYTHON_CEF_ROOT}/lib/libcef_dll_wrapper.a"
    )
endif()
