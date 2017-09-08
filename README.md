# CEF Python

Table of contents:
* [Introduction](#introduction)
* [Major sponsors](#major-sponsors)
* [Funding for v61.0 release](#funding-for-v610-release)
* [Install](#install)
* [Tutorial](#tutorial)
* [Examples](#examples)
* [Support](#support)
* [Support development](#support-development)
  * [Thanks](#thanks)
* [Releases](#releases)
* [Other READMEs](#other-readmes)
* [Quick links](#quick-links)


## Introduction

CEF Python is a BSD-licensed open source project founded by [Czarek Tomczak](http://www.linkedin.com/in/czarektomczak)
(hire me!) in 2012 and is based on Google Chromium and the
[CEF Framework](https://bitbucket.org/chromiumembedded/cef)
projects. The Chromium project focuses mainly on Google Chrome application
development, while CEF focuses on facilitating embedded browser use cases
in third-party applications. Lots of applications use CEF control, there are
more than [100 million CEF instances](http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF)
installed around the world. [Examples of embedding](examples/README-examples.md)
Chrome browser are available for many popular GUI toolkits including:
wxPython, PyGTK, PyQt, PySide, Kivy, Panda3D and PyGame/PyOpenGL.

There are many use cases for CEF. You can embed a web browser control
based on Chromium with great HTML 5 support. You can use it to create
a HTML 5 based GUI in an application, this can act as a replacement for
standard GUI toolkits such as wxWidgets, Qt or GTK. In such case to
communicate between Python<>Javascript use [javascript bindings](docs/Tutorial.md#javascript-integration)
or embed an internal web server and talk using http requests. You
can render web content off-screen in applications that use custom
drawing frameworks. You can use it for automated testing of existing
applications. You can use it for web scraping or as a web crawler,
or other kind of internet bots.


## Major sponsors

<a href="http://www.blueplanet.com/">
<img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/cyan.png">
</a>
<br>

<a href="https://clearchat.com/">
<img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/clearchat.png">
</a>
<br>

<a href="http://www.rentouch.ch/">
<img src="https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/rentouch.png">
</a>
<br><br>

See the [Support development](#support-development) section for a list of
all the individuals and companies supporting CEF Python.


## Funding for v61.0 release

For those interested in sponsoring a v61.0 release please see
[Issue #370](../../issues/370).


## Install

You can install [pypi/cefpython3](https://pypi.python.org/pypi/cefpython3)
package using pip tool. On Linux pip 8.1+ is required. You can
also download packages for offline installation available on the
[GitHub Releases](../../releases) pages. Command to install with pip:

```
pip install cefpython3==57.0
```

If you get an error when importing the cefpython3 package on
Windows then see this section in the Knowledge Base document:
[ImportError: DLL load failed (Windows)](docs/Knowledge-Base.md#importerror-dll-load-failed-windows).

## Tutorial

See the [Tutorial.md](docs/Tutorial.md) file.


## Examples

See the [README-examples.md](examples/README-examples.md) file.


## Support

- Ask questions, report problems and issues on the [Forum](https://groups.google.com/group/cefpython)
- Supported examples are listed in the [README.md](examples/README-examples.md) file
- Documentation is in the [docs/](docs) directory:
  - [Build instructions](docs/Build-instructions.md)
  - [Contributing code](docs/Contributing-code.md)
  - [Knowledge Base](docs/Knowledge-Base.md)
  - [Migration guide](docs/Migration-guide.md)
  - [Tutorial](docs/Tutorial.md)
- API reference is in the [api/](api) directory:
  - [API categories](api/API-categories.md#api-categories)
  - [API index](api/API-index.md#api-index)
- Additional documentation is available in [Issues labelled Knowledge Base](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22Knowledge+Base%22)
- To search documentation use GitHub "This repository" search
  at the top. To narrow results to documentation only select
  "Markdown" in the right pane.
- Wiki pages are deprecated and for v31 only


## Support development

If you would like to support general CEF Python development efforts
by making a donation please click the Paypal Donate button:

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=V7LU7PD4N4GGG'>
<img src='https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/donate.gif' />
</a><br><br>

If you would like to see some feature implemented you can make
a comment about that when making a donation. It will give it
a higher priority.

If you are interested in sponsorship opportunities please contact Czarek
directly (linkedin profile or email).

### Thanks

* [2017] Many thanks to [ClearChat Inc.](https://clearchat.com/) for sponsoring
  the v55/v56 releases for all platforms
* [2016-2017] Thanks to JetBrains for providing an Open Source license for
  [PyCharm](https://www.jetbrains.com/pycharm/)
* [2012-2016] Thanks to those who have made a Paypal donation:
  [Rentouch GmbH](http://www.rentouch.ch/), Walter Purvis, Rokas Stupuras,
  Alex Rattray, Greg Kacy, Paul Korzhyk
* [2012-2016] Thanks to those who have donated their time through code contributions,
  they are listed in the [Authors](Authors) file
* [2013-2015] Lots of thanks goes to [Cyan Inc.](http://www.blueplanet.com/)
  for sponsoring this project for a long time, making CEF Python 3 mature
* [2014] Thanks to Adam Duston for donating a Macbook to aid the development
  of Mac port
* [2013] Thanks to [Rentouch GmbH](http://www.rentouch.ch/) for sponsoring the
  development of the off-screen rendering support
* [2013] Thanks to Thomas Wusatiuk for sponsoring the development of the web
  response reading features


## Releases

Information on planned new and current releases, supported platforms,
python versions, architectures and requirements. If you want to
support old operating systems then choose the v31 release.

**Next release**

- To see planned new features or bugs to be fixed in the
  next release, see the
  [next release](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22next+release%22)
  label in the tracker
- To see planned new features or bugs to be fixed in the
  in one of next releases, see the
  [next release 2](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22next+release+2%22)
  label in the tracker

**Latest release**

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | 3.4 / 3.5 / 3.6 | Yes | Yes | Windows 7+
Linux | 2.7 | 3.4 / 3.5 / 3.6 | Yes | Yes | Debian 7+ / Ubuntu 12.04+
Mac | 2.7 | 3.4 / 3.5 / 3.6 | No | Yes | MacOS 10.9+

These platforms are not supported yet:
- ARM - see [Issue #267](../../issues/267)
- Android - see [Issue #307](../../issues/307)

**v31 release**

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | No | Yes | Yes | Windows XP+
Linux | 2.7 | No | Yes | Yes | Debian 7+ / Ubuntu 12.04+
Mac | 2.7 | No | Yes | Yes | MacOS 10.7+

Additional information for v31.2 release:
- On Windows/Mac you can install with command: `pip install cefpython3==31.2`
- Downloads are available on [wiki pages](../../wiki#downloads)
  and on GitHub Releases tagged [v31.2](../../releases/tag/v31.2).
- Documentation is on [wiki pages](../../wiki)
- API reference is available in revision [169a1b2](../../tree/169a1b20d3cd09879070d41aab28cfa195d2a7d5/docs/api)


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
  * [GetJavascriptBindings](api/Browser.md#getjavascriptbindings)
  * [GetMainFrame](api/Browser.md#getmainframe)
  * [GetNSTextInputContext](api/Browser.md#getnstextinputcontext)
  * [GetOpenerWindowHandle](api/Browser.md#getopenerwindowhandle)
  * [GetOuterWindowHandle](api/Browser.md#getouterwindowhandle)
  * [GetUrl](api/Browser.md#geturl)
  * [GetUserData](api/Browser.md#getuserdata)
  * [GetWindowHandle](api/Browser.md#getwindowhandle)
  * [GetIdentifier](api/Browser.md#getidentifier)
  * [GetZoomLevel](api/Browser.md#getzoomlevel)
  * [GoBack](api/Browser.md#goback)
  * [GoForward](api/Browser.md#goforward)
  * [HandleKeyEventAfterTextInputClient](api/Browser.md#handlekeyeventaftertextinputclient)
  * [HandleKeyEventBeforeTextInputClient](api/Browser.md#handlekeyeventbeforetextinputclient)
  * [HasDocument](api/Browser.md#hasdocument)
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
  * [SetBounds](api/Browser.md#setbounds)
  * [SendKeyEvent](api/Browser.md#sendkeyevent)
  * [SendMouseClickEvent](api/Browser.md#sendmouseclickevent)
  * [SendMouseMoveEvent](api/Browser.md#sendmousemoveevent)
  * [SendMouseWheelEvent](api/Browser.md#sendmousewheelevent)
  * [SendFocusEvent](api/Browser.md#sendfocusevent)
  * [SendCaptureLostEvent](api/Browser.md#sendcapturelostevent)
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
  * [image_load_disabled](api/BrowserSettings.md#image_load_disabled)
  * [javascript_disabled](api/BrowserSettings.md#javascript_disabled)
  * [javascript_open_windows_disallowed](api/BrowserSettings.md#javascript_open_windows_disallowed)
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
  * [GetBrowserByWindowHandle](api/cefpython.md#getbrowserbywindowhandle)
  * [GetCommandLineSwitch](api/cefpython.md#getcommandlineswitch)
  * [GetGlobalClientCallback](api/cefpython.md#getglobalclientcallback)
  * [GetModuleDirectory](api/cefpython.md#getmoduledirectory)
  * [GetVersion](api/cefpython.md#getversion)
  * [Initialize](api/cefpython.md#initialize)
  * [IsThread](api/cefpython.md#isthread)
  * [MessageLoop](api/cefpython.md#messageloop)
  * [MessageLoopWork](api/cefpython.md#messageloopwork)
  * [PostTask](api/cefpython.md#posttask)
  * [PostDelayedTask](api/cefpython.md#postdelayedtask)
  * [QuitMessageLoop](api/cefpython.md#quitmessageloop)
  * [SetGlobalClientCallback](api/cefpython.md#setglobalclientcallback)
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
  * [OnTitleChange](api/DisplayHandler.md#ontitlechange)
  * [OnTooltip](api/DisplayHandler.md#ontooltip)
  * [OnStatusMessage](api/DisplayHandler.md#onstatusmessage)
  * [OnConsoleMessage](api/DisplayHandler.md#onconsolemessage)
* [DownloadHandler](api/DownloadHandler.md#downloadhandler)
* [DpiAware (class)](api/DpiAware.md#dpiaware-class)
  * [CalculateWindowSize](api/DpiAware.md#calculatewindowsize)
  * [GetSystemDpi](api/DpiAware.md#getsystemdpi)
  * [IsProcessDpiAware](api/DpiAware.md#isprocessdpiaware)
  * [SetProcessDpiAware](api/DpiAware.md#setprocessdpiaware)
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
  * [OnBeforePopup](api/LifespanHandler.md#onbeforepopup)
  * [_OnAfterCreated](api/LifespanHandler.md#_onaftercreated)
  * [DoClose](api/LifespanHandler.md#doclose)
  * [OnBeforeClose](api/LifespanHandler.md#onbeforeclose)
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
  * [GetString](api/PaintBuffer.md#getstring)
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
  * [OnBeforeBrowse](api/RequestHandler.md#onbeforebrowse)
  * [OnBeforeResourceLoad](api/RequestHandler.md#onbeforeresourceload)
  * [GetResourceHandler](api/RequestHandler.md#getresourcehandler)
  * [OnResourceRedirect](api/RequestHandler.md#onresourceredirect)
  * [OnResourceResponse](api/RequestHandler.md#onresourceresponse)
  * [GetAuthCredentials](api/RequestHandler.md#getauthcredentials)
  * [OnQuotaRequest](api/RequestHandler.md#onquotarequest)
  * [GetCookieManager](api/RequestHandler.md#getcookiemanager)
  * [OnProtocolExecution](api/RequestHandler.md#onprotocolexecution)
  * [_OnBeforePluginLoad](api/RequestHandler.md#_onbeforepluginload)
  * [_OnCertificateError](api/RequestHandler.md#_oncertificateerror)
  * [OnRendererProcessTerminated](api/RequestHandler.md#onrendererprocessterminated)
  * [OnPluginCrashed](api/RequestHandler.md#onplugincrashed)
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
  * [SetTransparentPainting](api/WindowInfo.md#settransparentpainting)
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
