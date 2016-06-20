[API categories](API-categories.md) | [API index](API-index.md)


# WebRequest (class)


Table of contents:
* [Preface](#preface)
* [Methods](#methods)
  * [Create](#create)
  * [GetRequest](#getrequest)
  * [GetRequestStatus](#getrequeststatus)
  * [GetRequestError](#getrequesterror)
  * [GetResponse](#getresponse)
  * [Cancel](#cancel)


## Preface

Class used to make a URL request. URL requests are not associated with a
browser instance so no client handler callbacks will be executed. URL requests
can be created on any valid CEF thread in either the browser or render
process. Once created the methods of the URL request object must be accessed
on the same thread that created it.

The `WebRequest` example can be found in the `wxpython-response.py` script on Linux.


## Methods


### Create

| Parameter | Type |
| --- | --- |
| request | [Request](Request.md) |
| handler | [WebRequestClient](WebRequestClient.md) |
| __Return__ | static [WebRequest](WebRequest.md) |

 You cannot instantiate [WebRequest](WebRequest.md) class directly, use this static
 method instead by calling `cefpython.WebRequest.Create()`.

 The first parameter is a [Request](Request.md) object that needs to be created
 by calling `cefpython.Request.CreateRequest()`.

 The [WebRequestClient](WebRequestClient.md) handler is a python class that implements
 the [WebRequestClient](WebRequestClient.md) callbacks.

 You must keep a strong reference to the [WebRequest](WebRequest.md) object
 during the request, otherwise it gets destroyed and
 the [WebRequestClient](WebRequestClient.md) callbacks won't get called.


### GetRequest

| | |
| --- | --- |
| __Return__ | [Request](Request.md) |

 Returns the request object used to create this URL request. The returned
 object is read-only and should not be modified.


### GetRequestStatus

| | |
| --- | --- |
| __Return__ | RequestStatus |

 Returns the request status. `RequestStatus` can be one of:

 `cefpython.WebRequest.Status["Unknown"]` - Unknown status.  
 `cefpython.WebRequest.Status["Success"]` - Request succeeded.  
 `cefpython.WebRequest.Status["Pending"]` - An IO request is pending, and the caller will be informed when it is completed.  
 `cefpython.WebRequest.Status["Canceled"]` - Request was canceled programatically.  
 `cefpython.WebRequest.Status["Failed"]` - Request failed for some reason.  


### GetRequestError

| | |
| --- | --- |
| __Return__ | [NetworkError](NetworkError.md) |

 Returns the request error if status is "Canceled" or "Failed", or 0  
 otherwise.


### GetResponse

| | |
| --- | --- |
| __Return__ | [Response](Response.md) |

 Returns the response, or None if no response information is available.  
 Response information will only be available after the upload has completed.  
 The returned object is read-only and should not be modified.


### Cancel

| | |
| --- | --- |
| __Return__ | void |

 Cancel the request.
