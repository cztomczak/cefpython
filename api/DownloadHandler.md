[API categories](API-categories.md) | [API index](API-index.md)


# DownloadHandler

See also [Browser](Browser.md).StartDownload().


## Preface

In CEF 3 downloads are handled automatically if ApplicationSettings.`downloads_enabled` is set to True (default). A default `SaveAs` file dialog provided by OS is displayed. If the download is aborted by user LoadHandler.`OnLoadError` will get called with errorCode ERR_ABORTED.

There is no download progress available. If you need such feature you will have to create a custom implementation of downloads. It would need to be investigated which callbacks from client handlers would allow for such implementation. Take a look at RequestHandler.`OnBeforeBrowse`, `OnBeforeResourceLoad`, and/or ResourceHandler.

On Linux there is a bug and ERR_ABORTED is reported even for successful downloads. See the comments in the wxpython.py example.

A download handler with callbacks like `OnBeforeDownload` and
`OnDownloadUpdated` may be exposed to CEF Python in the future.
