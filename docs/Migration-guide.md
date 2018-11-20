# Migration guide

This migration guide will get you through to make your code work
with latest CEF Python. This document includes notable changes
that were introduced to cefpython and each topic is prefixed
with version number in which a change was introduced.
This migration guide doesn't cover all changes required for your
software to run smoothly. Some changes depend on the GUI framework
you are using and this guide doesn't cover these. You will have
to go to the examples/ root directory and see the example for your
GUI framework. The new examples are very straightforward and include
many useful comments explaining whys. You will have to get through
its code and see if anything changed that also requires changes
in your application.


Table of contents:
* [v49+ Distribution packages](#v49-distribution-packages)
* [v49+ cefbuilds.com is deprected, use Spotify Automated CEF Builds](#v49-cefbuildscom-is-deprected-use-spotify-automated-cef-builds)
* [v49+ Build instructions and build tools](#v49-build-instructions-and-build-tools)
* [v49: GPU acceleration should be disabled on Windows XP](#v49-gpu-acceleration-should-be-disabled-on-windows-xp)
* [v49 (Win) Handlers' callbacks and other interfaces](#v49-win-handlers-callbacks-and-other-interfaces)
* [v49+ High DPI support on Windows](#v49-high-dpi-support-on-windows)
* [v49 (Win) Do not call the 'WindowUtils.OnSize' function](#v49-win-do-not-call-the-windowutilsonsize-function)
* [v49+ Notify CEF on move or resize events](#v49-notify-cef-on-move-or-resize-events)
* [v49+ Flash support](#v49-flash-support)
* [v49+ Off-screen-rendering: new option "windowless_rendering_enabled"](#v49-off-screen-rendering-new-option-windowless_rendering_enabled)
* [v49+ BrowserSettings options removed](#v49-browsersettings-options-removed)
* [v49+ cef.Request.Flags changed](#v49-cefrequestflags-changed)
* [v49+ Request.GetHeaderMap and SetHeaderMap change](#v49-requestgetheadermap-and-setheadermap-change)
* [v49+ (Win) HTTPS cache problems on pages with certificate errors](#v49-win-https-cache-problems-on-pages-with-certificate-errors)
* [v50+ Importing the cefpython3 package on Linux](#v50-importing-the-cefpython3-package-on-linux)
* [v50+ Install X11 error handlers on Linux](#v50-install-x11-error-handlers-on-linux)
* [v50+ Set window bounds on Linux](#v50-set-window-bounds-on-linux)
* [v50+ Keyboard focus issues on Linux](#v50-keyboard-focus-issues-on-linux)
* [v50+ Windows XP and Vista are no more supported](#v50-windows-xp-and-vista-are-no-more-supported)
* [v50+ Mac 32-bit is no more supported](#v50-mac-32-bit-is-no-more-supported)
* [v51+ Remove LifespanHandler.RunModal](#v51-remove-lifespanhandlerrunmodal)
* [v54+ libcef.so library is stripped from symbols on Linux](#v54-libcefso-library-is-stripped-from-symbols-on-linux)
* [v55.3+ Handlers' callbacks and other interfaces](#v553-handlers-callbacks-and-other-interfaces)
* [v56+ MacOS 10.9+ required to run](#v56-macos-109-required-to-run)
* [v57.1+ High DPI support on Windows](#v571-high-dpi-support-on-windows)
* [v66+ Linux patch that fixed HTTPS cache problems on pages with certificate errors was disabled](#v66-linux-patch-that-fixed-https-cache-problems-on-pages-with-certificate-errors-was-disabled)
* [v66+ DisplayHandler.OnConsoleMessage has a new param 'level'](#v66-displayhandleronconsolemessage-has-a-new-param-level)
* [v66+ LifespanHandler.OnBeforePopup is now called on UI thread](#v66-lifespanhandleronbeforepopup-is-now-called-on-ui-thread)
* [v66+ RequestHandler.OnBeforeBrowse has a new param 'user_gesture'](#v66-requesthandleronbeforebrowse-has-a-new-param-user_gesture)
* [v66+ Window transparency changes](#v66-window-transparency-changes)
* [v66+ BrowserSettings.javascript_open_windows_disallowed option was removed](#v66-browsersettingsjavascript_open_windows_disallowed-option-was-removed)
* [v66+ Threads removed: TID_DB, TID_PROCESS_LAUNCHER, TID_CACHE](#v66-threads-removed-tid_db-tid_process_launcher-tid_cache)
* [v66+ cef.Request.Flags changed](#v66-cefrequestflags-changed)
* [v66+ RequestHandler.GetCookieManager not getting called in some cases](#v66-requesthandlergetcookiemanager-not-getting-called-in-some-cases)
* [v66+ Changes to Mac apps that integrate into existing message loop (Qt, wxPython)](#v66-changes-to-mac-apps-that-integrate-into-existing-message-loop-qt-wxpython)
* [v67+ Do not call the 'WindowUtils.OnSize' function](#v67-do-not-call-the-windowutilsonsize-function)


## v49+ Distribution packages

In latest CEF Python there is only one distribution package
available: a wheel package. Wheel packages are distributed on
[PyPI](https://pypi.python.org/pypi/cefpython3) and you can
install it using the pip tool (8.1+ required on Linux). You
can also download wheel packages from [GitHub Releases](../../../releases).

**Windows**

On Windows many of the distribution packages such as MSI, EXE,
ZIP and InnoSetup files, are no more available. It is too much
hassle to support these.

**Linux debian package**

On Linux the debian package is not supported anymore. Since
pip 8.1+ added support for manylinux1 wheel packages, you can
now easily install cefpython on Linux using the pip tool.
Installing cefpython on Ubuntu using pip should work out of
the box, all OS dependencies on Ubuntu should be satisfied
by default. However since upstream CEF has OS dependencies
that might not be installed by default on other OSes like e.g.
Fedora, and since debian packages allow to list these and install
in an automated manner, it might be reconsidered in the future
to provide debian packages again.


## v49+ cefbuilds.com is deprected, use Spotify Automated CEF Builds

The cefbuilds.com site with CEF prebuilt binaries is now deprecated.
From now on download prebuilt CEF binaries from the Spotify Automated
CEF Builds:

http://opensource.spotify.com/cefbuilds/index.html


## v49+ Build instructions and build tools

There were many changes in regards to building CEF and CEF Python.
There are now new tools in the tools/ root directory that fully
automate building CEF and CEF Python. CEF Python now provides
upstream CEF prebuilt binaries and libraries on GitHub Releases
tagged eg. "v49-upstream". With these binaries you can build
CEF Python from sources in less than 10 minutes. See the new
[Build instructions](Build-instructions.md) document.


## v49: GPU acceleration should be disabled on Windows XP

On XP you should disable GPU acceleration by setting the `--disable-gpu`
and `--disable-gpu-compositing` switches. These switches can
be passed programmatically to `cef.Initialize`, see
[api/Command Line Switches](../api/CommandLineSwitches.md).


## v49 (Win) Handlers' callbacks and other interfaces

In v49.0 release for Windows all handlers'
callbacks and other interfaces such as
CookieVisitor, StringVisitor and WebRequestClient, are now called
using keyword arguments (Issue [#291](../../../issues/291)).
This will cause many of existing code to break. This is how you
should declare callbacks using the new style:

```
def OnLoadStart(self, browser, **_):
	pass

def OnLoadStart(self, **kwargs):
	browser = kwargs["browser"]
```

In the first declaration you see that only one argument is
declared, the browser, the others unused will be in the "_"
variable (the name of the variable is so that PyCharm doesn't
warn about unused variable).

Even if you specify and use all arguments, always add the
unused kwargs (`**_`) at the end:

```
def OnLoadStart(self, browser, frame, **_):
	pass
```

This will be handy in the future, in a case when upstream CEF
adds a new argument to the API, your code won't break. When
an argument is removed in upstream CEF API, if it's possible
CEF Python will try to keep backward compatibility by
emulating behavior of the old argument.

In case of OnLoadStart, when you've used "browser" and "frame"
names for the arguments, your code won't break. However in
many other callbacks, where you've used argument names that
differed from how they were named in API docs, your code will
break. Also argument names were changed from camelCase
to underscores. For example the OnLoadEnd callback has renamed
the `httpStatusCode` argument to `http_code`. So in this case
your code will definitely break, unless you've also used
"http_code" for argument name.


## v49+ High DPI support on Windows

It is recommended to embed a DPI awareness manifest in both the main
process and the subprocesses (the subprocess.exe executable) instead
of calling `DpiAware`.[SetProcessDpiAware](../api/DpiAware.md#setprocessdpiaware)
which sets DPI awareness only for the main process.

The `ApplicationSettings`.[auto_zooming](../api/ApplicationSettings.md#auto_zooming)
option has a default value of an empty string now. Previously the
default was "system_dpi". When enabling High DPI support you should
set it to "system_dpi" explicitilly.

Note that `DpiAware`.[CalculateWindowSize](../api/DpiAware.md#calculatewindowsize)
does not handle all DPI settings (e.g. 132% on Windows 10).
In newer CEF Python there is available `DpiAware`[Scale](../api/DpiAware.md#scale)
which is more reliable and can handle all DPI resolutions. You can copy see
its implementation in `src/dpi_aware_win.pyx`.


## v49 (Win) Do not call the 'WindowUtils.OnSize' function

This function can sometimes cause app hanging during window resize.
Call instead the new `WindowUtils`.[UpdateBrowserSize](../api/WindowUtils.md#updatebrowsersize)
function. Except when you use the `pywin32.py` example, in such case
`WindowUtils.OnSize` must be called.
See [Issue #464](../../../issues/464) for more details.


## v49+ Notify CEF on move or resize events

It is required to notify the browser on move or resize events
so that popup widgets (e.g. \<select\>) are displayed in the correct
location and dismissed when the window moves. Also so that
drag & drop areas are updated accordingly. Call
Browser.[NotifyMoveOrResizeStarted()](../api/Browser.md#notifymoveorresizestarted)
during a move or resize event in your app window.


## v49+ Flash support

See [Issue #235](../../../issues/235) ("Flash support in CEF v49+")
for instructions on how to enable Flash.


## v49+ Off-screen-rendering: new option "windowless_rendering_enabled"

When using off-screen-rendering you must set the ApplicationSettings
"windowless_rendering_enabled" option to True. This applies to
examples such as: Kivy, Panda3D, PySDL2 and screenshot example.

API ref: ApplicationSettings.[windowless_rendering_enabled](../api/ApplicationSettings.md#windowless_rendering_enabled)


## v49+ BrowserSettings options removed

The following options were removed from BrowserSettings:
- user_style_sheet_location
- java_disabled
- accelerated_compositing
- author_and_user_styles_disabled


## v49+ cef.Request.Flags changed

The following flags were removed from cef.Request.Flags:
- AllowCookies
- ReportLoadTiming
- ReportRawHeaders

API ref: Request.[GetFlags](../api/Request.md#getflags)


## v49+ Request.GetHeaderMap and SetHeaderMap change

GetHeaderMap() will not include the Referer value if any
and SetHeaderMap() will ignore the Referer value.

API ref: Request.[GetHeaderMap](../api/Request.md#getheadermap)


## v49+ (Win) HTTPS cache problems on pages with certificate errors

The fix for HTTPS cache problems on pages with certificate errors
(and that includes self-signed certificates) is no more applied
on Windows.

See Issue [#125](../../../issues/125) for more details.


## v50+ Importing the cefpython3 package on Linux

In the past on Linux it was required for the cefpython3 package
to be imported before any other packages due to tcmalloc global
hook being loaded. This is not required anymore, tcmalloc is
disabled by default.


## v50+ Install X11 error handlers on Linux

It is required to install X11 error handlers on Linux, otherwise
you will see 'BadWindow' errors happening - sometimes randomly -
which will cause application to terminate. Since v56+ x11 error
handlers are installed automatically by default during the call
to cef.Initialize(). However sometimes that is not enough like
for example in the wxpython.py example which requires the x11
error handlers to be installed manually after wx was initialized,
and that is because wx initialization had reset x11 error handlers
that were installed earlier during cef initialization (Issue [#334](../../../issues/334)).

You can install X11 error handlers by calling:
```
WindowUtils = cef.WindowUtils()
WindowUtils.InstallX11ErrorHandlers()
```

API ref: WindowUtils.[InstallX11ErrorHandlers()](../api/WindowUtils.md#installx11errorhandlers-linux)


## v50+ Set window bounds on Linux

It is now required to set window bounds during window "resize",
"move" and "configure" events on Linux. You can do so by calling:

```
browser.SetBounds(x, y, width, height)
```

API ref: Browser.[SetBounds()](../api/Browser.md#setbounds)


## v50+ Keyboard focus issues on Linux

There several keyboard focus issues on Linux since CEF library
replaced GTK library with X11 library. Most of these issues are
fixed in examples by calling SetFocus in LoadHandler.OnLoadStart
during initial app loading and/or by calling SetFocus in
FocusHandler.OnGotFocus. This keyboard focus issues need to be
fixed in usptream CEF. For more details see Issue [#284](../../../issues/284).


## v50+ Windows XP and Vista are no more supported

CEF Python v49.0 was the last version to support Windows XP.
This is due to Chromium/CEF dropping XP support, last version
that supported XP was CEF v49.


## v50+ Mac 32-bit is no more supported

CEF Python v31.2 was the last version to support Mac 32-bit.
This is due to CEF/Chromium dropping 32-bit support, last version
that supported 32-bit was CEF v38.


## v51+ Remove LifespanHandler.RunModal

LifespanHandler.RunModal callback is no more available.


## v54+ libcef.so library is stripped from symbols on Linux

Symbols useful for debugging are no more available in libcef.so
shipped with distribution packages on Linux. This is explained
in details in Issue [#262](../../../issues/262).


## v55.3+ Handlers' callbacks and other interfaces

Since v55.3 all handlers' callbacks and other interfaces such as
CookieVisitor, StringVisitor and WebRequestClient, are now called
using keyword arguments (Issue [#291](../../../issues/291)).
This will cause many of existing code to break. This is how you
should declare callbacks using the new style:

```
def OnLoadStart(self, browser, **_):
	pass

def OnLoadStart(self, **kwargs):
	browser = kwargs["browser"]
```

In the first declaration you see that only one argument is
declared, the browser, the others unused will be in the "_"
variable (the name of the variable is so that PyCharm doesn't
warn about unused variable).

Even if you specify and use all arguments, always add the
unused kwargs (`**_`) at the end:

```
def OnLoadStart(self, browser, frame, **_):
	pass
```

This will be handy in the future, in a case when upstream CEF
adds a new argument to the API, your code won't break. When
an argument is removed in upstream CEF API, if it's possible
CEF Python will try to keep backward compatibility by
emulating behavior of the old argument.

In case of OnLoadStart, when you've used "browser" and "frame"
names for the arguments, your code won't break. However in
many other callbacks, where you've used argument names that
differed from how they were named in API docs, your code will
break. Also argument names were changed from camelCase
to underscores. For example the OnLoadEnd callback has renamed
the `httpStatusCode` argument to `http_code`. So in this case
your code will definitely break, unless you've also used
"http_code" for argument name.


## v56+ MacOS 10.9+ required to run

CEF v55 was the last version to support MacOS 10.7.


## v57.1+ High DPI support on Windows

The `cef.DpiAware.SetProcessDpiAware` function is now deprecated.
Use cef.DpiAware.[EnableHighDpiSupport](../api/DpiAware.md#enablehighdpisupport)
function instead.

The ApplicationSettings.[auto_zooming](../api/ApplicationSettings.md#auto_zooming)
option should have its value set to an empty string (a default now)
for High DPI support. In previous versions the default value was
"system_dpi" and if you have set it explicitilly in your application,
then you should change it to an empty string now.


## v66+ Linux patch that fixed HTTPS cache problems on pages with certificate errors was disabled

That patch allowed for HTTPS caching to work when using self-signed
certificates (or any invalid certificate). This doesn't work anymore.
If you need this feature then you can build from sources and apply
the patch yourself. See Issue [#125](../../../issues/125) for more details.


## v66+ DisplayHandler.OnConsoleMessage has a new param 'level'

The DisplayHandler.[OnConsoleMessage](../api/DisplayHandler.md#onconsolemessage)
callback has a new param `level`.


## v66+ LifespanHandler.OnBeforePopup is now called on UI thread

The LifespanHandler.[OnBeforePopup](../api/LifespanHandler.md#onbeforepopup)
callback is now called on UI thread. Previously it was called on
IO thread.


## v66+ RequestHandler.OnBeforeBrowse has a new param 'user_gesture'

The RequestHandler.[OnBeforeBrowse](../api/RequestHandler.md#onbeforebrowse)
callback has a new param `user_gesture`.


## v66+ Window transparency changes

1. OSR windows (off-screen rendering, also known as windowless) are now
transparent by default. You can control its transperency with
ApplicationSettings.[background_color](../api/ApplicationSettings.md#background_color) and BrowserSettings.[background_color](../api/BrowserSettings.md#background_color) options.
The WindowInfo.`SetTransparentPainting` method is now deprecated. Calling
it with True will do nothing, and calling it with False **will result
in exception**.

2. It is now possible to have
transparent windows also in **windowed mode**. This seems to be working
only on Linux (got it working on Fedora with just a change in window setting).


## v66+ BrowserSettings.javascript_open_windows_disallowed option was removed

The BrowserSettings.`javascript_open_windows_disallowed` option was removed
(setting it will do nothing).


## v66+ Threads removed: TID_DB, TID_PROCESS_LAUNCHER, TID_CACHE

These threads and their corresponding constants in the cefpython module
were removed: TID_DB, TID_PROCESS_LAUNCHER, TID_CACHE.

New threads were added, see cefpython.[PostTask](../api/cefpython.md#posttask)
description for a complete list of threads.


## v66+ cef.Request.Flags changed

Flags removed:
- AllowCachedCredentials

Flags added:
- OnlyFromCache
- AllowStoredCredentials
- StopOnRedirect

See a complete list of flags in the description of
cef.Request.[GetFlags](../api/Request.md#getflags) method.


## v66+ RequestHandler.GetCookieManager not getting called in some cases

In some cases the RequestHandler.[GetCookieManager](../api/RequestHandler.md#getcookiemanager)
callback is not getting called due to a race condition.
This bug is to be fixed in Issue [#429](../../../issues/429).


## v66+ Changes to Mac apps that integrate into existing message loop (Qt, wxPython)

These changes are required only on Mac platform.

In Qt apps calling message loop work in a timer doesn't work anymore.
You have to enable external message pump by setting
ApplicationSettings.[external_message_pump](../api/ApplicationSettings.md#external_message_pump)
to `True`. The `qt.py` example was updated to disable calling
message loop work in a timer. External message pump
is a recommended way over calling message loop work in a timer on Mac,
so this should make Qt apps work smoothly.

In wxPython apps you have to implement both approaches for
integrating with existing message loop at the same time:
1. Call `cef.MessageLoopWork` in a 10ms timer
2. Set `ApplicationSettings.external_message_pump` to True

This is not a correct approach and is only a temporary fix for wxPython
apps. More testing is required to check if that resolves all the issues
with message loop freezing. Only basic testing was performed. It was not
tested of how this change affects performance.

See Issue [#442](../../../issues/442) for more details on the issues.


## v67+ Do not call the 'WindowUtils.OnSize' function

This function can sometimes cause app hanging during window resize.
Call instead the new `WindowUtils`.[UpdateBrowserSize](../api/WindowUtils.md#updatebrowsersize)
function. Except when you use the `pywin32.py` example, in such case
`WindowUtils.OnSize` must be called.
See [Issue #464](../../../issues/464) for more details.

