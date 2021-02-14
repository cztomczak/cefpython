# Build instructions

Table of contents:
* [Preface](#preface)
* [Quick build instructions for Windows](#quick-build-instructions-for-windows)
* [Quick build instructions for Linux](#quick-build-instructions-for-linux)
* [Requirements](#requirements)
  * [Windows](#windows)
  * [Linux](#linux)
  * [Mac](#mac)
  * [All platforms](#all-platforms)
* [Build using prebuilt CEF binaries and libraries](#build-using-prebuilt-cef-binaries-and-libraries)
* [Build using CEF binaries from Spotify Automated Builds](#build-using-cef-binaries-from-spotify-automated-builds)
* [Build upstream CEF from sources](#build-upstream-cef-from-sources)
  * [Building old unsupported version of Chromium](#building-old-unsupported-version-of-chromium)
  * [Possible errors](#possible-errors)
* [Build CEF manually](#build-cef-manually)
* [CEF Automated Builds (Spotify and Adobe)](#cef-automated-builds-spotify-and-adobe)
* [Notes](#notes)
* [How to patch mini tutorial](#how-to-patch-mini-tutorial)


## Preface

These instructions are for the new releases of CEF Python v50+.
For the old v31 release see the build instructions on Wiki pages.

If you would like to quickly build cefpython then see the
[Quick build instructions for Windows](#quick-build-instructions-for-windows)
and [Quick build instructions for Linux](#quick-build-instructions-for-linux)
sections. These instructions are complete meaning you don't need
to read anything more from this document. Using these quick
instructions you should be able to build cefpython in less than
10 minutes.

There are several types of builds described in this document:

1. You can build CEF Python using prebuilt CEF binaries and libraries
   that were uploaded to GH releases
2. You can build CEF Python using prebuilt CEF binaries from
   Spotify Automated Builds.
3. You can build upstream CEF from sources, but note that building CEF
   is a long process that can take hours.

Before you can build CEF Python or CEF you must satisfy
[requirements](#requirements) listed on this page.


## Quick build instructions for Windows

Complete steps for building CEF Python v50+ with Python 2.7 using
prebuilt binaries and libraries from GitHub Releases.

When cloning repository you should checkout a stable branch which
are named "cefpythonXX" where XX is Chromium version number.

1) Tested and works fine on Windows 7 64-bit

2) Download [ninja](https://github.com/ninja-build/ninja) 1.7.2 or later
   and add it to PATH.

3) Download [cmake](https://cmake.org/download/) and add
   it to PATH.

4) For Python 2.7 Install "Visual C++ Compiler for Python 2.7"
  from [here](https://www.microsoft.com/en-us/download/details.aspx?id=44266)

5) For Python 2.7 and when using using "Visual C++ compiler for Python 2.7"
   you have to install "Visual C++ 2008 Redistributable Package"
   from [here](https://www.microsoft.com/en-us/download/details.aspx?id=29)
   and [here](https://www.microsoft.com/en-us/download/details.aspx?id=15336)

6) Clone cefpython, checkout for example "cefpython57" branch
   that includes Chromium v57, then create a build/ directory and enter it:
```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython57
mkdir build/
cd build/
```

7) Install python dependencies:
```
pip install --upgrade -r ../tools/requirements.txt
```

8) Download Windows binaries and libraries from
   [GH releases](https://github.com/cztomczak/cefpython/tags)
   tagged e.g. 'v57-upstream' when building v57. The version
   of the binaries must match exactly the CEF version from
   the "cefpython/src/version/cef_version_win.h" file
   (the CEF_VERSION constant).

8) Extract the archive in the "build/" directory.

9) Build cefpython and run examples (xx.x is version number):
```
python ../tools/build.py xx.x
```


## Quick build instructions for Linux

Complete steps for building CEF Python v50+ using prebuilt
binaries and libraries from GitHub Releases.

When cloning repository you should checkout a stable branch which
are named "cefpythonXX" where XX is Chromium version number.

1) Tested and works fine on Ubuntu 14.04 64-bit

2) Download [ninja](https://github.com/ninja-build/ninja) 1.7.1 or later
   and copy it to /usr/bin and chmod 755.

3) Install required packages (tested and works with: cmake 2.8.12
   and g++ 4.8.4):
```
sudo apt-get install python-dev cmake g++ libgtk2.0-dev
```

4) Clone cefpython, checkout for example "cefpython57" branch
   that includes Chromium v57, then create build/ directory and enter it:
```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython57
mkdir build/
cd build/
```

5) Install python dependencies:
```
sudo pip install --upgrade -r ../tools/requirements.txt
```

6) Download Linux binaries and libraries from
   [GH releases](https://github.com/cztomczak/cefpython/tags)
   tagged e.g. 'v57-upstream' when building v57. The version
   of the binaries must match exactly the CEF version from
   the "cefpython/src/version/cef_version_linux.h" file
   (the CEF_VERSION constant).

7) Extract the archive in the "build/" directory.

8) Build cefpython and run examples (xx.x is version number):
```
python ../tools/build.py xx.x
```


## Requirements

Below are platform specific requirements. Do these first before
following instructions in the "All platforms" section that lists
requirements common for all platforms.

### Windows

* Download [ninja](https://github.com/ninja-build/ninja) 1.7.2 or later
  and add it to PATH.
* Download [cmake](https://cmake.org/download/) and add it to PATH.
* Install an appropriate MS compiler for a specific Python version:
  https://wiki.python.org/moin/WindowsCompilers
    * For Python 2.7 install "Microsoft Visual C++ Compiler for Python 2.7"
      from [here](https://www.microsoft.com/en-us/download/details.aspx?id=44266)
    * When using "Visual C++ compiler for Python 2.7" you have to install
      "Microsoft Visual C++ 2008 Redistributable Package" from
      [here](https://www.microsoft.com/en-us/download/details.aspx?id=29) and
      [here](https://www.microsoft.com/en-us/download/details.aspx?id=15336)
    * For Python 2.7 copy "cefpython/src/windows/py27/stdint.h" to
      "%LocalAppData%\Programs\Common\Microsoft\Visual C++ for Python\9.0\VC\include\"
      if does not exist
    * For Python 3.4 follow the instructions for installing Windows SDK 7.1.
      If you encounter issue with .NET Framework 4 then make registry edits
      as suggested here: [Windows SDK setup failure](http://stackoverflow.com/a/33260090/623622).
    * For Python 3.4, if getting error:
      `Cannot open include file 'ammintrin.h': No such file or directory`
      then Copy that `ammitrin.h` file from for example VS 2015 installation
      directory or find this file on the web. This is a Microsoft issue.
* To build CEF from sources:
    * Use Win7 x64 or later. 32-bit OS'es are not supported. For more details
     see [here](https://www.chromium.org/developers/how-tos/build-instructions-windows).
    * For CEF branch >= 2704 install VS2015 Update 2 or later. Use the
      Custom Install option, see details [here](https://chromium.googlesource.com/chromium/src/+/master/docs/windows_build_instructions.md#Open-source-contributors).
    * Install [CMake](https://cmake.org/) 2.8.12.1 or newer and add cmake.exe
        to PATH
    * Install [ninja](http://martine.github.io/ninja/) and add ninja.exe
        to PATH
    * You need about 16 GB of RAM during linking. If there is an error
        just add additional virtual memory.


### Linux

* Install packages: `sudo apt-get install cmake g++ libgtk2.0-dev libgtkglext1-dev`
* If building CEF from sources:
    * Official binaries are built on Ubuntu 14.04 (cmake 2.8.12, g++ 4.8.4) and these instructions apply to that OS
    * For Fedora build dependencies see [Issue #466](https://github.com/cztomczak/cefpython/issues/466#issuecomment-419794341)
    * Download [ninja](https://github.com/ninja-build/ninja/releases) 1.7.1 or later
      and copy it to /usr/bin and chmod 755.
    * Install/upgrade required packages using one of the four methods below
      (these packages should be upgraded each time you update to newer CEF):
        1. For 64-bit build, type this command: `sudo apt-get install bison build-essential cdbs curl devscripts dpkg-dev elfutils fakeroot flex g++ git-core git-svn gperf libapache2-mod-php5 libasound2-dev libav-tools libbrlapi-dev libbz2-dev libcairo2-dev libcap-dev libcups2-dev libcurl4-gnutls-dev libdrm-dev libelf-dev libexif-dev libffi-dev libgconf2-dev libgconf-2-4 libgl1-mesa-dev libglib2.0-dev libglu1-mesa-dev libgnome-keyring-dev libgtk2.0-dev libkrb5-dev libnspr4-dev libnss3-dev libpam0g-dev libpci-dev libpulse-dev libsctp-dev libspeechd-dev libsqlite3-dev libssl-dev libudev-dev libwww-perl libxslt1-dev libxss-dev libxt-dev libxtst-dev mesa-common-dev openbox patch perl php5-cgi pkg-config python python-cherrypy3 python-crypto python-dev python-psutil python-numpy python-opencv python-openssl python-yaml rpm ruby subversion ttf-dejavu-core ttf-indic-fonts ttf-kochi-gothic ttf-kochi-mincho fonts-thai-tlwg wdiff wget zip`
        2. For 32-bit build, type this command: `bison build-essential cdbs curl devscripts dpkg-dev elfutils fakeroot flex g++ git-core git-svn gperf libapache2-mod-php5 libasound2-dev libav-tools libbrlapi-dev libbz2-dev libcairo2-dev libcap-dev libcups2-dev libcurl4-gnutls-dev libdrm-dev libelf-dev libexif-dev libffi-dev libgconf2-dev libgl1-mesa-dev libglib2.0-dev libglu1-mesa-dev libgnome-keyring-dev libgtk2.0-dev libkrb5-dev libnspr4-dev libnss3-dev libpam0g-dev libpci-dev libpulse-dev libsctp-dev libspeechd-dev libsqlite3-dev libssl-dev libudev-dev libwww-perl libxslt1-dev libxss-dev libxt-dev libxtst-dev mesa-common-dev openbox patch perl php5-cgi pkg-config python python-cherrypy3 python-crypto python-dev python-psutil python-numpy python-opencv python-openssl python-yaml rpm ruby subversion ttf-dejavu-core ttf-indic-fonts ttf-kochi-gothic ttf-kochi-mincho fonts-thai-tlwg wdiff wget zip lib32gcc1 lib32stdc++6 libc6-i386 linux-libc-dev:i386 libasound2:i386 libcap2:i386 libelf-dev:i386 libfontconfig1:i386 libgconf-2-4:i386 libglib2.0-0:i386 libgpm2:i386 libgtk2.0-0:i386 libgtk-3-0:i386 libncurses5:i386 libnss3:i386 libpango1.0-0:i386 libssl1.0.0:i386 libtinfo-dev:i386 libxcomposite1:i386 libxcursor1:i386 libxdamage1:i386 libxi6:i386 libxrandr2:i386 libxss1:i386 libxtst6:i386`
        3. See the list of packages on the
           [cef/AutomatedBuildSetup.md](https://bitbucket.org/chromiumembedded/cef/wiki/AutomatedBuildSetup.md#markdown-header-linux-configuration)
            wiki page.
        4. Run the install-build-deps.sh script -
           instructions provided further down on this page.
    * To build on Debian 7 see
      [cef/BuildingOnDebian7.md](https://bitbucket.org/chromiumembedded/cef/wiki/BuildingOnDebian7.md) and
      [cef/#1575](https://bitbucket.org/chromiumembedded/cef/issues/1575),
      and [cef/#1697](https://bitbucket.org/chromiumembedded/cef/issues/1697)
* Building CEF 32-bit is only possible using cross-compiling on
  64-bit machine. See [Issue #328](https://github.com/cztomczak/cefpython/issues/328).
* Sometimes it is also required to install these packages (eg. chroot):
  `sudo apt-get install libnss3 libnspr4 libxss1 libgconf-2-4`


### Mac

* MacOS 10.9+, Xcode5+ and Xcode command line tools. Only 64-bit builds
  are supported.
* Download [ninja](https://github.com/ninja-build/ninja) 1.7.2 or later
  and add it to PATH.
* Download [cmake](https://cmake.org/download/) and add it to PATH.


### All platforms

* Install/update dependencies for the tools by executing:
  `cd cefpython/tools/ && pip install --upgrade -r requirements.txt`.
  On Linux use `sudo`. You should run it each time you update to newer
  cefpython version to avoid issues.


## Build using prebuilt CEF binaries and libraries

When cloning repository you should checkout a stable branch which
are named "cefpythonXX" where XX is Chromium version number.

1) Clone cefpython, checkout for example "cefpython57" branch
   that includes Chromium v57, then create a build/ directory and enter it:
```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython57
mkdir build/
cd build/
```

2) Download binaries and libraries from
   [GH releases](https://github.com/cztomczak/cefpython/tags)
   tagged eg. 'v57-upstream' when building v57. The version
   of the binaries must match exactly the CEF version from
   the "cefpython/src/version/" directory (look for CEF_VERSION
   constant in .h file).

3) Extract the downloaded archive eg. "cef55_3.2883.1553.g80bd606_win32.zip"
   in the "build/" directory (using "extract here" option)

4) Run the build.py tool (xx.x is version number):
```
python ../tools/build.py xx.x
```


## Build using CEF binaries from Spotify Automated Builds

When cloning repository you should checkout a stable branch which
are named "cefpythonXX" where XX is Chromium version number.

1) Clone cefpython, checkout for example "cefpython57" branch
   that includes Chromium v57, then create a build/ directory and enter it:
```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython57
mkdir build/
cd build/
```

2) Download CEF binaries from [Spotify Automated Builds](http://opensource.spotify.com/cefbuilds/index.html).
   The version of the binaries must match exactly the CEF version
   from the "cefpython/src/version/" directory (look for CEF_VERSION
   constant in .h file).

3) Extract the downloaded archive eg.
   "cef_binary_3.2883.1553.g80bd606_windows32.tar.bz2"
   in the build/ directory (using "extract here" option)

4) Run the automate.py tool. After it completes you should see a new
   directory eg. "cef55_3.2883.1553.g80bd606_win32/".
```
python ../tools/automate.py --prebuilt-cef
```

5) Run the build.py tool (xx.x is version number):
```
python ../tools/build.py xx.x
```


## Build upstream CEF from sources


Building CEF from sources is a very long process that can take several
hours depending on your CPU speed and the platform you're building on.
To speed up the process you can pass the --fast-build flag, however
in such case result binaries won't be optimized.
You can optionally set how many parallel ninja jobs to run (by default
cores/2) with the --ninja-jobs flag passed to automate.py.

To build CEF from sources run the automate.py tool using the --build-cef
flag. The automate script will use version information from the
"cefpython/src/version/" directory. If you would like to use
a custom CEF branch
then use the --cef-branch flag, but note that this is only for advanced
users as this will require updating cefpython's C++/Cython code.

You should be fine by running automate.py with the default options,
but if you need to customize the build then use the --help flag to
see more options.

Remember to always upgrade packages listed in Requirements section each
time you update to newer CEF.

On Linux if there are errors about missing packages or others,
then see solutions in the [Possible errors](#possible-errors) section.


The commands below will build CEF from sources with custom CEF Python
patches applied and then build the CEF Python package. "xx.x" is version
number and "ninja-jobs 4" means to run 4 parallel jobs for compiling,
increase it if you have more CPU cores and want things to build faster.

The commands below checkout for example "cefpython57" branch that
includes Chromium v57. When cloning repository you should checkout
a stable branch which are named "cefpythonXX" where XX is Chromium
version number.

```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/
git checkout cefpython57
mkdir build/
cd build/
python ../tools/automate.py --build-cef --ninja-jobs 4
python ../tools/build.py xx.x
```

The automate.py tool should create eg. "cef55_3.2883.1553.g80bd606_win32/"
directory when it's done. Then the build.py tool will build the cefpython
module, make installer package, install the package and run unit tests
and examples. See the notes for commands for creating package installer
and/or wheel package for distribution.

### Building old unsupported version of Chromium 

When building an old version of Chromium you may get into issues.
For example as of this writing the latest CEF Python version is
v57, but current support Chromium version is v64. Now when building
v57 you may encounter issues since Chromium build tools had
many updates since v57. You have to checkout depot_tools from the
revision when Chromium v57 was released. When running automate.py
tool the depot_tools repository resides in `build_dir/depot_tools/`
directory. If you didn't run automate.py then you can find repository
url in automate-git.py script. For example for v57 release to checkout
an old revision of depot_tools you can use this command:

```
git checkout master@{2017-04-20}
```

After that set `DEPOT_TOOLS_UPDATE=0` environment variable and then
run automate.py tool.

### Possible errors

__Debug_GN_arm/ configuration error (Linux)__: Even though building
on Linux for Linux, Chromium still runs ARM configuration files. If
there is an error showing that pkg-config fails with GTK 3 library
then see solution in the third post in this topic on CEF Forum:
[Debug_GN_arm error when building on Linux, *not* arm](https://magpcss.org/ceforum/viewtopic.php?f=6&t=14976).

__MISSING PACKAGES (Linux)__: After the chromium sources are downloaded,
it will try to build cef projects and if it fails due to missing packages
make sure you've installed all the required packages listed in the
Requirements section further up on this page. If it still fails, you
can fix it by running the install-build-deps.sh script (intended for
Ubuntu systems, but you could edit it). When the "ttf-mscorefonts-installer"
graphical installer pops up don't install it - deny EULA.

```
cd build/chromium/src/build/
chmod 755 install-build-deps.sh
sudo ./install-build-deps.sh --no-chromeos-fonts --no-nacl --no-arm
```

After dependencies are satisifed re-run automate.py.


## Build CEF manually

CEF Python official binaries come with custom CEF binaries with
a few patches applied for our use case, see the Notes section further
down on this page.

On Linux before running any of CEF tools apply the issue73 patch
first.

To build CEF follow the instructions on the Branches and Building
CEF wiki page:
https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding

After it is successfully built, apply patches, rebuild and remake
distribs.

Note that CEF patches must be applied in the "download_dir/chromium/src/cef/"
directory, not in the "download_dir/cef/" directory.


## CEF Automated Builds (Spotify and Adobe)

There are two sites that provide automated CEF builds:
* Spotify - http://opensource.spotify.com/cefbuilds/index.html
  * This is the new build system
  * Since June 2016 all builds are without tcmalloc, see
    [cefpython/#73](https://github.com/cztomczak/cefpython/issues/73)
    and [cef/#1827](https://bitbucket.org/chromiumembedded/cef/issues/1827)
* Adobe - https://cefbuilds.com/
  * This is the old build system. Not tested whether it builds without
    tcmalloc.


## Notes

If you would like to update CEF version in cefpython then
see complete instructions provided in
[Issue #264](https://github.com/cztomczak/cefpython/issues/264).

When building for multiple Python versions on Linux/Mac use
pyenv to manage multiple Python installations, see
[Issue #249](https://github.com/cztomczak/cefpython/issues/249)
for details.

Command for making installer package is (xx.x is version number):
```
cd cefpython/build/
python ../tools/make_installer.py xx.x
```

To create a wheel package type:
```
cd cefpython/build/
python ../tools/make_installer.py xx.xx --wheel --universal
cd cefpython3_*/dist/
ls
```

Additional flags when using --wheel flag:
* `--python-tag cp27` to generate Python 2.7 only package
* `--universal` to build package for multiple Python versions
  (in such case you must first build multiple cefpython modules
   for each Python version)

CEF Python binaries are build using similar configuration as described
on the ["Automated Build Setup"](https://bitbucket.org/chromiumembedded/cef/wiki/AutomatedBuildSetup.md#markdown-header-platform-build-configurations) wiki page in upstream CEF. The automate.py tool incorporates most of
of the flags from these configurations.

To build the "libcef_dll_wrapper" library type these commands:
```
cd cef_binary*/
mkdir build
cd build/
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
ninja libcef_dll_wrapper
```

To build CEF sample applications type:
```
ninja cefclient cefsimple ceftests
```

Official CEF Python binaries may come with additional patches applied
to CEF/Chromium depending on platform. These patches can be found
in the "cefpython/patches/" directory. Whether you need these patches
depends on your use case, they may not be required and thus you could
use the Spotify Automated Builds. Spotify builds have the issue73 patch
(no tcmalloc) applied.

Currently (February 2017) only Linux releases have the custom
patches applied. Windows and Mac releases use CEF binaries from
Spotify Automated Builds.


## How to patch mini tutorial

Create a patch from unstaged changes in current directory:
```
cd chromium/src/cef/
git diff --no-prefix --relative > issue251.patch
```

To create a patch from last two commits:
```
git diff --no-prefix --relative HEAD~2..HEAD > issue251.patch
# or
git format-patch --no-prefix -2 HEAD --stdout > issue251.patch
```

Apply a patch in current directory and ignore git index:
```
patch -p0 < issue251.patch
```

Apply a patch in current directory and do not ignore git index:
```
cd chromium/src/cef/
git apply -v -p0 issue251.patch
```
