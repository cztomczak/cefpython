[API categories](API-categories.md) | [API index](API-index.md)


# cefpython

Functions in the cefpython module.


Table of contents:
* [Functions](#functions)
  * [CreateBrowser](#createbrowser)
  * [CreateBrowserSync](#createbrowsersync)
  * [ExceptHook](#excepthook)
  * [GetAppSetting](#getappsetting)
  * [GetAppPath](#getapppath)
  * [GetBrowserByIdentifier](#getbrowserbyidentifier)
  * [GetBrowserByWindowHandle](#getbrowserbywindowhandle)
  * [GetCommandLineSwitch](#getcommandlineswitch)
  * [GetDataUrl](#getdataurl)
  * [GetGlobalClientCallback](#getglobalclientcallback)
  * [GetModuleDirectory](#getmoduledirectory)
  * [GetVersion](#getversion)
  * [Initialize](#initialize)
  * [IsThread](#isthread)
  * [LoadCrlSetsFile](#loadcrlsetsfile)
  * [MessageLoop](#messageloop)
  * [MessageLoopWork](#messageloopwork)
  * [PostTask](#posttask)
  * [PostDelayedTask](#postdelayedtask)
  * [QuitMessageLoop](#quitmessageloop)
  * [SetGlobalClientCallback](#setglobalclientcallback)
  * [SetGlobalClientHandler](#setglobalclienthandler)
  * [SetOsModalLoop](#setosmodalloop)
  * [Shutdown](#shutdown)


## Functions


### CreateBrowser

Not yet implemented - currently this method just calls [CreateBrowserSync](#createbrowsersync).
In upstream CEF this method creates browser asynchronously. Currently
CEF Python depends on browser being created synchronously in a few parts
of code.


### CreateBrowserSync

| Parameter | Type |
| --- | --- |
| window_info | [WindowInfo](WindowInfo.md) |
| [settings](BrowserSettings.md) | [BrowserSettings](BrowserSettings.md) |
| url | string |
| window_title | string |
| __Return__ | [Browser](Browser.md) |

All parameters are optional.

This function can only be called on the UI thread.

If the url is a local path it needs to start with the `file://` prefix.
If the url contains special characters it may need proper handling.
Starting with v66.1+ it is required for the app code to encode the url
properly. You can use the `pathlib.PurePath.as_uri` in Python 3
or `urllib.pathname2url` in Python 2 (`urllib.request.pathname2url`
in Python 3) depending on your case.

The "window_title" parameter will be used only when parent
window provided in window_info was set to 0. This is for use
with hello_world.py and tutorial.py examples which don't use
any third party GUI framework for creation of top-level window.

After the call to CreateBrowserSync() the page is not yet loaded,
if you want your next lines of code to do some stuff on the
webpage you will have to implement
LoadHandler.[OnLoadingStateChange](LoadHandler.md#onloadingstatechange)
callback.


### ExceptHook

| Parameter | Type |
| --- | --- |
| exc_type | - |
| exc_value | - |
| exc_trace | - |
| __Return__ | void |

Global except hook to exit app cleanly on error. CEF has a multiprocess
architecture and when exiting you need to close all processes (main Browser
process, Renderer process, GPU process, etc.) by calling Shutdown().
This hook does the following: in case of exception write it to
the "error.log" file, display it to the console, shutdown CEF
and exit application immediately by ignoring "finally" (_exit()).

See also Tutorial: [Handling Python exceptions](../docs/Tutorial.md#handling-python-exceptions).


### GetAppSetting

| Parameter | Type |
| --- | --- |
| key | string |
| __Return__ | object |

Returns [ApplicationSettings](ApplicationSettings.md) option that was passed
to Initialize(). Returns None if key is not found.


### GetAppPath

| | |
| --- | --- |
| file_ (optional) | string |
| __Return__ | string |

Get path to where application resides.


### GetBrowserByIdentifier

| Parameter | Type |
| --- | --- |
| identifier | int |
| __Return__ | void |

Get browser by identifier. Browser identifier can be obtained by
calling `Browser.GetIdentifier`.


### GetBrowserByWindowHandle

| Parameter | Type |
| --- | --- |
| windowHandle | long |
| __Return__ | void |

Get browser by outer or inner window handle. An outer window handle is the one that was passed to CreateBrowserSync(). An inner window handle is a CEF internal window handle.


### GetCommandLineSwitch

| Parameter | Type |
| --- | --- |
| key | string |
| __Return__ | object |

Returns the [CommandLineSwitches](CommandLineSwitches.md) switch that was passed to Initialize(). Returns None if key is not found.


### GetDataUrl

| Parameter | Type |
| --- | --- |
| data | string |
| mediatype="html" (optional) | string |
| __Return__ | object |

Convert data to a Data URL. Only "html" media type is currently supported.

See:
https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs


### GetGlobalClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | object |

Returns a global client callback that was set using SetGlobalClientCallback()
or SetGlobalClientHandler. Returns None if callback was not set.


### GetModuleDirectory

| | |
| --- | --- |
| __Return__ | string |

Get the cefpython module directory. This method is useful to get full path to CEF binaries. This is required when setting [ApplicationSettings](ApplicationSettings.md) options like: 'browser_subprocess_path', 'resources_dir_pat' and 'locales_dir_path'.


### GetVersion

| | |
| --- | --- |
| __Return__ | dict |

Return CEF Python and CEF versions dictionary with keys:
* version
* chrome_version
* cef_version
* cef_api_hash_platform
* cef_api_hash_universal
* cef_commit_hash
* cef_commit_number


### Initialize

| Parameter | Type |
| --- | --- |
| settings (optional) | [ApplicationSettings](ApplicationSettings.md) |
| switches (optional) | [CommandLineSwitches](CommandLineSwitches.md) |
| __Return__ | bool |

This function should be called on the main application thread (UI thread) to initialize CEF when the application is started. A call to Initialize() must have a corresponding call to Shutdown() so that CEF exits cleanly. Otherwise when application closes data (eg. storage, cookies) might not be saved to disk or the process might freeze (experienced on Windows XP).


### IsThread

| Parameter | Type |
| --- | --- |
| threadID | int |
| __Return__ | bool |

Returns true if called on the specified thread.

CEF maintains multiple internal threads that are used for handling different types of tasks. The UI thread creates the browser window and is used for all interaction with the webkit rendering engine and V8 Javascript engine. The UI thread will be the same as the main application thread if CefInitialize() is called with an [ApplicationSettings](ApplicationSettings.md) 'multi_threaded_message_loop' option set to false. The IO thread is used for handling schema and network requests. The FILE thread is used for the application cache and other miscellaneous activities.

See PostTask() for a list of threads.


### LoadCrlSetsFile

| Parameter | Type |
| --- | --- |
| path | bytes |
| __Return__ | bool |

Description from upstream CEF:
> Loads the existing "Certificate Revocation Lists" file that is managed by
> Google Chrome. This file can generally be found in Chrome's User Data
> directory (e.g. "C:\Users\[User]\AppData\Local\Google\Chrome\User Data\" on
> Windows) and is updated periodically by Chrome's component updater service.
> Must be called in the browser process after the context has been initialized.
> See https://dev.chromium.org/Home/chromium-security/crlsets for background.


### MessageLoop

| | |
| --- | --- |
| __Return__ | void |

Run the CEF message loop. Use this function instead of an application-
provided message loop to get the best balance between performance and
CPU usage. This function should only be called on the main application
thread (UI thread) and only if cefpython.Initialize() is called with a
[ApplicationSettings](ApplicationSettings.md).multi_threaded_message_loop
value of false. This function will block until a quit message is received
by the system.

See also MessageLoopWork().


### MessageLoopWork

| | |
| --- | --- |
| __Return__ | void |

Call this function in a periodic timer (eg. 10ms).

Description from upstream CEF:
> Perform a single iteration of CEF message loop processing. This function is
> provided for cases where the CEF message loop must be integrated into an
> existing application message loop. Use of this function is not recommended
> for most users; use either the CefRunMessageLoop() function or
> CefSettings.multi_threaded_message_loop if possible. When using this function
> care must be taken to balance performance against excessive CPU usage. It is
> recommended to enable the CefSettings.external_message_pump option when using
> this function so that CefBrowserProcessHandler::OnScheduleMessagePumpWork()
> callbacks can facilitate the scheduling process. This function should only be
> called on the main application thread and only if CefInitialize() is called
> with a CefSettings.multi_threaded_message_loop value of false. This function
> will not block.


### PostTask

| Parameter | Type |
| --- | --- |
| thread | int |
| func | object |
| [args..] | mixed |
| __Return__ | void |

Post a task for execution on the thread associated with this task runner. Execution will occur asynchronously. Only Browser process threads are allowed.

List of threads in the Browser process:
* cef.TID_UI: The main thread in the browser. This will be the same as the main application thread if cefpython.Initialize() is called with a ApplicationSettings.multi_threaded_message_loop value of false. Do not perform blocking tasks on this thread. All tasks posted after CefBrowserProcessHandler::OnContextInitialized() and before CefShutdown() are guaranteed to run. This thread will outlive all other CEF threads.
* cef.TID_FILE (alias cef.TID_FILE_BACKGROUND): Used for blocking tasks (e.g. file system access) where the user won't notice if the task takes an arbitrarily long time to complete. All tasks posted after CefBrowserProcessHandler::OnContextInitialized() and before CefShutdown() are guaranteed to run.
* cef.TID_FILE_USER_VISIBLE: Used for blocking tasks (e.g. file system access) that affect UI or responsiveness of future user interactions. Do not use if an immediate response to a user interaction is expected. All tasks posted after CefBrowserProcessHandler::OnContextInitialized() and before CefShutdown() are guaranteed to run. Examples:
  - Updating the UI to reflect progress on a long task.
  - Loading data that might be shown in the UI after a future user
    interaction.
* cef.TID_FILE_USER_BLOCKING: Used for blocking tasks (e.g. file system access) that affect UI immediately after a user interaction. All tasks posted after CefBrowserProcessHandler::OnContextInitialized() and before CefShutdown() are guaranteed to run. Example: Generating data shown in the UI immediately after a click.
* cef.TID_IO: Used to process IPC and network messages. Do not perform blocking tasks on this thread. All tasks posted after CefBrowserProcessHandler::OnContextInitialized() and before CefShutdown() are guaranteed to run.

List of threads in the Renderer process:
* cef.TID_RENDERER: Tasks may be posted to this thread after CefRenderProcessHandler::OnRenderThreadCreated but are not guaranteed to run before sub-process termination (sub-processes may be killed at any time without warning).


### PostDelayedTask

| Parameter | Type |
| --- | --- |
| thread | int |
| delay_ms | int |
| func | object |
| [args..] | mixed |
| __Return__ | void |

Post a task for delayed execution on the specified thread. This
function behaves similarly to PostTask above, but with an additional
|delay_ms| argument.


### QuitMessageLoop

| | |
| --- | --- |
| __Return__ | void |

Quit the CEF message loop that was started by calling cefpython.MessageLoop(). This function should only be called on the main application thread (UI thread) and only if cefpython.MessageLoop() was used.


### SetGlobalClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| callback | function |
| __Return__ | void |

Current CEF Python implementation is limited in handling callbacks that occur during browser creation, in such cases a callback set with Browser.SetClientCallback() or Browser.SetClientHandler() won't work, as this methods can be called only after browser was created. An example of such callback is LifespanHandler.OnAfterCreated().

Some client callbacks are not associated with any browser. In such case use this function instead of the SetClientCallback() and SetClientHandler() [Browser](Browser.md) methods. An example of such callback is OnCertificateError() in [RequestHandler](RequestHandler.md).

Example of using SetGlobalClientCallback() is provided in the wxpython.py example.


### SetGlobalClientHandler

| Parameter | Type |
| --- | --- |
| handler | object |
| __Return__ | void |

Set client handler object (class instance). Its members will be inspected.
Private methods that are not meant to be callbacks should have their names
prepended with two underscores. Methods with single underscore or no
underscore are treated the same as client callbacks.

You can call this method multiple times to set many handlers. For
example you can create in your code several objects named AccessibilityHandler,
RequestHandler etc.


### SetOsModalLoop

| Parameter | Type |
| --- | --- |
| modalLoop | bool |
| __Return__ | void |

Set to true before calling Windows APIs like 'TrackPopupMenu' that enter a
modal message loop. Set to false after exiting the modal message loop.


### Shutdown

| | |
| --- | --- |
| __Return__ | void |

This function should be called on the main application thread (UI thread) to shut down CEF before the application exits.

You must call this function so that CEF shuts down cleanly. Remember also to delete all CEF browsers references for the browsers to shut down cleanly. For an example see the wxpython.py example MainFrame.OnClose().
