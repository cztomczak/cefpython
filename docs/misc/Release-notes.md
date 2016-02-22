# Release notes #

This document is DEPRECATED and won't be used anymore for newer releases.

Version 31.3 not yet released.
  * Added `__version__` attribute in the cefpython3.cefpython module ([Issue 167](../issues/167))
  * Added methods [Browser](Browser).`ExecuteFunction()` / `ExecuteJavascript()` which are wrappers for calling  [Browser](Browser).`GetMainFrame()`.`ExecuteFunction()` / `ExecuteJavascript()`.
  * Added functions [cefpython](cefpython).`GetAppSetting()` / `GetCommandLineSwitch()`

Version 31.2 released on January 10, 2015.
  * Initial release of Windows 64bit binaries ([Issue 82](../issues/82))
  * Initial release for Mac ([Issue 21](../issues/21)). See the [Download\_CEF3\_Mac](Download_CEF3_Mac) and BuildOnMac wiki pages.
  * Fixed BC break in cefpython.wx.chromectrl introduced in 31.1
  * Windows binaries do not ship the msvcr90.dll and Microsoft.VC90.CRT.manifest files anymore. The subprocess.exe executable does not depend on msvcr90.dll anymore.

Version 31.1 released on December 4, 2014.
  * (Windows) When cefpython detects that application is DPI aware (may be enabled by user in .exe properties) then it will set ApplicationSettings."auto\_zooming" to "system\_dpi" automatically. Added the DpiAware.`IsProcessDpiAware` method. See revision c11190523824.
  * Added new callbacks to LifespanHandler: `_OnAfterCreated`, `RunModal`, `DoClose`, `OnBeforeClose`. Thanks to Simon Hatt for the patch ([Issue 139](../issues/139)).
  * Fixed issue with `GetApplicationPath()` returning wrong directory in some cases. All examples have been updated. See revision 6b141a8f54b4.
  * Improvements to Linux installers (debian package, setup.py). See [Issue 149](../issues/149), [Issue 147](../issues/147), [Issue 145](../issues/145), [Issue 105](../issues/105), [Issue 99](../issues/99).
  * Windows users can now install cefpython3 package from PyPI. [Issue 144](../issues/144).

Version 31.0 released on August 1, 2014.
  * Updated Chrome to version 31.0.1650.69 ([Issue 124](../issues/124))
  * Added Qt example on Linux ([Issue 88](../issues/88))
  * Added GTK example on Linux ([Issue 95](../issues/95))
  * Added High DPI support on Windows. See the DpiAware wiki page and the ApplicationSettings.`auto_zooming` option. Example usage is in the wxpython.py example. See [Issue 112](../issues/112), [Issue 128](../issues/128).
  * Added Developer Tools support. See [Browser](Browser).`ShowDevTools`. Can be launched from mouse context menu as well. See also ApplicationSettings.`remote_debugging_port`, a default value of 0 enables devtools, to disable set it to -1. ([Issue 81](../issues/81))
  * Mouse context menu is now configurable, see ApplicationSettings.`context_menu`. New menu items added: "Reload", "Open in external browser", "Developer Tools". ([Issue 122](../issues/122))
  * Implemented a default DownloadHandler. File downloads are handled automatically with no additional code required. Added new option ApplicationSettings.`downloads_enabled`. ([Issue 87](../issues/87))
  * Exposed API for execution of tasks on various threads. This fixes problems with keyboard in popups in the wxpython.py example on Windows, an example usage is there. See [cefpython](cefpython).`PostTask`. See [Issue 61](../issues/61), [Issue 80](../issues/80).
  * Fixed issues with embedding multiple browsers in tabs ([Issue 97](../issues/97))
  * Fixed CEF message loop processing in wx.chromectrl, it could cause performance penalties when opening multiple browser tabs/windows ([Issue 129](../issues/129))
  * Fixed the browser cleanup code in the `OnClose` event in the wxpython examples, it could possibly cause crashes during shutdown ([Issue 107](../issues/107))
  * Fixed a crash in V8 javascript bindings when a call to [Frame](Frame).`LoadUrl` changed origin (scheme + domain). For example when a redirect to a different domain was being made. This problem occured only when javascript bindings were set ([Issue 130](../issues/130)).
  * Enabled caching on HTTPS even when there is certificate error, but only when ApplicationSettings.`ignore_certificate_errors` is set to True ([Issue 125](../issues/125))
  * Disabled tcmalloc hook on Linux in the CEF Python official binaries. It caused crashes when cefpython was not the very first library being imported ([Issue 73](../issues/73)).
  * Added the JavascriptDialogHandler ([Issue 118](../issues/118))
  * Added new option ApplicationSettings.unique\_request\_context\_per\_browser
  * Fixed problems with unique cookie manager per browser session. See notes in the RequestHandler.`GetCookieManager` callback ([Issue 126](../issues/126)).
  * Fixed cookie problems during POST requests in the ResourceHandler example on Linux ([Issue 127](../issues/127))
  * Fixed loading of local file urls that contained hash ([Issue 114](../issues/114))
  * Added the [Browser](Browser).`GetUrl` and `LoadUrl` methods
  * Redesigned the wxpython.py example. Added table of contents and source code highlighting among others.
  * Moved DisplayHandler.`OnLoadingStateChange` to LoadHandler (does not affect code)
  * Moved LoadHandler.`OnRendererProcessTerminated` and `OnPluginCrashed` to RequestHandler (does not affect code)
  * Updated descriptions many of the settings on the [ApplicationSettings](ApplicationSettings) and [BrowserSettings](BrowserSettings) wiki pages. A certain set of options can now also be set using command line switches.
  * Added new option ApplicationSettings.background\_color

Version 29.4 released on January 15, 2014.
  * Added `commandLineSwitches` param to [cefpython](cefpython).Initialize(). See the [CommandLineSwitches](CommandLineSwitches) wiki page. Thanks to Finn Hughes for the patch. See [Issue 65](../issues/65).
  * Debug options set in python (debug and log\_file) are now shared with the C++ browser process code. See [Issue 98](../issues/98).
  * Added new option "debug" to ApplicationSettings. Overwriting the g\_debug global variable in the cefpython module is now deprecated. See [Issue 100](../issues/100).
  * See revisions: [fd0ed30fb387](https://code.google.com/p/cefpython/source/detail?r=fd0ed30fb387d515986b2d20b635a8f90a715c66)

Version 29.3 released on January 13, 2014.
  * `CreateBrowserSync()`, `Shutdown()` and others are now called without GIL (global interpreter lock), to avoid deadlocks, see [Issue 102](../issues/102).
  * Added support for Distutils setup on Windows. Created MSI installer and Self-extracting zip for distribution using Distutils setup, see the BuildOnWindows wiki page for instructions ([Issue 108](../issues/108)).
  * See revisions: [ec1ce788373b](https://code.google.com/p/cefpython/source/detail?r=ec1ce788373bb9e0fd2cedd71e900c3877e9185a), [00f8606dbebc](https://code.google.com/p/cefpython/source/detail?r=00f8606dbebc40a061049b213271d3a4fb3b04e3), [75a19a8a9a1a](https://code.google.com/p/cefpython/source/detail?r=75a19a8a9a1a9eeb92d98464bd040892430b6eac)

Version 29.2 released on December 26, 2013.
  * Debian packages support on Linux, see the ["Create a Debian package"](https://code.google.com/p/cefpython/wiki/BuildOnLinux#Create_a_Debian_package) section on the BuildOnLinux wiki page
  * Fixes to [package installer on Windows](PackageInstallerOnWindows). Do not show examples in explorer window after installation has completed, when in /SILENT mode.
  * Added LifespanHandler.`OnBeforePopup`, see [Issue 93](../issues/93). Thanks to Greg Farrell for the patch.
  * Added RequestHandler.`OnBeforeBrowse`, see [Issue 94](../issues/94). Thanks to Greg Farrell for the patch.
  * Added new methods to [Frame](Frame): `GetSource()` and `GetText()`. See [Issue 96](../issues/96). Thanks to Greg Farrell for the patch.
  * See revisions: [13c472369c35](https://code.google.com/p/cefpython/source/detail?r=13c472369c356e41eda4caf82bcbe494a4cf6835), [f8abf0d73a64](https://code.google.com/p/cefpython/source/detail?r=f8abf0d73a646993e67065f1138e24bf9ae3691a), [893f4659f8e5](https://code.google.com/p/cefpython/source/detail?r=893f4659f8e570c334571ac0aa5c94b7b861856a), [be7029d302f3](https://code.google.com/p/cefpython/source/detail?r=be7029d302f36065dd7aa091d82987f7c6b18eb6),  [dcbbd8edf0a0](https://code.google.com/p/cefpython/source/detail?r=dcbbd8edf0a0fec617fa7e4acb41a318755ae84e)

Version 29.1 released on December 15, 2013
  * Updated Package Installer (Inno Setup Exe), the command line installation process with /SILENT flag does not require user interaction anymore. Also by default it will uninstall any existing cefpython3 package.
  * Fixes to the wx examples (both wxpython.py and wx.chromectrl), changed behavior of browser cleanup on close. By default a timer is used to process CEF message loop work, earlier it was EVT\_IDLE.
  * See revision [9bc68b3954ae](https://code.google.com/p/cefpython/source/detail?r=9bc68b3954ae0ac1a889060e756335bedfbda435)

Version 29.0 released on November 1, 2013.
  * Updated to Chrome 29.0.1547.80  CEF rev. 1491
  * Added [cefpython](cefpython).`SetOsModalLoop()`.
  * Added [Browser](Browser).`Print()`, `Find()`, `StopFinding()`.

Version 27.6 released on September 24, 2013.
  * Implemented response reading features: [RequestHandler](RequestHandler).`GetResourceHandler()`, [ResourceHandler](ResourceHandler), [Response](Response),  [WebRequest](WebRequest), [WebRequestClient](WebRequestClient), [Callback](Callback).
  * Added [wxpython-response.py](https://code.google.com/p/cefpython/source/browse/cefpython/cef3/linux/binaries_64bit/wxpython-response.py?r=c08fc026e625) script that emulates `OnResourceResponse` callback (not yet available in CEF 3) by utilizing [ResourceHandler](ResourceHandler) and [WebRequest](WebRequest).
  * This release was sponsored by Thomas Wusatiuk

Version 27.5 released on September 18, 2013.
  * Added support for the `<select>` elements in the Kivy OSR example
  * Fixes to the Kivy OSR example
  * This release was sponsored by Rentouch GmbH.

Version 27.4 released on September 14, 2013.
  * Added off-screen rendering support along with an example using the Kivy framework (see [Issue 69](../issues/69))
  * Fixed the renderer process crash when js bindings bindToFrames option was set to True
  * This release was sponsored by Rentouch GmbH.

Version 27.3 released on August 7, 2013.
  * Fixed keyboard issues in the wxpython examples, see [revision ec7123e1e596](https://code.google.com/p/cefpython/source/detail?r=ec7123e1e596d5b866318c01d7b4cbe9217eacec)

Version 27.2 released on August 5, 2013.
  * Added javascript and python callbacks
  * Added [JavascriptContextHandler](JavascriptContextHandler)
  * Added [RequestHandler](RequestHandler), [Request](Request) object, [WebPluginInfo](WebPluginInfo) object
  * Added [LoadHandler](LoadHandler)
  * Added [Cookie](Cookie), [CookieManager](CookieManager), [CookieVisitor](CookieVisitor)
  * Added new method to the [Browser](Browser) object: `ParentWindowWillClose()`.
  * Fixed [Browser](Browser).`CloseBrowser()` behavior
  * Updated to CEF 3 rev. 1352, Chrome version 27.0.1453.116.
  * This release is sponsored by Cyan Inc.

Version 27.1 released on July 25, 2013.
  * Added new methods to the [Frame](Frame) object: `GetBrowser()`, `GetParent()`.
  * Added new methods to the [Browser](Browser) object: `GetFrames()`, `GetFrameByIdentifier()`.
  * Added javascript bindings
  * Added new callbacks to [JavascriptContextHandler](JavascriptContextHandler): `OnContextCreated()`, `OnContextReleased()`.
  * This release is sponsored by Cyan Inc.

Version 27.0 released on June 24, 2013.
  * Introducing new naming convention for the binary distributions, see [Issue 68](../issues/68).
  * Updated to the Chrome version 27.0.1453.110, CEF 3 branch 1453 rev. 1279.
  * Added new options to ApplicationSettings: persist\_session\_cookies, ignore\_certificate\_errors.
  * Initial CEF 3 Linux release
  * Added new methods to the [Browser](Browser) object: `StartDownload()`, `SetMouseCursorChangeDisabled()`, `IsMouseCursorChangeDisabled()`, `WasResized()`, `WasHidden()`, `NotifyScreenInfoChanged()`.
  * This release is sponsored by Cyan Inc.

Version v13 released on 2013-03-14.
  * Introducing python package installer
  * Updated to Chrome 25.0.1364.68, CEF 3 branch 1364 revision `1094`
  * Added function [cefpython](cefpython).`GetModuleDirectory`()
  * Updated [wxPython](wxPython) example to use EVT\_IDLE instead of timer for the message loop work, optionally you can use EVT\_TIMER by defining USE\_EVT\_IDLE as False
  * Following options were removed from [BrowserSettings](BrowserSettings): auto\_detect\_proxy\_settings, encoding\_detector\_enabled, xss\_auditor\_enabled, site\_specific\_quirks\_disabled, hyperlink\_auditing\_disabled, user\_style\_sheet\_enabled, accelerated\_layers\_disabled, accelerated\_video\_disabled, accelerated\_2d\_canvas\_disabled, accelerated\_painting\_enabled, accelerated\_filters\_disabled, accelerated\_plugins\_enabled, fullscreen\_enabled.

Version 0.12 released on 2012-12-14.
  * Changed visual C runtime DLLs to version 9.0.21022.8, the version 9.0.30729.6161 might have caused conflicts, as manifest embedded in python binaries points to version 9.0.21022.8 ([Issue 37](../issues/37)).
  * Removed PyWin32 dependence from the PYD module ([Issue 38](../issues/38)).
  * Changes in [cefpython](cefpython) module: `CreateBrowser()` renamed to `CreateBrowserSync()`, the first param `windowID` changed to WindowInfo class. `GetBrowserByWindowID()` renamed to `GetBrowserByWindowHandle()`.
  * Changes in [Frame](Frame) object: `GetURL()` renamed to `GetUrl()`, `LoadURL()` renamed to `LoadUrl()`.
  * Changes in [Browser](Browser) object: `GetOpenerWindowID()` renamed to `GetOpenerWindowHandle()`. `GetWindowID()` renamed to `GetOuterWindowHandle()`. `GetInnerWindowID()` renamed to `GetWindowHandle()`.

Version 0.11 released on 2012-12-02.
  * Added missing Visual C runtime DLLs, revision eaea8692b298.

Version 0.10 released on 2012-12-02.
  * Initial CEF 3 support, api is currently very limited, javascript bindings are not implemented, neither client handlers, nor developer tools, revision edbe436fb522.