# CEF Python

Table of contents:
* [Introduction](#introduction)
* [Latest releases sponsored by](#latest-releases-sponsored-by)
  * [Thanks to all sponsors](#thanks-to-all-sponsors)
* [Install](#install)
* [Tutorial](#tutorial)
* [Examples](#examples)
* [Support](#support)
* [Releases](#releases)
  * [Next release](#next-release)
  * [Latest release](#latest-release)
  * [v49 release (WinXP/Vista)](#v49-release-winxpvista)
  * [v31 release (old systems)](#v31-release-old-systems)
* [Support development](#support-development)
  * [Thanks to all](#thanks-to-all)
* [Seeking new sponsors](#seeking-new-sponsors)
* [Other READMEs](#other-readmes)
* [Quick links](#quick-links)


## Introduction

CEF Python is an open source project founded by
[Czarek Tomczak](https://www.linkedin.com/in/czarektomczak/)
in 2012 to provide Python bindings for the
[Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef) (CEF).
The Chromium project focuses mainly on Google Chrome application
development while CEF focuses on facilitating embedded browser use cases
in third-party applications. Lots of applications use CEF control, there are
more than [100 million CEF instances](http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF)
installed around the world. There are numerous use cases for CEF:

1. Use it as a modern HTML5 based rendering engine that can act as
   a replacement for classic desktop GUI frameworks. Think of it as Electron
   for Python.
2. Embed a web browser widget in a classic Qt / GTK / wxPython desktop
   application
3. Render web content off-screen in applications that use custom drawing
   frameworks
4. Use it for automated testing of web applications with more advanced
   capabilities than Selenium web browser automation due to CEF low level
   programming APIs
5. Use it for web scraping, as a web crawler or other kind of internet bots

CEF Python also provides examples of embedding CEF for many Python GUI
frameworks such as PyQt, wxPython, PyGTK, PyGObject, Tkinter, Kivy, Panda3D,
PyGame, PyOpenGL, PyWin32, PySide and PySDL2.


## Latest releases sponsored by

<table border="0"><tr>
<td width="50%" valign="top">

<p align="center">
 <a href="https://www.fivestars.com/">
  <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/fivestars360.png">
 </a>
</p>

Thank you to Fivestars for sponsoring the [v66.1 release](../../releases/tag/v66.1)
with Python 3.8 / 3.9 support. Fivestars helps local communities thrive by empowering
small businesses with cutting edge marketing technology. Please visit their website:
<a href="https://www.fivestars.com/">Fivestars.com</a>

</td><td width="50%" valign="top">

<p align="center">
 <a href="https://lampix.com/">
  <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/lampix360.png">
 </a>
</p>

Thank you to Lampix for sponsoring the
[v66 release](../../releases/tag/v66.0). Lampix is the first hardware
and software solution that turns any surface into a smart, augmented reality
or interactive surface. Please visit their website:
<a href="https://lampix.com/">Lampix.com</a>

</tr></table>

### Thanks to all sponsors

<table>
 <tr>
  <td>
   <div align="center">
    <a href="https://www.fivestars.com/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/fivestars200.png">
    </a><br>
    <a href="https://www.fivestars.com/">www.fivestars.com</a>
   </div>
  </td>
  <td>
   <div align="center">
    <a href="https://lampix.com/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/lampix200.png">
    </a><br>
    <a href="https://lampix.com/">www.lampix.com</a>
   </div>
  </td>
  <td>
   <div align="center">
    <a href="http://www.blueplanet.com/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/cyan_new_logo_200x48.png">
    </a><br>
    <a href="http://www.blueplanet.com/">www.blueplanet.com</a>
   </div>
  </td>
 </tr>
 <tr>
  <td>
   <div align="center">
    <a href="https://highside.io/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/highside-onlight-200x48.png">
    </a><br>
    <a href="https://highside.io/">www.highside.io</a>
   <div align="center">
  </td>
  <td>
   <div align="center">
    <a href="http://www.rentouch.ch/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/rentouch.png">
    </a><br>
    <a href="http://www.rentouch.ch/">www.rentouch.ch</a>
   </div>
  </td>
  <td>
   <div align="center">
    <a href="https://www.jetbrains.com/pycharm/">
     <img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/pycharm.png">
    </a><br>
    <a href="https://www.jetbrains.com/pycharm/">www.jetbrains.com</a>
   </div>
  </td>
 <tr>
</table>


## Install

You can install [pypi/cefpython3](https://pypi.python.org/pypi/cefpython3)
package using pip tool. On Linux pip 8.1+ is required. You can
also download packages for offline installation available on the
[GitHub Releases](../../releases) pages. Command to install with pip:

```
pip install cefpython3==66.0
```


## Tutorial

See the [Tutorial.md](docs/Tutorial.md) document.


## Examples

See the [README-examples.md](examples/README-examples.md) and
[README-snippets.md](examples/snippets/README-snippets.md) documents.


## Support

- Ask questions and report problems on the
  [Forum](https://groups.google.com/group/cefpython)
- Supported examples are listed in the
  [README-examples.md](examples/README-examples.md) file
- Documentation is in the [docs/](docs) directory:
  - [Build instructions](docs/Build-instructions.md)
  - [Contributing code](docs/Contributing-code.md)
  - [Knowledge Base](docs/Knowledge-Base.md)
  - [Migration guide](docs/Migration-guide.md)
  - [Tutorial](docs/Tutorial.md)
- API reference is in the [api/](api) directory:
  - [API categories](api/API-categories.md#api-categories)
  - [API index](api/API-index.md#api-index)
- Additional documentation is available in
  [Issues labelled Knowledge Base](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22Knowledge+Base%22)
- To search documentation use GitHub "This repository" search
  at the top. To narrow results to documentation only select
  "Markdown" in the right pane.
- You can vote on issues in the tracker to let us know which issues are
  important to you. To do that add a +1 thumb up reaction to the first post
  in the issue. See
  [Most popular issues](../../issues?q=is%3Aissue+is%3Aopen+sort%3Areactions-%2B1-desc)
  sorted by reactions.


## Releases

Information on planned new and current releases, supported platforms,
python versions, architectures and requirements. If you want to
support old operating systems then choose the v31 release.

### Next release

- To see planned new features or bugs to be fixed in the near future in one of
  next releases, see the
  [next release](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22next+release%22)
  label in the tracker
- To see planned new features or bugs to be fixed in further future, see the
  [next release 2](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22next+release+2%22)
  label in the tracker

### Latest release

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 / 3.8 / 3.9 | Yes | Yes | Windows 7+ (Note that Python 3.9 supports Windows 8.1+)
Linux | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 | Yes | Yes | Debian 8+, Ubuntu 14.04+,<br> Fedora 24+, openSUSE 13.3+
Mac | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 | No | Yes | MacOS 10.9+

These platforms are not supported yet:
- ARM - see [Issue #267](../../issues/267)
- Android - see [Issue #307](../../issues/307)


### v49 release (WinXP/Vista)

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | 3.4 | Yes | Yes | Windows XP+

- Install with command: `pip --no-cache-dir install cefpython3==49.0`.
    - Please note that if you were previously installing cefpython3
      package it is required to use the `--no-cache-dir` flag,
      otherwise pip will end up with error message
      `No matching distribution found for cefpython3==49.0`.
      This happens because 49.0 release occured after 57.0 and 66.0
      releases.
- Downloads are available on GitHub Releases tagged
    [v49.0](../../releases/tag/v49.0).
- See [Migration guide](docs/Migration-guide.md) document for changes
  in this release
- Documentation is available in the [docs/](../../tree/cefpython49-winxp/docs)
  directory in the `cefpython49-winxp` branch
- API reference is available in the [api/](../../tree/cefpython49-winxp/api)
  directory in the `cefpython49-winxp` branch


### v31 release (old systems)

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | No | Yes | Yes | Windows XP+
Linux | 2.7 | No | Yes | Yes | Debian 7+ / Ubuntu 12.04+
Mac | 2.7 | No | Yes | Yes | MacOS 10.7+

Additional information for v31.2 release:
- On Windows/Mac you can install with command: `pip install cefpython3==31.2`
- Downloads are available on the GitHub Releases page tagged
  [v31.2](../../releases/tag/v31.2).
- API reference is available in revision [169a1b2](../../tree/169a1b20d3cd09879070d41aab28cfa195d2a7d5/docs/api)
- Other documentation can be downloaded by cloning the
  cefpython.wiki repository: `git clone git@github.com:cztomczak/cefpython.wiki.git`


## Support development

If you would like to support general CEF Python development efforts
by making a donation then please click the Paypal Donate button below.
If you would like to see a specific feature implemented then you can make
a comment about that when making a donation and that will give it a higher
priority.

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=V7LU7PD4N4GGG'>
<img src='https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/donate.gif' />
</a><br><br>


### Thanks to all

* [2021] Thank you to [Fivestars](https://www.fivestars.com/) for sponsoring
  the v66.1 release with Python 3.8 / 3.9 support
* [2018] Thanks to [Fivestars](https://www.fivestars.com/) for sponsoring
  the v49 release for legacy systems (WinXP/Vista)
* [2018] Many thanks to [Lampix](https://lampix.com/) for sponsoring the v66
  release for all platforms
* [2017] Many thanks to [HighSide Inc.](https://highside.io/) for sponsoring
  the v55/v56 releases for all platforms
* [2016-2018] Thanks to JetBrains for providing an Open Source license for
  [PyCharm](https://www.jetbrains.com/pycharm/)
* [2014] Thanks to Adam Duston for donating a Macbook to aid the development
  of Mac port
* [2013-2015] Lots of thanks goes to [Cyan Inc.](http://www.blueplanet.com/)
  for sponsoring this project for a long time, making CEF Python 3 mature
* [2013] Thanks to [Rentouch GmbH](http://www.rentouch.ch/) for sponsoring the
  development of the off-screen rendering support
* [2013] Thanks to Thomas Wusatiuk for sponsoring the development of the web
  response reading features
* [2012-2018] Thanks to those who have made a Paypal donation:
  [Rentouch GmbH](http://www.rentouch.ch/), Walter Purvis, Rokas Stupuras,
  Alex Rattray, Greg Kacy, Paul Korzhyk, Tomasz Tomanek.
* [2012-2017] Thanks to those who have donated their time through code
  contributions, they are listed in the [Authors](Authors) file


## Seeking new sponsors

CEF Python is seeking companies to sponsor further development of the project.
There are many proposals for new features submitted in the issue tracker. Most
notable are:

* Monthly releases with latest Chromium
* An automated build system similar to upstream CEF Spotify Automated Builds
* ARM and Android support
* Multi-threaded support for increased performance
* Proprietary codecs support in build tools: H264, H265,AC3, EAC3, MPEG-4
* More CEF API exposed, only about 50% is exposed so far
* Hundreds of new settings and Chromium preferences not yet exposed
* Easier integration with popular GUI toolkits in just a few lines of code
  and support for more third party GUI frameworks
* More examples of implementing various advanced features and more snippets
  as well

If your company would like to sponsor CEF Python development efforts then
please contact
[Czarek](https://www.linkedin.com/in/czarektomczak/).
Long term sponsorships are welcome and Czarek is open to ideas about
the project. He would love to spend more time on developing this project,
but he can't afford doing so in his free time. Currently there is no company
supporting this project actively on a daily basis.


## Other READMEs

- [PyInstaller packager](examples/pyinstaller/README-pyinstaller.md)



## Quick links

### Docs

- [Build instructions](docs/Build-instructions.md)
- [Knowledge Base](docs/Knowledge-Base.md)
- [Migration guide](docs/Migration-guide.md)
- [Tutorial](docs/Tutorial.md)


### API categories

#### Modules

 * [cefpython](api/cefpython.md#cefpython) module


#### Settings

 * [ApplicationSettings](api/ApplicationSettings.md#application-settings) dictionary
 * [BrowserSettings](api/BrowserSettings.md#browser-settings) dictionary
 * [CommandLineSwitches](api/CommandLineSwitches.md#command-line-switches) dictionary


#### Classes and objects

 * [Browser](api/Browser.md#browser-object) object
 * [Callback](api/Callback.md#callback-object) object
 * [Cookie](api/Cookie.md#cookie-class) class
 * [CookieManager](api/CookieManager.md#cookiemanager-class) class
 * [DpiAware](api/DpiAware.md#dpiaware-class) class (Win)
 * [DragData](api/DragData.md#dragdata-object) object
 * [Frame](api/Frame.md#frame-object) object
 * [Image](api/Image.md#image-object) object
 * [JavascriptBindings](api/JavascriptBindings.md#javascriptbindings-class) class
 * [JavascriptCallback](api/JavascriptCallback.md#javascriptcallback-object) object
 * [PaintBuffer](api/PaintBuffer.md#paintbuffer-object) object
 * [Request](api/Request.md#request-class) class
 * [Response](api/Response.md#response-object) object
 * [WebPluginInfo](api/WebPluginInfo.md#webplugininfo-object) object
 * [WebRequest](api/WebRequest.md#webrequest-class) class
 * [WindowInfo](api/WindowInfo.md#windowinfo-class) class
 * [WindowUtils](api/WindowUtils.md#windowutils-class) class


#### Client handlers (interfaces)

 * [AccessibilityHandler](api/AccessibilityHandler.md#accessibilityhandler-interface)
 * [DisplayHandler](api/DisplayHandler.md#displayhandler-interface)
 * [DownloadHandler](api/DownloadHandler.md#downloadhandler)
 * [FocusHandler](api/FocusHandler.md#focushandler-interface)
 * [JavascriptDialogHandler](api/JavascriptDialogHandler.md#javascriptdialoghandler-interface)
 * [KeyboardHandler](api/KeyboardHandler.md#keyboardhandler-interface)
 * [LifespanHandler](api/LifespanHandler.md#lifespanhandler-interface)
 * [LoadHandler](api/LoadHandler.md#loadhandler-interface)
 * [RenderHandler](api/RenderHandler.md#renderhandler-interface)
 * [RequestHandler](api/RequestHandler.md#requesthandler-interface)
 * [ResourceHandler](api/ResourceHandler.md#resourcehandler-interface)
 * [V8ContextHandler](api/V8ContextHandler.md#v8contexthandler-interface)


#### Other interfaces

 * [CookieVisitor](api/CookieVisitor.md#cookievisitor-interface) interface
 * [StringVisitor](api/StringVisitor.md#stringvisitor-interface) interface
 * [WebRequestClient](api/WebRequestClient.md#webrequestclient-interface) interface


### API index

* [AccessibilityHandler (interface)](api/AccessibilityHandler.md#accessibilityhandler-interface)
  * [_OnAccessibilityTreeChange](api/AccessibilityHandler.md#_onaccessibilitytreechange)
  * [_OnAccessibilityLocationChange](api/AccessibilityHandler.md#_onaccessibilitylocationchange)
* [Application settings](api/ApplicationSettings.md#application-settings)
  * [accept_language_list](api/ApplicationSettings.md#accept_language_list)
  * [app_user_model_id](api/ApplicationSettings.md#app_user_model_id)
  * [auto_zooming](api/ApplicationSettings.md#auto_zooming)
  * [background_color](api/ApplicationSettings.md#background_color)
  * [browser_subprocess_path](api/ApplicationSettings.md#browser_subprocess_path)
  * [cache_path](api/ApplicationSettings.md#cache_path)
  * [command_line_args_disabled](api/ApplicationSettings.md#command_line_args_disabled)
  * [context_menu](api/ApplicationSettings.md#context_menu)
  * [downloads_enabled](api/ApplicationSettings.md#downloads_enabled)
  * [external_message_pump](api/ApplicationSettings.md#external_message_pump)
  * [framework_dir_path](api/ApplicationSettings.md#framework_dir_path)
  * [ignore_certificate_errors](api/ApplicationSettings.md#ignore_certificate_errors)
  * [javascript_flags](api/ApplicationSettings.md#javascript_flags)
  * [locale](api/ApplicationSettings.md#locale)
  * [locales_dir_path](api/ApplicationSettings.md#locales_dir_path)
  * [debug](api/ApplicationSettings.md#debug)
  * [log_file](api/ApplicationSettings.md#log_file)
  * [log_severity](api/ApplicationSettings.md#log_severity)
  * [multi_threaded_message_loop](api/ApplicationSettings.md#multi_threaded_message_loop)
  * [net_security_expiration_enabled](api/ApplicationSettings.md#net_security_expiration_enabled)
  * [pack_loading_disabled](api/ApplicationSettings.md#pack_loading_disabled)
  * [persist_session_cookies](api/ApplicationSettings.md#persist_session_cookies)
  * [persist_user_preferences](api/ApplicationSettings.md#persist_user_preferences)
  * [product_version](api/ApplicationSettings.md#product_version)
  * [remote_debugging_port](api/ApplicationSettings.md#remote_debugging_port)
  * [resources_dir_path](api/ApplicationSettings.md#resources_dir_path)
  * [single_process](api/ApplicationSettings.md#single_process)
  * [string_encoding](api/ApplicationSettings.md#string_encoding)
  * [uncaught_exception_stack_size](api/ApplicationSettings.md#uncaught_exception_stack_size)
  * [unique_request_context_per_browser](api/ApplicationSettings.md#unique_request_context_per_browser)
  * [user_agent](api/ApplicationSettings.md#user_agent)
  * [user_data_path](api/ApplicationSettings.md#user_data_path)
  * [windowless_rendering_enabled](api/ApplicationSettings.md#windowless_rendering_enabled)
* [Browser (object)](api/Browser.md#browser-object)
  * [AddWordToDictionary](api/Browser.md#addwordtodictionary)
  * [CanGoBack](api/Browser.md#cangoback)
  * [CanGoForward](api/Browser.md#cangoforward)
  * [CloseBrowser](api/Browser.md#closebrowser)
  * [CloseDevTools](api/Browser.md#closedevtools)
  * [DragTargetDragEnter](api/Browser.md#dragtargetdragenter)
  * [DragTargetDragOver](api/Browser.md#dragtargetdragover)
  * [DragTargetDragLeave](api/Browser.md#dragtargetdragleave)
  * [DragTargetDrop](api/Browser.md#dragtargetdrop)
  * [DragSourceEndedAt](api/Browser.md#dragsourceendedat)
  * [DragSourceSystemDragEnded](api/Browser.md#dragsourcesystemdragended)
  * [ExecuteFunction](api/Browser.md#executefunction)
  * [ExecuteJavascript](api/Browser.md#executejavascript)
  * [Find](api/Browser.md#find)
  * [GetClientCallback](api/Browser.md#getclientcallback)
  * [GetClientCallbacksDict](api/Browser.md#getclientcallbacksdict)
  * [GetFocusedFrame](api/Browser.md#getfocusedframe)
  * [GetFrame](api/Browser.md#getframe)
  * [GetFrameByIdentifier](api/Browser.md#getframebyidentifier)
  * [GetFrames](api/Browser.md#getframes)
  * [GetFrameCount](api/Browser.md#getframecount)
  * [GetFrameIdentifiers](api/Browser.md#getframeidentifiers)
  * [GetFrameNames](api/Browser.md#getframenames)
  * [GetImage](api/Browser.md#getimage)
  * [GetJavascriptBindings](api/Browser.md#getjavascriptbindings)
  * [GetMainFrame](api/Browser.md#getmainframe)
  * [GetNSTextInputContext](api/Browser.md#getnstextinputcontext)
  * [GetOpenerWindowHandle](api/Browser.md#getopenerwindowhandle)
  * [GetOuterWindowHandle](api/Browser.md#getouterwindowhandle)
  * [GetSetting](api/Browser.md#getsetting)
  * [GetUrl](api/Browser.md#geturl)
  * [GetUserData](api/Browser.md#getuserdata)
  * [GetWindowHandle](api/Browser.md#getwindowhandle)
  * [GetIdentifier](api/Browser.md#getidentifier)
  * [GetZoomLevel](api/Browser.md#getzoomlevel)
  * [GoBack](api/Browser.md#goback)
  * [GoForward](api/Browser.md#goforward)
  * [HandleKeyEventAfterTextInputClient](api/Browser.md#handlekeyeventaftertextinputclient)
  * [HandleKeyEventBeforeTextInputClient](api/Browser.md#handlekeyeventbeforetextinputclient)
  * [HasDevTools](api/Browser.md#hasdevtools)
  * [HasDocument](api/Browser.md#hasdocument)
  * [Invalidate](api/Browser.md#invalidate)
  * [IsFullscreen](api/Browser.md#isfullscreen)
  * [IsLoading](api/Browser.md#isloading)
  * [IsMouseCursorChangeDisabled](api/Browser.md#ismousecursorchangedisabled)
  * [IsPopup](api/Browser.md#ispopup)
  * [IsWindowRenderingDisabled](api/Browser.md#iswindowrenderingdisabled)
  * [LoadUrl](api/Browser.md#loadurl)
  * [Navigate](api/Browser.md#navigate)
  * [NotifyMoveOrResizeStarted](api/Browser.md#notifymoveorresizestarted)
  * [NotifyScreenInfoChanged](api/Browser.md#notifyscreeninfochanged)
  * [ParentWindowWillClose](api/Browser.md#parentwindowwillclose)
  * [Print](api/Browser.md#print)
  * [Reload](api/Browser.md#reload)
  * [ReloadIgnoreCache](api/Browser.md#reloadignorecache)
  * [ReplaceMisspelling](api/Browser.md#replacemisspelling)
  * [SetAutoResizeEnabled](api/Browser.md#setautoresizeenabled)
  * [SetBounds](api/Browser.md#setbounds)
  * [SendKeyEvent](api/Browser.md#sendkeyevent)
  * [SendMouseClickEvent](api/Browser.md#sendmouseclickevent)
  * [SendMouseMoveEvent](api/Browser.md#sendmousemoveevent)
  * [SendMouseWheelEvent](api/Browser.md#sendmousewheelevent)
  * [SendFocusEvent](api/Browser.md#sendfocusevent)
  * [SendCaptureLostEvent](api/Browser.md#sendcapturelostevent)
  * [SetAccessibilityState](api/Browser.md#setaccessibilitystate)
  * [SetClientCallback](api/Browser.md#setclientcallback)
  * [SetClientHandler](api/Browser.md#setclienthandler)
  * [SetFocus](api/Browser.md#setfocus)
  * [SetMouseCursorChangeDisabled](api/Browser.md#setmousecursorchangedisabled)
  * [SetJavascriptBindings](api/Browser.md#setjavascriptbindings)
  * [SetUserData](api/Browser.md#setuserdata)
  * [SetZoomLevel](api/Browser.md#setzoomlevel)
  * [ShowDevTools](api/Browser.md#showdevtools)
  * [StartDownload](api/Browser.md#startdownload)
  * [StopLoad](api/Browser.md#stopload)
  * [StopFinding](api/Browser.md#stopfinding)
  * [ToggleFullscreen](api/Browser.md#togglefullscreen)
  * [TryCloseBrowser](api/Browser.md#tryclosebrowser)
  * [WasResized](api/Browser.md#wasresized)
  * [WasHidden](api/Browser.md#washidden)
* [Browser settings](api/BrowserSettings.md#browser-settings)
  * [Font settings](api/BrowserSettings.md#font-settings)
  * [accept_language_list](api/BrowserSettings.md#accept_language_list)
  * [application_cache_disabled](api/BrowserSettings.md#application_cache_disabled)
  * [background_color](api/BrowserSettings.md#background_color)
  * [databases_disabled](api/BrowserSettings.md#databases_disabled)
  * [default_encoding](api/BrowserSettings.md#default_encoding)
  * [dom_paste_disabled](api/BrowserSettings.md#dom_paste_disabled)
  * [file_access_from_file_urls_allowed](api/BrowserSettings.md#file_access_from_file_urls_allowed)
  * [inherit_client_handlers_for_popups](api/BrowserSettings.md#inherit_client_handlers_for_popups)
  * [image_load_disabled](api/BrowserSettings.md#image_load_disabled)
  * [javascript_disabled](api/BrowserSettings.md#javascript_disabled)
  * [javascript_close_windows_disallowed](api/BrowserSettings.md#javascript_close_windows_disallowed)
  * [javascript_access_clipboard_disallowed](api/BrowserSettings.md#javascript_access_clipboard_disallowed)
  * [local_storage_disabled](api/BrowserSettings.md#local_storage_disabled)
  * [plugins_disabled](api/BrowserSettings.md#plugins_disabled)
  * [remote_fonts](api/BrowserSettings.md#remote_fonts)
  * [shrink_standalone_images_to_fit](api/BrowserSettings.md#shrink_standalone_images_to_fit)
  * [tab_to_links_disabled](api/BrowserSettings.md#tab_to_links_disabled)
  * [text_area_resize_disabled](api/BrowserSettings.md#text_area_resize_disabled)
  * [universal_access_from_file_urls_allowed](api/BrowserSettings.md#universal_access_from_file_urls_allowed)
  * [user_style_sheet_location](api/BrowserSettings.md#user_style_sheet_location)
  * [web_security_disabled](api/BrowserSettings.md#web_security_disabled)
  * [webgl_disabled](api/BrowserSettings.md#webgl_disabled)
  * [windowless_frame_rate](api/BrowserSettings.md#windowless_frame_rate)
* [Callback (object)](api/Callback.md#callback-object)
  * [Continue](api/Callback.md#continue)
  * [Cancel](api/Callback.md#cancel)
* [cefpython](api/cefpython.md#cefpython)
  * [CreateBrowser](api/cefpython.md#createbrowser)
  * [CreateBrowserSync](api/cefpython.md#createbrowsersync)
  * [ExceptHook](api/cefpython.md#excepthook)
  * [GetAppSetting](api/cefpython.md#getappsetting)
  * [GetAppPath](api/cefpython.md#getapppath)
  * [GetBrowserByIdentifier](api/cefpython.md#getbrowserbyidentifier)
  * [GetBrowserByWindowHandle](api/cefpython.md#getbrowserbywindowhandle)
  * [GetCommandLineSwitch](api/cefpython.md#getcommandlineswitch)
  * [GetDataUrl](api/cefpython.md#getdataurl)
  * [GetGlobalClientCallback](api/cefpython.md#getglobalclientcallback)
  * [GetModuleDirectory](api/cefpython.md#getmoduledirectory)
  * [GetVersion](api/cefpython.md#getversion)
  * [Initialize](api/cefpython.md#initialize)
  * [IsThread](api/cefpython.md#isthread)
  * [LoadCrlSetsFile](api/cefpython.md#loadcrlsetsfile)
  * [MessageLoop](api/cefpython.md#messageloop)
  * [MessageLoopWork](api/cefpython.md#messageloopwork)
  * [PostTask](api/cefpython.md#posttask)
  * [PostDelayedTask](api/cefpython.md#postdelayedtask)
  * [QuitMessageLoop](api/cefpython.md#quitmessageloop)
  * [SetGlobalClientCallback](api/cefpython.md#setglobalclientcallback)
  * [SetGlobalClientHandler](api/cefpython.md#setglobalclienthandler)
  * [SetOsModalLoop](api/cefpython.md#setosmodalloop)
  * [Shutdown](api/cefpython.md#shutdown)
* [Command line switches](api/CommandLineSwitches.md#command-line-switches)
  * [enable-media-stream](api/CommandLineSwitches.md#enable-media-stream)
  * [proxy-server](api/CommandLineSwitches.md#proxy-server)
  * [no-proxy-server](api/CommandLineSwitches.md#no-proxy-server)
  * [disable-gpu](api/CommandLineSwitches.md#disable-gpu)
* [Cookie (class)](api/Cookie.md#cookie-class)
  * [Set](api/Cookie.md#set)
  * [Get](api/Cookie.md#get)
  * [SetName](api/Cookie.md#setname)
  * [GetName](api/Cookie.md#getname)
  * [SetValue](api/Cookie.md#setvalue)
  * [GetValue](api/Cookie.md#getvalue)
  * [SetDomain](api/Cookie.md#setdomain)
  * [GetDomain](api/Cookie.md#getdomain)
  * [SetPath](api/Cookie.md#setpath)
  * [GetPath](api/Cookie.md#getpath)
  * [SetSecure](api/Cookie.md#setsecure)
  * [GetSecure](api/Cookie.md#getsecure)
  * [SetHttpOnly](api/Cookie.md#sethttponly)
  * [GetHttpOnly](api/Cookie.md#gethttponly)
  * [SetCreation](api/Cookie.md#setcreation)
  * [GetCreation](api/Cookie.md#getcreation)
  * [SetLastAccess](api/Cookie.md#setlastaccess)
  * [GetLastAccess](api/Cookie.md#getlastaccess)
  * [SetHasExpires](api/Cookie.md#sethasexpires)
  * [GetHasExpires](api/Cookie.md#gethasexpires)
  * [SetExpires](api/Cookie.md#setexpires)
  * [GetExpires](api/Cookie.md#getexpires)
* [CookieManager (class)](api/CookieManager.md#cookiemanager-class)
  * [GetGlobalManager](api/CookieManager.md#getglobalmanager)
  * [GetBlockingManager](api/CookieManager.md#getblockingmanager)
  * [CreateManager](api/CookieManager.md#createmanager)
  * [SetSupportedSchemes](api/CookieManager.md#setsupportedschemes)
  * [VisitAllCookies](api/CookieManager.md#visitallcookies)
  * [VisitUrlCookies](api/CookieManager.md#visiturlcookies)
  * [SetCookie](api/CookieManager.md#setcookie)
  * [DeleteCookies](api/CookieManager.md#deletecookies)
  * [SetStoragePath](api/CookieManager.md#setstoragepath)
  * [FlushStore](api/CookieManager.md#flushstore)
* [CookieVisitor (interface)](api/CookieVisitor.md#cookievisitor-interface)
  * [Visit](api/CookieVisitor.md#visit)
* [DisplayHandler (interface)](api/DisplayHandler.md#displayhandler-interface)
  * [OnAddressChange](api/DisplayHandler.md#onaddresschange)
  * [OnAutoResize](api/DisplayHandler.md#onautoresize)
  * [OnConsoleMessage](api/DisplayHandler.md#onconsolemessage)
  * [OnLoadingProgressChange](api/DisplayHandler.md#onloadingprogresschange)
  * [OnStatusMessage](api/DisplayHandler.md#onstatusmessage)
  * [OnTitleChange](api/DisplayHandler.md#ontitlechange)
  * [OnTooltip](api/DisplayHandler.md#ontooltip)
* [DownloadHandler](api/DownloadHandler.md#downloadhandler)
* [DpiAware (class)](api/DpiAware.md#dpiaware-class)
  * [CalculateWindowSize](api/DpiAware.md#calculatewindowsize)
  * [EnableHighDpiSupport](api/DpiAware.md#enablehighdpisupport)
  * [GetSystemDpi](api/DpiAware.md#getsystemdpi)
  * [IsProcessDpiAware](api/DpiAware.md#isprocessdpiaware)
  * [SetProcessDpiAware](api/DpiAware.md#setprocessdpiaware)
  * [Scale](api/DpiAware.md#scale)
* [DragData (object)](api/DragData.md#dragdata-object)
  * [IsLink](api/DragData.md#islink)
  * [IsFragment](api/DragData.md#isfragment)
  * [GetLinkUrl](api/DragData.md#getlinkurl)
  * [GetLinkTitle](api/DragData.md#getlinktitle)
  * [GetFragmentText](api/DragData.md#getfragmenttext)
  * [GetFragmentHtml](api/DragData.md#getfragmenthtml)
  * [GetImage](api/DragData.md#getimage)
  * [GetImageHotspot](api/DragData.md#getimagehotspot)
  * [HasImage](api/DragData.md#hasimage)
* [FocusHandler (interface)](api/FocusHandler.md#focushandler-interface)
  * [OnTakeFocus](api/FocusHandler.md#ontakefocus)
  * [OnSetFocus](api/FocusHandler.md#onsetfocus)
  * [OnGotFocus](api/FocusHandler.md#ongotfocus)
* [Frame (object)](api/Frame.md#frame-object)
  * [Copy](api/Frame.md#copy)
  * [Cut](api/Frame.md#cut)
  * [Delete](api/Frame.md#delete)
  * [ExecuteFunction](api/Frame.md#executefunction)
  * [ExecuteJavascript](api/Frame.md#executejavascript)
  * [GetBrowser](api/Frame.md#getbrowser)
  * [GetParent](api/Frame.md#getparent)
  * [GetIdentifier](api/Frame.md#getidentifier)
  * [GetBrowserIdentifier](api/Frame.md#getbrowseridentifier)
  * [GetName](api/Frame.md#getname)
  * [GetParent](api/Frame.md#getparent)
  * [GetSource](api/Frame.md#getsource)
  * [GetText](api/Frame.md#gettext)
  * [GetUrl](api/Frame.md#geturl)
  * [IsFocused](api/Frame.md#isfocused)
  * [IsMain](api/Frame.md#ismain)
  * [IsValid](api/Frame.md#isvalid)
  * [LoadString](api/Frame.md#loadstring)
  * [LoadUrl](api/Frame.md#loadurl)
  * [Paste](api/Frame.md#paste)
  * [Redo](api/Frame.md#redo)
  * [SelectAll](api/Frame.md#selectall)
  * [Undo](api/Frame.md#undo)
  * [ViewSource](api/Frame.md#viewsource)
* [Image (object)](api/Image.md#image-object)
  * [GetAsBitmap](api/Image.md#getasbitmap)
  * [GetAsPng](api/Image.md#getaspng)
  * [GetHeight](api/Image.md#getheight)
  * [GetWidth](api/Image.md#getwidth)
* [JavascriptBindings (class)](api/JavascriptBindings.md#javascriptbindings-class)
  * [\_\_init\_\_](api/JavascriptBindings.md#__init__)
  * [IsValueAllowed](api/JavascriptBindings.md#isvalueallowed)
  * [Rebind](api/JavascriptBindings.md#rebind)
  * [SetFunction](api/JavascriptBindings.md#setfunction)
  * [SetObject](api/JavascriptBindings.md#setobject)
  * [SetProperty](api/JavascriptBindings.md#setproperty)
* [JavascriptCallback (object)](api/JavascriptCallback.md#javascriptcallback-object)
  * [Call](api/JavascriptCallback.md#call)
  * [GetFrame](api/JavascriptCallback.md#getframe)
  * [GetId](api/JavascriptCallback.md#getid)
  * [GetFunctionName](api/JavascriptCallback.md#getfunctionname)
* [JavascriptDialogHandler (interface)](api/JavascriptDialogHandler.md#javascriptdialoghandler-interface)
  * [Continue](api/JavascriptDialogHandler.md#continue)
  * [OnJavascriptDialog](api/JavascriptDialogHandler.md#onjavascriptdialog)
  * [OnBeforeUnloadJavascriptDialog](api/JavascriptDialogHandler.md#onbeforeunloadjavascriptdialog)
  * [OnResetJavascriptDialogState](api/JavascriptDialogHandler.md#onresetjavascriptdialogstate)
  * [OnJavascriptDialogClosed](api/JavascriptDialogHandler.md#onjavascriptdialogclosed)
* [KeyboardHandler (interface)](api/KeyboardHandler.md#keyboardhandler-interface)
  * [OnPreKeyEvent](api/KeyboardHandler.md#onprekeyevent)
  * [OnKeyEvent](api/KeyboardHandler.md#onkeyevent)
* [LifespanHandler (interface)](api/LifespanHandler.md#lifespanhandler-interface)
  * [DoClose](api/LifespanHandler.md#doclose)
  * [_OnAfterCreated](api/LifespanHandler.md#_onaftercreated)
  * [OnBeforeClose](api/LifespanHandler.md#onbeforeclose)
  * [OnBeforePopup](api/LifespanHandler.md#onbeforepopup)
* [LoadHandler (interface)](api/LoadHandler.md#loadhandler-interface)
  * [OnLoadingStateChange](api/LoadHandler.md#onloadingstatechange)
  * [OnLoadStart](api/LoadHandler.md#onloadstart)
  * [OnDomReady](api/LoadHandler.md#ondomready)
  * [OnLoadEnd](api/LoadHandler.md#onloadend)
  * [OnLoadError](api/LoadHandler.md#onloaderror)
* [Network error](api/NetworkError.md#network-error)
  * [ERR_NONE](api/NetworkError.md#err_none)
  * [ERR_ABORTED](api/NetworkError.md#err_aborted)
  * [ERR_ACCESS_DENIED](api/NetworkError.md#err_access_denied)
  * [ERR_ADDRESS_INVALID](api/NetworkError.md#err_address_invalid)
  * [ERR_ADDRESS_UNREACHABLE](api/NetworkError.md#err_address_unreachable)
  * [ERR_CACHE_MISS](api/NetworkError.md#err_cache_miss)
  * [ERR_CERT_AUTHORITY_INVALID](api/NetworkError.md#err_cert_authority_invalid)
  * [ERR_CERT_COMMON_NAME_INVALID](api/NetworkError.md#err_cert_common_name_invalid)
  * [ERR_CERT_CONTAINS_ERRORS](api/NetworkError.md#err_cert_contains_errors)
  * [ERR_CERT_DATE_INVALID](api/NetworkError.md#err_cert_date_invalid)
  * [ERR_CERT_END](api/NetworkError.md#err_cert_end)
  * [ERR_CERT_INVALID](api/NetworkError.md#err_cert_invalid)
  * [ERR_CERT_NO_REVOCATION_MECHANISM](api/NetworkError.md#err_cert_no_revocation_mechanism)
  * [ERR_CERT_REVOKED](api/NetworkError.md#err_cert_revoked)
  * [ERR_CERT_UNABLE_TO_CHECK_REVOCATION](api/NetworkError.md#err_cert_unable_to_check_revocation)
  * [ERR_CONNECTION_ABORTED](api/NetworkError.md#err_connection_aborted)
  * [ERR_CONNECTION_CLOSED](api/NetworkError.md#err_connection_closed)
  * [ERR_CONNECTION_FAILED](api/NetworkError.md#err_connection_failed)
  * [ERR_CONNECTION_REFUSED](api/NetworkError.md#err_connection_refused)
  * [ERR_CONNECTION_RESET](api/NetworkError.md#err_connection_reset)
  * [ERR_DISALLOWED_URL_SCHEME](api/NetworkError.md#err_disallowed_url_scheme)
  * [ERR_EMPTY_RESPONSE](api/NetworkError.md#err_empty_response)
  * [ERR_FAILED](api/NetworkError.md#err_failed)
  * [ERR_FILE_NOT_FOUND](api/NetworkError.md#err_file_not_found)
  * [ERR_FILE_TOO_BIG](api/NetworkError.md#err_file_too_big)
  * [ERR_INSECURE_RESPONSE](api/NetworkError.md#err_insecure_response)
  * [ERR_INTERNET_DISCONNECTED](api/NetworkError.md#err_internet_disconnected)
  * [ERR_INVALID_ARGUMENT](api/NetworkError.md#err_invalid_argument)
  * [ERR_INVALID_CHUNKED_ENCODING](api/NetworkError.md#err_invalid_chunked_encoding)
  * [ERR_INVALID_HANDLE](api/NetworkError.md#err_invalid_handle)
  * [ERR_INVALID_RESPONSE](api/NetworkError.md#err_invalid_response)
  * [ERR_INVALID_URL](api/NetworkError.md#err_invalid_url)
  * [ERR_METHOD_NOT_SUPPORTED](api/NetworkError.md#err_method_not_supported)
  * [ERR_NAME_NOT_RESOLVED](api/NetworkError.md#err_name_not_resolved)
  * [ERR_NO_SSL_VERSIONS_ENABLED](api/NetworkError.md#err_no_ssl_versions_enabled)
  * [ERR_NOT_IMPLEMENTED](api/NetworkError.md#err_not_implemented)
  * [ERR_RESPONSE_HEADERS_TOO_BIG](api/NetworkError.md#err_response_headers_too_big)
  * [ERR_SSL_CLIENT_AUTH_CERT_NEEDED](api/NetworkError.md#err_ssl_client_auth_cert_needed)
  * [ERR_SSL_PROTOCOL_ERROR](api/NetworkError.md#err_ssl_protocol_error)
  * [ERR_SSL_RENEGOTIATION_REQUESTED](api/NetworkError.md#err_ssl_renegotiation_requested)
  * [ERR_SSL_VERSION_OR_CIPHER_MISMATCH](api/NetworkError.md#err_ssl_version_or_cipher_mismatch)
  * [ERR_TIMED_OUT](api/NetworkError.md#err_timed_out)
  * [ERR_TOO_MANY_REDIRECTS](api/NetworkError.md#err_too_many_redirects)
  * [ERR_TUNNEL_CONNECTION_FAILED](api/NetworkError.md#err_tunnel_connection_failed)
  * [ERR_UNEXPECTED](api/NetworkError.md#err_unexpected)
  * [ERR_UNEXPECTED_PROXY_AUTH](api/NetworkError.md#err_unexpected_proxy_auth)
  * [ERR_UNKNOWN_URL_SCHEME](api/NetworkError.md#err_unknown_url_scheme)
  * [ERR_UNSAFE_PORT](api/NetworkError.md#err_unsafe_port)
  * [ERR_UNSAFE_REDIRECT](api/NetworkError.md#err_unsafe_redirect)
* [PaintBuffer (object)](api/PaintBuffer.md#paintbuffer-object)
  * [GetIntPointer](api/PaintBuffer.md#getintpointer)
  * [GetBytes](api/PaintBuffer.md#getbytes)
* [RenderHandler (interface)](api/RenderHandler.md#renderhandler-interface)
  * [GetRootScreenRect](api/RenderHandler.md#getrootscreenrect)
  * [GetViewRect](api/RenderHandler.md#getviewrect)
  * [GetScreenRect](api/RenderHandler.md#getscreenrect)
  * [GetScreenPoint](api/RenderHandler.md#getscreenpoint)
  * [OnPopupShow](api/RenderHandler.md#onpopupshow)
  * [OnPopupSize](api/RenderHandler.md#onpopupsize)
  * [OnPaint](api/RenderHandler.md#onpaint)
  * [OnCursorChange](api/RenderHandler.md#oncursorchange)
  * [OnScrollOffsetChanged](api/RenderHandler.md#onscrolloffsetchanged)
  * [OnTextSelectionChanged](api/RenderHandler.md#ontextselectionchanged)
  * [StartDragging](api/RenderHandler.md#startdragging)
  * [UpdateDragCursor](api/RenderHandler.md#updatedragcursor)
* [Request (class)](api/Request.md#request-class)
  * [CreateRequest](api/Request.md#createrequest)
  * [IsReadOnly](api/Request.md#isreadonly)
  * [GetUrl](api/Request.md#geturl)
  * [SetUrl](api/Request.md#seturl)
  * [GetMethod](api/Request.md#getmethod)
  * [SetMethod](api/Request.md#setmethod)
  * [GetPostData](api/Request.md#getpostdata)
  * [SetPostData](api/Request.md#setpostdata)
  * [GetHeaderMap](api/Request.md#getheadermap)
  * [GetHeaderMultimap](api/Request.md#getheadermultimap)
  * [SetHeaderMap](api/Request.md#setheadermap)
  * [SetHeaderMultimap](api/Request.md#setheadermultimap)
  * [GetFlags](api/Request.md#getflags)
  * [SetFlags](api/Request.md#setflags)
  * [GetFirstPartyForCookies](api/Request.md#getfirstpartyforcookies)
  * [SetFirstPartyForCookies](api/Request.md#setfirstpartyforcookies)
  * [GetResourceType](api/Request.md#getresourcetype)
  * [GetTransitionType](api/Request.md#gettransitiontype)
* [RequestHandler (interface)](api/RequestHandler.md#requesthandler-interface)
  * [CanGetCookies](api/RequestHandler.md#cangetcookies)
  * [CanSetCookie](api/RequestHandler.md#cansetcookie)
  * [GetAuthCredentials](api/RequestHandler.md#getauthcredentials)
  * [GetCookieManager](api/RequestHandler.md#getcookiemanager)
  * [GetResourceHandler](api/RequestHandler.md#getresourcehandler)
  * [OnBeforeBrowse](api/RequestHandler.md#onbeforebrowse)
  * [_OnBeforePluginLoad](api/RequestHandler.md#_onbeforepluginload)
  * [OnBeforeResourceLoad](api/RequestHandler.md#onbeforeresourceload)
  * [_OnCertificateError](api/RequestHandler.md#_oncertificateerror)
  * [OnQuotaRequest](api/RequestHandler.md#onquotarequest)
  * [OnResourceRedirect](api/RequestHandler.md#onresourceredirect)
  * [OnResourceResponse](api/RequestHandler.md#onresourceresponse)
  * [OnPluginCrashed](api/RequestHandler.md#onplugincrashed)
  * [OnProtocolExecution](api/RequestHandler.md#onprotocolexecution)
  * [OnRendererProcessTerminated](api/RequestHandler.md#onrendererprocessterminated)
* [ResourceHandler (interface)](api/ResourceHandler.md#resourcehandler-interface)
  * [ProcessRequest](api/ResourceHandler.md#processrequest)
  * [GetResponseHeaders](api/ResourceHandler.md#getresponseheaders)
  * [ReadResponse](api/ResourceHandler.md#readresponse)
  * [CanGetCookie](api/ResourceHandler.md#cangetcookie)
  * [CanSetCookie](api/ResourceHandler.md#cansetcookie)
  * [Cancel](api/ResourceHandler.md#cancel)
* [Response (object)](api/Response.md#response-object)
  * [IsReadOnly](api/Response.md#isreadonly)
  * [GetStatus](api/Response.md#getstatus)
  * [SetStatus](api/Response.md#setstatus)
  * [GetStatusText](api/Response.md#getstatustext)
  * [SetStatusText](api/Response.md#setstatustext)
  * [GetMimeType](api/Response.md#getmimetype)
  * [SetMimeType](api/Response.md#setmimetype)
  * [GetHeader](api/Response.md#getheader)
  * [GetHeaderMap](api/Response.md#getheadermap)
  * [GetHeaderMultimap](api/Response.md#getheadermultimap)
  * [SetHeaderMap](api/Response.md#setheadermap)
  * [SetHeaderMultimap](api/Response.md#setheadermultimap)
* [StringVisitor (interface)](api/StringVisitor.md#stringvisitor-interface)
  * [Visit](api/StringVisitor.md#visit)
* [V8ContextHandler (interface)](api/V8ContextHandler.md#v8contexthandler-interface)
  * [OnContextCreated](api/V8ContextHandler.md#oncontextcreated)
  * [OnContextReleased](api/V8ContextHandler.md#oncontextreleased)
* [Virtual Key codes](api/VirtualKey.md#virtual-key-codes)
* [WebPluginInfo (object)](api/WebPluginInfo.md#webplugininfo-object)
  * [GetName](api/WebPluginInfo.md#getname)
  * [GetPath](api/WebPluginInfo.md#getpath)
  * [GetVersion](api/WebPluginInfo.md#getversion)
  * [GetDescription](api/WebPluginInfo.md#getdescription)
* [WebRequest (class)](api/WebRequest.md#webrequest-class)
  * [Create](api/WebRequest.md#create)
  * [GetRequest](api/WebRequest.md#getrequest)
  * [GetRequestStatus](api/WebRequest.md#getrequeststatus)
  * [GetRequestError](api/WebRequest.md#getrequesterror)
  * [GetResponse](api/WebRequest.md#getresponse)
  * [Cancel](api/WebRequest.md#cancel)
* [WebRequestClient (interface)](api/WebRequestClient.md#webrequestclient-interface)
  * [OnUploadProgress](api/WebRequestClient.md#onuploadprogress)
  * [OnDownloadProgress](api/WebRequestClient.md#ondownloadprogress)
  * [OnDownloadData](api/WebRequestClient.md#ondownloaddata)
  * [OnRequestComplete](api/WebRequestClient.md#onrequestcomplete)
* [WindowInfo (class)](api/WindowInfo.md#windowinfo-class)
  * [SetAsChild](api/WindowInfo.md#setaschild)
  * [SetAsPopup](api/WindowInfo.md#setaspopup)
  * [SetAsOffscreen](api/WindowInfo.md#setasoffscreen)
* [WindowUtils (class)](api/WindowUtils.md#windowutils-class)
  * [OnSetFocus ](api/WindowUtils.md#onsetfocus-win)
  * [OnSize ](api/WindowUtils.md#onsize-win)
  * [OnEraseBackground ](api/WindowUtils.md#onerasebackground-win)
  * [SetTitle ](api/WindowUtils.md#settitle-win)
  * [SetIcon ](api/WindowUtils.md#seticon-win)
  * [GetParentHandle](api/WindowUtils.md#getparenthandle)
  * [IsWindowHandle](api/WindowUtils.md#iswindowhandle)
  * [gtk_plug_new ](api/WindowUtils.md#gtk_plug_new-linux)
  * [gtk_widget_show ](api/WindowUtils.md#gtk_widget_show-linux)
  * [InstallX11ErrorHandlers ](api/WindowUtils.md#installx11errorhandlers-linux)
