// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "resource_handler.h"

///
// Begin processing the request. To handle the request return true and call
// CefCallback::Continue() once the response header information is available
// (CefCallback::Continue() can also be called from inside this method if
// header information is available immediately). To cancel the request return
// false.
///
/*--cef()--*/
bool ResourceHandler::ProcessRequest(CefRefPtr<CefRequest> request,
                          CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_ProcessRequest(resourceHandlerId_, request,
            callback);
}

///
// Retrieve response header information. If the response length is not known
// set |response_length| to -1 and ReadResponse() will be called until it
// returns false. If the response length is known set |response_length|
// to a positive value and ReadResponse() will be called until it returns
// false or the specified number of bytes have been read. Use the |response|
// object to set the mime type, http status code and other optional header
// values. To redirect the request to a new URL set |redirectUrl| to the new
// URL.
///
/*--cef()--*/
void ResourceHandler::GetResponseHeaders(CefRefPtr<CefResponse> response,
                              int64& response_length,
                              CefString& redirectUrl) {
    REQUIRE_IO_THREAD();
    ResourceHandler_GetResponseHeaders(resourceHandlerId_, response,
            response_length, redirectUrl);
}

///
// Read response data. If data is available immediately copy up to
// |bytes_to_read| bytes into |data_out|, set |bytes_read| to the number of
// bytes copied, and return true. To read the data at a later time set
// |bytes_read| to 0, return true and call CefCallback::Continue() when the
// data is available. To indicate response completion return false.
///
/*--cef()--*/
bool ResourceHandler::ReadResponse(void* data_out,
                        int bytes_to_read,
                        int& bytes_read,
                        CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_ReadResponse(resourceHandlerId_, data_out,
            bytes_to_read, bytes_read, callback);
}

///
// Return true if the specified cookie can be sent with the request or false
// otherwise. If false is returned for any cookie then no cookies will be sent
// with the request.
///
/*--cef()--*/
bool ResourceHandler::CanGetCookie(const CefCookie& cookie) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_CanGetCookie(resourceHandlerId_, cookie);
}

///
// Return true if the specified cookie returned with the response can be set
// or false otherwise.
///
/*--cef()--*/
bool ResourceHandler::CanSetCookie(const CefCookie& cookie) { 
    REQUIRE_IO_THREAD();
    return ResourceHandler_CanSetCookie(resourceHandlerId_, cookie);
}

///
// Request processing has been canceled.
///
/*--cef()--*/
void ResourceHandler::Cancel() {
    REQUIRE_IO_THREAD();
    return ResourceHandler_Cancel(resourceHandlerId_);
}
