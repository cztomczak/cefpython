file(GLOB _sources "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

add_library(cpp_utils STATIC ${_sources})
add_dependencies(cpp_utils cefpython_headers)

target_include_directories(cpp_utils PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
)

if(WIN32)
    target_compile_options(cpp_utils PRIVATE /EHsc /wd4190)
    target_compile_definitions(cpp_utils PRIVATE
        WIN32 _WIN32 _WINDOWS
        NTDDI_VERSION=0x06010000 WINVER=0x0601 _WIN32_WINNT=0x0601
        NDEBUG _NDEBUG _CRT_SECURE_NO_WARNINGS NOMINMAX
        BROWSER_PROCESS
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h"
    )
elseif(APPLE)
    target_compile_options(cpp_utils PRIVATE -DNDEBUG -O3)
    target_compile_definitions(cpp_utils PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
else()
    target_compile_options(cpp_utils PRIVATE -DNDEBUG -O3 -Wno-stringop-overflow)
    target_compile_definitions(cpp_utils PRIVATE
        CEFPYTHON_API_H_FILE="cefpython_api_fixed.h")
endif()
