CEF Python binary distribution
------------------------------

EXAMPLES
--------

Examples using pywin32 extension:
- cefsimple.py
- cefadvanced.py

Embedding CEF in GUI frameworks:
- pygtk_.py
- wxpython.py
- pyqt.py
- pyside.py

Browser for testing:
- cefclient.exe

HELP
----

Project's website: http://code.google.com/p/cefpython/
Wiki pages: http://code.google.com/p/cefpython/w/list
Help forum: https://groups.google.com/group/cefpython?hl=en
Report bugs, star issues: http://code.google.com/p/cefpython/issues/list

REDISTRIBUTION
--------------

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
ApplicationSettings.locale. Only configured locales need to be distributed. If no
locale is configured the default locale of "en-US" will be used. The
locales folder must exist in the same directory as libcef.dll.

* Other resources
devtools_resources.pak

Note: Contains WebKit image and inspector resources. Pack file loading can be
disabled completely using CefSettings.pack_loading_disabled. The resources
directory path can be customized using CefSettings.resources_dir_path.

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

Test components:

* cefclient application that does not need to be redistributed.
cefclient.exe


ICON
----

icon.ico is from "FS Ubuntu Icons" by Frank Souza.
Licensed under GNU General Public License.

LICENSING
---------

The CEF Python project is BSD licensed (http://opensource.org/licenses/BSD-3-Clause).
Other software included in this distribution is provided under other licenses.
Please visit the below link for complete Chromium and third-party licensing information:
http://code.google.com/chromium/terms.html
