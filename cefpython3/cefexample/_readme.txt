CEF Python is an open source project founded by Czarek Tomczak in 2012 to 
provide python bindings for the Chromium Embedded Framework (in short CEF).
Chromium is the engine that is behind Google Chrome and CEF is a perfect solution
for implementing HTML based GUI in a desktop application. Bindings to CEF are 
possible thanks to Cython which allows to use c++ libraries directly in Python.

---------------------
EXAMPLES
---------------------

	Run example applications:
	- cefsimple.py

---------------------
HELP?
---------------------

	Project's website: http://code.google.com/p/cefpython/
	Wiki pages: http://code.google.com/p/cefpython/w/list
	Cefpython group: https://groups.google.com/group/cefpython?hl=en
	Cef forum: http://magpcss.org/ceforum/viewforum.php?f=16
	Browse, report, star issues: http://code.google.com/p/cefpython/issues/list
	License: New BSD License

---------------------
REDISTRIBUTION
---------------------

	Required components:

	* CEF core library
	    libcef.dll

	* Unicode support
	    icudt.dll

	* cefpython.pyd - cefpython library compiled using Cython extension,
	this is a dll-like file in python world.
	* cefwindow.py - functions to create window using pywin32 extension.

	* Manifest and msvcr90.dll are dependencies of cefpython.pyd:
	Microsoft.VC90.CRT.manifest
	msvcm90.dll (not really required but must be redistributed together)
	msvcp90.dll (not really required but must be redistributed together)
	msvcr90.dll

	Optional components:

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
	
---------------------
  ICON icon.ico
---------------------

	That icon is from "FS Ubuntu Icons" by Frank Souza.
	Licensed under GNU General Public License.