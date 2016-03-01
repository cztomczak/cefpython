[API categories](API-categories.md) | [API index](API-index.md)


# Application settings


Table of contents:
* [Introduction](#introduction)
* [Settings](#settings)
  * [auto_zooming (string)](#auto_zooming-string)
  * [background_color (int)](#background_color-int)
  * [browser_subprocess_path (string)](#browser_subprocess_path-string)
  * [cache_path (string)](#cache_path-string)
  * [command_line_args_disabled (bool)](#command_line_args_disabled-bool)
  * [context_menu (dict)](#context_menu-dict)
  * [downloads_enabled (bool)](#downloads_enabled-bool)
  * [ignore_certificate_errors (bool)](#ignore_certificate_errors-bool)
  * [javascript_flags (string)](#javascript_flags-string)
  * [locale (string)](#locale-string)
  * [locales_dir_path (string)](#locales_dir_path-string)
  * [debug (bool)](#debug-bool)
  * [log_file (string)](#log_file-string)
  * [log_severity (int)](#log_severity-int)
  * [multi_threaded_message_loop (bool)](#multi_threaded_message_loop-bool)
  * [pack_loading_disabled (bool)](#pack_loading_disabled-bool)
  * [persist_session_cookies (bool)](#persist_session_cookies-bool)
  * [product_version (string)](#product_version-string)
  * [release_dcheck_enabled (bool)](#release_dcheck_enabled-bool)
  * [remote_debugging_port (int)](#remote_debugging_port-int)
  * [resources_dir_path (string)](#resources_dir_path-string)
  * [single_process (bool)](#single_process-bool)
  * [string_encoding (string)](#string_encoding-string)
  * [uncaught_exception_stack_size (int)](#uncaught_exception_stack_size-int)
  * [unique_request_context_per_browser (bool)](#unique_request_context_per_browser-bool)
  * [user_agent (string)](#user_agent-string)


## Introduction

These settings can be passed when calling [cefpython](cefpython.md).Initialize() .

The default values of options that are suggested in descriptions may not always be correct, it may be best to set them explicitily.

There are hundreds of options that can be set through CEF/Chromium command line switches. These switches can be set programmatically by passing a dictionary with switches as second argument to [cefpython](cefpython.md).Initialize(). See the [CommandLineSwitches](CommandLineSwitches.md) wiki page for more information.


## Settings


### auto_zooming (string)

Windows only. Perform automatic zooming of browser contents. Example values for auto_zooming (numeric value means a zoom level):

  * "system_dpi" - use system DPI settings, see the [DpiAware](DpiAware.md) wiki page for more details.
  * "0.0" (96 DPI)
  * "1.0" (120 DPI)
  * "2.0" (144 DPI)
  * "-1.0" (72 DPI)
  * "" - if cefpython detects that application is DPI aware it will automatically set `auto_zooming` to "system_dpi". If you do not wish such behavior set `auto_zooming` to an empty string. See the [DpiAware](DpiAware.md) wiki page for more details on that.

Example values that can be set in Win7 DPI settings (Control Panel Appearance and Personalization Display):

  * Smaller 100% (Default) = 96 DPI = 0.0 zoom level
  * Medium 125% = 120 DPI = 1.0 zoom level
  * Larger 150% = 144 DPI = 2.0 zoom level
  * Custom 75% = 72 DPI = -1.0 zoom level


### background_color (int)

Used on Mac OS X to specify the background color for hardware accelerated
content.

32-bit ARGB color value, not premultiplied. The color components are always
in a known order. Equivalent to the `SkColor` type.


### browser_subprocess_path (string)

The path to a separate executable that will be launched for sub-processes.
By default the browser process executable is used. See the comments on
CefExecuteProcess() for details. Also configurable using the --browser-subprocess-path switch.


### cache_path (string)

The location where cache data will be stored on disk. If empty an in-memory
cache will be used for some features and a temporary disk cache for others.
HTML5 databases such as localStorage will only persist across sessions if a
cache path is specified.

CEF flushes cookies or other cache data to disk every 30 seconds, or immediately when [cefpython](cefpython.md).Shutdown() is called.

When this option is not set (empty string), a unique cache directory will be created in the user's temp directory for each run of the application.


### command_line_args_disabled (bool)

Set to true (1) to disable configuration of browser process features using
standard CEF and Chromium [command-line arguments](CommandLineSwitches.md). Configuration can still
be specified using CEF data structures or via the
`CefApp::OnBeforeCommandLineProcessing()` method.


### context_menu (dict)

Configure mouse context menu. All dict values are of type bool and are True by default.

  * `enabled` - whether to enable mouse context menu
  * `navigation` - show the "Back", "Forward" and "Reload" items. The "Reload" option calls [Browser](Browser.md).`ReloadIgnoreCache`.
  * `print` - show the "Print..." item
  * `view_source` - show the "View source" item
  * `external_browser` - show the "Open in external browser" and "Open frame in external browser" options. On Linux the external browser is not focused when opening url.
  * `devtools` - show the "Developer Tools" option. See also ApplicationSettings.`remote_debugging_port`.


### downloads_enabled (bool)

Default: True

Downloads are handled automatically. A default `SaveAs` file dialog provided by OS is displayed. See also the [DownloadHandler](DownloadHandler.md) wiki page.


### ignore_certificate_errors (bool)

Set to true (1) to ignore errors related to invalid SSL certificates.  
Enabling this setting can lead to potential security vulnerabilities like  
"man in the middle" attacks. Applications that load content from the  
internet should not enable this setting. Also configurable using the  
"ignore-certificate-errors" [command-line switch](CommandLineSwitches.md).

Important: the official CEF Python binary releases incorporate a patch that changes the caching behavior on sites with SSL certificate errors when used with this setting. Chromium by default disallows caching of content when there is certificate error. CEF Python applies a patch to Chromium sources to allow for caching even when there is certificate error, but only when the "ignore_certificate_errors" option is set to True. When it's set to False then the Chromium's caching behavior does not change. Enabling caching with certificate errors is useful on local private networks that use self-signed SSL certificates. See the referenced CEF topic in [Issue #125](../issues/125) for more details.


### javascript_flags (string)

Custom flags that will be used when initializing the V8 Javascript engine.  
The consequences of using custom flags may not be well tested. Also  
configurable using the --js-flags switch.


### locale (string)

The locale string that will be passed to Webkit. If empty the default  
locale of "en-US" will be used. This value is ignored on Linux where locale  
is determined using environment variable parsing with the precedence order:  
LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also configurable using the "lang"  
[command-line switch](CommandLineSwitches.md).


### locales_dir_path (string)

The fully qualified path for the locales directory. If this value is empty  
the locales directory must be located in the module directory. This value  
is ignored on Mac OS X where pack files are always loaded from the app  
bundle Resources directory. Also configurable using the "locales-dir-path"  
[command-line switch](CommandLineSwitches.md).


### debug (bool)

Whether cefpython should display debug messages in console and write them to "log_file" (see the next option).

In previous versions of cefpython, this option was set by overwriting module's g_debug global variable, this way of setting is now deprecated.


### log_file (string)

The directory and file name to use for the debug log. If not set, the  
default name of "debug.log" will be used and the file will be written  
to the application directory. Set it to empty string to not use this file.  
Also configurable using the --log-file switch.


### log_severity (int)

The log severity. Only messages of this severity level or higher will be  
logged. Also configurable using the --log-severity switch with  
a value of "verbose", "info", "warning", "error", "error-report" or  
"disable".

Accepted values:

cefpython.`LOGSEVERITY_VERBOSE`  
cefpython.`LOGSEVERITY_INFO`  
cefpython.`LOGSEVERITY_WARNING`  
cefpython.`LOGSEVERITY_ERROR`  
cefpython.`LOGSEVERITY_ERROR_REPORT`  
cefpython.`LOGSEVERITY_DISABLE`  

The default is cefpython.`LOGSEVERITY_INFO`.


### multi_threaded_message_loop (bool)

Set to true (1) to have the browser process message loop run in a separate
thread. If false (0) than the [cefpython](cefpython.md).MessageLoopWork() function must be called from your application message loop.

This option is not and cannot be supported on OS-X for architectural reasons. This option only works on Windows.


### pack_loading_disabled (bool)

Set to true (1) to disable loading of pack files for resources and locales.  
A resource bundle handler must be provided for the browser and render  
processes via `CefApp::GetResourceBundleHandler()` if loading of pack files  
is disabled. Also configurable using the --disable-pack-loading switch.


### persist_session_cookies (bool)

To persist session cookies (cookies without an expiry date or validity  
interval) by default when using the global cookie manager set this value to  
true. Session cookies are generally intended to be transient and most Web  
browsers do not persist them. A |cache_path| value must also be specified to  
enable this feature. Also configurable using the "persist-session-cookies"  
[command-line switch](CommandLineSwitches.md).


### product_version (string)

Value that will be inserted as the product portion of the default  
User-Agent string. If empty the Chromium product version will be used. If  
|userAgent| is specified this value will be ignored. Also configurable  
using the --product-version switch.


### release_dcheck_enabled (bool)

Enable DCHECK in release mode to ease debugging. Also configurable using the  
"enable-release-dcheck" [command-line switch](CommandLineSwitches.md).

Cefpython binaries are available only using release builds.  
Failed DCHECKs will be displayed to the console or logged to a file,  
this may help identify problems in an application. Do not enable it  
in production as it might hurt performance.


### remote_debugging_port (int)

Set to a value between 1024 and 65535 to enable remote debugging on the  
specified port. For example, if 8080 is specified the remote debugging URL  
will be http://127.0.0.1:8080. CEF can be remotely debugged from CEF or  
Chrome browser window. Also configurable using the "remote-debugging-port"  
[command-line switch](CommandLineSwitches.md).

A default value of 0 will generate a random port between 49152–65535. A value of -1 will disable remote debugging.

NOTE: Do not use the --remote-debugging-port command line switch, as it collides with this option.


### resources_dir_path (string)

The fully qualified path for the resources directory. If this value is  
empty the cef.pak and/or devtools_resources.pak files must be located in  
the module directory on Windows/Linux or the app bundle Resources directory  
on Mac OS X. Also configurable using the --resources-dir-path switch.


### single_process (bool)

Set to true (1) to use a single process for the browser and renderer. This  
run mode is not officially supported by Chromium and is less stable than  
the multi-process default. Also configurable using the "single-process"  
[command-line switch](CommandLineSwitches.md).


### string_encoding (string)

What kind of encoding should we use when converting unicode string to bytes string? This conversion is done when you pass a unicode string to javascript.

This encoding is also used when converting bytes to unicode, this includes the post data in the [Request](Request.md) object.

The default is "utf-8".

The behavior for encode/decode errors is to replace the unknown character with "?", this can be changed in the "string_utils.pyx" file through UNICODE_ENCODE_ERRORS/BYTES_DECODE_ERRORS constants.


### uncaught_exception_stack_size (int)

The number of stack trace frames to capture for uncaught exceptions.  
Specify a positive value to enable the [JavascriptContextHandler](JavascriptContextHandler.md).OnUncaughtException()
callback. Specify 0 (default value) and  
OnUncaughtException() will not be called. Also configurable using the  
"uncaught-exception-stack-size" [command-line switch](CommandLineSwitches.md).


### unique_request_context_per_browser (bool)

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


### user_agent (string)

Value that will be returned as the User-Agent HTTP header. If empty the
default User-Agent string will be used. Also configurable using the
"user-agent" [command-line switch](CommandLineSwitches.md).
