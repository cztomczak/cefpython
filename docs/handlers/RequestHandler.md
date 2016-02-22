# RequestHandler callbacks #

Implement this interface to handle events related to browser requests.

For an example of how to implement handler see [cefpython](cefpython).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).

The `RequestHandler` tests can be found in the wxpython.py script.

## CEF 3 ##

void **OnBeforeBrowse**([Browser](Browser) browser, [Frame](Frame) frame, [Request](Request) request, bool isRedirect)

> Called on the UI thread before browser navigation. Return true to cancel
> the navigation or false to allow the navigation to proceed. The |request|
> object cannot be modified in this callback.
> [DisplayHandler](DisplayHandler).`OnLoadingStateChange` will be called twice in all cases.
> If the navigation is allowed [LoadHandler](LoadHandler).`OnLoadStart` and
> `OnLoadEnd` will be called. If the navigation is canceled
> [LoadHandler](LoadHandler).`OnLoadError` will be called with an |errorCode| value of
> ERR\_ABORTED.

bool **OnBeforeResourceLoad**([Browser](Browser) browser, [Frame](Frame) frame, [Request](Request) request)

> Called on the IO thread before a resource request is loaded. The |request|
> object may be modified. To cancel the request return true otherwise return false.

[ResourceHandler](ResourceHandler) **GetResourceHandler**([Browser](Browser) browser, [Frame](Frame) frame, [Request](Request) request)

> Called on the IO thread before a resource is loaded. To allow the resource
> to load normally return None. To specify a handler for the resource return
> a [ResourceHandler](ResourceHandler) object. The |request| object should not be modified in
> this callback.

> The [ResourceHandler](ResourceHandler) object is a python class that implements the `ResourceHandler` callbacks. Remember to keep a strong reference to this object while resource is being loaded.

> The `GetResourceHandler` example can be found in the `wxpython-response.py` script on Linux.

void **OnResourceResponse**()

> Not yet available in CEF 3 (see [CEF Issue 515](https://bitbucket.org/chromiumembedded/cef/issues/515)), though it can be emulated, see the comment below.

> You can implement this functionality by using [ResourceHandler](ResourceHandler)
> and [WebRequest](WebRequest) / [WebRequestClient](WebRequestClient). For an example see the `_OnResourceResponse()` method in the [wxpython-response.py](../blob/master/cefpython/cef3/linux/binaries_64bit/wxpython-response.py) script.

void **OnResourceRedirect**([Browser](Browser) browser, [Frame](Frame) frame, string oldUrl, list& newUrlOut)

> Called on the IO thread when a resource load is redirected. The |oldUrl|
> parameter will contain the old URL. The `newUrlOut[0]` parameter will contain
> the new URL and can be changed if desired.

bool **GetAuthCredentials**([Browser](Browser) browser, [Frame](Frame) frame, bool isProxy, string host, int port, string realm, string scheme, `AuthCallback` callback) {

> Called on the IO thread when the browser needs credentials from the user.
> |isProxy| indicates whether the host is a proxy server. |host| contains the
> hostname and |port| contains the port number. Return true to continue the
> request and call `AuthCallback`::Continue() when the authentication
> information is available. Return false to cancel the request.

> The `AuthCallback` object methods:
  * void Continue(string username, string password)
  * void Cancel()

bool **OnQuotaRequest**([Browser](Browser) browser, string originUrl, long newSize, `QuotaCallback` callback)

> Called on the IO thread when javascript requests a specific storage quota
> size via the `webkitStorageInfo.requestQuota` function. |originUrl| is the
> origin of the page making the request. |newSize| is the requested quota
> size in bytes. Return true and call `QuotaCallback::Continue()` either in
> this method or at a later time to grant or deny the request. Return False
> to cancel the request.

> The `QuotaCallback` object methods:
  * void Continue(bool allow)
  * void Cancel()

[CookieManager](CookieManager) **GetCookieManager**([Browser](Browser) browser|None, string mainUrl)

> Called on the IO thread to retrieve the cookie manager. |mainUrl| is the URL of the top-level frame. Cookies managers can be unique per browser or shared across multiple browsers. The global cookie manager will be used if this method returns None.

> To successfully implement separate cookie manager per browser session, you have to set ApplicationSettings.`unique_request_context_per_browser` to True. Otherwise the browser param passed to this callback will always be the same first browser that was created using [cefpython](cefpython).`CreateBrowserSync`.

> Popup browsers created javascript's window.open share the same renderer process and request context. If you want to have separate cookie managers for popups created using window.open then you have to implement the LifespanHandler.`OnBeforePopup` callback. Return True in that callback to cancel popup creation and instead create the window on your own and embed browser in it. The `CreateAnotherBrowser` function from the wxpython example does that.

> IMPORTANT: in an exceptional case the `browser` parameter could be None, so you should handle such case. During testing this issue did not occur, but it may happen in some yet unknown scenarios.

void **OnProtocolExecution**([Browser](Browser) browser, string url, list& allowExecutionOut)

> Called on the UI thread to handle requests for URLs with an unknown
> protocol component. Set `allowExecutionOut[0]` to True to attempt execution
> via the registered OS protocol handler, if any.
> SECURITY WARNING: YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED
> ON SCHEME, HOST OR OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.

> There's no default implementation for OnProtocolExecution on Linux,
> you have to make OS system call on your own. You probably also need
> to use [LoadHandler](LoadHandler)::`OnLoadError()` when implementing this on Linux.

bool **`_`OnBeforePluginLoad**([Browser](Browser) browser, string url, string policyUrl, [WebPluginInfo](WebPluginInfo) info)

> Called on the browser process IO thread before a plugin is loaded. Return
> True to block loading of the plugin.

> This callback will be executed during browser creation, thus you must call [cefpython](cefpython).`SetGlobalClientCallback()` to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.

> Plugins are loaded on demand, only when website requires it.
> This callback is called every time the page tries to load a plugin (perhaps even multiple times per plugin).

bool **`_`OnCertificateError**([NetworkError](NetworkError) certError, string requestUrl, `AllowCertificateErrorCallback` callback)

> This callback is not associated with any specific browser, thus you must call [cefpython](cefpython).`SetGlobalClientCallback()` to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.

> Called on the UI thread to handle requests for URLs with an invalid
> SSL certificate. Return True and call `AllowCertificateErrorCallback`::
> `Continue()` either in this method or at a later time to continue or cancel
> the request. Return False to cancel the request immediately. If |callback|
> is empty the error cannot be recovered from and the request will be
> canceled automatically. If [ApplicationSettings](ApplicationSettings).`ignore_certificate_errors` is set
> all invalid certificates will be accepted without calling this method.

> The `AllowCertificateErrorCallback` object methods:
  * void Continue(bool allow)

void **OnRendererProcessTerminated**([Browser](Browser) browser, `TerminationStatus` status)

> Called when the render process terminates unexpectedly. |status| indicates
> how the process terminated.

> `TerminationStatus` constants:
  * cefpython.TS\_ABNORMAL\_TERMINATION - Non-zero exit status.
  * cefpython.TS\_PROCESS\_WAS\_KILLED - SIGKILL or task manager kill.
  * cefpython.TS\_PROCESS\_CRASHED - Segmentation fault.

void **OnPluginCrashed**([Browser](Browser) browser, string pluginPath)

> Called when a plugin has crashed. |pluginPath| is the path of the plugin
> that crashed.

## CEF 1 ##

bool **OnBeforeBrowse**([Browser](Browser) `browser`, [Frame](Frame) `frame`, [Request](Request) `request`, int `navType`, bool `isRedirect`)

> Called on the UI thread before browser navigation. Return true to cancel the navigation or false to allow the navigation to proceed.

> You cannot modify request headers nor post data via the [Request](Request)
> object in this callback, you have to do it in `OnBeforeResourceLoad()`.

> `|navType|` can be one of:

> `cefpython.NAVTYPE_LINKCLICKED`<br>
<blockquote><code>cefpython.NAVTYPE_FORMSUBMITTED</code><br>
<code>cefpython.NAVTYPE_BACKFORWARD</code><br>
<code>cefpython.NAVTYPE_RELOAD</code><br>
<code>cefpython.NAVTYPE_FORMRESUBMITTED</code><br>
<code>cefpython.NAVTYPE_OTHER</code><br>
<code>cefpython.NAVTYPE_LINKDROPPED</code><br></blockquote>

bool <b>OnBeforeResourceLoad</b>(<a href='Browser'>Browser</a> <code>browser</code>, <a href='Request'>Request</a> <code>request</code>, string& <code>redirectURL[0]</code>, <a href='StreamReader'>StreamReader</a> <code>streamReader</code>, <a href='Response'>Response</a> <code>response</code>, int <code>loadFlags</code>)<br>
<br>
<blockquote>Called on the IO thread before a resource is loaded.  To allow the resource<br>
to load normally return false. To redirect the resource to a new url<br>
populate the |redirectUrl| value and return false.  To specify data for the<br>
resource set it through |streamReader|, use the |response|<br>
object to set mime type, HTTP status code and optional header values, and<br>
return false. To cancel loading of the resource return true. Any<br>
modifications to |request| will be observed.  If the URL in |request| is<br>
changed and |redirectUrl| is also set, the URL in |request| will be used.</blockquote>

void <b>OnResourceRedirect</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>oldURL</code>, string& <code>newURL[0]</code>)<br>
<br>
<blockquote>Called on the IO thread when a resource load is redirected. The <code>|oldURL|</code> parameter will contain the old URL. The <code>|newURL[0]|</code> parameter will contain the new URL and can be changed if desired.</blockquote>

void <b>OnResourceResponse</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>url</code>, <a href='Response'>Response</a> <code>response</code>, <a href='ContentFilter'>ContentFilter</a>& <code>filter[0]</code>)<br>
<br>
<blockquote>Called on the UI thread after a response to the resource request is received. Set <code>|filter|</code> if response content needs to be monitored and/or modified as it arrives.</blockquote>

<blockquote><a href='ContentFilter'>ContentFilter</a> is not yet implemented, as of the moment you can only read responses using the <a href='Response'>Response</a> object.</blockquote>

<blockquote>This function does not get called for local disk resources (file:///). If you want to track local disk resources that failed to load, the way to go is to implement <a href='Schemehandler'>Schemehandler</a> (see thread here: <a href='http://magpcss.org/ceforum/viewtopic.php?f=6&t=3442'>http://magpcss.org/ceforum/viewtopic.php?f=6&amp;t=3442</a>)</blockquote>

bool <b>OnProtocolExecution</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>URL</code>, bool& <code>allowOSExecution[0]</code>)<br>
<br>
<blockquote>Called on the IO thread to handle requests for URLs with an unknown<br>
protocol component. Return true to indicate that the request should<br>
succeed because it was handled externally. Set <code>|allowOSExecution[0]|</code> to true and return false to attempt execution via the registered OS protocol handler, if any. If false is returned and either <code>|allowOSExecution[0]|</code> is false or OS protocol handler execution fails then the request will fail with an error condition.</blockquote>

<blockquote>SECURITY WARNING: you should use this method to enforce restrictions based on scheme, host or other url analysis before allowing os execution.</blockquote>

<a href='DownloadHandler'>DownloadHandler</a> <b>GetDownloadHandler</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>mimeType</code>, string <code>filename</code>, int <code>contentLength</code>)<br>
<br>
<blockquote>Called on the UI thread when a server indicates via the<br>
'Content-Disposition' header that a response represents a file to download.<br>
|mimeType| is the mime type for the download, |fileName| is the suggested<br>
target file name and |contentLength| is either the value of the<br>
'Content-Size' header or -1 if no size was provided.</blockquote>

<blockquote>Return a <a href='DownloadHandler'>DownloadHandler</a> object to download the file or False<br>
to cancel the file download.</blockquote>

<blockquote>The <code>DownloadHandler</code> object is a python class that implements the<br>
<code>DownloadHandler</code> callbacks, you must keep a strong reference to<br>
this object while download is proceeding, otherwise it gets destroyed<br>
and the callbacks won't be called.</blockquote>

bool <b>GetAuthCredentials</b>(<a href='Browser'>Browser</a> <code>browser</code>, bool <code>isProxy</code>, string <code>host</code>, int <code>port</code>, string <code>realm</code>, string <code>scheme</code>, string& <code>username[0]</code>, string& <code>password[0]</code>)<br>
<br>
<blockquote>On Windows there is a default implementation for Http Authentication. On Linux there is no default implementation.</blockquote>

<blockquote>Called on the IO thread when the browser needs credentials from the user. <code>|isProxy|</code> indicates whether the host is a proxy server. <code>|host|</code> contains the hostname and port number. Set <code>|username[0]|</code> and <code>|password[0]|</code> and return true to handle the request. Return false to cancel the request.</blockquote>

<a href='CookieManager'>CookieManager</a> <b>GetCookieManager</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>mainUrl</code>)<br>
<br>
<blockquote>Called on the IO thread to retrieve the cookie manager. <code>|mainUrl|</code> is the URL of the top-level frame. Cookies managers can be unique per browser or shared across multiple browsers. The global cookie manager will be used if this method returns None.</blockquote>

<blockquote>This method may be called multiple times for the same browser,<br>
if you return a cookie manager you need to save it somewhere<br>
so that you don't create a new one on next call,  use<br>
<a href='Browser'>Browser</a>.<code>SetUserData()</code> and <a href='Browser'>Browser</a>.<code>GetUserData()</code> for<br>
that purpose.