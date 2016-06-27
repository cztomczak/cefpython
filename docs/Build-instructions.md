# Build instructions

NOTE: These instructions are for the master branch (Chrome 51).

There are several types of builds you can perform:

1. You can build CEF Python using prebuilt CEF binaries that were
   uploaded to GH releases (tagged eg. v51-upstream)
2. You can build both CEF Python and CEF from sources, but note
   that Building CEF is a long process that can take hours.
   In the tools/ directory there is the automate.py script that
   automates building CEF.
3. You may also use prebuilt binaries from Spotify automated builds,
   see the CEF automated builds section.

Before you can build CEF Python or CEF you must satisfy requirements
listed on this page.


Table of contents:
* [Requirements](#requirements)
* [Build CEF Python using prebuilt CEF binaries](#build-cef-python-using-prebuilt-cef-binaries)
* [Build both CEF Python and CEF from sources](#build-both-cef-python-and-cef-from-sources)
* [Build CEF manually](#build-cef-manually)
* [CEF automated builds](#cef-automated-builds)
* [How to patch](#how-to-patch)


## Build CEF Python 51 BETA

1. Works fine on Ubuntu 14.04 64-bit (cmake 2.8.12 and g++ 4.8.4)
2. Download 64-bit Linux standard distribution from Spotify builds:
   http://opensource.spotify.com/cefbuilds/index.html
    * As of writing the proper file is:
      "cef_binary_3.2704.1432.g60b3718_linux64.tar.bz2"
    * Check CEF version in "cefpython/src/version/cef_version_linux.h"
      to make sure you're downloading the right file
3. Download [ninja](http://martine.github.io/ninja/) 1.7.1 or later
   and copy it to /usr/bin and chmod 755.
4. Install packages: `sudo apt-get install python-dev cmake g++`
5. Create projects to build:
```
cd cef_binary/
mkdir build
cd build/
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
```
6. To build type: `ninja libcef_dll_wrapper`. You may also build cefclient
   by typing `nincja cefclient`, but this will require installing
   additional packages, read Requirements further on this page.
7. Copy "cef_binary/Resources/*" to "cefpython/src/linux/binaries_64bit/"
8. Copy "cef_binary/Release/*" to "cefpython/src/linux/binaries_64bit/"
9. Copy "cef_binary/build/libcef_dll_wrapper/*"
   to "cefpython/src/linux/setup/lib_64bit/" (create dir)
10. Temporary fix for Isue #231 - copy icudtl.dat and natives_blob.bin
    to /usr/bin (where the python executable resides)
11. Build cefpython:
```
cd cefpython/src/linux/
python compile.py 51.0
```
12. As of writing only "pygtk_.py" and "kivy_.py" examples work.


## Requirements

Below are platform specific requirements. Do these first before
following instructions in the "All platforms" section that lists
requirements common for all platforms.

__Windows__

* For Python 2.7 - VS2008 compiler is required:
  http://www.microsoft.com/en-us/download/details.aspx?id=44266
* For Python 3.4 - VS2010 compiler is required:
  https://docs.python.org/3.4/using/windows.html#compiling-python-on-windows
* For Python 3.5 - VS2015 compiler is required:
  https://docs.python.org/3.5/using/windows.html#compiling-python-on-windows
* To build CEF from sources:
    * Use Win7 x64 or later. 32-bit OS'es are not supported. For more details
     see [here](https://www.chromium.org/developers/how-tos/build-instructions-windows).
    * For CEF branch >= 2704 install VS2015 Update 2 or later
    * For CEF branch < 2704 install VS2013 Update 4 or later
    * Install [CMake](https://cmake.org/) 2.8.12.1 or newer and add cmake.exe
        to PATH
    * Install [ninja](http://martine.github.io/ninja/) and add ninja.exe
        to PATH
    * You need about 16 GB of RAM during linking. If there is an error
        just add additional virtual memory.
    * For Python 2.7 copy "cefpython/src/windows/stdint.h" to
      "%LocalAppData%\Programs\Common\Microsoft\Visual C++ for Python\9.0\VC\include\"


__Linux__

* Install packages: `sudo apt-get install python-dev cmake g++`
* To build upstream cefclient/cefsimple you need to install these packages:
  `sudo apt-get install libgtk2.0-dev libgtkglext1-dev`
* If building CEF from sources:
    * Official binaries are built on Ubuntu 14.04 (cmake 2.8.12, g++ 4.8.4)
    * Download [ninja](http://martine.github.io/ninja/) 1.7.1 or later
      and copy it to /usr/bin and chmod 755.
    * Install required packages using one of the methods below:
        1. See Linux configuration for CEF automated
      builds on the [cef/AutomatedBuildSetup.md](https://bitbucket.org/chromiumembedded/cef/wiki/AutomatedBuildSetup.md#markdown-header-linux-configuration)
      wiki page.
        2. Run the install-build-deps.sh script - instructions provided
          further down on this page.
* To build on Debian 7 see
  [cef/BuildingOnDebian7.md](https://bitbucket.org/chromiumembedded/cef/wiki/BuildingOnDebian7.md) and
  [cef/#1575](https://bitbucket.org/chromiumembedded/cef/issues/1575),
  and [cef/#1697](https://bitbucket.org/chromiumembedded/cef/issues/1697)
* To perform a 32-bit Linux build on a 64-bit Linux system see
  [cef/#1804](https://bitbucket.org/chromiumembedded/cef/issues/1804)


__All platforms__

* Install dependencies for the automate.py tool by executing:
  `cd tools/ && pip install -r requirements.txt`. This will install
  some PyPI packages including Cython. On Windows installing Cython
  requires a VS compiler - see instructions above for Windows.


## Build CEF Python using prebuilt CEF binaries

Prebuilt binaries are available on
[GitHub Releases](https://github.com/cztomczak/cefpython/releases)
and tagged eg. 'v47-upstream'.

Run the automate.py tool using the --prebuilt-cef flag that will download
prebuilt binaries from GitHub Releases using version information from
src/version/.

__NOTE__: The --prebuilt-cef flag is not implemented yet.
```
cd tools/
python automate.py --prebuilt-cef
```

You should be fine by running automate.py with the default options, but if you
need to customize the build then use the --help flag to see more.


## Build both CEF Python and CEF from sources

Run the automate.py tool using the --build-cef flag. Specify cef branch
and optionally how many parallel ninja jobs to run (by default cores/2).
If building on Linux see the Important note futher down.

```
cd tools/
python automate.py --build-cef --cef-branch 2526 --ninja-jobs 6
```

__IMPORTANT NOTE (Linux)__: On Linux it will fail on first run. After the chromium
sources are downloaded, it will try to build cef projects and fail
due to missing packages. You will need to run the install-build-deps.sh
script (intended for Ubuntu systems). When the "ttf-mscorefonts-installer"
graphical installer pops up don't install it - deny EULA.

```
cd build/chromium/src/build/
chmod 755 install-build-deps.sh
sudo ./install-build-deps.sh --no-arm --no-chromeos-fonts --no-nacl
```

After dependencies are satisifed re-run automate.py.

You should be fine by running automate.py with the default options, but if you
need to customize the build then use the --help flag to see more.


## Build CEF manually

CEF Python official binaries come with custom CEF binaries with
a few patches applied for our use case. These patches are in the
patches/ directory.

On Linux before running any of CEF tools apply the issue73 patch
first.

To build CEF follow the instructions on the Branches and Building
CEF wiki page:
https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding

After it is successfully built - apply patches, rebuild and remake
distribs.

Note that CEF patches must be applied in the "download_dir/chromium/src/cef/"
directory, not in the "download_dir/cef/" directory.


## CEF automated builds

There are two sites that provide latest builds of CEF:
* Spotify - http://opensource.spotify.com/cefbuilds/index.html
  * This is a new build system
  * Since 07/06/2016 all builds are without tcmalloc, see
    [cefpython/#73](https://github.com/cztomczak/cefpython/issues/73)
    and [cef/#1827](https://bitbucket.org/chromiumembedded/cef/issues/1827)
* Adobe - https://cefbuilds.com/
  * This is an old build system. It probably still builds with tcmalloc
    (see above)

Official CEF Python binaries come with additional patches to CEF/Chromium,
see the [patches/](../../../tree/master/patches) directory. Whether you
need these patches depends on your use case, they may not be required
and thus you could use the Spotify binaries. Spotify builds have the
issue73 patch (tcmalloc) applied.


## How to patch

Create a patch from unstaged changes in current directory:
```
cd chromium/src/cef/
git diff --no-prefix --relative > cef.gyp.patch
```

Apply a patch in current directory:
```
cd chromium/src/cef/
git apply cef.gyp.patch
```
