# Copyright (c) 2017 The CEF Python authors. All rights reserved.
# Licensed under the BSD 3-clause license.

"""
build_module.py is for internal use only - called by build.py.
This is Cython's setup for building the cefpython module
"""

# Use setuptools so that "Visual C++ compiler for Python 2.7" tools
# can be used. Otherwise "Unable to find vcvarsall.bat" error occurs.
try:
    from setuptools import setup
    from setuptools import Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension

# Use "Extension" from Cython.Distutils so that "cython_directives" works
from Cython.Distutils import build_ext, Extension
from Cython.Compiler import Options
from common import *
import sys
import platform
import Cython
import os

# Cython options. Stop on first error, otherwise hundreds
# of errors appear in the console.
Options.fast_fail = True


def get_winsdk_lib():
    print("[build_module.py] Detect Windows SDK library directory")
    ret = ""
    if WINDOWS:
        if ARCH32:
            winsdk_libs = [
                r"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.1\\Lib",
                r"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0\\Lib",
            ]
        elif ARCH64:
            winsdk_libs = [
                r"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.1\\Lib\\x64",
                r"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0\\Lib\\x64",
            ]
        else:
            raise Exception("Unknown architecture")
        for lib in winsdk_libs:
            if os.path.exists(lib):
                ret = lib
                break
        if not ret:
            ret = winsdk_libs[0]
        if not os.path.exists(ret):
            raise Exception("Windows SDK Lib directory not found: %s"
                            % ret)
    return ret


def set_compiler_options(options):
    """Extends options and also sets environment variables."""
    print("[build_module.py] Set compiler options")

    extra_compile_args = list()
    extra_link_args = list()

    if WINDOWS:
        # /EHsc - using STL string, multimap and others that use
        #         C++ exceptions.
        #
        # /ignore:4217 - disable warnings such as this:
        #
        #   client_handler_py27_32bit.lib(client_handler.obj): warning LNK4217:
        #   locally defined symbol _RemovePythonCallbacksForFrame imported in
        #   function "public: virtual bool __thiscall
        #   ClientHandler::OnProcessMessageReceived
        #
        # The above warning LNK4217 is caused by the warning below which occurs
        # when building the client_handler.lib static library:
        #
        #   cefpython.h(36): warning C4190: 'RequestHandler_GetResourceHandler'
        #   has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is
        #   incompatible with C
        #
        # The C4190 warning is disabled with pragma in cefpython.h, see the
        # fix_cefpython_h() in the build.py script.
        extra_compile_args.extend(['/EHsc'])
        extra_link_args.extend(['/ignore:4217'])

    if LINUX:
        if len(sys.argv) > 1 and "--fast" in sys.argv:
            sys.argv.remove("--fast")
            # Fast mode disables optimization flags
            print("[build_module.py] FAST mode On")
            extra_compile_args.extend(['-flto', '-std=gnu++11'])
            extra_link_args.extend(['-flto'])
        else:
            # Fix "ImportError ... undefined symbol ..." caused by CEF's
            # include/base/ headers by adding the -flto flag (Issue #230).
            # Unfortunately -flto prolongs compilation time significantly.
            # More on the other flags: https://stackoverflow.com/questions/
            # 6687630/ .
            extra_compile_args.extend(['-flto', '-fdata-sections',
                                      '-ffunction-sections', '-std=gnu++11'])
            extra_link_args.extend(['-flto', '-Wl,--gc-sections'])

    if MAC:
        os.environ["CC"] = "gcc"
        os.environ["CXX"] = "g++"

    options["extra_compile_args"] = extra_compile_args
    options["extra_link_args"] = extra_link_args


def get_include_dirs():
    print("[build_module.py] Prepare include directories")
    include_dirs = list()
    common_include_dirs = [
        SRC_DIR,
        os.path.join(SRC_DIR, "common"),
        os.path.join(SRC_DIR, "extern"),
        os.path.join(SRC_DIR, "extern", "cef")
    ]
    if WINDOWS:
        include_dirs.extend([WINDOWS_DIR])
        include_dirs.extend(common_include_dirs)
    elif MAC:
        include_dirs.extend([MAC_DIR])
        include_dirs.extend(common_include_dirs)
        # TODO: Check these directories, are these really required on Mac?
        include_dirs.extend([
            '/usr/include/gtk-2.0',
            '/usr/include/glib-2.0',
            '/usr/include/gtk-unix-print-2.0',
            '/usr/include/cairo',
            '/usr/include/pango-1.0',
            '/usr/include/gdk-pixbuf-2.0',
            '/usr/include/atk-1.0',
            # Fedora
            '/usr/lib64/gtk-2.0/include',
            '/usr/lib64/gtk-unix-print-2.0',
            '/usr/lib64/glib-2.0/include',
            '/usr/lib/gtk-2.0/include',
            '/usr/lib/gtk-2.0/gtk-unix-print-2.0',
            '/usr/lib/glib-2.0/include',
        ])
    elif LINUX:
        include_dirs.extend([LINUX_DIR])
        include_dirs.extend(common_include_dirs)
        include_dirs.extend([
            '/usr/include/gtk-2.0',
            '/usr/include/glib-2.0',
            '/usr/include/gtk-unix-print-2.0',
            '/usr/include/cairo',
            '/usr/include/pango-1.0',
            '/usr/include/gdk-pixbuf-2.0',
            '/usr/include/atk-1.0',
            # Ubuntu
            '/usr/lib/x86_64-linux-gnu/gtk-2.0/include',
            '/usr/lib/x86_64-linux-gnu/gtk-unix-print-2.0',
            '/usr/lib/x86_64-linux-gnu/glib-2.0/include',
            '/usr/lib/i386-linux-gnu/gtk-2.0/include',
            '/usr/lib/i386-linux-gnu/gtk-unix-print-2.0',
            '/usr/lib/i386-linux-gnu/glib-2.0/include',
            # Fedora
            '/usr/lib64/gtk-2.0/include',
            '/usr/lib64/gtk-unix-print-2.0',
            '/usr/lib64/glib-2.0/include',
            '/usr/lib/gtk-2.0/include',
            '/usr/lib/gtk-2.0/gtk-unix-print-2.0',
            '/usr/lib/glib-2.0/include',
        ])
    return include_dirs


def get_library_dirs():
    print("[build_module.py] Prepare library directories")
    library_dirs = [
        os.path.join(CEF_BINARIES_LIBRARIES, "lib"),
    ]
    if WINDOWS:
        library_dirs.extend([
            get_winsdk_lib(),
            os.path.join(SRC_DIR, "client_handler",
                         "Release_py{pyver}_{os}"
                         .format(pyver=PYVERSION, os=OS_POSTFIX2)),
            os.path.join(SRC_DIR, "subprocess",
                         "Release_{os}"
                         .format(os=OS_POSTFIX2)),
            os.path.join(SRC_DIR, "subprocess",
                         "Release_py{pyver}_{os}"
                         .format(pyver=PYVERSION, os=OS_POSTFIX2)),
            os.path.join(SRC_DIR, "cpp_utils",
                         "Release_{os}"
                         .format(os=OS_POSTFIX2))
        ])
    if MAC or LINUX:
        library_dirs.extend([
            os.path.join(SRC_DIR, "client_handler"),
            os.path.join(SRC_DIR, "subprocess"),  # libcefpythonapp
            os.path.join(SRC_DIR, "cpp_utils"),
        ])
    return library_dirs


def get_libraries():
    print("[build_module.py] Prepare libraries")
    libraries = list()
    if WINDOWS:
        libraries.extend([
            "libcef",
            "libcef_dll_wrapper_md",
            "User32",
            "client_handler_py{pyver}_{os}".format(
                    pyver=PYVERSION, os=OS_POSTFIX2),
            "libcefpythonapp_py{pyver}_{os}".format(
                    pyver=PYVERSION, os=OS_POSTFIX2),
            "cpp_utils_{os}".format(
                    os=OS_POSTFIX2),
        ])
    elif MAC:
        libraries.extend([
            'client_handler',
            'cef_dll_wrapper',
            'cefpythonapp',
            'cpp_utils'
        ])
    elif LINUX:
        libraries.extend([
            "X11",
            "gobject-2.0",
            "glib-2.0",
            "gtk-x11-2.0",
            # CEF and CEF Python libraries
            "cef_dll_wrapper",
            "cefpythonapp",
            "client_handler",
            "cpp_utils",
        ])
    return libraries


def get_ext_modules(options):
    ext_modules = [Extension(
        "cefpython_py%s" % PYVERSION,
        ["cefpython.pyx"],

        # Ignore the warning in the console:
        # > C:\Python27\lib\distutils\extension.py:133: UserWarning:
        # > Unknown Extension options: 'cython_directives' warnings.warn(msg)
        cython_directives={
            # Any conversion to unicode must be explicit using .decode().
            "c_string_type": "bytes",
            "c_string_encoding": "utf-8",
        },

        language='c++',

        include_dirs=options["include_dirs"],
        library_dirs=options["library_dirs"],

        # Static libraries only. Order is important, if library A depends on B,
        # then B must be included before A.
        libraries=options["libraries"],

        # When you put "./" in here, loading of libcef.so will only work when
        # running scripts from the same directory that libcef.so resides in.
        # runtime_library_dirs=[
        #    './'
        # ],

        extra_compile_args=options["extra_compile_args"],
        extra_link_args=options["extra_link_args"],

        # Defining macros:
        # define_macros = [("UNICODE","1"), ("_UNICODE","1"), ]
    )]
    return ext_modules


def compile_time_constants():
    print("[build_module.py] Generate compile_time_constants.pxi")
    with open(os.path.join(SRC_DIR, "compile_time_constants.pxi"), "w") as fd:
        fd.write('# This file was generated by setup.py\n')
        # A way around Python 3.2 bug: UNAME_SYSNAME is not set
        fd.write('DEF UNAME_SYSNAME = "%s"\n' % platform.uname()[0])
        fd.write('DEF PY_MAJOR_VERSION = %s\n' % sys.version_info.major)


def main():
    if len(sys.argv) <= 1:
        print(__doc__)
        sys.exit(1)
    print("[build_module.py] Cython version: %s" % Cython.__version__)
    compile_time_constants()
    options = dict()
    set_compiler_options(options)
    options["include_dirs"] = get_include_dirs()
    options["library_dirs"] = get_library_dirs()
    options["libraries"] = get_libraries()
    print("[build_module.py] Execute setup()")
    setup(
        name='cefpython_py%s' % PYVERSION,
        cmdclass={'build_ext': build_ext},
        ext_modules=get_ext_modules(options)
    )


if __name__ == "__main__":
    main()
