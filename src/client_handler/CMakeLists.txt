file(GLOB _all_cpp "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
if(APPLE)
    file(GLOB _mm_files "${CMAKE_CURRENT_SOURCE_DIR}/*.mm")
    list(APPEND _all_cpp ${_mm_files})
endif()

# filter_sources() is defined in the top-level CMakeLists and shared with the
# subprocess CMakeLists so the platform skip rules live in one place.
filter_sources(_all_cpp _sources)

add_library(client_handler STATIC ${_sources})
add_dependencies(client_handler cefpython_headers)

target_include_directories(client_handler PRIVATE
    "${CEFPYTHON_SRC_DIR}"
    "${CEFPYTHON_SRC_DIR}/common"
    "${CEFPYTHON_PYX_STAGE_DIR}"
    ${Python_INCLUDE_DIRS}
    "${CEFPYTHON_CEF_ROOT}"
)

# Common browser-process flags (Windows def block, -DNDEBUG -O3, API header
# define, etc.) come from cefpython_common_flags defined in the top-level
# CMakeLists.
target_link_libraries(client_handler PRIVATE cefpython_common_flags)
