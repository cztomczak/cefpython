#!/usr/bin/env python3
# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Build cefpython3.

Dev workflow (no wheel; `import cefpython3` works from the repo):
    python tools/build.py
    python tools/build.py --unittests

Wheel workflow (what CI runs; add --version for a release):
    python tools/build.py --wheel
    python tools/build.py --wheel --version 147.1
"""
import argparse
import os
import site
import shutil
import subprocess
import sys

import cef_version

PYVERSION = "{0}{1}".format(*sys.version_info[:2])
BUILD_DIR = os.path.join("build", "_cmake_build_py" + PYVERSION)
PKG_DIR = "cefpython3"
CEF_RUNTIME_STAMP = os.path.join("build", "cef_runtime_installed.txt")

WINDOWS = sys.platform == "win32"
LINUX = sys.platform.startswith("linux")
MAC = sys.platform == "darwin"

MAC_HELPER_APP_NAMES = [
    "cefpython Helper.app",
    "cefpython Helper (Alerts).app",
    "cefpython Helper (GPU).app",
    "cefpython Helper (Plugin).app",
    "cefpython Helper (Renderer).app",
]


def run(cmd, **kwargs):
    print("[build.py]", " ".join(str(a) for a in cmd))
    ret = subprocess.run(cmd, **kwargs)
    if ret.returncode != 0:
        sys.exit(ret.returncode)


def cmake_build(clean=False, profiling=False, line_tracing=False):
    if clean and os.path.exists(BUILD_DIR):
        print("[build.py] Removing", BUILD_DIR)
        shutil.rmtree(BUILD_DIR)
    cache = os.path.join(BUILD_DIR, "CMakeCache.txt")
    if not os.path.exists(cache):
        cmake_args = ["cmake", "-S", ".", "-B", BUILD_DIR,
                      "-DPython_EXECUTABLE=" + sys.executable]
        if WINDOWS:
            cmake_args += ["-A", "x64"]
        else:
            cmake_args += ["-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release"]
        if profiling:
            cmake_args.append("-DENABLE_PROFILING=ON")
        if line_tracing:
            cmake_args.append("-DENABLE_LINE_TRACING=ON")
        run(cmake_args)

    build_args = ["cmake", "--build", BUILD_DIR, "--parallel"]
    if WINDOWS:
        build_args += ["--config", "Release"]
    run(build_args)


def install_into_package():
    """Install into cefpython3/ using the install() rules in CMakeLists.txt.
    The CEF runtime is installed only once per CEF version."""
    install_args = ["cmake", "--install", BUILD_DIR, "--prefix", "."]
    if WINDOWS:
        install_args += ["--config", "Release"]
    run(install_args + ["--component", "cefpython"])

    cef_ver = cef_version.read()["CEF_VERSION"]
    if WINDOWS:
        sentinel = os.path.join(PKG_DIR, "libcef.dll")
    elif MAC:
        sentinel = os.path.join(PKG_DIR, "Chromium Embedded Framework.framework")
    else:
        sentinel = os.path.join(PKG_DIR, "libcef.so")
    installed_ver = None
    if os.path.exists(CEF_RUNTIME_STAMP):
        with open(CEF_RUNTIME_STAMP) as f:
            installed_ver = f.read().strip()
    if os.path.exists(sentinel) and installed_ver == cef_ver:
        return
    run(install_args + ["--component", "cef_runtime"])
    with open(CEF_RUNTIME_STAMP, "w") as f:
        f.write(cef_ver + "\n")


def write_version_file(version):
    path = os.path.join(PKG_DIR, "_version.py")
    content = '__version__ = "{0}"\n'.format(version)
    if os.path.exists(path):
        with open(path) as f:
            if f.read() == content:
                return
    with open(path, "w") as f:
        f.write(content)
    print("[build.py] Version {0} -> {1}".format(version, path))


def _codesign_macos(pkg_dir):
    # automate.py changes the framework install name, invalidating its upstream
    # signature. Sign staged code inside-out and verify every final bundle.
    framework = os.path.join(
        pkg_dir, "Chromium Embedded Framework.framework")
    if not os.path.isdir(framework):
        print("[build.py] ERROR: CEF framework is missing:", framework)
        sys.exit(1)
    _codesign_if_invalid(framework, deep=True)

    module = os.path.join(pkg_dir, "cefpython_py{0}.so".format(PYVERSION))
    if not os.path.isfile(module):
        print("[build.py] ERROR: extension module is missing:", module)
        sys.exit(1)
    _codesign_if_invalid(module)

    for name in MAC_HELPER_APP_NAMES:
        app = os.path.join(pkg_dir, name)
        executable = os.path.join(
            app, "Contents", "MacOS", os.path.splitext(name)[0])
        if not os.path.isfile(executable):
            print("[build.py] ERROR: helper executable is missing:", executable)
            sys.exit(1)
        os.chmod(executable, 0o755)
        _codesign_if_invalid(app, deep=True)


def _codesign_if_invalid(target, deep=False):
    deep_flag = ["--deep"] if deep else []
    verify_cmd = ["codesign", "--verify"] + deep_flag + ["--strict", target]
    if subprocess.run(verify_cmd, capture_output=True).returncode == 0:
        return
    print("[build.py] codesign:", os.path.basename(target))
    run(["codesign", "--force"] + deep_flag + ["--sign", "-", target])
    run(verify_cmd[:-1] + ["--verbose=2", target])


def write_dev_pth():
    # Put the repo root on sys.path so `import cefpython3` works in any script
    # without setting PYTHONPATH.
    pth = _dev_pth_path()
    repo_root = os.getcwd()
    if not os.path.exists(pth) or open(pth).read().strip() != repo_root:
        with open(pth, "w") as f:
            f.write(repo_root + "\n")
        print("[build.py] Dev install: wrote", pth)


def remove_dev_pth():
    pth = _dev_pth_path()
    if os.path.exists(pth):
        os.remove(pth)
        print("[build.py] Removed dev install", pth)


def _dev_pth_path():
    return os.path.join(site.getsitepackages()[0], "cefpython3-dev.pth")


def wheel_build():
    # Package the already staged (and, on macOS, signed) tree. Calling
    # ``pip wheel .`` here would rebuild in an isolated CMake tree and bypass
    # _codesign_macos(), producing helpers and a modified CEF framework with
    # invalid or missing signatures.
    run([sys.executable, "tools/build_distrib.py",
         "--out-dir", os.path.join("build", "dist")])


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        "--clean", action="store_true",
        help="delete the CMake build directory before building (full rebuild)")
    parser.add_argument(
        "--unittests", action="store_true",
        help="run the unit tests after building")
    parser.add_argument(
        "--wheel", action="store_true",
        help="also build a wheel in build/dist/ (it is not installed)")
    parser.add_argument(
        "--version",
        help="release version, e.g. 147.0, 147.1 or 147.0.1"
             " (default: a development version derived from git)")
    parser.add_argument(
        "--enable-profiling", action="store_true",
        help="Cython: enable cProfile instrumentation (profile=True)")
    parser.add_argument(
        "--enable-line-tracing", action="store_true",
        help="Cython: enable line-level tracing/coverage (linetrace=True)")
    args = parser.parse_args()

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(repo_root)

    try:
        version = cef_version.package_version(args.version)
    except ValueError as exc:
        parser.error(str(exc))

    cmake_build(clean=args.clean, profiling=args.enable_profiling,
                line_tracing=args.enable_line_tracing)
    install_into_package()
    write_version_file(version)
    if MAC:
        _codesign_macos(PKG_DIR)

    if args.wheel:
        remove_dev_pth()
        wheel_build()
    else:
        write_dev_pth()

    if args.unittests:
        env = os.environ.copy()
        env["PYTHONPATH"] = os.getcwd()
        run([sys.executable, "unittests/_test_runner.py"], env=env)


if __name__ == "__main__":
    main()
