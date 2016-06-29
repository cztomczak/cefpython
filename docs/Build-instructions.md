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
* [Build CEF Python 51 BETA](#build-cef-python-51-beta)
* [Requirements](#requirements)
* [Build CEF Python using prebuilt CEF binaries](#build-cef-python-using-prebuilt-cef-binaries)
* [Build both CEF Python and CEF from sources](#build-both-cef-python-and-cef-from-sources)
* [Build CEF manually](#build-cef-manually)
* [CEF automated builds](#cef-automated-builds)
* [How to patch](#how-to-patch)


## Build CEF Python 51 BETA

Complete steps for building CEF Python 51 using prebuilt
binaries from Spotify Automated Builds.

1) Tested and works fine on Ubuntu 14.04 64-bit (cmake 2.8.12 and g++ 4.8.4)

2) Download [ninja](http://martine.github.io/ninja/) 1.7.1 or later
   and copy it to /usr/bin and chmod 755.

3) Install packages: `sudo apt-get install python-dev cmake g++`

4) Download 64-bit Linux binaries and libraries from
   [GH releases](https://github.com/cztomczak/cefpython/releases)
   tagged 'v51-upstream'.


5) Copy "bin/*" to "cefpython/src/linux/binaries_64bit/"

6) Copy "lib/*" to "cefpython/src/linux/setup/lib_64bit/" (create dir)

7) Build cefpython:
```
cd cefpython/src/linux/
python compile.py 51.0
```

8) As of writing only "pygtk_.py" and "kivy_.py" examples are working


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
* If building CEF from sources:
    * Official binaries are built on Ubuntu 14.04 (cmake 2.8.12, g++ 4.8.4)
    * Download [ninja](http://martine.github.io/ninja/) 1.7.1 or later
      and copy it to /usr/bin and chmod 755.
    * Install required packages using one of the three methods below:
        1. Type command: `sudo apt-get install bison build-essential cdbs curl devscripts dpkg-dev elfutils fakeroot flex g++ git-core git-svn gperf libapache2-mod-php5 libasound2-dev libav-tools libbrlapi-dev libbz2-dev libcairo2-dev libcap-dev libcups2-dev libcurl4-gnutls-dev libdrm-dev libelf-dev libexif-dev libffi-dev libgconf2-dev libgl1-mesa-dev libglib2.0-dev libglu1-mesa-dev libgnome-keyring-dev libgtk2.0-dev libkrb5-dev libnspr4-dev libnss3-dev libpam0g-dev libpci-dev libpulse-dev libsctp-dev libspeechd-dev libsqlite3-dev libssl-dev libudev-dev libwww-perl libxslt1-dev libxss-dev libxt-dev libxtst-dev mesa-common-dev openbox patch perl php5-cgi pkg-config python python-cherrypy3 python-crypto python-dev python-psutil python-numpy python-opencv python-openssl python-yaml rpm ruby subversion ttf-dejavu-core ttf-indic-fonts ttf-kochi-gothic ttf-kochi-mincho fonts-thai-tlwg wdiff zip`
        2. See the list of packages on the
           [cef/AutomatedBuildSetup.md](https://bitbucket.org/chromiumembedded/cef/wiki/AutomatedBuildSetup.md#markdown-header-linux-configuration)
            wiki page.
        2. Run the install-build-deps.sh script -
           instructions provided further down on this page.
    * To build on Debian 7 see
      [cef/BuildingOnDebian7.md](https://bitbucket.org/chromiumembedded/cef/wiki/BuildingOnDebian7.md) and
      [cef/#1575](https://bitbucket.org/chromiumembedded/cef/issues/1575),
      and [cef/#1697](https://bitbucket.org/chromiumembedded/cef/issues/1697)
    * To perform a 32-bit Linux build on a 64-bit Linux system see
      Linux configuration in upstream cef/AutomatedBuildSetup.md. See also
      [cef/#1804](https://bitbucket.org/chromiumembedded/cef/issues/1804).
* If using prebuilt binaries from Spotify automated builds and want to
  build cefclient/cefsimple you need to install these packages:
  `sudo apt-get install libgtk2.0-dev libgtkglext1-dev`


__All platforms__

* Install dependencies for the automate.py tool by executing:
  `cd tools/ && pip install -r requirements.txt`. This will install
  some PyPI packages including Cython. On Windows installing Cython
  requires a VS compiler - see instructions above for Windows.


## Build CEF Python using prebuilt CEF binaries

__NOT WORKING YET__

Prebuilt binaries are available on
[GitHub Releases](https://github.com/cztomczak/cefpython/releases)
and tagged eg. 'v51-upstream'.

Run the automate.py tool using the --prebuilt-cef flag that will download
prebuilt binaries from GitHub Releases using version information from
the "src/version/" directory.

```
cd tools/
python automate.py --prebuilt-cef
```

You should be fine by running automate.py with the default options, but if you
need to customize the build then use the --help flag to see more.


## Build both CEF Python and CEF from sources

Run the automate.py tool using the --build-cef flag. You can optionally
set how many parallel ninja jobs to run (by default cores/2) with
the --ninja-jobs flag.

The automate script will use version information from the "src/version/"
directory. If you would like to use a custom CEF branch then you can
use the --cef-branch flag - but note that this is only for advanced
users as this will require updating cefpython's C++/Cython code.

If building on Linux and there are errors, see the MISSING PACKAGES
note futher down.

You should be fine by running automate.py with the default options, but if you
need to customize the build then use the --help flag to see more.

```
cd ~/cefpython/
mkdir build/ && cd build
python ../tools/automate.py --build-cef --ninja-jobs 6
cd cef*_*_linux64/
cp bin/* ../../../src/linux/binaries_64bit/
mkdir ../../../src/linux/setup/lib_64bit/
cp lib/* ../../../src/linux/setup/lib_64bit/
cd ../../../src/linux/
python compile.py 51.0
```

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
sudo ./install-build-deps.sh --no-lib32 --no-arm --no-chromeos-fonts --no-nacl
```

After dependencies are satisifed re-run automate.py.


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
  * This is the new build system
  * Since June 2016 all builds are without tcmalloc, see
    [cefpython/#73](https://github.com/cztomczak/cefpython/issues/73)
    and [cef/#1827](https://bitbucket.org/chromiumembedded/cef/issues/1827)
* Adobe - https://cefbuilds.com/
  * This is the old build system. Not tested whether it builds without
    tcmalloc.

To build the "libcef_dll_wrapper" library type these commands:
```
cd cef_binary/
mkdir build
cd build/
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
ninja libcef_dll_wrapper
```

To build CEF sample applications type `ninja cefclient cefsimple`.

Official CEF Python binaries come with additional patches to CEF/Chromium,
see the [patches/](../../../tree/master/patches) directory. Whether you
need these patches depends on your use case, they may not be required
and thus you could use the Spotify binaries. Spotify builds have the
issue73 patch (no tcmalloc) applied.


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
