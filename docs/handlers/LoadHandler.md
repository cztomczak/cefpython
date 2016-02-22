# LoadHandler callbacks #

Implement this interface to handle events related to browser load status. The methods of this class will be called on the UI thread.

For an example of how to implement handler see [cefpython](cefpython).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).

## CEF 3 ##

void **OnLoadingStateChange**([Browser](Browser) browser, bool isLoading, bool canGoBack, bool canGoForward)

> Called when the loading state has changed. This callback will be executed
> twice. Once when loading is initiated either programmatically or by user
> action, and once when loading is terminated due to completion, cancellation
> of failure.

void **OnLoadStart**([Browser](Browser) browser, [Frame](Frame) frame)

> Called when the browser begins loading a frame. The |frame| value will
> never be empty -- call the IsMain() method to check if this frame is the
> main frame. Multiple frames may be loading at the same time. Sub-frames may
> start or continue loading after the main frame load has ended. This method
> may not be called for a particular frame if the load request for that frame
> fails. For notification of overall browser load status use
> [DisplayHandler](DisplayHandler).`OnLoadingStateChange` instead.

void **OnDomReady**()

> Not yet implemented. See [Issue 32](../issues/32).

void **OnLoadEnd**([Browser](Browser) browser, [Frame](Frame) frame, int httpStatusCode)

> Called when the browser is done loading a frame. The |frame| value will
> never be empty -- call the IsMain() method to check if this frame is the
> main frame. Multiple frames may be loading at the same time. Sub-frames may
> start or continue loading after the main frame load has ended. This method
> will always be called for all frames irrespective of whether the request
> completes successfully.

> This event behaves like window.onload, it waits for all the content to load (e.g. images), there is currently no callback for a DOMContentLoaded event, see [Issue 32](../issues/32).

> There are some cases when this callback won't get called, see this topic: http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10906

void **OnLoadError**([Browser](Browser) browser, [Frame](Frame) frame, [NetworkError](NetworkError) errorCode, list& errorText, string failedUrl)

> Called when the resource load for a navigation fails or is canceled.
> |errorCode| is the error code number, |`errorText[0]`| is the error text and
> |failedUrl| is the URL that failed to load. See net\base\net\_error\_list.h
> for complete descriptions of the error codes.

> This callback may get called when [Browser](Browser).`StopLoad` is called, or when file download is aborted (see DownloadHandler).

## CEF 1 ##

void **OnDomReady**()

> Not yet implemented. See [Issue 32](../issues/32).

void **OnLoadEnd**([Browser](Browser) `browser`, [Frame](Frame) `frame`, int `httpStatusCode`)

> Called when the browser is done loading a frame (top frame, iframe, frameset, popup). The |Frame| value will never be empty -- call the IsMain() method to check if this frame is the main frame. Multiple frames may be loading at the same time. Sub-frames may start or continue loading after the main frame load has ended. This method will always be called for all frames irrespective of whether the request completes successfully.

> This event behaves like window.onload, it waits for all the content to load (e.g. images), there is currently no callback for a DOMContentLoaded event, see [Issue 32](../issues/32).

> There are some cases when this callback won't get called, see this topic: http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10906

bool **OnLoadError**([Browser](Browser) `browser`, [Frame](Frame) `frame`, int [errorCode](NetworkError), string `failedURL`, string list &`errorText`)

> Called when the browser fails to load a frame (top frame, iframe, frameset, popup). |errorCode| is the error code number and |failedUrl| is the URL that failed to load. To provide custom error text assign the text to `errorText[0]` and return true. Otherwise, return false for the default error text.

> OnLoadError may be called very early in the navigation process before |frame| or its GetURL() value has been set, thus the availability of additional parameter `failedURL`.

void **OnLoadStart**([Browser](Browser), [Frame](Frame))

> Called when the browser begins loading a frame (top frame, iframe, frameset, popup). The |Frame| value will never be empty -- call the IsMain() method to check if this frame is the main frame. Multiple frames may be loading at the same time. Sub-frames may start or continue loading after the main frame load has ended. This method may not be called for a particular frame if the load request for that frame fails.