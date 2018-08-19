[API categories](API-categories.md) | [API index](API-index.md)


# RequestHandler (interface)

Implement this interface to handle events related to browser requests.
The methods of this class will be called on the thread indicated.

Related code snippets:
- [network_cookies.py](../examples/snippets/network_cookies.py)

Available in upstream CEF, but not yet exposed to CEF Python:
- OnOpenURLFromTab
- OnSelectClientCertificate


Table of contents:
* [Callbacks](#callbacks)
  * [CanGetCookies](#cangetcookies)
  * [CanSetCookie](#cansetcookie)
  * [GetAuthCredentials](#getauthcredentials)
  * [GetCookieManager](#getcookiemanager)
  * [GetResourceHandler](#getresourcehandler)
  * [OnBeforeBrowse](#onbeforebrowse)
  * [_OnBeforePluginLoad](#_onbeforepluginload)
  * [OnBeforeResourceLoad](#onbeforeresourceload)
  * [_OnCertificateError](#_oncertificateerror)
  * [OnQuotaRequest](#onquotarequest)
  * [OnResourceRedirect](#onresourceredirect)
  * [OnResourceResponse](#onresourceresponse)
  * [OnPluginCrashed](#onplugincrashed)
  * [OnProtocolExecution](#onprotocolexecution)
  * [OnRendererProcessTerminated](#onrendererprocessterminated)


## Callbacks


### CanGetCookies

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| __Return__ | bool |

Description from upstream CEF:
> Called on the IO thread before sending a network request with a "Cookie"
> request header. Return true to allow cookies to be included in the network
> request or false to block cookies. The |request| object should not be
> modified in this callback.


### CanSetCookie

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| cookie | [Cookie](Cookie.md) |
| __Return__ | bool |

Description from upstream CEF:
> Called on the IO thread when receiving a network request with a
> "Set-Cookie" response header value represented by |cookie|. Return true to
> allow the cookie to be stored or false to block the cookie. The |request|
> object should not be modified in this callback.


### GetAuthCredentials

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| is_proxy | bool |
| host | string |
| port | int |
| realm | string |
| scheme | string |
| callback | AuthCallback |
| __Return__ | bool |{

Called on the IO thread when the browser needs credentials from the user.
|is_proxy| indicates whether the host is a proxy server. |host| contains the
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

Example implementations:
- Using Kivy framework: see [this commit](https://github.com/allestuetsmerweh/garden.cefpython/commit/d0d77283230adccdb838e6053ceed29845acd2eb)
  in the garden.cefpython project.
- For Windows using WinAPI and C++. This is deprecated code from
  CEF Python 1: [[1]](https://github.com/cztomczak/cefpython/tree/cefpython31/cefpython/cef1/http_authentication),
  [[2]](https://github.com/cztomczak/cefpython/blob/cefpython31/cefpython/request_handler_cef1.pyx#L231),
  [[3]](https://github.com/cztomczak/cefpython/blob/cefpython31/cefpython/http_authentication_win.pyx).


### GetCookieManager

| Parameter | Type |
| --- | --- |
| browser | None or [Browser](Browser.md) |
| main_url | string |
| __Return__ | [CookieManager](CookieManager.md) |

Called on the IO thread to retrieve the cookie manager. |main_url|
is the URL of the top-level frame. Cookies managers can be unique
per browser or shared across multiple browsers. The global cookie
manager will be used if this method returns None.

**IMPORTANT**: In some cases this callback is not called due to a
race condition. See Issue [#429](../../../issues/429) for details.

To successfully implement separate cookie manager per browser session,
you have to set ApplicationSettings.`unique_request_context_per_browser`
to True. Otherwise the browser param passed to this callback will
always be the same first browser that was created using
[cefpython](cefpython.md).`CreateBrowserSync`.

**NOTE**: If implementing custom cookie managers you will encounter
problems similar to [Issue #365](../../../issues/365) ("Cookies not
flushed to disk when closing app immediately"). To resolve
it you have to call CookieManager.[FlushStore](CookieManager.md#flushstore)
method when closing associated browser.

Popup browsers created javascript's window.open share the same
renderer process and request context. If you want to have separate
cookie managers for popups created using window.open then you have
to implement the LifespanHandler.`OnBeforePopup` callback. Return
True in that callback to cancel popup creation and instead create
the window on your own and embed browser in it.
The `CreateAnotherBrowser` function from the old v31 wxpython
example does that.


### GetResourceHandler

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| __Return__ | [ResourceHandler](ResourceHandler.md) |

Called on the IO thread before a resource is loaded. To allow the resource
to load normally return None. To specify a handler for the resource return
a [ResourceHandler](ResourceHandler.md) object. The |request| object should
not be modified in this callback.

The [ResourceHandler](ResourceHandler.md) object is a python class that
implements the `ResourceHandler` callbacks. Remember to keep a strong
reference to this object while resource is being loaded.

The `GetResourceHandler` example can be found in the old v31
"wxpython-response.py" script on Linux.


### OnBeforeBrowse

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| user_gesture | bool |
| is_redirect | bool |
| __Return__ | bool |

Description from upstream CEF:
> Called on the UI thread before browser navigation. Return true to cancel
> the navigation or false to allow the navigation to proceed. The |request|
> object cannot be modified in this callback.
> CefLoadHandler::OnLoadingStateChange will be called twice in all cases.
> If the navigation is allowed CefLoadHandler::OnLoadStart and
> CefLoadHandler::OnLoadEnd will be called. If the navigation is canceled
> CefLoadHandler::OnLoadError will be called with an |errorCode| value of
> ERR_ABORTED. The |user_gesture| value will be true if the browser
> navigated via explicit user gesture (e.g. clicking a link) or false if it
> navigated automatically (e.g. via the DomContentLoaded event).


### _OnBeforePluginLoad

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| mime_type | string |
| plugin_url | string |
| is_main_frame | bool |
| top_origin_url | string |
| plugin_info | [WebPluginInfo](WebPluginInfo.md) |
| __Return__ | bool |

Description from upstream CEF:
> Called on multiple browser process threads before a plugin instance is
> loaded. |mime_type| is the mime type of the plugin that will be loaded.
> |plugin_url| is the content URL that the plugin will load and may be empty.
> |is_main_frame| will be true if the plugin is being loaded in the main
> (top-level) frame, |top_origin_url| is the URL for the top-level frame that
> contains the plugin when loading a specific plugin instance or empty when
> building the initial list of enabled plugins for 'navigator.plugins'
> JavaScript state. |plugin_info| includes additional information about the
> plugin that will be loaded. |plugin_policy| is the recommended policy.
> Modify |plugin_policy| and return true to change the policy. Return false
> to use the recommended policy. The default plugin policy can be set at
> runtime using the `--plugin-policy=[allow|detect|block]` command-line flag.
> Decisions to mark a plugin as disabled by setting |plugin_policy| to
> PLUGIN_POLICY_DISABLED may be cached when |top_origin_url| is empty. To
> purge the plugin list cache and potentially trigger new calls to this
> method call CefRequestContext::PurgePluginListCache.

Return True to block loading of the plugin.

This callback will be executed during browser creation, thus you must
call [cefpython](cefpython.md).SetGlobalClientCallback() to use it.
The callback name was prefixed with "`_`" to distinguish this special
behavior.

Plugins are loaded on demand, only when website requires it.
This callback is called every time the page tries to load a plugin
(perhaps even multiple times per plugin).


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


### _OnCertificateError

| Parameter | Type |
| --- | --- |
| cert_error | [NetworkError](NetworkError.md) |
| request_url | string |
| callback | RequestCallback |
| __Return__ | bool |

This callback is not associated with any specific browser, thus you
must call [cefpython](cefpython.md).SetGlobalClientCallback() to use
it. The callback name was prefixed with "`_`" to distinguish this
special behavior.

Called on the UI thread to handle requests for URLs with an invalid
SSL certificate. Return true and call CefRequestCallback::Continue() either
in this method or at a later time to continue or cancel the request. Return
false to cancel the request immediately. If
CefSettings.ignore_certificate_errors is set all invalid certificates will
be accepted without calling this method.

The `RequestCallback` object methods:
  * void Continue(bool allow)
  * void Cancel()


### OnQuotaRequest

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| origin_url | string |
| new_size | long |
| callback | RequestCallback |
| __Return__ | bool |

Called on the IO thread when javascript requests a specific storage quota
size via the `webkitStorageInfo.requestQuota` function. |origin_url| is the
origin of the page making the request. |new_size| is the requested quota
size in bytes. Return true to continue the request and call
CefRequestCallback::Continue() either in this method or at a later time to
grant or deny the request. Return false to cancel the request immediately.

The `RequestCallback` object methods:
* void Continue(bool allow)
* void Cancel()


### OnResourceRedirect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| old_url | string |
| new_url_out | list[string] |
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


### OnResourceResponse

| | |
| --- | --- |
| __Return__ | void |

Available in upstream CEF, but not yet exposed to CEF Python.
See Issue #229.

You can implement this functionality by using
[ResourceHandler](ResourceHandler.md) and [WebRequest](WebRequest.md)
/ [WebRequestClient](WebRequestClient.md). For an example see the
_OnResourceResponse() method in the old v31 [wxpython-response.py]
example.


### OnPluginCrashed

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| plugin_path | string |
| __Return__ | void |

Called when a plugin has crashed. |plugin_path| is the path of the plugin
that crashed.


### OnProtocolExecution

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| url | string |
| allow_execution_out | list[bool] |
| __Return__ | void |

Called on the UI thread to handle requests for URLs with an unknown
protocol component. Set |allow_execution_out[0]| to True to attempt
execution via the registered OS protocol handler, if any.

__SECURITY NOTE__: You should use this callback to enforce restrictions
based on scheme, host or other url analysis before allowing OS execution.

There's no default implementation for OnProtocolExecution on Linux,
you have to make OS system call on your own. You probably also need
to use [LoadHandler](LoadHandler.md)::OnLoadError() when implementing
this on Linux.


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
