# CookieVisitor callbacks #

See [CookieManager](CookieManager).`VisitAllCookies()` and [CookieManager](CookieManager).`VisitUrlCookies()`.

You must keep a strong reference to the [CookieVisitor](CookieVisitor) object
while visiting cookies, otherwise it gets destroyed and the
[CookieVisitor](CookieVisitor) callbacks won't be called.

## CEF 1, CEF 3 ##

bool **Visit**([Cookie](Cookie) cookie, int count, int total, list deleteCookie)

> Method that will be called once for each cookie. |count| is the 0-based
> index for the current cookie. |total| is the total number of cookies.
> Set |`deleteCookie[0]`| to True to delete the cookie currently being visited.
> Return False to stop visiting cookies, True to continue. This method may
> never be called if no cookies are found.