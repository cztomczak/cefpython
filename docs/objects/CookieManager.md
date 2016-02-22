# CookieManager class #

This class cannot be instantiated directly, use the `CreateManager()`
static method for this purpose.

The cookie tests can be found in the wxpython.py script.

## CEF 3 ##

static [CookieManager](CookieManager) **GetGlobalManager**()

> Returns the global cookie manager. By default data will be stored at
> [ApplicationSettings](ApplicationSettings).cache\_path if specified or in memory otherwise.

static [CookieManager](CookieManager) **CreateManager**(string path, bool `persistSessionCookies`=False)

> Creates a new cookie manager. Otherwise, data will be stored at the
> specified |path|. To persist session cookies (cookies without an expiry
> date or validity interval) set |persistSessionCookies|
> to true. If using global manager then see the [ApplicationSettings](ApplicationSettings).`persist_session_cookies`
> option. Session cookies are generally intended to be transient and most
> Web browsers do not persist them. Returns None if creation fails.

> You can have a separate cookie manager for each browser,
> see [RequestHandler](RequestHandler).`GetCookieManager()`.

void **SetSupportedSchemes**(list schemes)

> Set the schemes supported by this manager. By default only "http" and
> "https" schemes are supported. Must be called before any cookies are
> accessed.

bool **VisitAllCookies**([CookieVisitor](CookieVisitor) object)

> Visit all cookies. The returned cookies are ordered by longest path,
> then by earliest creation date. Returns false if cookies cannot be
> accessed.

> The `CookieVisitor` object is a python class that implements the `CookieVisitor`
> callbacks. You must keep a strong reference to the `CookieVisitor` object while
> visiting cookies, otherwise it gets destroyed and the `CookieVisitor` callbacks
> won't be called.

bool **VisitUrlCookies**(string url, bool includeHttpOnly, [CookieVisitor](CookieVisitor) object)

> Visit a subset of cookies. The results are filtered by the given url
> scheme, host, domain and path. If |includeHttpOnly| is true HTTP-only
> cookies will also be included in the results. The returned cookies are
> ordered by longest path, then by earliest creation date. Returns false
> if cookies cannot be accessed.

> The `CookieVisitor` object is a python class that implements the `CookieVisitor`
> callbacks. You must keep a strong reference to the `CookieVisitor` object while
> visiting cookies, otherwise it gets destroyed and the `CookieVisitor` callbacks
> won't be called.

void **SetCookie**(string url, [Cookie](Cookie) cookie)

> Sets a cookie given a valid URL and a `Cookie` object.
> It will check for disallowed characters (e.g. the ';' character is disallowed
> within the cookie value attribute) and will not set the cookie if such
> characters are found.

> The CEF C++ equivalent function will be called on the IO thread, thus it executes
> asynchronously, when this method returns the cookie will not yet be set.

> TODO: the CEF C++ function returns a true or false value depending on whether it
> succeeded or failed, the return value is not yet implemented in CEF Python,
> as there is currently no API exposed to CEF Python for posting tasks on various threads.

void **DeleteCookies**(string url, string cookie\_name)

> Delete all cookies that match the specified parameters. If both |url| and
> values |cookie\_name| are specified all host and domain cookies matching
> both will be deleted. If only |url| is specified all host cookies (but not
> domain cookies) irrespective of path will be deleted. If |url| is empty all
> cookies for all hosts and domains will be deleted. Deleting cookies will fail
> if a non-empty invalid URL is specified or if cookies cannot be accessed.

> The CEF C++ equivalent function will be called on the IO thread, thus it executes
> asynchronously, when this method returns the cookies will not yet be deleted.

> TODO: the CEF C++ function returns a true or false value depending on whether it
> succeeded or failed, the return value is not yet implemented in CEF Python,
> as there is currently no API exposed to CEF Python for posting tasks on various threads.

bool **SetStoragePath**(string `path`, bool `persist_session_cookies`=False)

> Sets the directory path that will be used for storing cookie data. If
> |path| is empty data will be stored in memory only. Otherwise, data will be
> stored at the specified |path|. To persist session cookies (cookies without
> an expiry date or validity interval) set |persist\_session\_cookies| to true.
> Session cookies are generally intended to be transient and most Web browsers
> do not persist them. Returns false if cookies cannot be accessed.

bool **FlushStore**(`CompletionHandler` handler)

> Not yet implemented.

> Flush the backing store (if any) to disk and execute the specified
> |handler| on the IO thread when done. Returns false if cookies cannot be
> accessed.

## CEF 1 ##

static [CookieManager](CookieManager) **GetGlobalManager**()

> Returns the global cookie manager. By default data will be stored at
> [ApplicationSettings](ApplicationSettings).cache\_path if specified or in memory otherwise.

static [CookieManager](CookieManager) **CreateManager**(string path)

> Creates a new cookie manager. Otherwise, data will be stored at the
> specified |path|. To persist session cookies (cookies without an expiry
> date or validity interval) set |persist\_session\_cookies|
> to true. If using global manager then see the [ApplicationSettings](ApplicationSettings).`persist_session_cookies`
> option. Session cookies are generally intended to be transient and most
> Web browsers do not persist them. Returns None if creation fails.

> You can have a separate cookie manager for each browser,
> see [RequestHandler](RequestHandler).`GetCookieManager()`.

void **SetSupportedSchemes**(list schemes)

> Set the schemes supported by this manager. By default only "http" and
> "https" schemes are supported. Must be called before any cookies are
> accessed.

bool **VisitAllCookies**([CookieVisitor](CookieVisitor) object)

> Visit all cookies. The returned cookies are ordered by longest path,
> then by earliest creation date. Returns false if cookies cannot be
> accessed.

> The `CookieVisitor` object is a python class that implements the `CookieVisitor`
> callbacks. You must keep a strong reference to the `CookieVisitor` object while
> visiting cookies, otherwise it gets destroyed and the `CookieVisitor` callbacks
> won't be called.

bool **VisitUrlCookies**(string url, bool includeHttpOnly, [CookieVisitor](CookieVisitor) object)

> Visit a subset of cookies. The results are filtered by the given url
> scheme, host, domain and path. If |includeHttpOnly| is true HTTP-only
> cookies will also be included in the results. The returned cookies are
> ordered by longest path, then by earliest creation date. Returns false
> if cookies cannot be accessed.

> The `CookieVisitor` object is a python class that implements the `CookieVisitor`
> callbacks. You must keep a strong reference to the `CookieVisitor` object while
> visiting cookies, otherwise it gets destroyed and the `CookieVisitor` callbacks
> won't be called.

void **SetCookie**(string url, [Cookie](Cookie) cookie)

> Sets a cookie given a valid URL and a `Cookie` object.
> It will check for disallowed characters (e.g. the ';' character is disallowed
> within the cookie value attribute) and will not set the cookie if such
> characters are found.

> The CEF C++ equivalent function will be called on the IO thread, thus it executes
> asynchronously, when this method returns the cookie will not yet be set.

> TODO: the CEF C++ function returns a true or false value depending on whether it
> succeeded or failed, the return value is not yet implemented in CEF Python,
> as there is currently no API exposed to CEF Python for posting tasks on various threads.

void **DeleteCookies**(string url, string cookie\_name)

> Delete all cookies that match the specified parameters. If both |url| and
> values |cookie\_name| are specified all host and domain cookies matching
> both will be deleted. If only |url| is specified all host cookies (but not
> domain cookies) irrespective of path will be deleted. If |url| is empty all
> cookies for all hosts and domains will be deleted. Deleting cookies will fail
> if a non-empty invalid URL is specified or if cookies cannot be accessed.

> The CEF C++ equivalent function will be called on the IO thread, thus it executes
> asynchronously, when this method returns the cookies will not yet be deleted.

> TODO: the CEF C++ function returns a true or false value depending on whether it
> succeeded or failed, the return value is not yet implemented in CEF Python,
> as there is currently no API exposed to CEF Python for posting tasks on various threads.

bool **SetStoragePath**(string `path`, bool `persistSessionCookies`=False)

> Sets the directory path that will be used for storing cookie data. If
> |path| is empty data will be stored in memory only. Otherwise, data will be
> stored at the specified |path|. To persist session cookies (cookies without
> an expiry date or validity interval) set |persistSessionCookies| to true.
> Session cookies are generally intended to be transient and most Web browsers
> do not persist them. Returns false if cookies cannot be accessed.