[API categories](API-categories.md) | [API index](API-index.md)


# LoadHandler (interface)

Implement this interface to handle events related to browser load status. The methods of this class will be called on the UI thread.

For an example of how to implement handler see [cefpython](cefpython.md).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).


Table of contents:
* [Callbacks](#callbacks)
  * [OnLoadingStateChange](#onloadingstatechange)
  * [OnLoadStart](#onloadstart)
  * [OnDomReady](#ondomready)
  * [OnLoadEnd](#onloadend)
  * [OnLoadError](#onloaderror)


## Callbacks


### OnLoadingStateChange

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| isLoading | bool |
| canGoBack | bool |
| canGoForward | bool |
| __Return__ | void |

Called when the loading state has changed. This callback will be executed
twice. Once when loading is initiated either programmatically or by user
action, and once when loading is terminated due to completion, cancellation
of failure.


### OnLoadStart

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| __Return__ | void |

Called when the browser begins loading a frame. The |frame| value will
never be empty -- call the IsMain() method to check if this frame is the
main frame. Multiple frames may be loading at the same time. Sub-frames may
start or continue loading after the main frame load has ended. This method
may not be called for a particular frame if the load request for that frame
fails. For notification of overall browser load status use
[DisplayHandler](DisplayHandler.md).`OnLoadingStateChange` instead.


### OnDomReady

| | |
| --- | --- |
| __Return__ | void |

Not yet implemented. See [Issue #32](../issues/32).


### OnLoadEnd

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| httpStatusCode | int |
| __Return__ | void |

Called when the browser is done loading a frame. The |frame| value will
never be empty -- call the IsMain() method to check if this frame is the
main frame. Multiple frames may be loading at the same time. Sub-frames may
start or continue loading after the main frame load has ended. This method
will always be called for all frames irrespective of whether the request
completes successfully.

This event behaves like window.onload, it waits for all the content to load (e.g. images), there is currently no callback for a DOMContentLoaded event, see [Issue #32](../issues/32).

There are some cases when this callback won't get called, see this topic: http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10906


### OnLoadError

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| errorCode | [NetworkError](NetworkError.md) |
| errorText | list& |
| failedUrl | string |
| __Return__ | void |

Called when the resource load for a navigation fails or is canceled.
|errorCode| is the error code number, |`errorText[0]`| is the error text and
|failedUrl| is the URL that failed to load. See net\base\net_error_list.h
for complete descriptions of the error codes.

This callback may get called when [Browser](Browser.md).`StopLoad` is called, or when file download is aborted (see DownloadHandler).
