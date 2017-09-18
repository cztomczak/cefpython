[API categories](API-categories.md) | [API index](API-index.md)


# ResourceHandler (interface)

Class used to implement a custom request handler interface. The methods of this class will always be called on the IO thread.

See [RequestHandler](RequestHandler.md).GetResourceHandler().

You must keep a strong reference to the `ResourceHandler` object while resource is being loaded, otherwise it gets destroyed and the `ResourceHandler` callbacks won't be called.

Make requests using [WebRequest](WebRequest.md) and [WebRequestClient](WebRequestClient.md).

The `ResourceHandler` example can be found in the [wxpython-response.py](https://github.com/cztomczak/cefpython/blob/cefpython31/cefpython/cef3/linux/binaries_64bit/wxpython-response.py) script.


Table of contents:
* [Callbacks](#callbacks)
  * [ProcessRequest](#processrequest)
  * [GetResponseHeaders](#getresponseheaders)
  * [ReadResponse](#readresponse)
  * [CanGetCookie](#cangetcookie)
  * [CanSetCookie](#cansetcookie)
  * [Cancel](#cancel)


## Callbacks


### ProcessRequest

| Parameter | Type |
| --- | --- |
| request | [Request](Request.md) |
| callback | [Callback](Callback.md) |
| __Return__ | bool |

Begin processing the request. To handle the request return True and call
[Callback](Callback.md).Continue() once the response header information
is available (`Callback::Continue()` can also be called from inside this
method if header information is available immediately). To cancel the
request return False.


### GetResponseHeaders

| Parameter | Type |
| --- | --- |
| response | [Response](Response.md) |
| response_length_out | list[int] |
| redirect_url_out | list[string] |
| __Return__ | void |

Retrieve response header information. If the response length is not known
set |response_length_out[0]| to -1 and ReadResponse() will be called until it
returns false. If the response length is known set |response_length_out[0]|
to a positive value and ReadResponse() will be called until it returns
false or the specified number of bytes have been read. Use the |response|
object to set the mime type, http status code and other optional header
values. To redirect the request to a new URL set |redirect_url_out[0]|
to the new URL. If an error occured while setting up the request you
can call SetError() on |response| to indicate the error condition.


### ReadResponse

| Parameter | Type |
| --- | --- |
| data_out | list[bytes] |
| bytes_to_read | int |
| bytes_read_out | list[int] |
| callback | [Callback](Callback.md) |
| __Return__ | void |

Read response data. If data is available immediately copy up to
|bytes_to_read| bytes into |data_out|, set |bytes_read_out| to the number of
bytes copied, and return true. To read the data at a later time set
|bytes_read_out| to 0, return true and call `callback.Continue()` when the
data is available. To indicate response completion return false.


### CanGetCookie

| Parameter | Type |
| --- | --- |
| cookie | [Cookie](Cookie.md) |
| __Return__ | bool |

Return true if the specified cookie can be sent with the request or false
otherwise. If false is returned for any cookie then no cookies will be sent
with the request.


### CanSetCookie

| Parameter | Type |
| --- | --- |
| cookie | [Cookie](Cookie.md) |
| __Return__ | bool |

Return true if the specified cookie returned with the response can be set
or false otherwise.


### Cancel

| | |
| --- | --- |
| __Return__ | void |

Request processing has been canceled.
