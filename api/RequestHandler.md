[API categories](API-categories.md) | [API index](API-index.md)


# RequestHandler (interface)

Implement this interface to handle events related to browser requests.

For an example of how to implement handler see [cefpython](cefpython.md).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).

The `RequestHandler` tests can be found in the wxpython.py script.

The following callbacks are available in upstream CEF, but were not yet
exposed:
* OnOpenURLFromTab
* OnSelectClientCertificate


Table of contents:
* [Callbacks](#callbacks)
  * [OnBeforeBrowse](#onbeforebrowse)
  * [OnBeforeResourceLoad](#onbeforeresourceload)
  * [GetResourceHandler](#getresourcehandler)
  * [OnResourceResponse](#onresourceresponse)
  * [OnResourceRedirect](#onresourceredirect)
  * [GetAuthCredentials](#getauthcredentials)
  * [OnQuotaRequest](#onquotarequest)
  * [GetCookieManager](#getcookiemanager)
  * [OnProtocolExecution](#onprotocolexecution)
  * [_OnBeforePluginLoad](#_onbeforepluginload)
  * [_OnCertificateError](#_oncertificateerror)
  * [OnRendererProcessTerminated](#onrendererprocessterminated)
  * [OnPluginCrashed](#onplugincrashed)


## Callbacks


### OnBeforeBrowse

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| isRedirect | bool |
| __Return__ | bool |

Called on the UI thread before browser navigation. Return true to cancel
the navigation or false to allow the navigation to proceed. The |request|
object cannot be modified in this callback.
[DisplayHandler](DisplayHandler.md).`OnLoadingStateChange` will be called twice in all cases.
If the navigation is allowed [LoadHandler](LoadHandler.md).`OnLoadStart` and
`OnLoadEnd` will be called. If the navigation is canceled
[LoadHandler](LoadHandler.md).`OnLoadError` will be called with an |errorCode| value of
ERR_ABORTED.


### OnBeforeResourceLoad

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| __Return__ | bool |

Called on the IO thread before a resource request is loaded. The |request|
object may be modified. To cancel the request return true otherwise return
false.


### GetResourceHandler

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| __Return__ | [ResourceHandler](ResourceHandler.md) |

Called on the IO thread before a resource is loaded. To allow the resource
to load normally return None. To specify a handler for the resource return
a [ResourceHandler](ResourceHandler.md) object. The |request| object should not be modified in
this callback.

The [ResourceHandler](ResourceHandler.md) object is a python class that implements the `ResourceHandler` callbacks. Remember to keep a strong reference to this object while resource is being loaded.

The `GetResourceHandler` example can be found in the `wxpython-response.py` script on Linux.


### OnResourceResponse

| | |
| --- | --- |
| __Return__ | void |

Not yet available in CEF 3 (see [CEF Issue 515](https://bitbucket.org/chromiumembedded/cef/issues/515)), though it can be emulated, see the comment below.

You can implement this functionality by using [ResourceHandler](ResourceHandler.md)
and [WebRequest](WebRequest.md) / [WebRequestClient](WebRequestClient.md). For an example see the _OnResourceResponse() method in the [wxpython-response.py]
(../src/linux/binaries_64bit/wxpython-response.py) script.


### OnResourceRedirect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| oldUrl | string |
| out newUrl[0] | string |
| request | [Request](Request.md) |
| response | [Response](Response.md) |
| __Return__ | void |

Description from upstream CEF:
> Called on the IO thread when a resource load is redirected. The |request|
> parameter will contain the old URL and other request-related information.
> The |response| parameter will contain the response that resulted in the
> redirect. The |new_url| parameter will contain the new URL and can be
> changed if desired. The |request| object cannot be modified in this
> callback.


### GetAuthCredentials

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| isProxy | bool |
| host | string |
| port | int |
| realm | string |
| scheme | string |
| callback | AuthCallback |
| __Return__ | bool |{

Called on the IO thread when the browser needs credentials from the user.
|isProxy| indicates whether the host is a proxy server. |host| contains the
hostname and |port| contains the port number. |realm| is the realm of the
challenge and may be empty. |scheme| is the authentication scheme used,
such as "basic" or "digest", and will be empty if the source of the request
is an FTP server. Return true to continue the request and call
CefAuthCallback::Continue() either in this method or at a later time when
the authentication information is available. Return false to cancel the
request immediately.

The `AuthCallback` object methods:
* void Continue(string username, string password)
* void Cancel()


### OnQuotaRequest

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| originUrl | string |
| newSize | long |
| callback | RequestCallback |
| __Return__ | bool |

Called on the IO thread when javascript requests a specific storage quota
size via the `webkitStorageInfo.requestQuota` function. |originUrl| is the
origin of the page making the request. |newSize| is the requested quota
size in bytes. Return true to continue the request and call
CefRequestCallback::Continue() either in this method or at a later time to
grant or deny the request. Return false to cancel the request immediately.

The `RequestCallback` object methods:
* void Continue(bool allow)
* void Cancel()


### GetCookieManager

| Parameter | Type |
| --- | --- |
| browser|None | [Browser](Browser.md) |
| mainUrl | string |
| __Return__ | [CookieManager](CookieManager.md) |

Called on the IO thread to retrieve the cookie manager. |mainUrl| is the URL of the top-level frame. Cookies managers can be unique per browser or shared across multiple browsers. The global cookie manager will be used if this method returns None.

To successfully implement separate cookie manager per browser session, you have to set ApplicationSettings.`unique_request_context_per_browser` to True. Otherwise the browser param passed to this callback will always be the same first browser that was created using [cefpython](cefpython.md).`CreateBrowserSync`.

Popup browsers created javascript's window.open share the same renderer process and request context. If you want to have separate cookie managers for popups created using window.open then you have to implement the LifespanHandler.`OnBeforePopup` callback. Return True in that callback to cancel popup creation and instead create the window on your own and embed browser in it. The `CreateAnotherBrowser` function from the wxpython example does that.

IMPORTANT: in an exceptional case the `browser` parameter could be None, so you should handle such case. During testing this issue did not occur, but it may happen in some yet unknown scenarios.


### OnProtocolExecution

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| url | string |
| allowExecutionOut | list& |
| __Return__ | void |

Called on the UI thread to handle requests for URLs with an unknown
protocol component. Set `allowExecutionOut[0]` to True to attempt execution
via the registered OS protocol handler, if any.
SECURITY WARNING: YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED
ON SCHEME, HOST OR OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.

There's no default implementation for OnProtocolExecution on Linux,
you have to make OS system call on your own. You probably also need
to use [LoadHandler](LoadHandler.md)::OnLoadError() when implementing this on Linux.


### _OnBeforePluginLoad

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| mime_type | string |
| plugin_url | string |
| top_origin_url | string |
| info | [WebPluginInfo](WebPluginInfo.md) |
| __Return__ | bool |

Description from upstream CEF:
> Called on multiple browser process threads before a plugin instance is
> loaded. |mime_type| is the mime type of the plugin that will be loaded.
> |plugin_url| is the content URL that the plugin will load and may be empty.
> |top_origin_url| is the URL for the top-level frame that contains the
> plugin when loading a specific plugin instance or empty when building the
> initial list of enabled plugins for 'navigator.plugins' JavaScript state.
> |plugin_info| includes additional information about the plugin that will be
> loaded. |plugin_policy| is the recommended policy. Modify |plugin_policy|
> and return true to change the policy. Return false to use the recommended
> policy. The default plugin policy can be set at runtime using the
> `--plugin-policy=[allow|detect|block]` command-line flag. Decisions to mark
> a plugin as disabled by setting |plugin_policy| to PLUGIN_POLICY_DISABLED
> may be cached when |top_origin_url| is empty. To purge the plugin list
> cache and potentially trigger new calls to this method call
> CefRequestContext::PurgePluginListCache.

Return True to block loading of the plugin.

This callback will be executed during browser creation, thus you must call [cefpython](cefpython.md).SetGlobalClientCallback() to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.

Plugins are loaded on demand, only when website requires it.
This callback is called every time the page tries to load a plugin (perhaps even multiple times per plugin).


### _OnCertificateError

| Parameter | Type |
| --- | --- |
| certError | [NetworkError](NetworkError.md) |
| requestUrl | string |
| callback | RequestCallback |
| __Return__ | bool |

This callback is not associated with any specific browser, thus you must call [cefpython](cefpython.md).SetGlobalClientCallback() to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.

Called on the UI thread to handle requests for URLs with an invalid
SSL certificate. Return true and call CefRequestCallback::Continue() either
in this method or at a later time to continue or cancel the request. Return
false to cancel the request immediately. If
CefSettings.ignore_certificate_errors is set all invalid certificates will
be accepted without calling this method.

The `RequestCallback` object methods:
  * void Continue(bool allow)
  * void Cancel()


### OnRendererProcessTerminated

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| status | TerminationStatus |
| __Return__ | void |

Called when the render process terminates unexpectedly. |status| indicates
how the process terminated.

`TerminationStatus` constants in the cefpython module:
  * TS_ABNORMAL_TERMINATION - Non-zero exit status.
  * TS_PROCESS_WAS_KILLED - SIGKILL or task manager kill.
  * TS_PROCESS_CRASHED - Segmentation fault.


### OnPluginCrashed

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| pluginPath | string |
| __Return__ | void |

Called when a plugin has crashed. |pluginPath| is the path of the plugin
that crashed.
