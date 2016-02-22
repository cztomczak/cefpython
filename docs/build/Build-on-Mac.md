# Build instructions for Mac #

The original instructions on building Chromium/CEF can be found on the CEF project [Branches and Building](https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding) wiki page.

Table of contents:


## Preliminary notes ##

  * These instructions were tested using:
    * OS X 10.9.4 Mavericks
    * Fresh install of Python 2.7.9 from python.org
    * XCode 4.6.3
    * Command Line Tools for XCode, Apr 2014
  * XCode 6 is not supported by CEF (officially)

## TODO ##

  * Fix HTTPS caching on sites with SSL certificate errors (optional)
  * Disable the tcmalloc memory allocation global hook (optional, but recommended) - [Issue 155](../issues/155)

## Prepare environment ##

You need to set the following environment variables:
  * CC=gcc
  * CXX=g++
  * CEF\_CCFLAGS and ARCHFLAGS - either "-arch i386" when building 32bit or "-arch x86\_64" for 64bit

If you're building 32bit on 64bit then:
  * Create an alias python="arch -i386 python"
  * Set the `CEF_CCFLAGS` and `ARCHFLAGS` env variables to `"-arch i386"`

### An example script to prepare 32-bit environment ###

Save it as mac32.sh and type "`source mac32.sh`".

```
#!/bin/bash

PATH=/usr/local/bin:$PATH
export PATH
alias python="arch -i386 python"

CEF_CCFLAGS="-arch i386"
export CEF_CCFLAGS

ARCHFLAGS="-arch i386"
export ARCHFLAGS

export CC=gcc
export CXX=g++
```

### An example script to prepare 64-bit environment ###

Save it as mac64.sh and type "`source mac64.sh`".

```
#!/bin/bash

PATH=/usr/local/bin:$PATH
export PATH

CEF_CCFLAGS="-arch x86_64"
export CEF_CCFLAGS

ARCHFLAGS="-arch x86_64"
export ARCHFLAGS

export CC=gcc
export CXX=g++
```


## Install Cython ##

Download Cython 0.19.2 from PYPI. Latest versions are not supported, see [Issue 110](../issues/110).

https://pypi.python.org/pypi/Cython/0.19.2

Extract it and install. Before installing make sure you have exported the CC, CXX and ARCHFLAGS environment variables. Cython compilation will fail if it tries to compile for both 32bit and 64bit, that's why it is required to set ARCHFLAGS to either 32bit or 64bit architecture.

```
python setup.py install
```

## Download CEF binaries and build cefclient ##

Download CEF ready binaries from [cefbuilds.com](http://cefbuilds.com/). The branch and revision must match with the ones provided in the [BUILD\_COMPATIBILITY.txt](../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt) file.

Extract the archive. In our case this will create the `cef_binary_3.1650.1639_macosx32` directory to which we will later reference as the `cef_binary` directory.

Open the cefclient.xcodeproj project. When using Xcode 4.2 or newer you will need to change the "Compiler for C/C++/Objective-C" setting to "LLVM GCC 4.2" under "Build Settings" for each target.

Change build configuration to Release. From menu: Product > Scheme > Edit Scheme > Run > Build configuration: Release and OK. Click the Run button to build the project.

If there are errors while compiling `cefclient_osr_widget_mac.mm` then fix them:
  * Remove the `"(readwrite, atomic)"` string that appears before `"bool was_last_mouse_down_on_view"`
  * Move the `sendScrollWheelEvet` method up in the source file before it is referenced by the `shortCircuitScrollWheelEvent` method

Go to the `xcodebuild/Release/` directory and run `cefclient.app` to see if everything works fine.

## Download the CEF Python sources ##

```
git clone https://github.com/cztomczak/cefpython
```

## Copy CEF binaries and libraries to the CEF Python directories ##

  * Copy "cef\_binary/xcodebuild/Release/libcef\_dll\_wrapper.a" to "cefpython/cef3/mac/setup/lib\_32bit/"
  * Copy "`cef_binary/Release/*.dylib|so`" to "cefpython/cef3/mac/binaries\_32bit/"
  * Copy "cef\_binary/Resources/" to "cefpython/cef3/mac/binaries\_32bit/Resources/"

## Build the CEF Python module ##

```
cd cefpython/cef3/mac/
python compile.py
```

## Build packages for distribution ##

```
cd cefpython/cef3/mac/installer/
./build_all.sh
```

This should create dist/ directory with a Python Wheel package and a Distutils source package.

If you've built the cefpython module for both 32bit and 64bit and binaries are available in both mac/binaries\_32bit/ and mac/binaries\_64bit/ directories, then the setup script will create packages with fat binaries that can run on both 32bit and 64bit.