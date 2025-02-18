[API categories](API-categories.md) | [API index](API-index.md)


# CookieAccessFilter (interface)



Table of contents:
* [Callbacks](#callbacks)
  * [CanSendCookie](#cansendcookie)
  * [CanSaveCookie](#cansavecookie)


## Callbacks


### CanSendCookie

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| cookie | [Cookie](Cookie.md) |
| __Return__ | bool |

Called on the IO thread before a resource is sent. Browser and frame values represent
the source of the request. Return true if the specified cookie can be sent with the
request or false otherwise.

### CanSaveCookie

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| request | [Request](Request.md) |
| response | [Response](Response.md) |
| cookie | [Cookie](Cookie.md) |
| __Return__ | bool |

Called on the IO thread after a resource response is received. Browser and frame values
represent the source of the request. Return true if the specified cookie returned with
the response can be saved or false otherwise.

