[API categories](API-categories.md) | [API index](API-index.md)


# Request (class)

Object of this class is used in [RequestHandler](RequestHandler.md).OnBeforeBrowse() and [RequestHandler](RequestHandler.md).OnBeforeResourceLoad().


Table of contents:
* [Methods](#methods)
  * [CreateRequest](#createrequest)
  * [IsReadOnly](#isreadonly)
  * [GetUrl](#geturl)
  * [SetUrl](#seturl)
  * [GetMethod](#getmethod)
  * [SetMethod](#setmethod)
  * [GetPostData](#getpostdata)
  * [SetPostData](#setpostdata)
  * [GetHeaderMap](#getheadermap)
  * [GetHeaderMultimap](#getheadermultimap)
  * [SetHeaderMap](#setheadermap)
  * [SetHeaderMultimap](#setheadermultimap)
  * [GetFlags](#getflags)
  * [SetFlags](#setflags)
  * [GetFirstPartyForCookies](#getfirstpartyforcookies)
  * [SetFirstPartyForCookies](#setfirstpartyforcookies)
  * [GetResourceType](#getresourcetype)
  * [GetTransitionType](#gettransitiontype)


## Methods


### CreateRequest

| | |
| --- | --- |
| __Return__ | static Request |

You cannot instantiate `Request` class directly, use this static method
instead by calling `cefpython.Request.CreateRequest()`.


### IsReadOnly

| | |
| --- | --- |
| __Return__ | bool |

Returns true if this object is read-only.


### GetUrl

| | |
| --- | --- |
| __Return__ | str |

Get the fully qualified url.


### SetUrl

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

Set the fully qualified url.


### GetMethod

| | |
| --- | --- |
| __Return__ | str |

Get the request method type. The value will default to POST
if post data is provided and GET otherwise.


### SetMethod

| Parameter | Type |
| --- | --- |
| method | string |
| __Return__ | void |

Set the request method type.


### GetPostData

| | |
| --- | --- |
| __Return__ | list/dict |

Get the post data. All strings are byte strings. If the form content
type is "multipart/form-data" then the post data will be returned
as a list. If the form content type is
"application/x-www-form-urlencoded" then the post data will
be returned as a dict.


### SetPostData

| Parameter | Type |
| --- | --- |
| postData | list/dict |
| __Return__ | void |

Set the post data. All strings are expected to be byte strings.
See GetPostData() for an explanation of the postData type.

### GetHeaderMap

| | |
| --- | --- |
| __Return__ | dict |

Get the header values. Will not include the Referer value if any.

Duplicate values are overwritten by the last one.


### GetHeaderMultimap

| | |
| --- | --- |
| __Return__ | list |

Get the header values. Will not include the Referer value if any.

Returns list of tuples (name, value). Headers may have duplicate keys,
if you want to ignore duplicates use GetHeaderMap().


### SetHeaderMap

| Parameter | Type |
| --- | --- |
| headerMap | dict |
| __Return__ | void |

Set the header values. If a Referer value exists in the header map it will
be removed and ignored.


### SetHeaderMultimap

| Parameter | Type |
| --- | --- |
| headerMultimap | list |
| __Return__ | void |

Set the header values. If a Referer value exists in the header map it will
be removed and ignored.

`headerMultimap` must be a list of tuples (name, value).


### GetFlags

| | |
| --- | --- |
| __Return__ | int |

Get the flags used in combination with WebRequest.

Available flags below. Can be accessed via `cefpython.Request.Flags["xxx"]`.
These flags are also defined as constants starting with "UR_FLAG_"
in the cefpython module.requ

* **None** - Default behavior.
* **SkipCache** - If set the cache will be skipped when handling the request. Setting this value is equivalent to specifying the "Cache-Control: no-cache" request header. Setting this value in combination with UR_FLAG_ONLY_FROM_CACHE will cause the request to fail.
* **OnlyFromCache** - If set the request will fail if it cannot be served from the cache (or some equivalent local store). Setting this value is equivalent to specifying the "Cache-Control: only-if-cached" request header. Setting this value in combination with UR_FLAG_SKIP_CACHE will cause the request to fail.
* **AllowStoredCredentials** - If set user name, password, and cookies may be sent with the request, and cookies may be saved from the response.
* **ReportUploadProgress** - If set upload progress events will be generated when a request has a body.
* **NoDownloadData** - If set the [WebRequestClient](WebRequestClient.md)::`OnDownloadData` method will not be called.
* **NoRetryOn5xx** - If set 5xx redirect errors will be propagated to the observer instead of automatically re-tried. This currently only applies for requests originated in the browser process.
* **StopOnRedirect** - If set 3XX responses will cause the fetch to halt immediately rather than continue through the redirect.




### SetFlags

| Parameter | Type |
| --- | --- |
| flags | int |
| __Return__ | void |

Set the flags used in combination with [WebRequest](WebRequest.md).
See GetFlags() for possible values.


### GetFirstPartyForCookies

| | |
| --- | --- |
| __Return__ | str |

Get the url to the first party for cookies used in combination with
WebRequest.


### SetFirstPartyForCookies

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

Set the url to the first party for cookies used in combination with
WebRequest.


### GetResourceType

| | |
| --- | --- |
| __Return__ | int |

Not yet implemented in CEF Python.

Get the resource type for this request. Only available in the browser
process.


### GetTransitionType

| | |
| --- | --- |
| __Return__ | int |

Not yet implemented in CEF Python.

Get the transition type for this request. Only available in the browser
process and only applies to requests that represent a main frame or
sub-frame navigation.

