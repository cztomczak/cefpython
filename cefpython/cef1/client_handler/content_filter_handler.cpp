// Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "content_filter_handler.h"

void ContentFilterHandler::ProcessData(const void* data, int data_size,
                                  CefRefPtr<CefStreamReader>& substitute_data) {
    REQUIRE_UI_THREAD();
    ContentFilterHandler_ProcessData(contentFilterId_, data, data_size,
            substitute_data);
}

void ContentFilterHandler::Drain(CefRefPtr<CefStreamReader>& remainder) {
    REQUIRE_UI_THREAD();
    ContentFilterHandler_Drain(contentFilterId_, remainder);
}