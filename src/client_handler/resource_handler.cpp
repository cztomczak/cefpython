// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "resource_handler.h"

bool ResourceHandler::ProcessRequest(CefRefPtr<CefRequest> request,
                          CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_ProcessRequest(resourceHandlerId_, request,
            callback);
}

void ResourceHandler::GetResponseHeaders(CefRefPtr<CefResponse> response,
                              int64& response_length,
                              CefString& redirectUrl) {
    REQUIRE_IO_THREAD();
    ResourceHandler_GetResponseHeaders(resourceHandlerId_, response,
            response_length, redirectUrl);
}

bool ResourceHandler::ReadResponse(void* data_out,
                        int bytes_to_read,
                        int& bytes_read,
                        CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_ReadResponse(resourceHandlerId_, data_out,
            bytes_to_read, bytes_read, callback);
}

bool ResourceHandler::CanGetCookie(const CefCookie& cookie) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_CanGetCookie(resourceHandlerId_, cookie);
}

bool ResourceHandler::CanSetCookie(const CefCookie& cookie) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_CanSetCookie(resourceHandlerId_, cookie);
}

void ResourceHandler::Cancel() {
    REQUIRE_IO_THREAD();
    return ResourceHandler_Cancel(resourceHandlerId_);
}
