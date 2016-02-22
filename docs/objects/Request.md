# Request class #

Object of this class is used in [RequestHandler](RequestHandler).`OnBeforeBrowse()` and [RequestHandler](RequestHandler).`OnBeforeResourceLoad()`.

## CEF 3 ##

static `Request` **CreateRequest**()

> You cannot instantiate `Request` class directly, use this static method
> instead by calling `cefpython.Request.CreateRequest()`.

bool **IsReadOnly**()

> Returns true if this object is read-only.

str **GetUrl**()

> Get the fully qualified url.

void **SetUrl**(string url)

> Set the fully qualified url.

str **GetMethod**()

> Get the request method type. The value will default to POST
> if post data is provided and GET otherwise.

void **SetMethod**(string method)

> Set the request method type.

list|dict **GetPostData**()

> Get the post data. If the form content type is "multipart/form-data"
> then the post data will be returned as a list. If the form content
> type is "application/x-www-form-urlencoded" then the post data will
> be returned as a dict.

void **SetPostData**(list|dict postData)

> Set the post data. See `GetPostData()` for an explanation of the
> postData type.

dict **GetHeaderMap**()

> Get all header fields with duplicate keys overwritten by last.

list **GetHeaderMultimap**()

> Get all header fields. Returns list of tuples (name, value). Headers may have duplicate keys, if you want to ignore duplicates use `GetHeaderMap()`.

void **SetHeaderMap**(dict `headerMap`)

> Set all header fields.

void **SetHeaderMultimap**(list `headerMultimap`)

> Set all header fields. `headerMultimap` must be a list of tuples (name, value).

int **GetFlags**()

> Get the flags used in combination with WebRequest.

> Available flags (access via `cefpython.Request.Flags["xxx"]`):

  * **None** - Default behavior.<br>
<ul><li><b>SkipCache</b> - If set the cache will be skipped when handling the request.<br>
</li><li><b>AllowCachedCredentials</b> - If set user name, password, and cookies may be sent with the request.<br>
</li><li><b>AllowCookies</b> - If set cookies may be sent with the request and saved from the response. <code>AllowCachedCredentials</code> must also be set.<br>
</li><li><b>ReportUploadProgress</b> - If set upload progress events will be generated when a request has a body.<br>
</li><li><b>ReportLoadTiming</b> - If set load timing info will be collected for the request.<br>
</li><li><b>ReportRawHeaders</b> - If set the headers sent and received for the request will be recorded.<br>
</li><li><b>NoDownloadData</b> - If set the <a href='WebRequestClient'>WebRequestClient</a>::<code>OnDownloadData</code> method will not be called.<br>
</li><li><b>NoRetryOn5xx</b> - If set 5xx redirect errors will be propagated to the observer instead of automatically re-tried. This currently only applies for requests originated in the browser process.</li></ul>

void <b>SetFlags</b>(int flags)<br>
<br>
<blockquote>Set the flags used in combination with <a href='WebRequest'>WebRequest</a>.</blockquote>

str <b>GetFirstPartyForCookies</b>()<br>
<br>
<blockquote>Get the url to the first party for cookies used in combination with<br>
WebRequest.</blockquote>

void <b>SetFirstPartyForCookies</b>(string url)<br>
<br>
<blockquote>Set the url to the first party for cookies used in combination with<br>
WebRequest.</blockquote>

int <b>GetResourceType</b>()<br>
<br>
<blockquote>Not yet implemented in CEF Python.</blockquote>

<blockquote>Get the resource type for this request. Accurate resource type information may only be available in the browser process.</blockquote>

<pre><code>  // Top level page.<br>
  RT_MAIN_FRAME<br>
  // Frame or iframe.<br>
  RT_SUB_FRAME,<br>
  // CSS stylesheet.<br>
  RT_STYLESHEET,<br>
  // External script.<br>
  RT_SCRIPT,<br>
  // Image (jpg/gif/png/etc).<br>
  RT_IMAGE,<br>
  // Font.<br>
  RT_FONT_RESOURCE,<br>
  // Some other subresource. This is the default type if the actual type is unknown.<br>
  RT_SUB_RESOURCE,<br>
  // Object (or embed) tag for a plugin, or a resource that a plugin requested.<br>
  RT_OBJECT,<br>
  // Media resource.<br>
  RT_MEDIA,<br>
  // Main resource of a dedicated worker.<br>
  RT_WORKER,<br>
  // Main resource of a shared worker.<br>
  RT_SHARED_WORKER,<br>
  // Explicitly requested prefetch.<br>
  RT_PREFETCH,<br>
  // Favicon.<br>
  RT_FAVICON,<br>
  // XMLHttpRequest.<br>
  RT_XHR,<br>
</code></pre>

int <b>GetTransitionType</b>()<br>
<br>
<blockquote>Not yet implemented in CEF Python.</blockquote>

<blockquote>Get the transition type for this request. Only available in the browser<br>
process and only applies to requests that represent a main frame or<br>
sub-frame navigation.</blockquote>

<pre><code>///<br>
// Transition type for a request. Made up of one source value and 0 or more<br>
// qualifiers.<br>
///<br>
enum cef_transition_type_t {<br>
  ///<br>
  // Source is a link click or the JavaScript window.open function. This is<br>
  // also the default value for requests like sub-resource loads that are not<br>
  // navigations.<br>
  ///<br>
  TT_LINK = 0,<br>
<br>
  ///<br>
  // Source is some other "explicit" navigation action such as creating a new<br>
  // browser or using the LoadURL function. This is also the default value<br>
  // for navigations where the actual type is unknown.<br>
  ///<br>
  TT_EXPLICIT = 1,<br>
<br>
  ///<br>
  // Source is a subframe navigation. This is any content that is automatically<br>
  // loaded in a non-toplevel frame. For example, if a page consists of several<br>
  // frames containing ads, those ad URLs will have this transition type.<br>
  // The user may not even realize the content in these pages is a separate<br>
  // frame, so may not care about the URL.<br>
  ///<br>
  TT_AUTO_SUBFRAME = 3,<br>
<br>
  ///<br>
  // Source is a subframe navigation explicitly requested by the user that will<br>
  // generate new navigation entries in the back/forward list. These are<br>
  // probably more important than frames that were automatically loaded in<br>
  // the background because the user probably cares about the fact that this<br>
  // link was loaded.<br>
  ///<br>
  TT_MANUAL_SUBFRAME = 4,<br>
<br>
  ///<br>
  // Source is a form submission by the user. NOTE: In some situations<br>
  // submitting a form does not result in this transition type. This can happen<br>
  // if the form uses a script to submit the contents.<br>
  ///<br>
  TT_FORM_SUBMIT = 7,<br>
<br>
  ///<br>
  // Source is a "reload" of the page via the Reload function or by re-visiting<br>
  // the same URL. NOTE: This is distinct from the concept of whether a<br>
  // particular load uses "reload semantics" (i.e. bypasses cached data).<br>
  ///<br>
  TT_RELOAD = 8,<br>
<br>
  ///<br>
  // General mask defining the bits used for the source values.<br>
  ///<br>
  TT_SOURCE_MASK = 0xFF,<br>
<br>
  // Qualifiers.<br>
  // Any of the core values above can be augmented by one or more qualifiers.<br>
  // These qualifiers further define the transition.<br>
<br>
  ///<br>
  // Attempted to visit a URL but was blocked.<br>
  ///<br>
  TT_BLOCKED_FLAG = 0x00800000,<br>
<br>
  ///<br>
  // Used the Forward or Back function to navigate among browsing history.<br>
  ///<br>
  TT_FORWARD_BACK_FLAG = 0x01000000,<br>
<br>
  ///<br>
  // The beginning of a navigation chain.<br>
  ///<br>
  TT_CHAIN_START_FLAG = 0x10000000,<br>
<br>
  ///<br>
  // The last transition in a redirect chain.<br>
  ///<br>
  TT_CHAIN_END_FLAG = 0x20000000,<br>
<br>
  ///<br>
  // Redirects caused by JavaScript or a meta refresh tag on the page.<br>
  ///<br>
  TT_CLIENT_REDIRECT_FLAG = 0x40000000,<br>
<br>
  ///<br>
  // Redirects sent from the server by HTTP headers.<br>
  ///<br>
  TT_SERVER_REDIRECT_FLAG = 0x80000000,<br>
<br>
  ///<br>
  // Used to test whether a transition involves a redirect.<br>
  ///<br>
  TT_IS_REDIRECT_MASK = 0xC0000000,<br>
<br>
  ///<br>
  // General mask defining the bits used for the qualifiers.<br>
  ///<br>
  TT_QUALIFIER_MASK = 0xFFFFFF00,<br>
};<br>
</code></pre>

<h2>CEF 1</h2>

static <code>Request</code> <b>CreateRequest</b>()<br>
<br>
<blockquote>You cannot instantiate <code>Request</code> class directly, use this static method<br>
instead by calling <code>cefpython.Request.CreateRequest()</code>.</blockquote>

str <b>GetUrl</b>()<br>
<br>
<blockquote>Get the fully qualified url.</blockquote>

void <b>SetUrl</b>(string url)<br>
<br>
<blockquote>Set the fully qualified url.</blockquote>

str <b>GetMethod</b>()<br>
<br>
<blockquote>Get the request method type. The value will default to POST<br>
if post data is provided and GET otherwise.</blockquote>

void <b>SetMethod</b>(string method)<br>
<br>
<blockquote>Set the request method type.</blockquote>

list|dict <b>GetPostData</b>()<br>
<br>
<blockquote>Get the post data. If the form content type is "multipart/form-data"<br>
then the post data will be returned as a list. If the form content<br>
type is "application/x-www-form-urlencoded" then the post data will<br>
be returned as a dict.</blockquote>

void <b>SetPostData</b>(list|dict postData)<br>
<br>
<blockquote>Set the post data. See <code>GetPostData()</code> for an explanation of the<br>
postData type.</blockquote>

dict <b>GetHeaderMap</b>()<br>
<br>
<blockquote>Get all header fields with duplicate keys overwritten by last.</blockquote>

list <b>GetHeaderMultimap</b>()<br>
<br>
<blockquote>Get all header fields. Returns list of tuples (name, value). Headers may have duplicate keys, if you want to ignore duplicates use <code>GetHeaderMap()</code>.</blockquote>

void <b>SetHeaderMap</b>(dict <code>headerMap</code>)<br>
<br>
<blockquote>Set all header fields.</blockquote>

void <b>SetHeaderMultimap</b>(list <code>headerMultimap</code>)<br>
<br>
<blockquote>Set all header fields. <code>headerMultimap</code> must be a list of tuples (name, value).</blockquote>

int <b>GetFlags</b>()<br>
<br>
<blockquote>Get the flags used in combination with WebRequest.</blockquote>

<blockquote>Available flags (access via cefpython.Request.Flags["xxx"]):</blockquote>

<blockquote><code>None</code><br>
<code>SkipCache</code><br>
<code>AllowCachedCredentials</code><br>
<code>AllowCookies</code><br>
<code>ReportUploadProgress</code><br>
<code>ReportLoadTiming</code><br>
<code>ReportRawHeaders</code></blockquote>

void <b>SetFlags</b>(int flags)<br>
<br>
<blockquote>Set the flags used in combination with <a href='WebRequest'>WebRequest</a>.</blockquote>

str <b>GetFirstPartyForCookies</b>()<br>
<br>
<blockquote>Get the url to the first party for cookies used in combination with<br>
WebRequest.</blockquote>

void <b>SetFirstPartyForCookies</b>(string url)<br>
<br>
<blockquote>Set the url to the first party for cookies used in combination with<br>
WebRequest.