// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "web_request_client.h"

///
// Interface that should be implemented by the CefURLRequest client. The
// methods of this class will be called on the same thread that created the
// request.
///

///
// Notifies the client that the request has completed. Use the
// CefURLRequest::GetRequestStatus method to determine if the request was
// successful or not.
///
/*--cef()--*/
void WebRequestClient::OnRequestComplete(CefRefPtr<CefURLRequest> request) {
    WebRequestClient_OnRequestComplete(webRequestId_, request);
}

///
// Notifies the client of upload progress. |current| denotes the number of
// bytes sent so far and |total| is the total size of uploading data (or -1 if
// chunked upload is enabled). This method will only be called if the
// UR_FLAG_REPORT_UPLOAD_PROGRESS flag is set on the request.
///
/*--cef()--*/
void WebRequestClient::OnUploadProgress(CefRefPtr<CefURLRequest> request,
                            uint64 current,
                            uint64 total) {
    WebRequestClient_OnUploadProgress(webRequestId_, request, current, total);
}

///
// Notifies the client of download progress. |current| denotes the number of
// bytes received up to the call and |total| is the expected total size of the
// response (or -1 if not determined).
///
/*--cef()--*/
void WebRequestClient::OnDownloadProgress(CefRefPtr<CefURLRequest> request,
                              uint64 current,
                              uint64 total) {
    WebRequestClient_OnDownloadProgress(webRequestId_, request, current,
            total);
}

///
// Called when some part of the response is read. |data| contains the current
// bytes received since the last call. This method will not be called if the
// UR_FLAG_NO_DOWNLOAD_DATA flag is set on the request.
///
/*--cef()--*/
void WebRequestClient::OnDownloadData(CefRefPtr<CefURLRequest> request,
                          const void* data,
                          size_t data_length) {
    WebRequestClient_OnDownloadData(webRequestId_, request, data, data_length);
}
