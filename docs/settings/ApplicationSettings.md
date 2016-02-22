# Application settings #

## Introduction ##

These settings can be passed when calling [cefpython](cefpython).`Initialize()` .

The default values of options that are suggested in descriptions may not always be correct, it may be best to set them explicitily.

There are hundreds of options that can be set through CEF/Chromium command line switches. These switches can be set programmatically by passing a dictionary with switches as second argument to [cefpython](cefpython).Initialize(). See the [CommandLineSwitches](CommandLineSwitches) wiki page for more information.

## Settings ##

### auto\_detect\_proxy\_settings\_enabled (bool) ###

> Available only in CEF 1. This is a Windows-only option.

> Set to True to use the system proxy resolver on Windows when "Automatically detect settings" is checked. This setting is disabled by default for performance reasons.

### auto\_zooming (string) ###

> Windows only. Perform automatic zooming of browser contents. Example values for auto\_zooming (numeric value means a zoom level):

  * "system\_dpi" - use system DPI settings, see the DpiAware wiki page for more details.
  * "0.0" (96 DPI)
  * "1.0" (120 DPI)
  * "2.0" (144 DPI)
  * "-1.0" (72 DPI)
  * "" - if cefpython detects that application is DPI aware it will automatically set `auto_zooming` to "system\_dpi". If you do not wish such behavior set `auto_zooming` to an empty string. See the DpiAware wiki page for more details on that.

> Example values that can be set in Win7 DPI settings (Control Panel > Appearance and Personalization > Display):

  * Smaller 100% (Default) = 96 DPI = 0.0 zoom level
  * Medium 125% = 120 DPI = 1.0 zoom level
  * Larger 150% = 144 DPI = 2.0 zoom level
  * Custom 75% = 72 DPI = -1.0 zoom level

### background\_color (int) ###

> Used on Mac OS X to specify the background color for hardware accelerated
> content.

> 32-bit ARGB color value, not premultiplied. The color components are always
> in a known order. Equivalent to the `SkColor` type.

### browser\_subprocess\_path (string) ###

> Available only in CEF 3.

> The path to a separate executable that will be launched for sub-processes.
> By default the browser process executable is used. See the comments on
> `CefExecuteProcess()` for details. Also configurable using the
> "browser-subprocess-path" [command-line switch](CommandLineSwitches).

### cache\_path (string) ###

> The location where cache data will be stored on disk. If empty an in-memory
> cache will be used for some features and a temporary disk cache for others.
> HTML5 databases such as localStorage will only persist across sessions if a
> cache path is specified.

> CEF flushes cookies or other cache data to disk every 30 seconds, or immediately when [cefpython](cefpython).`Shutdown()` is called.

> When this option is not set (empty string), a unique cache directory will be created in the user's temp directory for each run of the application.

### command\_line\_args\_disabled (bool) ###

> Set to true (1) to disable configuration of browser process features using
> standard CEF and Chromium [command-line arguments](CommandLineSwitches). Configuration can still
> be specified using CEF data structures or via the
> `CefApp::OnBeforeCommandLineProcessing()` method.

### context\_menu (dict) ###

> Configure mouse context menu. All dict values are of type bool and are True by default.

  * `enabled` - whether to enable mouse context menu
  * `navigation` - show the "Back", "Forward" and "Reload" items. The "Reload" option calls [Browser](Browser).`ReloadIgnoreCache`.
  * `print` - show the "Print..." item
  * `view_source` - show the "View source" item
  * `external_browser` - show the "Open in external browser" and "Open frame in external browser" options. On Linux the external browser is not focused when opening url.
  * `devtools` - show the "Developer Tools" option. See also ApplicationSettings.`remote_debugging_port`.

### context\_safety\_implementation (int) ###

> Not yet ported to cefpython.

### downloads\_enabled**= (bool, default True) ###**

> In CEF Python 3 downloads are handled automatically. A default `SaveAs` file dialog provided by OS is displayed. See also the DownloadHandler wiki page.

### list **extra\_plugin\_paths (string) ###**

> Available only in CEF 1. Not yet implemented.

> List of fully qualified paths to plugins (including plugin name) that will be loaded in addition to any plugins found in the default search paths.

### graphics\_implementation (int) ###

> Windows-only option. Available only in CEF 1.

> The graphics implementation that CEF will use for rendering GPU accelerated content like WebGL, accelerated layers and 3D CSS. Possible values:

> `cefpython.ANGLE_IN_PROCESS`<br>
<blockquote><code>cefpython.ANGLE_IN_PROCESS_COMMAND_BUFFER</code><br>
<code>cefpython.DESKTOP_IN_PROCESS</code><br>
<code>cefpython.DESKTOP_IN_PROCESS_COMMAND_BUFFER</code></blockquote>

<h3>ignore_certificate_errors (bool)</h3>

<blockquote>Set to true (1) to ignore errors related to invalid SSL certificates.<br>
Enabling this setting can lead to potential security vulnerabilities like<br>
"man in the middle" attacks. Applications that load content from the<br>
internet should not enable this setting. Also configurable using the<br>
"ignore-certificate-errors" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<blockquote>Important: the official CEF Python binary releases incorporate a patch that changes the caching behavior on sites with SSL certificate errors when used with this setting. Chromium by default disallows caching of content when there is certificate error. CEF Python applies a patch to Chromium sources to allow for caching even when there is certificate error, but only when the "ignore_certificate_errors" option is set to True. When it's set to False then the Chromium's caching behavior does not change. Enabling caching with certificate errors is useful on local private networks that use self-signed SSL certificates. See the referenced CEF topic in <a href='https://code.google.com/p/cefpython/issues/detail?id=125'>Issue 125</a> for more details.</blockquote>

<h3>javascript_flags (string)</h3>

<blockquote>Custom flags that will be used when initializing the V8 Javascript engine.<br>
The consequences of using custom flags may not be well tested. Also<br>
configurable using the "js-flags" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>local_storage_quota (int)</h3>

<blockquote>Available only in CEF 1.</blockquote>

<blockquote>Quota limit for localStorage data across all origins. Default size is 5MB.</blockquote>

<h3>locale (string)</h3>

<blockquote>The locale string that will be passed to Webkit. If empty the default<br>
locale of "en-US" will be used. This value is ignored on Linux where locale<br>
is determined using environment variable parsing with the precedence order:<br>
LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also configurable using the "lang"<br>
<a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>locales_dir_path (string)</h3>

<blockquote>The fully qualified path for the locales directory. If this value is empty<br>
the locales directory must be located in the module directory. This value<br>
is ignored on Mac OS X where pack files are always loaded from the app<br>
bundle Resources directory. Also configurable using the "locales-dir-path"<br>
<a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>debug (bool)</h3>

<blockquote>Whether cefpython should display debug messages in console and write them to "log_file" (see the next option).</blockquote>

<blockquote>In previous versions of cefpython, this option was set by overwriting module's g_debug global variable, this way of setting is now deprecated.</blockquote>

<h3>log_file (string)</h3>

<blockquote>The directory and file name to use for the debug log. If not set, the<br>
default name of "debug.log" will be used and the file will be written<br>
to the application directory. Set it to empty string to not use this file.<br>
Also configurable using the "log-file" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>log_severity (int)</h3>

<blockquote>The log severity. Only messages of this severity level or higher will be<br>
logged. Also configurable using the "log-severity" <a href='CommandLineSwitches'>command-line switch</a> with<br>
a value of "verbose", "info", "warning", "error", "error-report" or<br>
"disable".</blockquote>

<blockquote>Accepted values:</blockquote>

<blockquote>cefpython.<code>LOGSEVERITY_VERBOSE</code><br>
cefpython.<code>LOGSEVERITY_INFO</code><br>
cefpython.<code>LOGSEVERITY_WARNING</code><br>
cefpython.<code>LOGSEVERITY_ERROR</code><br>
cefpython.<code>LOGSEVERITY_ERROR_REPORT</code><br>
cefpython.<code>LOGSEVERITY_DISABLE</code><br></blockquote>

<blockquote>The default is cefpython.<code>LOGSEVERITY_INFO</code>.</blockquote>

<h3>multi_threaded_message_loop (bool)</h3>

<blockquote>Set to true (1) to have the browser process message loop run in a separate<br>
thread. If false (0) than the <a href='cefpython'>cefpython</a>.<code>MessageLoopWork()</code> function must be<br>
called from your application message loop.</blockquote>

<blockquote>This option is not and cannot be supported on OS-X for architectural reasons. This option only works on Windows.</blockquote>

<h3>pack_loading_disabled (bool)</h3>

<blockquote>Set to true (1) to disable loading of pack files for resources and locales.<br>
A resource bundle handler must be provided for the browser and render<br>
processes via <code>CefApp::GetResourceBundleHandler()</code> if loading of pack files<br>
is disabled. Also configurable using the "disable-pack-loading" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>persist_session_cookies (bool)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>To persist session cookies (cookies without an expiry date or validity<br>
interval) by default when using the global cookie manager set this value to<br>
true. Session cookies are generally intended to be transient and most Web<br>
browsers do not persist them. A |cache_path| value must also be specified to<br>
enable this feature. Also configurable using the "persist-session-cookies"<br>
<a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>product_version (string)</h3>

<blockquote>Value that will be inserted as the product portion of the default<br>
User-Agent string. If empty the Chromium product version will be used. If<br>
|userAgent| is specified this value will be ignored. Also configurable<br>
using the "product-version" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>release_dcheck_enabled (bool)</h3>

<blockquote>Enable DCHECK in release mode to ease debugging. Also configurable using the<br>
"enable-release-dcheck" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<blockquote>Cefpython binaries are available only using release builds.<br>
Failed DCHECKs will be displayed to the console or logged to a file,<br>
this may help identify problems in an application. Do not enable it<br>
in production as it might hurt performance.</blockquote>

<h3>remote_debugging_port (int)</h3>

<blockquote>Set to a value between 1024 and 65535 to enable remote debugging on the<br>
specified port. For example, if 8080 is specified the remote debugging URL<br>
will be <a href='http://127.0.0.1:8080'>http://127.0.0.1:8080</a>. CEF can be remotely debugged from CEF or<br>
Chrome browser window. Also configurable using the "remote-debugging-port"<br>
<a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<blockquote>A default value of 0 will generate a random port between 49152–65535. A value of -1 will disable remote debugging.</blockquote>

<blockquote>NOTE: Do not use the --remote-debugging-port command line switch, as it collides with this option.</blockquote>

<h3>resources_dir_path (string)</h3>

<blockquote>The fully qualified path for the resources directory. If this value is<br>
empty the cef.pak and/or devtools_resources.pak files must be located in<br>
the module directory on Windows/Linux or the app bundle Resources directory<br>
on Mac OS X. Also configurable using the "resources-dir-path" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>session_storage_quota (int)</h3>

<blockquote>Available only in CEF 1.</blockquote>

<blockquote>Quota limit for sessionStorage data per namespace. Default size is 5MB.</blockquote>

<h3>single_process (bool)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Set to true (1) to use a single process for the browser and renderer. This<br>
run mode is not officially supported by Chromium and is less stable than<br>
the multi-process default. Also configurable using the "single-process"<br>
<a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>string_encoding (string)</h3>

<blockquote>What kind of encoding should we use when converting unicode string to bytes string? This conversion is done when you pass a unicode string to javascript.</blockquote>

<blockquote>This encoding is also used when converting bytes to unicode, this includes the post data in the <a href='Request'>Request</a> object.</blockquote>

<blockquote>The default is "utf-8".</blockquote>

<blockquote>The behavior for encode/decode errors is to replace the unknown character with "?", this can be changed in the "string_utils.pyx" file through UNICODE_ENCODE_ERRORS/BYTES_DECODE_ERRORS constants.</blockquote>

<h3>uncaught_exception_stack_size (int)</h3>

<blockquote>The number of stack trace frames to capture for uncaught exceptions.<br>
Specify a positive value to enable the <a href='JavascriptContextHandler'>JavascriptContextHandler</a>.<code>OnUncaughtException()</code>
callback. Specify 0 (default value) and<br>
<code>OnUncaughtException()</code> will not be called. Also configurable using the<br>
"uncaught-exception-stack-size" <a href='CommandLineSwitches'>command-line switch</a>.</blockquote>

<h3>unique_request_context_per_browser (bool)</h3>

<blockquote>A request context provides request handling for a set of related browser<br>
objects. Browser objects with different<br>
request contexts will never be hosted in the same render process. Browser<br>
objects with the same request context may or may not be hosted in the same<br>
render process depending on the process model. Browser objects created<br>
indirectly via the JavaScript window.open function or targeted links will<br>
share the same render process and the same request context as the source<br>
browser.</blockquote>

<blockquote>To successfully implement separate cookie manager per browser session<br>
with the use of the RequestHandler.<code>GetCookieManager</code> callback, you have to<br>
set <code>unique_request_context_per_browser</code> to True.</blockquote>

<h3>user_agent (string)</h3>

<blockquote>Value that will be returned as the User-Agent HTTP header. If empty the<br>
default User-Agent string will be used. Also configurable using the<br>
"user-agent" <a href='CommandLineSwitches'>command-line switch</a>.