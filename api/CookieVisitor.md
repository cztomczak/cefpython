[API categories](API-categories.md) | [API index](API-index.md)


# CookieVisitor (interface)

See [CookieManager](CookieManager.md).VisitAllCookies() and [CookieManager](CookieManager.md).VisitUrlCookies().

You must keep a strong reference to the [CookieVisitor](CookieVisitor.md) object
while visiting cookies, otherwise it gets destroyed and the
[CookieVisitor](CookieVisitor.md) callbacks won't be called.


Table of contents:
* [Callbacks](#callbacks)
  * [Visit](#visit)


## Callbacks


### Visit

| Parameter | Type |
| --- | --- |
| cookie | [Cookie](Cookie.md) |
| count | int |
| total | int |
| delete_cookie_out | list[bool] |
| __Return__ | bool |

Method that will be called once for each cookie. |count| is the 0-based
index for the current cookie. |total| is the total number of cookies.
Set |delete_cookie_out[0]| to True to delete the cookie currently being visited.
Return False to stop visiting cookies, True to continue. This method may
never be called if no cookies are found.
