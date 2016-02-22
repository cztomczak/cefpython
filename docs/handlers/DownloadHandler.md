# DownloadHandler callbacks #

See also [Browser](Browser).`StartDownload()`.

## CEF 3 ##

In CEF 3 downloads are handled automatically if ApplicationSettings.`downloads_enabled` is set to True (default). A default `SaveAs` file dialog provided by OS is displayed. If the download is aborted by user LoadHandler.`OnLoadError` will get called with errorCode ERR\_ABORTED.

There is no download progress available. If you need such feature you will have to create a custom implementation of downloads. It would need to be investigated which callbacks from client handlers would allow for such implementation. Take a look at RequestHandler.`OnBeforeBrowse`, `OnBeforeResourceLoad`, and/or ResourceHandler.

On Linux there is a bug and ERR\_ABORTED is reported even for successful downloads. See the comments in the wxpython.py example.

A download handler with callbacks like `OnBeforeDownload` and
`OnDownloadUpdated` may be exposed to CEF Python in the future.

## CEF 1 ##

See [RequestHandler](RequestHandler).`GetDownloadHandler()`.

You must keep a strong reference to the `DownloadHandler` object while downloading, otherwise it gets destroyed and the `DownloadHandler` callbacks won't be called.

The callbacks of the `DownloadHandler` class will always be called on the UI thread.

An example `DownloadHandler` can be found in the wxpython.py script.

bool **OnData**(str data)

> A portion of the file contents have been received. This method will be
> called multiple times until the download is complete. Return |True| to
> continue receiving data and |False| to cancel.

void **OnComplete**()

> The download is complete.