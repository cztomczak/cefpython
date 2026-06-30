#!/usr/bin/env python3
# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Build cefpython3.

Usage:
    build.py [--clean] [--wheel] [--unittests]
             [--enable-profiling] [--enable-line-tracing]

Options:
    --clean                Delete the CMake build directory before building (full rebuild).
    --wheel                Build installable wheel (used by CI and release).
                           Default: build directly with CMake for fast dev iteration.
    --unittests            Run unit tests after building.
    --enable-profiling     Cython: enable cProfile instrumentation (profile=True).
    --enable-line-tracing  Cython: enable line-level tracing/coverage (linetrace=True).

Dev workflow (fast, shows compiler output):
    python tools/build.py
    python tools/build.py --clean
    python tools/build.py --unittests

CI / release workflow (builds a .whl):
    python tools/build.py --wheel
    python tools/build.py --wheel --unittests
"""
import glob
import os
import site
import shutil
import subprocess
import sys

BUILD_DIR = os.path.join("build", "_cmake_build")
PKG_DIR = "cefpython3"

WINDOWS = sys.platform == "win32"
LINUX = sys.platform.startswith("linux")
MAC = sys.platform == "darwin"


def run(cmd, **kwargs):
    print("[build.py]", " ".join(str(a) for a in cmd))
    ret = subprocess.run(cmd, **kwargs)
    if ret.returncode != 0:
        sys.exit(ret.returncode)


def _read_cef_version():
    """Full CEF version string from the per-platform version header,
    e.g. "147.0.10+gd58e84d+chromium-147.0.7727.118"."""
    if WINDOWS:
        header = os.path.join("src", "version", "cef_version_win.h")
    elif MAC:
        header = os.path.join("src", "version", "cef_version_macarm64.h")
    else:
        header = os.path.join("src", "version", "cef_version_linux.h")
    with open(header) as f:
        for line in f:
            if line.startswith("#define CEF_VERSION "):
                return line.split('"')[1]
    raise RuntimeError("CEF_VERSION not found in " + header)


def cmake_dev_build(clean=False, profiling=False, line_tracing=False):
    if clean and os.path.exists(BUILD_DIR):
        print("[build.py] Removing", BUILD_DIR)
        shutil.rmtree(BUILD_DIR)
    cache = os.path.join(BUILD_DIR, "CMakeCache.txt")
    if not os.path.exists(cache):
        cmake_args = ["cmake", "-S", ".", "-B", BUILD_DIR]
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

    # Copy extension module to cefpython3/
    os.makedirs(PKG_DIR, exist_ok=True)
    if WINDOWS:
        pattern = os.path.join(BUILD_DIR, "Release", "cefpython_py*.pyd")
    else:
        pattern = os.path.join(BUILD_DIR, "cefpython_py*.so")
    modules = glob.glob(pattern)
    if not modules:
        print("[build.py] ERROR: no extension module found after build")
        sys.exit(1)
    for mod in modules:
        dst = os.path.join(PKG_DIR, os.path.basename(mod))
        shutil.copy2(mod, dst)
        print("[build.py] ->", dst)

    # Copy subprocess executable to cefpython3/
    if WINDOWS:
        exe = os.path.join(BUILD_DIR, "subprocess_build", "Release", "subprocess.exe")
    else:
        exe = os.path.join(BUILD_DIR, "subprocess_build", "subprocess")
    if os.path.exists(exe):
        dst = os.path.join(PKG_DIR, os.path.basename(exe))
        shutil.copy2(exe, dst)
        print("[build.py] ->", dst)

    # One-time: copy CEF runtime files (DLLs/SOs, .pak, locales/) into cefpython3/
    if WINDOWS:
        already_copied = bool(glob.glob(os.path.join(PKG_DIR, "*.dll")))
        cef_glob = os.path.join("build", "cef*_win64")
    elif MAC:
        already_copied = os.path.isdir(
            os.path.join(PKG_DIR, "Chromium Embedded Framework.framework"))
        cef_glob = os.path.join("build", "cef*_mac*")
    else:
        already_copied = os.path.exists(os.path.join(PKG_DIR, "libcef.so"))
        cef_glob = os.path.join("build", "cef[0-9]*_linux64")
    if not already_copied:
        # Select the dir matching the exact CEF version from src/version/ so a
        # leftover dir for a different CEF version in build/ is never picked up.
        cef_version = _read_cef_version()
        cef_dirs = [d for d in sorted(glob.glob(cef_glob))
                    if cef_version in os.path.basename(d)]
        if cef_dirs:
            cef_bin = os.path.join(cef_dirs[-1], "bin")
            print("[build.py] One-time: copying CEF runtime files to", PKG_DIR)
            _copy_cef_runtime(cef_bin, PKG_DIR)
        else:
            print("[build.py] ERROR: no CEF %s runtime dir found matching %s"
                  % (cef_version, cef_glob))
            sys.exit(1)

    # Ad-hoc sign compiled binaries so macOS allows them to run.
    if MAC:
        _codesign_macos(PKG_DIR)

    # Write a .pth file so the repo root is on sys.path and
    # `import cefpython3` works in any script without setting PYTHONPATH.
    site_dir = site.getsitepackages()[0]
    pth = os.path.join(site_dir, "cefpython3-dev.pth")
    repo_root = os.getcwd()
    if not os.path.exists(pth) or open(pth).read().strip() != repo_root:
        with open(pth, "w") as f:
            f.write(repo_root + "\n")
        print("[build.py] Dev install: wrote", pth)


def _copy_cef_runtime(src_bin, dst_dir):
    exclude_prefixes = ("cefclient", "cefsimple", "ceftests", "chrome-sandbox")
    for name in os.listdir(src_bin):
        if any(name.startswith(p) for p in exclude_prefixes):
            continue
        src = os.path.join(src_bin, name)
        dst = os.path.join(dst_dir, name)
        if os.path.isdir(src):
            if not os.path.exists(dst):
                shutil.copytree(src, dst, symlinks=True)
        else:
            shutil.copy2(src, dst)


def _codesign_macos(pkg_dir):
    # Ad-hoc sign our compiled binaries; CEF framework already carries its own sig.
    targets = []
    exe = os.path.join(pkg_dir, "subprocess")
    if os.path.exists(exe):
        os.chmod(exe, 0o755)
        targets.append(exe)
    for so in glob.glob(os.path.join(pkg_dir, "cefpython_py*.so")):
        targets.append(so)
    for target in targets:
        print("[build.py] codesign:", os.path.basename(target))
        ret = subprocess.run(
            ["codesign", "--force", "--sign", "-", target])
        if ret.returncode != 0:
            print("[build.py] WARNING: codesign failed for", target,
                  "— continuing anyway")


def pip_wheel_build():
    dist_dir = os.path.join("build", "dist")
    os.makedirs(dist_dir, exist_ok=True)
    run([sys.executable, "-m", "pip", "wheel",
         "--no-build-isolation", "-w", dist_dir, "."])
    wheels = glob.glob(os.path.join(dist_dir, "cefpython3-*.whl"))
    if not wheels:
        print("[build.py] ERROR: no wheel found in", dist_dir)
        sys.exit(1)
    wheel = max(wheels, key=os.path.getmtime)
    run([sys.executable, "-m", "pip", "install", "--force-reinstall", wheel])


def main():
    clean = "--clean" in sys.argv
    wheel = "--wheel" in sys.argv
    unittests = "--unittests" in sys.argv
    profiling = "--enable-profiling" in sys.argv
    line_tracing = "--enable-line-tracing" in sys.argv

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(repo_root)

    if wheel:
        pip_wheel_build()
    else:
        cmake_dev_build(clean=clean, profiling=profiling, line_tracing=line_tracing)

    if unittests:
        env = os.environ.copy()
        env["PYTHONPATH"] = os.getcwd()
        run([sys.executable, "unittests/_test_runner.py"], env=env)


if __name__ == "__main__":
    main()
