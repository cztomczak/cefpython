CEF Python is an open source project founded by Czarek Tomczak in 2012 to 
provide python bindings for the Chromium Embedded Framework (in short CEF).
Chromium is the engine that is behind Google Chrome and CEF is a perfect solution
for implementing HTML based GUI in a desktop application. Bindings to CEF are 
possible thanks to Cython which allows to use c++ libraries directly in Python.

---------------------
EXAMPLES
---------------------

	There are 2 example applications:
	- cefsimple.py
	- cefadvanced.py

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

	This binary distribution contains the below components. Components listed under
	the "required" section must be redistributed with all applications using CEF.
	Components listed under the "optional" section may be excluded if the related
	features will not be used.

	Required components:

	* CEF core library
	libcef.dll

	* Unicode support
	icudt.dll

	* Localized resources
	locales/
	Note: A .pak file is loaded from this folder based on the value of
	CefSettings.locale. Only configured locales need to be distributed. If no
	locale is configured the default locale of "en-US" will be used. The
	locales folder must exist in the same directory as libcef.dll.

	* Other resources
	chrome.pak
	Note: The chrome.pak file must exist in the same directory as libcef.dll.

	* cefpython.pyd - cefpython library compiled using Cython extension,
	this is a dll-like file in python world.
	* cefwindow.py - functions to create window using pywin32 extension.

	* Manifest and msvcr90.dll are dependencies of cefpython.pyd:
	Microsoft.VC90.CRT.manifest
	msvcm90.dll (not really required but must be redistributed together)
	msvcp90.dll (not really required but must be redistributed together)
	msvcr90.dll

	Optional components:

	* FFmpeg audio and video support
	avcodec-53.dll
	avformat-53.dll
	avutil-51.dll
	Note: Without these components HTML5 audio and video will not function.

	* Angle and Direct3D support
	d3dcompiler_43.dll
	d3dx9_43.dll
	libEGL.dll
	libGLESv2.dll
	Note: Without these components the default ANGLE_IN_PROCESS graphics
	implementation for HTML5 accelerated content like 2D canvas, 3D CSS and
	WebGL will not function. To use the desktop GL graphics implementation which
	does not require these components (and does not work on all systems) set
	CefSettings.graphics_implementation to DESKTOP_IN_PROCESS.


---------------------
  ICON icon.ico
---------------------

	That icon is from "FS Ubuntu Icons" by Frank Souza.
	Licensed under GNU General Public License.