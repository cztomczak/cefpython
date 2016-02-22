# Build instructions for Windows #

The original instructions on building Chromium/CEF can be found on the CEF project [Branches and Building](https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding) wiki page.

Table of contents:


## Preliminary notes ##

  * The steps of downloading and building Chromium from sources may be skipped by downloading CEF ready binaries from [cefbuilds.com](http://cefbuilds.com/). The branch and revision must match with the ones provided in the [BUILD\_COMPATIBILITY.txt](../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt) file.
  * The path to the chromium directory should not contain any spaces
  * Compiling cefpython was tested with Python 2.7 / 3.2 (32bit). See [Issue 121](../issues/121) for Python 3.4 support.
  * To build Chromium you will need Windows 7 64-bit or later.
  * The result binaries require at least Windows XP SP3 to run.
  * To build 64-bit binaries you will need VS2008 Pro. The Express edition cannot is missing the x64 platform configuration.

## Install the Chromium tools ##

1. See the "Build environment" section on the Chromium project site, the instructions are available for Visual Studio 2010 and for the Express edition which is free:

(link seems no more relevant, as Chrome now officially uses VS 2013, but CEF Python probably still requires VS 2010 as it uses an older version of Chrome)

http://www.chromium.org/developers/how-tos/build-instructions-windows#TOC-Build-environment

You have to install Visual Studio 2010 with Service Packs and x64 compiler tools, Windows SDK and DirectX SDK. Do not install the Cygwin.

2. Install depot\_tools:

```
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

If you do not have git installed download and extract depot\_tools from here:

https://src.chromium.org/svn/trunk/tools/depot_tools.zip

3. Add depot\_tools directory to your system PATH (Advanced System Settings > Environment Variables > System variables > PATH).

4. Run the gclient once command:

```
gclient once
```

This will install git, svn and python to the depot\_tools directory.

5. Python 2.6.2 has been installed to the depot\_tools directory that shall be used from now on by gclient and the CEF tools, if you have some other python in your system PATH then this may cause conflicts, remove it or add depot\_tools at the beginning of the system PATH. After the PATH is modified make sure you're running the python from depot tools by running the command:

```
python --version
```

It should display "Python 2.6.2".

## Configure Chromium to use a specific revision ##

1. Go open the BUILD\_COMPATIBILITY.txt file.

For CEF 1: ../blob/master/cefpython/cef1/BUILD_COMPATIBILITY.txt

For CEF 3: ../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt

Later we will need the "Chromium release url" and and the "CEF repository url" so keep it in sight.

2. Create the "chromium" directory:

```
mkdir chromium
```

3. Configure Chromium to use a specific revision (through a release url) by running the "gclient config" command, the release url we will be using is from the BUILD\_COMPATIBILITY.txt file:

```
cd chromium/
gclient config {Chromium release url}
```

4. Edit the "chromium/.gclient" and edit the "custom\_deps" to reduce the size of the sources to downoad:

```
  "custom_deps": {
    "src/content/test/data/layout_tests/LayoutTests": None,
    "src/chrome/tools/test/reference_build/chrome_win": None,
    "src/chrome_frame/tools/test/reference_build/chrome_win": None,
    "src/chrome/tools/test/reference_build/chrome_linux": None,
    "src/chrome/tools/test/reference_build/chrome_mac": None,
    "src/third_party/hunspell_dictionaries": None,
  },
```

This excludes some directories that contain lots of data (many many gigabytes) that would extend the time significantly when synchronizing Chromium sources with the revision we've selected.

5. Type the "svn ls" command and permanently accept the SSL certificate if it appears:

```
svn ls https://src.chromium.org/chrome
```

## Download the Chromium sources ##

Download the Chromium sources by running the "gclient sync" command. The Chromium sources will be updated to the revision based on the release url we've configured earlier via "gclient config". Read also the "Possible issues" section below in case you encounter errors.

```
cd chromium/
gclient sync --jobs 8 --force
```

This can take a while and sometimes it can break with some errors when a download fails. In such case you should run the "gclient sync" command once again. One of the last messages in the console should be:

```
Updating projects from gyp files...
```

#### Possible issues while running "gclient sync" ####

  * You may encounter an error while checking out the gsutil repo, fix it [by removing gsutil entries from the DEPS file](http://src.chromium.org/viewvc/chrome/releases/33.0.1750.29/DEPS?r1=245305&r2=245304&pathrev=245305).

## Download the CEF sources ##

Download the CEF sources, the repository url can be found in the BUILD\_COMPATIBILITY.txt file.

```
cd chromium/src/
svn checkout {CEF repository url} cef
```

This will download the CEF sources to the "cef" directory inside the Chromium "src" directory.

## Download the CEF Python sources ##

Run the "git clone" command for the CEF Python repository. This download can take hundreds of megabytes.

```
git clone https://github.com/cztomczak/cefpython
```

## Fix HTTPS caching on sites with SSL certificate errors (optional) ##

This is an optional fix. By default Chromium disables caching when there is certificate error. This patch will fix the HTTPS caching only when [ApplicationSettings](ApplicationSettings.md).ignore\_certificate\_errors is set to True. Official cefpython binaries have this fix applied, starting with the 31.0 release. See also [Issue 125](https://code.google.com/p/cefpython/issues/detail?id=125).

Apply the patch in the "`~/chromium/src/`" directory. Modifications are made in the `HttpCache::Transaction::WriteResponseInfoToEntry` function.

```
Index: net/http/http_cache_transaction.cc
===================================================================
--- http_cache_transaction.cc   (revision 241641)
+++ http_cache_transaction.cc   (working copy)
@@ -2240,7 +2240,8 @@
   // reverse-map the cert status to a net error and replay the net error.
   if ((cache_->mode() != RECORD &&
        response_.headers->HasHeaderValue("cache-control", "no-store")) ||
-      net::IsCertStatusError(response_.ssl_info.cert_status)) {
+       (!cache_->GetSession()->params().ignore_certificate_errors &&
+       net::IsCertStatusError(response_.ssl_info.cert_status))) {
     DoneWritingToEntry(false);
     ReportCacheActionFinish();
     if (net_log_.IsLoggingAllEvents())
```



## Build CEF binaries and libraries ##

1. Set the "GYP\_MSVS\_VERSION" environment variable depending on version of Visual Studio you are using. For Visual Studio 2010 set it to "2010", for the Express edition set it to "2010e".

2. Generate the build files based on the GYP configuration by running the "cef\_create\_projects.bat" script.

```
cd chromium/src/cef/
cef_create_projects.bat
```

3. Open the "cef.sln" solution file, change the configuration to Release mode and build it.

```
cd chromium/src/cef/
cef.sln
```

After it's built you can close the solution.

4. Run the "make\_distrib.bat" script.

```
cd chromium/src/cef/tools/
make_distrib.bat --allow-partial
```

5. Go to the "chromium/src/cef/binary\_distrib/cef\_binary\_xxxx\_windows/" directory, for the next few steps we will be calling this directory the "cef\_binary" directory.

6. Open the "cef\_binary/cefclient2010.sln" solution, change the configuration to Release mode and build it.

7. Copy the "cef\_binary/README.txt" file to the "cefpython/cef3/windows/binaries\_32bit/" directory.

8. Go to the "cef\_binary/Release/" directory and copy the "libcef.lib" file to the "cefpython/cef3/windows/setup/" directory.

9. Go to the "cef\_binary/out/Release/" directory, copy the following files:

  * locales/ directory
  * all the .exe, .dll and .pak files

Copy them to the "cefpython/cef3/windows/binaries\_32bit/" directory.

If you already had any binaries in the "binaries\_32bit/" directory from the previous build process then delete them first, but do not delete the visual c runtime dlls (msvcm90.dll, msvcp90.dll, msvcr90.dll).

It might be useful to copy also the debug symbols for the CEF library, so that you can debug the stack trace when there is an error in the CEF library. To copy the debug symbols go to the "chromium/src/cef/binary\_distrib/cef\_binary\_3.1650.1646\_windows32\_release\_symbols/" directory and copy the "libcef.dll.pdb" file to the "cefpython/cef3/windows/binaries\_32bit/" directory.

## Install CEF Python build dependencies ##

1. Install Visual Studio 2008 with Service Pack 1 or the Express edition which is free. Building Python is supported only on VS2008, thus the same requirement stands for Cython.

2. Install [Windows SDK 7.0](http://www.microsoft.com/en-us/download/confirmation.aspx?id=18950) to the default location.

GRMSDK\_EN\_DVD.iso - for Windows 32bit<br>
GRMSDKX_EN_DVD.iso - for Windows 64bit<br>
<br>
3. Download <a href='https://pypi.python.org/pypi/Cython/0.19.2'>Cython 0.19.2</a> from PYPI. Later version are not supported by cefpython. Extract it and install:<br>
<pre><code>python setup.py install<br>
</code></pre>

4. (Optional) Install the <a href='https://sourceforge.net/projects/pywin32/'>pywin32 extension</a> to run the pywin32 example.<br>
<br>
<h2>Build the CEF Python static libraries</h2>

1. Before building static libraries you have to set the "PYTHON_INCLUDE_PATH" environment variable, it should point to the include/ directory in the python installation directory. If you have python installed to the "C:\Python27\" directory (or "C:\Python34\",  "C:\Python27_x64\", "C:\Python27_amd64",  "C:\Python27_64", "C:\Python34_x64\" etc.), then setting the "PYTHON_INCLUDE_PATH" environment variable is not required.<br>
<br>
2. Go to the "chromium/src/cef/binary_distrib/cef_binary/" directory, open the "libcef_dll_wrapper.vcproj" project file in Visual Studio 2008 (not VS2010) and change the configuration to Release mode.<br>
<br>
2a. Change the properties of the "libcef_dll_wrapper" project:<br>
<ul><li>Set the "C/C++ > Output files > Program Database File Name" option an empty string. This will get rid of warnings during cython compilation</li></ul>

Build it. Go to the cef_binary/out/Release/lib/ directory and rename "libcef_dll_wrapper.lib" to "libcef_dll_wrapper_mt.lib". Copy it to the cefpython/cef3/windows/setup/lib_32bit/ directory.<br>
<br>
2b. Change the properties of the "libcef_dll_wrapper" project:<br>
<ul><li>Set the "C/C++ > Code Generation > Runtime Library" to "Multi-threaded DLL (/MD)".<br>
</li><li>In "C/C++ > Command Line" add a flag: "-D_HAS_EXCEPTIONS=1" (or set "multi_threaded_dll" in your GYP configuration, see <a href='https://bitbucket.org/chromiumembedded/cef/issues/970/cef3-win-generate-libcef_dll_wrapper'>CEF Issue 970</a>).</li></ul>

Build it. After it's built, go to the "cef_binary/out/Release/lib/" directory. Rename "libcef_dll_wrapper.lib" to "libcef_dll_wrapper_md.lib" and copy it to the "cefpython/cef3/windows/setup/lib_32bit/" directory.<br>
<br>
<h2>Build the CEF Python module</h2>

Go to the "cefpython/cef3/windows/" directory.<br>
<br>
There is one thing to do before building. An up-to-date "cefpython.h" file needs to be generated, signatures of the Cython public functions are there. To generate this file you need to run the compile.bat script and ignore any errors you see. When asked whether to continue press "y" (yes). The compile.bat script expects first argument to be release version number:<br>
<pre><code>compile.bat 31.2<br>
</code></pre>

After cefpython.h was generated run the compile.bat script once again.<br>
<br>
If everything went fine then the "cefpython_py27.pyd" (or py34.pyd) module should be created in the "cefpython/cef3/windows/binaries_32bit/" directory and the "wxpython.py" example should be launched automatically.<br>
<br>
The compile.bat script also accepts additional flags that can be passed after the version argument:<br>
<ul><li>--rebuild - to rebuild vcproj builds<br>
</li><li>--py27-32bit, --py27-64bit, --py34-32bit, --py34-64bit - these allow to set PATH for specific Python version. This path contains minimum set of directories to allow detecting possible issues early.</li></ul>

<h2>Build packages for distribution</h2>

To be able to build the inno setup installer you have to install <a href='http://www.jrsoftware.org/isdl.php'>Inno Setup 5</a>. It should be installed to the deafault location "c:\Program Files (x86)\Inno Setup 5\ISCC.exe", otherwise you will have to edit the "make-installer.py" script and change the path. To disable creation of inno setup installer package pass the "<code>--disable-inno-setup</code>" flag after the version number argument.<br>
<br>
You will also need the pip package manager, please <a href='http://stackoverflow.com/questions/4750806/how-to-install-pip-on-windows'>see here</a> on how to install it on Windows. It needs to be a recent version of pip, so that Python Wheels are supported. The build_all.bat script will install some dependencies (setuptools, wheel) if they are missing. If you have some old versions of pip/setuptools/wheel installed, then you need to upgrade them by typing these commands:<br>
<br>
<pre><code>pip install --upgrade pip<br>
pip install --upgrade setuptools<br>
pip install --upgrade wheel<br>
</code></pre>

To create multiple packages run the build_all.bat script. The first argument is a version number. There are also optional flags that you can pass after the version argument: --disable-inno-setup, --py27-32bit, --py27-64bit, --py34-32bit, --py34-64bit.<br>
<pre><code>cd cefpython/cef3/windows/installer/<br>
build_all.bat win32 31.2<br>
</code></pre>

If everything went fine then you should see multiple distributions created in the dist/ directory.