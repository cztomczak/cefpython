# Build instructions

Table of contents:

* [Preface](#preface)
* [Requirements](#requirements)
  * [Windows](#windows)
  * [Linux](#linux)
  * [macOS](#macos)
* [Quick build](#quick-build)
* [Build steps in detail](#build-steps-in-detail)
  * [1. Install Python build tools](#1-install-python-build-tools)
  * [2. Get CEF binaries](#2-get-cef-binaries)
  * [3. Build cefpython](#3-build-cefpython)
  * [4. Run unit tests](#4-run-unit-tests)
  * [5. Build a wheel package](#5-build-a-wheel-package)


## Preface

These instructions are for CEF Python v147+, which uses CMake for compilation
and `tools/build_distrib.py` for wheel packaging. The workflow is driven by
the helper scripts described below. For older releases (v50-v123) see the
build instructions in that release's branch/tag - the build system was
substantially rewritten for v147 and the old instructions no longer apply.

Supported platforms, matching what CI builds and tests on every push (see
[.github/workflows/](../.github/workflows/)):

* Windows x64
* Linux x64
* macOS (Apple Silicon / arm64)

Supported Python versions: 3.10 - 3.14.

Before building you must satisfy the platform-specific [requirements](#requirements)
listed below.


## Requirements

### Windows

* Python 3.10+ (64-bit).
* Visual Studio 2022 or later with the "Desktop development with C++"
  workload. See https://wiki.python.org/moin/WindowsCompilers for which
  VS version is required by your Python version.
* CMake and Ninja are installed into the active Python environment in
  step 1 below; no separate system installation is required.

### Linux

* Python 3.10+ (64-bit). Tested on Ubuntu 24.04.
* Install the packages in the "Install system dependencies" step of
  [ci-linux.yml](../.github/workflows/ci-linux.yml) to compile cefpython.
* To run cefpython on a minimal system or under Xvfb, also install the packages
  in that workflow's "Install runtime dependencies" step. The workflow is the
  authoritative, tested package list so it does not drift from this guide.

### macOS

* Python 3.10+ (arm64/Apple Silicon) on macOS 12 or later. Tested on macOS 14.
* Xcode with command line tools installed (`xcode-select --install`).
* CMake and Ninja are installed into the active Python environment in
  step 1 below; no separate system installation is required.
* Ad-hoc code signing is done automatically by the build (via the
  system `codesign` tool) so that macOS allows the built binaries to run.


## Quick build

```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython147
python -m venv .venv
```

Activate the virtual environment:

```text
# Windows Command Prompt (including a Visual Studio Developer Command Prompt)
.venv\Scripts\activate.bat

# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Linux or macOS
. .venv/bin/activate
```

Then install the build dependencies and build:

```
python tools/requirements.py
python tools/download_cef.py
python tools/automate.py --prebuilt-cef
python tools/build.py --unittests
```

This downloads and prepares the matching CEF binaries for your platform,
builds the cefpython extension module, and runs the unit test suite.
See below for what each step does and the available options.


## Build steps in detail

### 1. Install Python build tools

Create and activate a virtual environment as shown in the
[quick build](#quick-build), or activate an existing environment, then run:

```
python tools/requirements.py
```

This helper uses the active Python interpreter to install Cython,
scikit-build-core, CMake, Ninja and the other build-time dependencies listed in
[tools/requirements.txt](../tools/requirements.txt) into the active Python
environment. No separate system installation of CMake or Ninja is required;
activating the environment places their executables on `PATH`. Re-run this
after pulling changes because the build requirements may change.

### 2. Get CEF binaries

```
python tools/download_cef.py
python tools/automate.py --prebuilt-cef
```

`tools/download_cef.py` reads the required CEF version from
`src/version/cef_version_*.h`, downloads the matching distribution from
[Spotify Automated Builds](https://cef-builds.spotifycdn.com/index.html),
verifies its checksum, and extracts it into `build/`.

`tools/automate.py --prebuilt-cef` then builds the CEF wrapper library and
prepares the `build/cef<version>_<platform>/` directory that
`tools/build.py` expects. It does not download CEF itself.

To download without preparing (e.g. to inspect the archive first), or to
download for a different platform than the one you're on, see
`python tools/download_cef.py --help`.

### 3. Build cefpython

```
python tools/build.py
```

By default this runs a fast CMake dev build: it configures (first run
only) and builds `build/_cmake_build/`, then copies the extension module,
the subprocess executable, and the CEF runtime files into `cefpython3/` so
that `import cefpython3` works directly from the repo.

Useful flags (see `python tools/build.py` docstring for the full list):

* `--clean` - delete the CMake build directory first (full rebuild).
* `--unittests` - run the unit test suite after building.
* `--wheel` - additionally build an installable wheel and install it
  (see [Build a wheel package](#5-build-a-wheel-package)).
* `--enable-profiling` / `--enable-line-tracing` - Cython cProfile /
  line-tracing instrumentation, for profiling or coverage.

### 4. Run unit tests

```
python tools/build.py --unittests
```

or, if you've already built:
```
python unittests/_test_runner.py
```

On Linux this requires a display - either a real one or Xvfb:
`xvfb-run python unittests/_test_runner.py`.

### 5. Build a wheel package

```
python tools/build.py --wheel
```

This packages the already-built (and, on macOS, already-signed) tree in
`cefpython3/` into a wheel under `build/dist/`, using
[tools/build_distrib.py](../tools/build_distrib.py), and installs it with
`python -m pip install --force-reinstall`.

CI currently executes the configure, build, staging, and packaging steps
explicitly, invoking `tools/build_distrib.py --dev` for commit-identifiable
wheels. Consolidating this workflow behind a standards-compliant Python build
backend is deferred to a follow-up task.

To smoke-test a built wheel the way CI does (install it, then launch and
auto-close a couple of the example apps):
```
python tools/smoke_test.py
```
