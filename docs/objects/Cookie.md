# Cookie class #

See also [CookieManager](CookieManager).`SetCookie()` and [CookieVisitor](CookieVisitor).`Visit()`.

## CEF 1, CEF 3 ##

void **Set**(dict cookie)

> Set cookie properties via a dict.

> The cookie may have the following keys:<br>
<blockquote>- name (str)<br>
- value (str)<br>
- domain (str)<br>
- path (str)<br>
- secure (bool)<br>
- httpOnly (bool)<br>
- creation (datetime.datetime)<br>
- lastAccess (datetime.datetime)<br>
- hasExpires (bool)<br>
- expires (datetime.datetime)<br></blockquote>

dict <b>Get</b>()<br>
<br>
<blockquote>Get all cookie properties as a dict.</blockquote>

void <b>SetName</b>(string name)<br>
<br>
<blockquote>Set the cookie name.</blockquote>

string <b>GetName</b>()<br>
<br>
<blockquote>Get the cookie name.</blockquote>

void <b>SetValue</b>(string value)<br>
<br>
<blockquote>Set the cookie value.</blockquote>

string <b>GetValue</b>()<br>
<br>
<blockquote>Get the cookie value.</blockquote>

void <b>SetDomain</b>(string domain)<br>
<br>
<blockquote>If |domain| is empty a host cookie will be<br>
created instead of a domain cookie. Domain cookies are stored with a<br>
leading "." and are visible to sub-domains whereas host cookies are<br>
not.</blockquote>

string <b>GetDomain</b>()<br>
<br>
<blockquote>Get the cookie domain.</blockquote>

void <b>SetPath</b>(string path)<br>
<br>
<blockquote>If |path| is non-empty only URLs at or below the path will get the<br>
cookie value.</blockquote>

string <b>GetPath</b>()<br>
<br>
<blockquote>Get the cookie path.</blockquote>

void <b>SetSecure</b>(bool secure)<br>
<br>
<blockquote>If |secure| is true the cookie will only be sent for HTTPS requests.</blockquote>

bool <b>GetSecure</b>()<br>
<br>
<blockquote>Get the secure property.</blockquote>

void <b>SetHttpOnly</b>(bool httpOnly)<br>
<br>
<blockquote>If |httponly| is true the cookie will only be sent for HTTP requests.</blockquote>

bool <b>GetHttpOnly</b>()<br>
<br>
<blockquote>Get the httpOnly property.</blockquote>

void <b>SetCreation</b>(datetime.datetime creation)<br>
<br>
<blockquote>The cookie creation date. This is automatically populated by the system on<br>
cookie creation.</blockquote>

datetime.datetime <b>GetCreation</b>()<br>
<br>
<blockquote>Get the creation property.</blockquote>

void <b>SetLastAccess</b>(datetime.datetime lastAccess)<br>
<br>
<blockquote>The cookie last access date. This is automatically populated by the system<br>
on access.</blockquote>

datetime.datetime <b>GetLastAccess</b>()<br>
<br>
<blockquote>Get the lastAccess property.</blockquote>

void <b>SetHasExpires</b>(bool hasExpires)<br>
<br>
<blockquote>The cookie expiration date is only valid if |hasExpires| is true.</blockquote>

bool <b>GetHasExpires</b>()<br>
<br>
<blockquote>Get the hasExpires property.</blockquote>

void <b>SetExpires</b>(datetime.datetime expires)<br>
<br>
<blockquote>Set the cookie expiration date. You should also call <code>SetHasExpires()</code>.</blockquote>

datetime.datetime <b>GetExpires</b>()<br>
<br>
<blockquote>Get the expires property.