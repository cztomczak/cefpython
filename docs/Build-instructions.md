# Build instructions

Table of contents:

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
* [Versions](#versions)
* [Making a release](#making-a-release)


## Requirements

### Windows

* Visual Studio 2022 or later with the "Desktop development with C++"
  workload. See https://wiki.python.org/moin/WindowsCompilers for which
  VS version is required by your Python version.
* CMake and Ninja are installed into the active Python environment in
  step 1 below; no separate system installation is required.

### Linux

* Install the packages in the "Install system dependencies" step of
  [ci-linux.yml](../.github/workflows/ci-linux.yml) to compile cefpython.
* To run cefpython on a minimal system or under Xvfb, also install the packages
  in that workflow's "Install runtime dependencies" step. The workflow is the
  authoritative, tested package list so it does not drift from this guide.

### macOS

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

This builds the extension module and installs it, with the CEF runtime, into
`cefpython3/`, so that `import cefpython3` works directly from the repo. No
wheel is created.

Useful flags (see `python tools/build.py --help` for the full list):

* `--clean` - delete the CMake build directory first (full rebuild).
* `--unittests` - run the unit test suite after building.
* `--wheel` - additionally build a wheel
  (see [Build a wheel package](#5-build-a-wheel-package)).
* `--version VERSION` - set a release version (see [Versions](#versions)).
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

This creates a wheel in `build/dist/`. To test it the way CI does:

```
pip install build/dist/cefpython3-<version>-<tags>.whl
python unittests/_test_runner.py
python tools/smoke_test.py
```

Afterwards, run `pip uninstall cefpython3` and `python tools/build.py` to
switch back to the dev tree.


## Versions

`tools/build.py` writes the version to `cefpython3/_version.py` on every run.
The extension module and the wheel use that same version, so
`cefpython3.__version__` and `cef.GetVersion()["version"]` always match the
wheel's version.

By default it is a development version, e.g. `147.0.dev5231+g98cd08e`:

* `147` is the Chromium major version from `src/version/cef_version_*.h`.
* `.0` is fixed, so a dev version sorts before every 147.x release
  (`147.0.dev5231` < `147.0` < `147.1`).
* `dev5231` is the number of commits in the checked-out history.
* `+g98cd08e` is the short hash of the current commit.

Without git history (e.g. a source ZIP download) the version is `147.0.dev0`.
A shallow clone gives a wrong commit count, so CI checks out the full history.

For a release, set the version explicitly:

```
python tools/build.py --wheel --version 147.1
```

`--version` takes any PEP 440 version, e.g. `147.1`, `147.0.1` or `147.1b1`.


## Making a release

Run the "CI Linux", "CI Windows" and "CI macOS ARM" workflows from the Actions
tab ("Run workflow") with the `version` input set, e.g. `147.1`, then download
the wheel artifacts.
