file(GLOB _sources "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

add_library(cpp_utils STATIC ${_sources})
add_dependencies(cpp_utils cefpython_headers)

target_include_directories(cpp_utils PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
    # After src/: platform-generated CEF headers not vendored in src/include.
    "${CEFPYTHON_CEF_ROOT}"
)

# Common browser-process flags come from cefpython_common_flags defined in the
# top-level CMakeLists.
target_link_libraries(cpp_utils PRIVATE cefpython_common_flags)
