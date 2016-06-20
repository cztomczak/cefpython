[API categories](API-categories.md) | [API index](API-index.md)


# WebRequestClient (interface)

See [WebRequest](WebRequest.md).CreateWebRequest().

You have to keep a strong reference to the [WebRequest](WebRequest.md) object
during the request, otherwise it gets destroyed and
the [WebRequestClient](WebRequestClient.md) callbacks won't get called.

Table of contents:
* [Callbacks](#callbacks)
  * [OnUploadProgress](#onuploadprogress)
  * [OnDownloadProgress](#ondownloadprogress)
  * [OnDownloadData](#ondownloaddata)
  * [OnRequestComplete](#onrequestcomplete)
  * [GetAuthCredentials](#getauthcredentials)


## Callbacks

The methods of this class will be called on the same thread that
created the request unless otherwise documented.


### OnUploadProgress

| Parameter | Type |
| --- | --- |
| webRequest | [WebRequest](WebRequest.md) |
| current | long |
| total | long |
| __Return__ | void |

Notifies the client of upload progress. |current| denotes the number of
bytes sent so far and |total| is the total size of uploading data (or -1 if
chunked upload is enabled). This method will only be called if the
`ReportUploadProgress` flag is set on the request (see [Request](Request.md).GetFlags()
and SetFlags())


### OnDownloadProgress

| Parameter | Type |
| --- | --- |
| webRequest | [WebRequest](WebRequest.md) |
| current | long |
| total | long |
| __Return__ | void |

Notifies the client of download progress. |current| denotes the number of
bytes received up to the call and |total| is the expected total size of the
response (or -1 if not determined).


### OnDownloadData

| Parameter | Type |
| --- | --- |
| webRequest | [WebRequest](WebRequest.md) |
| data | string |
| __Return__ | void |

Called when some part of the response is read. |data| contains the current
bytes received since the last call. This method will not be called if the
`NoDownloadData` flag is set on the request (see [Request](Request.md).GetFlags()
and SetFlags()).


### OnRequestComplete

| Parameter | Type |
| --- | --- |
| webRequest | [WebRequest](WebRequest.md) |
| __Return__ | void |

Notifies the client that the request has completed. Use the
[WebRequest](WebRequest.md).GetRequestStatus() method to determine if the request was
successful or not.


### GetAuthCredentials

| Parameter | Type |
| --- | --- |
| isProxy | bool |
| host | string |
| port | int |
| realm | string |
| scheme | string |
| callback | [Callback](Callback.md) |
| __Return__ | bool |

 Called on the IO thread when the browser needs credentials from the user.
 |isProxy| indicates whether the host is a proxy server. |host| contains the
 hostname and |port| contains the port number. Return true to continue the
 request and call [Callback](Callback.md).Continue() when the authentication
 information is available. Return false to cancel the request. This method
 will only be called for requests initiated from the browser process.
