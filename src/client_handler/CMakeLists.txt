file(GLOB _all_cpp "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
if(APPLE)
    file(GLOB _mm_files "${CMAKE_CURRENT_SOURCE_DIR}/*.mm")
    list(APPEND _all_cpp ${_mm_files})
endif()

set(_sources "")
foreach(_f IN LISTS _all_cpp)
    get_filename_component(_name "${_f}" NAME)
    set(_skip FALSE)
    if(_name MATCHES "_win\\.cpp$" AND NOT WIN32)
        set(_skip TRUE)
    elseif(_name MATCHES "_linux\\.cpp$" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(_skip TRUE)
    elseif(_name MATCHES "_mac\\.(cpp|mm)$" AND NOT APPLE)
        set(_skip TRUE)
    elseif(_name MATCHES "^x11\\.cpp$" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(_skip TRUE)
    elseif(_name MATCHES "gtk" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(_skip TRUE)
    endif()
    if(NOT _skip)
        list(APPEND _sources "${_f}")
    endif()
endforeach()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
endif()

add_library(client_handler STATIC ${_sources})
add_dependencies(client_handler cefpython_headers)

target_include_directories(client_handler PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_include_directories(client_handler PRIVATE ${GTK3_INCLUDE_DIRS})
endif()

if(WIN32)
    target_compile_options(client_handler PRIVATE /EHsc /wd4190)
    target_compile_definitions(client_handler PRIVATE
        WIN32 _WIN32 _WINDOWS
        NTDDI_VERSION=0x06010000 WINVER=0x0601 _WIN32_WINNT=0x0601
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS NOMINMAX
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
elseif(APPLE)
    target_compile_options(client_handler PRIVATE -DNDEBUG -O3)
    target_compile_definitions(client_handler PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
else()
    target_compile_options(client_handler PRIVATE -DNDEBUG -O3)
    target_compile_definitions(client_handler PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
endif()
