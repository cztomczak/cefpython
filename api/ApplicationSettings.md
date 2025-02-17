[API categories](API-categories.md) | [API index](API-index.md)


# Application settings


Table of contents:
* [Introduction](#introduction)
* [Settings](#settings)
  * [app_user_model_id](#app_user_model_id)
  * [auto_zooming](#auto_zooming)
  * [background_color](#background_color)
  * [browser_subprocess_path](#browser_subprocess_path)
  * [cache_path](#cache_path)
  * [command_line_args_disabled](#command_line_args_disabled)
  * [context_menu](#context_menu)
  * [downloads_enabled](#downloads_enabled)
  * [external_message_pump](#external_message_pump)
  * [framework_dir_path](#framework_dir_path)
  * [ignore_certificate_errors](#ignore_certificate_errors)
  * [javascript_flags](#javascript_flags)
  * [locale](#locale)
  * [locales_dir_path](#locales_dir_path)
  * [debug](#debug)
  * [log_file](#log_file)
  * [log_severity](#log_severity)
  * [multi_threaded_message_loop](#multi_threaded_message_loop)
  * [net_security_expiration_enabled](#net_security_expiration_enabled)
  * [pack_loading_disabled](#pack_loading_disabled)
  * [persist_session_cookies](#persist_session_cookies)
  * [persist_user_preferences](#persist_user_preferences)
  * [product_version](#product_version)
  * [remote_debugging_port](#remote_debugging_port)
  * [resources_dir_path](#resources_dir_path)
  * [single_process](#single_process)
  * [string_encoding](#string_encoding)
  * [uncaught_exception_stack_size](#uncaught_exception_stack_size)
  * [unique_request_context_per_browser](#unique_request_context_per_browser)
  * [user_agent](#user_agent)
  * [windowless_rendering_enabled](#windowless_rendering_enabled)


## Introduction

These settings can be passed when calling [cefpython](cefpython.md).Initialize() .

The default values of options that are suggested in descriptions may not always be correct, it may be best to set them explicitily.

There are hundreds of options that can be set through CEF/Chromium command line switches. These switches can be set programmatically by passing a dictionary with switches as second argument to [cefpython](cefpython.md).Initialize(). See the [CommandLineSwitches](CommandLineSwitches.md) wiki page for more information.

Issue #244 is to add even more configurable settings by exposing API
to Chromium Preferences.


## Settings


### app_user_model_id

This is setting is applied only on Windows.
It sets [AppUserModelID](https://msdn.microsoft.com/en-us/library/windows/desktop/dd378459(v=vs.85).aspx)
(also known as AppID) for all processes (Browser, Renderer, GPU, etc.).
Setting this is required on Windows 10 to workaround issues related to
pinning app to Taskbar. More details can be found in [Issue #395](https://github.com/cztomczak/cefpython/issues/395).

Internally this setting will append "--app-user-model-id" switch to
all processes.


### auto_zooming

(string)
Windows only. Perform automatic zooming of browser contents. Example
values for auto_zooming (numeric value means a zoom level):

  * "" - default is empty string
  * "0.0" (96 DPI)
  * "1.0" (120 DPI)
  * "2.0" (144 DPI)
  * "-1.0" (72 DPI)
  * "system_dpi" - Deprecated. Use system DPI settings. This value is
    deprecated, as it is no more required to set auto_zooming to this
    value after High DPI support was enabled.

Example values that can be set in Win7 DPI settings (Control Panel Appearance and Personalization Display):

  * Smaller 100% (Default) = 96 DPI = 0.0 zoom level
  * Medium 125% = 120 DPI = 1.0 zoom level
  * Larger 150% = 144 DPI = 2.0 zoom level
  * Custom 75% = 72 DPI = -1.0 zoom level


### background_color

(int)
Description from upstream CEF:
> Background color used for the browser before a document is loaded and when
> no document color is specified. The alpha component must be either fully
> opaque (0xFF) or fully transparent (0x00). If the alpha component is fully
> opaque then the RGB components will be used as the background color. If the
> alpha component is fully transparent for a windowed browser then the
> default value of opaque white be used. If the alpha component is fully
> transparent for a windowless (off-screen) browser then transparent painting
> will be enabled.

32-bit ARGB color value, not premultiplied. The color components are always
in a known order. Equivalent to the `SkColor` type in Chromium.


### browser_subprocess_path

(string)
The path to a separate executable that will be launched for sub-processes.
If this value is empty on Windows or Linux then the main process executable
will be used. If this value is empty on macOS then a helper executable must
exist at "Contents/Frameworks/<app> Helper.app/Contents/MacOS/<app> Helper"
in the top-level app bundle. See the comments on CefExecuteProcess() for
details. Also configurable using the "browser-subprocess-path" command-line
switch.


### cache_path

(string)
The location where cache data will be stored on disk. If empty then
browsers will be created in "incognito mode" where in-memory caches are
used for storage and no data is persisted to disk. HTML5 databases such as
localStorage will only persist across sessions if a cache path is
specified. Can be overridden for individual CefRequestContext instances via
the CefRequestContextSettings.cache_path value.

CEF flushes cookies or other cache data to disk every 30 seconds,
or immediately when [cefpython](cefpython.md).Shutdown() is called.

When this option is not set (empty string), a unique cache directory
will be created in the user's temp directory for each run of the application.


### command_line_args_disabled

(bool)
Set to true (1) to disable configuration of browser process features using
standard CEF and Chromium [command-line arguments](CommandLineSwitches.md). Configuration can still
be specified using CEF data structures or via the
`CefApp::OnBeforeCommandLineProcessing()` method.


### context_menu

(dict)
Configure mouse context menu. All dict values are of type bool and are True by default.

  * `enabled` - whether to enable mouse context menu
  * `navigation` - show the "Back", "Forward" and "Reload" items. The "Reload" option calls [Browser](Browser.md).`ReloadIgnoreCache`.
  * `print` - show the "Print..." item
  * `view_source` - show the "View source" item
  * `external_browser` - show the "Open in external browser" and "Open frame in external browser" options. On Linux the external browser is not focused when opening url.
  * `devtools` - show the "Developer Tools" option. See also ApplicationSettings.`remote_debugging_port`.


### downloads_enabled

(bool)
Default: True

Downloads are handled automatically. A default `SaveAs` file dialog provided by OS is displayed. See also the [DownloadHandler](DownloadHandler.md) wiki page.


### external_message_pump

(bool)
Default: False

This option is for use on Mac and Linux only. On Windows for best
performance you should use a multi-threaded message loop instead
of calling CefDoMessageLoopWork in a timer.

EXPERIMENTAL (Linux): There are issues with this option on Linux. See
                      [Issue #246](https://github.com/cztomczak/cefpython/issues/246) 
                      for details.

It is recommended to use this option as a replacement for calls to
cefpython.MessageLoopWork(). CEF Python will do these calls automatically
using CEF's OnScheduleMessagePumpWork. This results in improved performance
on Windows and Mac and resolves some bugs with missing keyboard events
on these platforms. See [Issue #246](https://github.com/cztomczak/cefpython/issues/246)
for more details.

IMPORTANT: Currently there are issues on Mac with both message loop work
           and external message pump. In Qt apps calling message loop
           work in a timer doesn't work anymore, you have to use external
           message pump. In wxPython apps it is required to call a message
           loop work in a timer and enable external message pump
           both at the same time (an incorrect approach, but it works).
           This is just a temporary solution and how this affects
           performance was not tested. See [Issue #442](../../../issues/442)
           for more details.

Description from upstream CEF:
> Set to true (1) to control browser process main (UI) thread message pump
> scheduling via the CefBrowserProcessHandler::OnScheduleMessagePumpWork()
> callback. This option is recommended for use in combination with the
> CefDoMessageLoopWork() function in cases where the CEF message loop must be
> integrated into an existing application message loop (see additional
> comments and warnings on CefDoMessageLoopWork). Enabling this option is not
> recommended for most users; leave this option disabled and use either the
> CefRunMessageLoop() function or multi_threaded_message_loop if possible.


### framework_dir_path

The path to the CEF framework directory on macOS. If this value is empty
then the framework must exist at "Contents/Frameworks/Chromium Embedded
Framework.framework" in the top-level app bundle. Also configurable using
the "framework-dir-path" command-line switch.

See also [Issue #304](../../../issues/304).


### javascript_flags

(string)
Custom flags that will be used when initializing the V8 Javascript engine.  
The consequences of using custom flags may not be well tested. Also  
configurable using the --js-flags switch.

To enable WebAssembly support set the `--expose-wasm` flag.


### locale

(string)
The locale string that will be passed to Webkit. If empty the default  
locale of "en-US" will be used. This value is ignored on Linux where locale  
is determined using environment variable parsing with the precedence order:  
LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also configurable using the "lang"  
[command-line switch](CommandLineSwitches.md).


### locales_dir_path

(string)
The fully qualified path for the locales directory. If this value is empty  
the locales directory must be located in the module directory. This value  
is ignored on Mac OS X where pack files are always loaded from the app  
bundle Resources directory. Also configurable using the "locales-dir-path"  
[command-line switch](CommandLineSwitches.md).


### debug

(bool)
Whether cefpython should display debug messages in console and write them to "log_file" (see the next option).

In previous versions of cefpython, this option was set by overwriting module's g_debug global variable, this way of setting is now deprecated.


### log_file

(string)
The directory and file name to use for the debug log. If empty a default
log file name and location will be used. On Windows and Linux a "debug.log"
file will be written in the main executable directory. On Mac OS X a
"~/Library/Logs/<app name>_debug.log" file will be written where <app name>
is the name of the main app executable. Also configurable using the
"log-file" command-line switch.


### log_severity

(int)
The log severity. Only messages of this severity level or higher will be  
logged. Also configurable using the --log-severity switch with  
a value of "verbose", "info", "warning", "error", "error-report" or  
"disable".

Accepted values - constants available in the cefpython module:
* LOGSEVERITY_VERBOSE
* LOGSEVERITY_INFO
* LOGSEVERITY_WARNING
* LOGSEVERITY_ERROR (default)
* LOGSEVERITY_DISABLE


### multi_threaded_message_loop

(bool)
Set to true (1) to have the browser process message loop run in a separate
thread. If false (0) than the [cefpython](cefpython.md).MessageLoopWork()
function must be called from your application message loop. This option is
only supported on Windows.

When this option is set to true, you don't call CEF message loop explicitilly
anymore. Also app's main thread is no more CEF's UI thread, thus many of API
calls will require using cef.[cefpython.md#posttask](PostTask) function to run
code on UI thread. You should also pay attention when reading API docs, as many
handlers/callbacks execute on specific threads, so when this option is On then
your app's code can start executing on different threads.

This option is not and cannot be supported on OS-X for architectural reasons.


### net_security_expiration_enabled

(bool)
Set to true (1) to enable date-based expiration of built in network
security information (i.e. certificate transparency logs, HSTS preloading
and pinning information). Enabling this option improves network security
but may cause HTTPS load failures when using CEF binaries built more than
10 weeks in the past. See https://www.certificate-transparency.org/ and
https://www.chromium.org/hsts for details. Can be set globally using the
CefSettings.enable_net_security_expiration value.



### pack_loading_disabled

(bool)
Set to true (1) to disable loading of pack files for resources and locales.  
A resource bundle handler must be provided for the browser and render  
processes via `CefApp::GetResourceBundleHandler()` if loading of pack files  
is disabled. Also configurable using the --disable-pack-loading switch.


### persist_session_cookies

(bool)
To persist session cookies (cookies without an expiry date or validity  
interval) by default when using the global cookie manager set this value to  
true. Session cookies are generally intended to be transient and most Web  
browsers do not persist them. A |cache_path| value must also be specified to  
enable this feature. Also configurable using the "persist-session-cookies"  
[command-line switch](CommandLineSwitches.md).


### persist_user_preferences

(bool)
To persist user preferences as a JSON file in the cache path directory set
this value to true (1). A |cache_path| value must also be specified
to enable this feature. Also configurable using the
"persist-user-preferences" command-line switch. Can be overridden for
individual CefRequestContext instances via the
CefRequestContextSettings.persist_user_preferences value.


### product_version

(string)
Value that will be inserted as the product portion of the default  
User-Agent string. If empty the Chromium product version will be used. If  
|userAgent| is specified this value will be ignored. Also configurable  
using the --product-version switch.


### remote_debugging_port

(int)
Set to a value between 1024 and 65535 to enable remote debugging on the  
specified port. For example, if 8080 is specified the remote debugging URL  
will be http://127.0.0.1:8080. CEF can be remotely debugged from CEF or  
Chrome browser window. Also configurable using the "remote-debugging-port"  
[command-line switch](CommandLineSwitches.md).

A default value of 0 will generate a random port between 49152–65535. A value of -1 will disable remote debugging.

NOTE: Do not use the --remote-debugging-port command line switch, as it collides with this option.


### resources_dir_path

(string)
The fully qualified path for the resources directory. If this value is  
empty the cef.pak and/or devtools_resources.pak files must be located in  
the module directory on Windows/Linux or the app bundle Resources directory  
on Mac OS X. Also configurable using the --resources-dir-path switch.


### single_process

(bool)
Set to true (1) to use a single process for the browser and renderer. This  
run mode is not officially supported by Chromium and is less stable than  
the multi-process default. Also configurable using the "single-process"  
[command-line switch](CommandLineSwitches.md).


### string_encoding

(string)
What kind of encoding should we use when converting unicode string to bytes string. This conversion is done when you pass a unicode string to javascript.

This encoding is also used when converting bytes to unicode, this includes the post data in the [Request](Request.md) object.

The default is "utf-8".

The behavior for encode/decode errors is to replace the unknown character with "?", this can be changed in the "string_utils.pyx" file through UNICODE_ENCODE_ERRORS/BYTES_DECODE_ERRORS constants.


### uncaught_exception_stack_size

(int)
The number of stack trace frames to capture for uncaught exceptions.  
Specify a positive value to enable the [V8ContextHandler](V8ContextHandler.md).OnUncaughtException()
callback. Specify 0 (default value) and  
OnUncaughtException() will not be called. Also configurable using the  
"uncaught-exception-stack-size" [command-line switch](CommandLineSwitches.md).


### unique_request_context_per_browser

(bool)
A request context provides request handling for a set of related browser  
objects. Browser objects with different  
request contexts will never be hosted in the same render process. Browser  
objects with the same request context may or may not be hosted in the same  
render process depending on the process model. Browser objects created  
indirectly via the JavaScript window.open function or targeted links will  
share the same render process and the same request context as the source  
browser.

To successfully implement separate cookie manager per browser session  
with the use of the RequestHandler.`GetCookieManager` callback, you have to  
set `unique_request_context_per_browser` to True.

In upstream CEF each request context may have separate settings like
cache_path, persist_session_cookies, persist_user_preferences,
ignore_certificate_errors, enable_net_security_expiration,
accept_language_list. Such functionality wasn't yet exposed in CEF Python.


### user_agent

(string)
Value that will be returned as the User-Agent HTTP header. If empty the
default User-Agent string will be used. Also configurable using the
"user-agent" [command-line switch](CommandLineSwitches.md).


### windowless_rendering_enabled

(bool)
Set to true (1) to enable windowless (off-screen) rendering support. Do not
enable this value if the application does not use windowless rendering as
it may reduce rendering performance on some systems.
