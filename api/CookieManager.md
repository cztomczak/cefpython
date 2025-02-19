[API categories](API-categories.md) | [API index](API-index.md)


# CookieManager (class)

Class used for managing cookies. The methods of this class may be called on
any thread unless otherwise indicated.

Use the `CookieManager.CreateManager` static method to instantiate
this class.

TODO: in upstream CEF some methods here have a callback parameter
that when non-NULL will execute asynchronously on the IO thread
when storage has been initialized. SetCookie and DeleteCookies
also have an OnComplete callback.


Table of contents:
* [Methods](#methods)
  * [GetGlobalManager](#getglobalmanager)
  * [VisitAllCookies](#visitallcookies)
  * [VisitUrlCookies](#visiturlcookies)
  * [SetCookie](#setcookie)
  * [DeleteCookies](#deletecookies)
  * [SetStoragePath](#setstoragepath)
  * [FlushStore](#flushstore)


## Methods


### GetGlobalManager

| | |
| --- | --- |
| __Return__ | [CookieManager](CookieManager.md) |

Returns the global cookie manager. By default data will be stored at
[ApplicationSettings](ApplicationSettings.md).cache_path if specified or in memory otherwise.

Description from upstream CEF:
> Returns the global cookie manager. By default data will be stored at
> CefSettings.cache_path if specified or in memory otherwise. If |callback|
> is non-NULL it will be executed asnychronously on the IO thread after the
> manager's storage has been initialized. Using this method is equivalent to
> calling CefRequestContext::GetGlobalContext()->GetDefaultCookieManager()


### VisitAllCookies

| Parameter | Type |
| --- | --- |
| object | [CookieVisitor](CookieVisitor.md) |
| __Return__ | bool |

Visit all cookies on the IO thread. The returned cookies are ordered by
longest path, then by earliest creation date. Returns false if cookies
cannot be accessed.

The `CookieVisitor` object is a python class that implements the
CookieVisitor`callbacks. You must keep a strong reference to the
CookieVisitor` object while visiting cookies, otherwise it gets
destroyed and the `CookieVisitor` callbacks won't be called.


### VisitUrlCookies

| Parameter | Type |
| --- | --- |
| url | string |
| includeHttpOnly | bool |
| object | [CookieVisitor](CookieVisitor.md) |
| __Return__ | bool |

Visit a subset of cookies on the IO thread. The results are filtered by the
given url scheme, host, domain and path. If |includeHttpOnly| is true
HTTP-only cookies will also be included in the results. The returned
cookies are ordered by longest path, then by earliest creation date.
Returns false if cookies cannot be accessed.

The `CookieVisitor` object is a python class that implements the
`CookieVisitor` callbacks. You must keep a strong reference to the
`CookieVisitor` object while visiting cookies, otherwise it gets destroyed
and the `CookieVisitor` callbacks won't be called.


### SetCookie

| Parameter | Type |
| --- | --- |
| url | string |
| cookie | [Cookie](Cookie.md) |
| __Return__ | void |

Sets a cookie given a valid URL and a `Cookie` object.
It will check for disallowed characters (e.g. the ';' character is disallowed
within the cookie value attribute) and fail without setting the cookie if
such characters are found. Returns
false if an invalid URL is specified or if cookies cannot be accessed.

The CEF C++ equivalent function will be called on the IO thread, thus
it executes asynchronously, when this method returns the cookie will
not yet be set.

TODO: the CEF C++ function returns false if an invalid URL
is specified or if cookies cannot be accessed.


### DeleteCookies

| Parameter | Type |
| --- | --- |
| url | string |
| cookie_name | string |
| __Return__ | void |

Delete all cookies that match the specified parameters. If both |url| and
|cookie_name| values are specified all host and domain cookies matching
both will be deleted. If only |url| is specified all host cookies (but not
domain cookies) irrespective of path will be deleted. If |url| is empty all
cookies for all hosts and domains will be deleted.
Cookies can alternately be deleted using the Visit*Cookies() methods.

The CEF C++ equivalent function will be called on the IO thread,
thus it executes asynchronously, when this method returns the cookies
will not yet be deleted.

TODO: the CEF C++ function returns false if a non-empty invalid URL is
specified or if cookies cannot be accessed.


### SetStoragePath

| Parameter | Type |
| --- | --- |
| path | string |
| persist_session_cookies=False | bool |
| __Return__ | bool |

Sets the directory path that will be used for storing cookie data. If
|path| is empty data will be stored in memory only. Otherwise, data will be
stored at the specified |path|. To persist session cookies (cookies without
an expiry date or validity interval) set |persist_session_cookies| to true.
Session cookies are generally intended to be transient and most Web
browsers do not persist them. Returns false if cookies cannot be accessed.


### FlushStore

| Parameter | Type |
| --- | --- |
| callback | CompletionHandler (optional) |
| __Return__ | bool |

Flush the backing store (if any) to disk. If |callback| is non-NULL it will
be executed asnychronously on the IO thread after the flush is complete.
Returns false if cookies cannot be accessed.

The callback arg is not implemented yet.
