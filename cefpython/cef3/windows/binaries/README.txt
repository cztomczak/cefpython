CEF Python Binary Distribution
-------------------------------------------------------------------------------

This distribution contains all components necessary to build and distribute an
application using CEF. Please see the LICENSING section of this document for
licensing terms and conditions.

REDISTRIBUTION
--------------

This binary distribution contains the below components. Components listed under
the "required" section must be redistributed with all applications using CEF.
Components listed under the "optional" section may be excluded if the related
features will not be used.

Required components
-------------------

* CEF core library
    libcef.dll

* Unicode support
    icudt.dll

* subprocess.exe - for launching sub-processes, you can change its name
through ApplicationSettings.browser_subprocess_path.

* cefpython_py27.pyd - cefpython library compiled using Cython extension,
this is a dll-like file in python world.

* cefwindow.py - functions to create window using pywin32 extension.

* Manifest and msvcr90.dll are dependencies of cefpython.pyd:
Microsoft.VC90.CRT.manifest
msvcm90.dll (not really required but must be redistributed together)
msvcp90.dll (not really required but must be redistributed together)
msvcr90.dll

Optional components
-------------------

* Localized resources
    locales/
  Note: Contains localized strings for WebKit UI controls. A .pak file is loaded
  from this folder based on the CefSettings.locale value. Only configured
  locales need to be distributed. If no locale is configured the default locale
  of "en-US" will be used. Locale file loading can be disabled completely using
  CefSettings.pack_loading_disabled. The locales folder path can be customized
  using CefSettings.locales_dir_path.

* Other resources
    cef.pak
    devtools_resources.pak
  Note: Contains WebKit image and inspector resources. Pack file loading can be
  disabled completely using CefSettings.pack_loading_disabled. The resources
  directory path can be customized using CefSettings.resources_dir_path.

* FFmpeg audio and video support
    avcodec-54.dll
    avformat-54.dll
    avutil-51.dll
  Note: Without these components HTML5 audio and video will not function.

* Angle and Direct3D support
    d3dcompiler_43.dll
    d3dx9_43.dll
    libEGL.dll
    libGLESv2.dll
  Note: Without these components HTML5 accelerated content like 2D canvas, 3D
  CSS and WebGL will not function.


LICENSING
---------

The CEF project is BSD licensed. Please read the LICENSE.txt file included with
this binary distribution for licensing terms and conditions. Other software
included in this distribution is provided under other licenses. Please visit the
below link for complete Chromium and third-party licensing information.

http://code.google.com/chromium/terms.html 
