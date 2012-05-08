=CEF Python=

CEF Python project is to create python bindings for Chromium Embedded Framework (CEF, http://code.google.com/p/chromiumembedded/), for the C++ API of CEF.

The integration with CEF C++ api is possible by using Cython extension (http://cython.org/), which allows to include and use c++ libraries directly in python.

==Current status==

The project is still in early development (10%), but a working demo is ready, it displays a html page in a browser window, and that's all for the moment. But the hard part is over, example of how to convert c++ headers is in cefbindings.pyx file.

==Downloads==

The download consists of both: the runtime, and all the stuff used to create that runtime. Currently only windows platform is supported.

Version 0.11: http://code.google.com/p/cefpython/downloads/detail?name=cefpython_0.11.zip

==Requirements (to run)==

 * Python 2.7 (should also work with Python 2.6 or 3.1, but needs compiling)
 * pywin32 extension

==Running==

Python bindings are already compiled (cefapi.pyd - for Python 2.7) so you can run client immadiately by executing cefclient.py.

==Screenshot of running cefclient.py==

https://cefpython.googlecode.com/svn/trunk/cefpython.jpg

==Requirements (to compile)==

 * Python (any version)
 * pywin32 extension
 * cython extension (tested using latest 0.16 from github)
 * Visual Studio (c++ compiler is only needed)
 * User32.lib from windows SDK

==Installation instructions (to compile)==

 # Install Python
 # Install pywin32 extension (if you install ActivePython it is installed by default)
 # Install Cython (cefpython is tested with the latest 0.16 version from github: https://github.com/cython/cython)
 # Install Visual Studio (Express editions are free)
 # Install Windows SDK (User32.lib is required)
 # Edit setup/setup.py and change path "d:/winsdk7/Lib/" to your Windows SDK Lib directory.

==Compilation==

You need to install Visual Studio on your machine, cython setup script will detect it automatically.

Run compile-n-run.bat.

This batch file copies cefapi.pyx and cefbindings.pyx to setup directory, both files are combined into one file called cefapi.pyx, after that it runs cython's setup.py. That setup compiles python code to c++ code, cefapi.cpp is created and compiled to a DLL-like file called cefapi.pyd. This pyd is copied to upper directory and cefclient.py is run.

==Description of files and directories==

CEF headers:

 * include/

CEF runtime:

 * locales/
 * icudt.dll
 * libcef.dll
 * chrome.pak

Cython compilation:

 * setup/setup.bat
 * setup/setup.py

CEF Python:

 * cefapi.pyd - PYD is an equivalent of DLL in python, this is the runtime of CEF Python
 * cefapi.pyx - this should be api, but there is no real yet, just a big main(), creating window and calling CEF c++ api
 * cefbindings.pyx - this is python's equivalent of c++ .h file
 * cefclient.py - as there is no api this file only calls main() of cefapi.pyx
 * cefclient2.h - an empty implementation of CefClient, we need to pass it to CreateBrowser()
 * cefwindow.py - window creation using win32 api via win32py extension