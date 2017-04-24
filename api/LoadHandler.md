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
| is_loading | bool |
| can_go_back | bool |
| can_go_forward | bool |
| __Return__ | void |

Called when the loading state has changed. This callback will be executed
twice. Once when loading is initiated either programmatically or by user
action, and once when loading is terminated due to completion, cancellation
of failure. It will be called before any calls to OnLoadStart and after all
calls to OnLoadError and/or OnLoadEnd.


### OnLoadStart

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| __Return__ | void |

Description from upstream CEF:
> Called after a navigation has been committed and before the browser begins
> loading contents in the frame. The |frame| value will never be empty --
> call the IsMain() method to check if this frame is the main frame.
> |transition_type| provides information about the source of the navigation
> and an accurate value is only available in the browser process. Multiple
> frames may be loading at the same time. Sub-frames may start or continue
> loading after the main frame load has ended. This method will not be called
> for same page navigations (fragments, history state, etc.) or for
> navigations that fail or are canceled before commit. For notification of
> overall browser load status use OnLoadingStateChange instead.

This callback is called for a number of different reasons, including when
history.pushState or history.replaceState changes the reference fragment
for the currently loaded page. In most cases you want to use
OnLoadingStateChange. In newer CEF there is |transition_type| arg that
provides information about the source of the navigation.


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
| http_code | int |
| __Return__ | void |

Description from upstream CEF:
> Called when the browser is done loading a frame. The |frame| value will
> never be empty -- call the IsMain() method to check if this frame is the
> main frame. Multiple frames may be loading at the same time. Sub-frames may
> start or continue loading after the main frame load has ended. This method
> will not be called for same page navigations (fragments, history state,
> etc.) or for navigations that fail or are canceled before commit. For
> notification of overall browser load status use OnLoadingStateChange
> instead.

This event behaves like window.onload, it waits for all the content
to load (e.g. images), there is currently no callback for
a DOMContentLoaded event, see [Issue #32](../issues/32).

There are some cases when this callback won't get called, see this
topic: http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10906


### OnLoadError

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| error_code | [NetworkError](NetworkError.md) |
| error_text_out | list[string] |
| failed_url | string |
| __Return__ | void |

Description from upstream CEF:
> Called when a navigation fails or is canceled. This method may be called
> by itself if before commit or in combination with OnLoadStart/OnLoadEnd if
> after commit. |errorCode| is the error code number, |errorText| is the
> error text and |failedUrl| is the URL that failed to load.
> See net\base\net_error_list.h for complete descriptions of the error codes.

This callback may get called when [Browser](Browser.md).`StopLoad`
is called, or when file download is aborted (see DownloadHandler).
