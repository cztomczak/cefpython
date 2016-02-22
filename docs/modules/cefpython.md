# cefpython

Functions in the cefpython module.

<!-- START doctoc -->
<!-- END doctoc -->

### CreateBrowserSync

| Parameter | Type |
| --- | --- |
| windowInfo | [WindowInfo](../objects/WindowInfo.md) |
| [BrowserSettings](../settings/BrowserSettings.md) | dict |
| navigateUrl | string |
| requestContext | void |
| __Return__ | [Browser](../objects/Browser.md) |

This function should only be called on the UI thread. The 'requestContext' parameter is not yet implemented. You must first create a window and initialize 'windowInfo' by calling WindowInfo.SetAsChild().

After the call to CreateBrowserSync() the page is not yet loaded, if you want your next lines of code to do some stuff on the webpage you will have to implement [LoadHandler](../handlers/LoadHandler.md).OnLoadEnd() callback, see example below:

```python
def OnLoadEnd(browser, frame, httpCode):
    if frame == browser.GetMainFrame():
        print("Finished loading main frame: %s (http code = %d)"
              % (frame.GetUrl(), httpCode))

browser = cefpython.CreateBrowserSync(windowInfo, settings, url)
browser.SetClientCallback("OnLoadEnd", OnLoadEnd)
```

### GetAppSetting

| Parameter | Type |
| --- | --- |
| key | string |
| __Return__ | object |

Returns [ApplicationSettings](../settings/ApplicationSettings.md) option that was passed to Initialize(). Returns None if key is not found.

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

Returns the [CommandLineSwitches](../settings/CommandLineSwitches.md) switch that was passed to Initialize(). Returns None if key is not found.

### GetGlobalClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | object |

Returns a global client callback that was set using SetGlobalClientCallback(). Returns None if callback was not set.

### GetModuleDirectory

| | |
| --- | --- |
| __Return__ | string |

Get the cefpython module directory. This method is useful to get full path to CEF binaries. This is required when setting [ApplicationSettings](../settings/ApplicationSettings.md) options like: 'browser_subprocess_path', 'resources_dir_pat' and 'locales_dir_path'.

### Initialize

| Parameter | Type |
| --- | --- |
| [ApplicationSettings](../settings/ApplicationSettings.md)=None | dict |
| [CommandLineSwitches](../settings/CommandLineSwitches.md)=None | dict |
| __Return__ | bool |

This function should be called on the main application thread (UI thread) to initialize CEF when the application is started. A call to Initialize() must have a corresponding call to Shutdown() so that CEF exits cleanly. Otherwise when application closes data (eg. storage, cookies) might not be saved to disk or the process might freeze (experienced on Windows XP).

### IsThread

| Parameter | Type |
| --- | --- |
| threadID | int |
| __Return__ | bool |

Returns true if called on the specified thread.

CEF maintains multiple internal threads that are used for handling different types of tasks. The UI thread creates the browser window and is used for all interaction with the webkit rendering engine and V8 Javascript engine. The UI thread will be the same as the main application thread if CefInitialize() is called with an [ApplicationSettings](../settings/ApplicationSettings.md) 'multi_threaded_message_loop' option set to false. The IO thread is used for handling schema and network requests. The FILE thread is used for the application cache and other miscellaneous activities.

List of threads in the Browser process. These are constants defined in the cefpython module:

* TID_UI: The main thread in the browser. This will be the same as the main application thread if cefpython.Initialize() is called with a ApplicationSettings.multi_threaded_message_loop value of false.
* TID_DB: Used to interact with the database.
* TID_FILE: Used to interact with the file system.
* TID_FILE_USER_BLOCKING: Used for file system operations that block user interactions. Responsiveness of this thread affects users.
* TID_PROCESS_LAUNCHER: Used to launch and terminate browser processes.
* TID_CACHE: Used to handle slow HTTP cache operations.
* TID_IO: Used to process IPC and network messages.

List of threads in the Renderer process:
* TID_RENDERER: The main thread in the renderer. Used for all webkit and V8 interaction.

### IsKeyModifier

| Parameter | Type |
| --- | --- |
| key | int |
| modifiers | int |
| __Return__ | bool |

For use with [KeyboardHandler](../handlers/KeyboardHandler.md) to check whether ALT, SHIFT or CTRL are pressed.

### MessageLoop

| | |
| --- | --- |
| __Return__ | void |

Run the CEF message loop. Use this function instead of an application-
provided message loop to get the best balance between performance and CPU usage. This function should only be called on the main application thread (UI thread) and only if cefpython.Initialize() is called with a
[ApplicationSettings](../settings/ApplicationSettings.md).multi_threaded_message_loop value of false. This function will block until a quit message is received by the system.

### MessageLoopWork

| | |
| --- | --- |
| __Return__ | void |

Perform a single iteration of CEF message loop processing. This function is used to integrate the CEF message loop into an existing application message loop. Care must be taken to balance performance against excessive CPU usage. This function should only be called on the main application thread (UI thread) and only if cefpython.Initialize() is called with a [ApplicationSettings](../settings/ApplicationSettings.md).multi_threaded_message_loop value of false. This function will not block.

Alternatively you could create a periodic timer (with 10 ms interval) that calls cefpython.MessageLoopWork().

MessageLoopWork() is not tested on OS X and there are known issues - according to  [this post](http://www.magpcss.org/ceforum/viewtopic.php?p=27124#p27124) by Marshall.

### PostTask

| Parameter | Type |
| --- | --- |
| threadId | int |
| func | object |
| ... | *args |
| __Return__ | void |

Post a task for execution on the thread associated with this task runner. Execution will occur asynchronously. Only Browser process threads are allowed, see IsThread() for a list of available threads and their descriptions.

An example usage is in the wxpython.py example on Windows, in implementation of LifespanHandler.OnBeforePopup().

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

Some client callbacks are not associated with any browser. In such case use this function instead of the SetClientCallback() and SetClientHandler() [Browser](../objects/Browser.md) methods. An example of such callback is OnCertificateError() in [RequestHandler](../handlers/RequestHandler.md).

Example of using SetGlobalClientCallback() is provided in the wxpython.py example.

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
