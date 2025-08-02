# CEF Python

Table of contents:
* [Introduction](#introduction)
* [Install](#install)
* [Examples](#examples)
* [Support](#support)
* [Support development](#support-development)
* [Seeking sponsors](#seeking-sponsors)
* [API](#api)


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


## Install

Command to install with pip:

```
pip install cefpython3==66.1
```

Hosted at [pypi/cefpython3](https://pypi.python.org/pypi/cefpython3). On Linux pip 8.1+ is required.

You can also download packages for offline installation available on the [GitHub Releases](../../releases) pages.

Below is a table with supported platforms, python versions and architectures.

OS | Py2 | Py3 | 32bit | 64bit | Requirements
--- | --- | --- | --- | --- | ---
Windows | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 / 3.8 / 3.9 | Yes | Yes | Windows 7+ (Note that Python 3.9 supports Windows 8.1+)
Linux | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 | Yes | Yes | Debian 8+, Ubuntu 14.04+,<br> Fedora 24+, openSUSE 13.3+
Mac | 2.7 | 3.4 / 3.5 / 3.6 / 3.7 | No | Yes | MacOS 10.9+


## Examples

- [Tutorial](docs/Tutorial.md)
- [All examples](examples/README-examples.md)
- [Snippets](examples/snippets/README-snippets.md)
- [PyInstaller packager](examples/pyinstaller/README-pyinstaller.md)


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

## Support development

To support general CEF Python development efforts you can make a donation using PayPal button below:

<a href='https://www.paypal.com/donate/?hosted_button_id=V7LU7PD4N4GGG'>
<img src='https://raw.githubusercontent.com/wiki/cztomczak/phpdesktop/donate.gif' />
</a><br>


## Seeking sponsors

CEF Python is seeking companies to sponsor development of this project. Most important
thing would be to have continuous monthly releases with updates to latest Chromium. There is
also lots of cool features and new settings that would be nice to implement. We have not yet
exposed all of upstream CEF APIs. If your company would like to sponsor CEF Python development efforts
then please contact [Czarek](https://www.linkedin.com/in/czarektomczak/). There are no active sponsors
at this moment.


### Previous sponsors

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


## API

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
  * [SendCaptureLostEvent](api/Browser.md#sendcapturelostevent)
  * [SetAccessibilityState](api/Browser.md#setaccessibilitystate)
  * [SetClientCallback](api/Browser.md#setclientcallback)
  * [SetClientHandler](api/Browser.md#setclienthandler)
  * [SetFocus](api/Browser.md#setfocus)
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
  * [application_cache_disabled](api/BrowserSettings.md#application_cache_disabled)
  * [background_color](api/BrowserSettings.md#background_color)
  * [databases_disabled](api/BrowserSettings.md#databases_disabled)
  * [default_encoding](api/BrowserSettings.md#default_encoding)
  * [dom_paste_disabled](api/BrowserSettings.md#dom_paste_disabled)
  * [inherit_client_handlers_for_popups](api/BrowserSettings.md#inherit_client_handlers_for_popups)
  * [image_load_disabled](api/BrowserSettings.md#image_load_disabled)
  * [javascript_disabled](api/BrowserSettings.md#javascript_disabled)
  * [javascript_close_windows_disallowed](api/BrowserSettings.md#javascript_close_windows_disallowed)
  * [javascript_access_clipboard_disallowed](api/BrowserSettings.md#javascript_access_clipboard_disallowed)
  * [local_storage_disabled](api/BrowserSettings.md#local_storage_disabled)
  * [remote_fonts](api/BrowserSettings.md#remote_fonts)
  * [shrink_standalone_images_to_fit](api/BrowserSettings.md#shrink_standalone_images_to_fit)
  * [tab_to_links_disabled](api/BrowserSettings.md#tab_to_links_disabled)
  * [text_area_resize_disabled](api/BrowserSettings.md#text_area_resize_disabled)
  * [user_style_sheet_location](api/BrowserSettings.md#user_style_sheet_location)
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
  * [SetReferrer](api/Request.md#setreferrer)
  * [GetReferrerURL](api/Request.md#getreferrerurl)
  * [GetReferrerPolicy](api/Request.md#getreferrerpolicy)
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
  * [GetAuthCredentials](api/RequestHandler.md#getauthcredentials)
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
