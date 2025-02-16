// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "resource_handler.h"

bool ResourceHandler::ProcessRequest(CefRefPtr<CefRequest> request,
                          CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return ResourceHandler_ProcessRequest(resourceHandlerId_, request,
            callback);
}

void ResourceHandler::GetResponseHeaders(CefRefPtr<CefResponse> response,
                              int64_t& response_length,
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

void ResourceHandler::Cancel() {
    REQUIRE_IO_THREAD();
    return ResourceHandler_Cancel(resourceHandlerId_);
}
