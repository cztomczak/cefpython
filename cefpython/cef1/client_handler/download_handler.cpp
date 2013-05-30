// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "download_handler.h"
#include <stdio.h>

bool DownloadHandler::ReceivedData(
        void* data,
        int data_size
        ) {
    REQUIRE_UI_THREAD();
    if (data_size == 0)
        return true;
    return DownloadHandler_ReceivedData(downloadHandlerId_, data, data_size);
}

void DownloadHandler::Complete() {
    REQUIRE_UI_THREAD();
    DownloadHandler_Complete(downloadHandlerId_);
}
