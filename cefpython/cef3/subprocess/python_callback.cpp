// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "python_callback.h"

void RemovePythonCallbacksForFrame(CefRefPtr<CefFrame> frame) {
    // Send a process message to Browser to remove all python
    // callbacks for given frame. This function is called from
    // CefRenderProcessHandler::OnContextReleased().
}
