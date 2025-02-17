# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Called by build.py internally. Builds C++ projects using
distutils/setuptools compilers. This tool is executed by build.py
on Windows only currently. Output directories are in
build/build_cefpython/.

Usage:
    build_cpp_projects.py [--force]

TODO: Linux/Mac support, see makefiles, add include dirs using
      compiler.add_include_dir, compiler/linker flags,
      refactor macros.
"""

# import setuptools so that distutils msvc compiler is patched
# noinspection PyUnresolvedReferences
import setuptools
from distutils.ccompiler import new_compiler
from common import *
import shutil
from pprint import pprint

# Macros
MACROS = [
    "WIN32", "_WIN32", "_WINDOWS",
    # Windows 7+ minimum supported
    ("NTDDI_VERSION", "0x06010000"),
    ("WINVER", "0x0601"),
    ("_WIN32_WINNT", "0x0601"),
    "NDEBUG", "_NDEBUG",
    "_CRT_SECURE_NO_WARNINGS",
]
cefpython_app_MACROS = MACROS + [
    "BROWSER_PROCESS",
]
subprocess_MACROS = MACROS + [
    "RENDERER_PROCESS",
    "UNICODE", "_UNICODE",
    "NOMINMAX",
    "WIN32_LEAN_AND_MEAN",
    ("_HAS_EXCEPTIONS", "0"),
]

# Compiler args
COMPILER_ARGS = [
    "/EHsc",
    "/std:c++17",
]
subprocess_COMPILER_ARGS = [
    "/MT",
    "/std:c++17",
]

# Linker args
subprocess_LINKER_ARGS = [
    "/MANIFEST:NO",
    "/LARGEADDRESSAWARE",
]

# Command line args
FORCE_FLAG = False


def main():
    command_line_args()
    clean_build_directories_if_forced()
    print_compiler_options()
    build_cefpython_app_library()
    build_library(lib_name="client_handler",
                  macros=MACROS,
                  sources_dir=CLIENT_HANDLER_DIR,
                  output_dir=BUILD_CLIENT_HANDLER)
    build_library(lib_name="cpp_utils",
                  macros=MACROS,
                  sources_dir=CPP_UTILS_DIR,
                  output_dir=BUILD_CPP_UTILS)
    build_subprocess_executable()
    print("[build_cpp_projects.py] Done building C++ projects")


def command_line_args():
    global FORCE_FLAG
    if "--force" in sys.argv:
        FORCE_FLAG = True


def clean_build_directories_if_forced():
    build_dirs = [BUILD_CEFPYTHON_APP, BUILD_CLIENT_HANDLER, BUILD_CPP_UTILS,
                  BUILD_SUBPROCESS]
    if FORCE_FLAG:
        print("[build_cpp_projects.py] Clean C++ projects build directories")
        for bdir in build_dirs:
            if os.path.isdir(bdir):
                shutil.rmtree(bdir)


def print_compiler_options():
    compiler = get_compiler()
    print("build_cpp_projects.py] Shared macros:")
    pprint(MACROS, indent=3, width=160)
    print("[build_cpp_projects.py] cefpython_app library macros:")
    pprint(cefpython_app_MACROS, indent=3, width=160)
    print("[build_cpp_projects.py] subprocess executable macros:")
    pprint(subprocess_MACROS, indent=3, width=160)
    print("[build_cpp_projects.py] Compiler options:")
    pprint(vars(compiler), indent=3, width=160)


def get_compiler(static=False):
    # NOTES:
    # - VS2008 and VS2010 are both using distutils/msvc9compiler.py
    compiler = new_compiler()
    # Must initialize so that "compile_options" and others are available
    compiler.initialize()
    if static:
        compiler.compile_options.remove("/MD")
        # Overwrite function that adds /MANIFESTFILE, as for subprocess
        # manifest is disabled. Otherwise warning LNK4075 is generated.
        if hasattr(compiler, "manifest_setup_ldargs"):
            compiler.manifest_setup_ldargs = lambda *_: None
    return compiler


def build_library(lib_name, macros, output_dir,
                  sources=None, sources_dir=None):
    assert bool(sources_dir) ^ bool(sources)  # xor
    print("[build_cpp_projects.py] Build library: {lib_name}"
          .format(lib_name=lib_name))
    compiler = get_compiler()
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    if sources_dir:
        assert not sources
        sources = get_sources(sources_dir)
    (changed, objects) = smart_compile(compiler,
                                       macros=macros,
                                       extra_args=COMPILER_ARGS,
                                       sources=sources,
                                       output_dir=output_dir)
    lib_path = os.path.join(output_dir, lib_name + LIB_EXT)
    if changed or not os.path.exists(lib_path):
        compiler.create_static_lib(objects, lib_name,
                                   output_dir=output_dir)
        print("[build_cpp_projects.py] Created library: {lib_name}"
              .format(lib_name=lib_name))
    else:
        print("[build_cpp_projects.py] Library is up-to-date: {lib_name}"
              .format(lib_name=lib_name))


def build_cefpython_app_library():
    sources = get_sources(SUBPROCESS_DIR, exclude_names=["main.cpp"])
    main_message_loop_dir = os.path.join(SUBPROCESS_DIR, "main_message_loop")
    sources.extend(get_sources(main_message_loop_dir))
    build_library(lib_name="cefpython_app",
                  macros=cefpython_app_MACROS,
                  sources=sources,
                  output_dir=BUILD_CEFPYTHON_APP)


def build_subprocess_executable():
    print("[build_cpp_projects.py] Build executable: subprocess")
    compiler = get_compiler(static=True)
    sources = get_sources(SUBPROCESS_DIR,
                          exclude_names=["print_handler_gtk.cpp"])
    (changed, objects) = smart_compile(compiler,
                                       macros=subprocess_MACROS,
                                       extra_args=subprocess_COMPILER_ARGS,
                                       sources=sources,
                                       output_dir=BUILD_SUBPROCESS)
    executable_path = os.path.join(BUILD_SUBPROCESS,
                                   "subprocess" + EXECUTABLE_EXT)
    if changed or not os.path.exists(executable_path):
        lib_dir = os.path.join(CEF_BINARIES_LIBRARIES, "lib")
        lib_dir_vs = os.path.join(lib_dir,
                                  get_msvs_for_python(vs_prefix=True))
        compiler.link_executable(objects,
                                 output_progname="subprocess",
                                 output_dir=BUILD_SUBPROCESS,
                                 libraries=["libcef",
                                            "libcef_dll_wrapper_MT"],
                                 library_dirs=[lib_dir, lib_dir_vs],
                                 # TODO linker flags for Linux/Mac
                                 extra_preargs=None,
                                 extra_postargs=subprocess_LINKER_ARGS)
    else:
        print("[build_cpp_projects.py] Executable is up-to-date: subprocess")


def get_sources(sources_dir, exclude_names=None):
    if not exclude_names:
        exclude_names = list()
    sources = glob.glob(os.path.join(sources_dir, "*.cpp"))
    if MAC:
        sources.extend(glob.glob(os.path.join(sources_dir, "*.mm")))
    ret = list()
    for source_file in sources:
        filename = os.path.basename(source_file)
        if "_win.cpp" in filename and not WINDOWS:
            continue
        if "_linux.cpp" in filename and not LINUX:
            continue
        if "x11" in filename and not LINUX:
            continue
        if "gtk" in filename and not LINUX:
            continue
        if "_mac.cpp" in filename and not MAC:
            continue
        exclude = False
        for name in exclude_names:
            if name in filename:
                exclude = True
                break
        if not exclude:
            ret.append(source_file)
    return ret


def smart_compile(compiler, macros, extra_args, sources, output_dir):
    """Smart compile will only recompile files that need recompiling."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    any_changed = False
    objects = list()
    for source_file in sources:
        header_file = source_file.replace(".cpp", ".h")
        header_file = header_file.replace(".mm", ".h")
        assert header_file.endswith(".h")
        if not os.path.isfile(header_file):
            header_file = None
        obj_file = os.path.join(output_dir, os.path.basename(source_file))
        obj_file = obj_file.replace(".cpp", OBJ_EXT)
        obj_file = obj_file.replace(".mm", OBJ_EXT)
        assert obj_file.endswith(OBJ_EXT)
        if os.path.exists(obj_file):
            # Recompile source file if its time is newer than obj file,
            # Also check its header file time. Also check times of any
            # possible includes: cefpython_fixed.h, src/common/ files.
            obj_time = os.path.getmtime(obj_file)
            source_time = os.path.getmtime(source_file)
            header_time = os.path.getmtime(header_file) if header_file else 0
            cefpython_h_fixed_time = os.path.getmtime(
                    CEFPYTHON_API_HFILE_FIXED)
            common_files_time = get_directory_mtime(os.path.join(SRC_DIR,
                                                                 "common"))
            changed = ((source_time > obj_time)
                       or (header_time > obj_time)
                       or (cefpython_h_fixed_time > obj_time)
                       or (common_files_time > obj_time))
        else:
            changed = True
        if changed:
            any_changed = True
        else:
            objects.append(obj_file)
    if any_changed:
        # If any has changed must recompile all given sources (for a library
        # or executable). This is because we don't know which sources include
        # which header files so must recompile everything.
        objects = list()
        # Compile each source file separately so that when compiling
        # source files from different directories, object files are
        # all put in the same output_directory. Otherwise distutils
        # will create lots of subdirs in output_directory.
        macros = macros_as_tuples(macros)
        common_dir = os.path.join(SRC_DIR, "common")
        original_dir = os.getcwd()
        for source_file in sources:
            source_dir = os.path.dirname(source_file)
            os.chdir(source_dir)
            source_basename = os.path.basename(source_file)
            oneobj = compiler.compile([source_basename],
                                      output_dir=output_dir,
                                      macros=macros,
                                      # TODO include dirs for Linux/Mac
                                      include_dirs=[SRC_DIR,
                                                    common_dir,
                                                    get_python_include_path()],
                                      # TODO compiler flags for Linux/Mac
                                      extra_preargs=None,
                                      extra_postargs=extra_args)
            assert len(oneobj) == 1
            objects.append(os.path.join(source_dir, oneobj[0]))
        os.chdir(original_dir)
    assert len(objects)
    return any_changed, objects


def macros_as_tuples(macros):
    """Return all macros as tuples. Required by distutils.ccompiler."""
    ret_macros = list()
    for macro in macros:
        if isinstance(macro, str):
            ret_macros.append((macro, ""))
        else:
            assert isinstance(macro, tuple)
            ret_macros.append(macro)
    return ret_macros


def get_directory_mtime(directory):
    # For example check src/common/ directory for newest modification time
    assert os.path.isdir(directory)
    files = glob.glob(os.path.join(directory, "*"))
    ret_mtime = 0
    for header_file in files:
        mtime = os.path.getmtime(header_file)
        if mtime > ret_mtime:
            ret_mtime = mtime
    assert ret_mtime
    return ret_mtime


if __name__ == "__main__":
    main()
