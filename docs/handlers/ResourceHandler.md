# `ResourceHandler` callbacks #

Class used to implement a custom request handler interface. The methods of this class will always be called on the IO thread.

See [RequestHandler](RequestHandler).`GetResourceHandler()`.

You must keep a strong reference to the `ResourceHandler` object while resource is being loaded, otherwise it gets destroyed and the `ResourceHandler` callbacks won't be called.

Make requests using [WebRequest](WebRequest) and [WebRequestClient](WebRequestClient).

The `ResourceHandler` example can be found in the [wxpython-response.py](../blob/master/cefpython/cef3/linux/binaries_64bit/wxpython-response.py) script.

## CEF 3 ##

bool **ProcessRequest**([Request](Request) request, [Callback](Callback) callback)

> Begin processing the request. To handle the request return True and call
> [Callback](Callback).`Continue()` once the response header information is available
> (`Callback::Continue()` can also be called from inside this method if
> header information is available immediately). To cancel the request return
> False.


void **GetResponseHeaders**([Response](Response) response, list& responseLengthOut, list& redirectUrlOut)

> Retrieve response header information. If the response length is not known
> set `responseLengthOut[0]` to -1 and `ReadResponse()` will be called until it
> returns false. If the response length is known set `responseLengthOut[0]`
> to a positive value and `ReadResponse()` will be called until it returns
> false or the specified number of bytes have been read. Use the |response|
> object to set the mime type, http status code and other optional header
> values. To redirect the request to a new URL set `redirectUrlOut[0]` to the new url.


bool **ReadResponse**(list& dataOut, int bytesToRead, list& bytesReadOut, [Callback](Callback) callback)

> Read response data. If data is available immediately copy up to
> `bytesToRead` bytes into `dataOut[0]`, set `bytesReadOut[0]` to the number of
> bytes copied, and return true. To read the data at a later time set
> `bytesReadOut[0]` to 0, return true and call `callback.Continue()` when the
> data is available. To indicate response completion return false.


bool **CanGetCookie**([Cookie](Cookie) cookie)

> Return true if the specified cookie can be sent with the request or false
> otherwise. If false is returned for any cookie then no cookies will be sent
> with the request.

bool **CanSetCookie**([Cookie](Cookie) cookie)

> Return true if the specified cookie returned with the response can be set
> or false otherwise.

void **Cancel**()

> Request processing has been canceled.