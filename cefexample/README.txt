CEF Python provides bindings for the Chromium Embedded Framework (CEF). 

Example application
	There are 2 example applications:
	- cefsimple.py
	- cefadvanced.py

Files
	cefpython.pyd - cefpython library compiled using Cython extension,
				this is a dll-like file in python world.
	cefwindow.py - functions to create window using pywin32 extension.

	DLL's and .PAK file are from "cef_binary_1.1025.607_windows.zip"
	that can be downloaded from the Chromium Embedded Framework
	project: http://code.google.com/p/chromiumembedded/

	Manifest and msvcr90.dll are dependencies of cefpython.pyd:
		Microsoft.VC90.CRT.manifest
		msvcm90.dll (not really required but must be redistributed together)
		msvcp90.dll (not really required but must be redistributed together)
		msvcr90.dll

Programming API
	http://code.google.com/p/cefpython/wiki/API

Having issues?
	Report bugs or wanted features here:
	http://code.google.com/p/cefpython/issues/list

License
	New BSD License
Copyright
	Czarek Tomczak. All rights reserved.
Website:
	http://code.google.com/p/cefpython/


icon.ico
	That icon is from "FS Ubuntu Icons" by Frank Souza.
	Licensed under GNU General Public License.

------------------------------------------------------------------------------------------------

CHANGELOG.

Version 0.33 released on 2012-08-19
 * New function exposed: Frame.LoadURL()
 * Fixed bug in: Frame.ExecuteJavascript()
 * Javascript error handling example
 * New function exposed: cefpython.SingleMessageLoop(),
allows to integrate with existing application's message loop, see [PyGTK] example.
 * Fix to detection of infinite recursion in javascript bindings.
 * Improved detection of current directory when passing path to html file or icon,
try cefpython.GetRealPath(file) or cefpython.GetRealPath() to get current dir.

Version 0.30 released on 2012-07-15.
 * Implemented JavascriptBindings.
 * Implemented JavascriptCallback.
 * Implemented Python callbacks as arguments/return value to javascript functions.
 * Frame.!GetProperty()/!SetProperty().
 * Fixed application error when closing main window (Issue 2).

Version 0.26 released on 2012-07-08.
 * Implemented KeyboardHandler
 * cefadvanced.py: example of binding F12 key to open Developer tools, and F5 to refresh page.

Version 0.25 released on 2012-07-07.
 * Browser object is almost ready, Frame still needs some work.
 * Client handlers are starting to work, implemented LoadHandler.
 
Version 0.22 released on 2012-07-02.
 * Object oriented model for the Browser api
 * Removed cefwindow as a dependency of cefpython module.
 * Fixed bug: browser's client area did not get keyboard focus.

Version 0.21 released on 2012-07-02.
 * Fixed bug: browser's client area wasn't resized when window size changed.

Version 0.20 released on 2012-07-01.
 * First release that comes with real API.

Version 0.11 released on 2012-02-14.
 * Fixed hardcoded path to cefexample.html

Version 0.10 released on 2012-02-14.
 * This is just a proof of concept that python bindings to C++ api of CEF can be done with Cython.
