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
* [v49+ Handlers' callbacks and other interfaces](#v49-handlers-callbacks-and-other-interfaces)
* [v49+ High DPI support on Windows](#v49-high-dpi-support-on-windows)
* [v49+ Do not call the 'WindowUtils.OnSize' function](#v49-do-not-call-the-windowutilsonsize-function)
* [v49+ Notify CEF on move or resize events](#v49-notify-cef-on-move-or-resize-events)
* [v49+ Flash support](#v49-flash-support)
* [v49+ Off-screen-rendering: new option "windowless_rendering_enabled"](#v49-off-screen-rendering-new-option-windowless_rendering_enabled)
* [v49+ BrowserSettings options removed](#v49-browsersettings-options-removed)
* [v49+ cef.Request.Flags changed](#v49-cefrequestflags-changed)
* [v49+ Request.GetHeaderMap and SetHeaderMap change](#v49-requestgetheadermap-and-setheadermap-change)
* [v49+ HTTPS cache problems on pages with certificate errors](#v49-https-cache-problems-on-pages-with-certificate-errors)



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


## v49+ Handlers' callbacks and other interfaces

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
In newer CEF Python there is available `DpiAware.Scale` which is more
reliable and can handle all DPI resolutions. You can copy see its
implementation in `src/dpi_aware_win.pyx`.

## v49+ Do not call the 'WindowUtils.OnSize' function

This function can sometimes cause app hanging during window resize.
Call instead the new `WindowUtils`.[UpdateBrowserSize](../api/WindowUtils.md#updatebrowsersize)
function. Except when you use the `pywin32.py` example, in such case
`WindowUtils.OnSize` must be called. See [Issue #464](../../../issues/464)
for details.


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


## v49+ HTTPS cache problems on pages with certificate errors

The fix for HTTPS cache problems on pages with certificate errors
(and that includes self-signed certificates) is no more applied
on Windows.

Soon this will fix also won't be applied on Linux anymore when
cefpython starts using CEF prebuilt binaries from Spotify.

See Issue [#125](../../../issues/125) for more details.
