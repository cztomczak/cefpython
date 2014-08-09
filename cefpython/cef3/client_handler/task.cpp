// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "task.h"
#include "include/cef_runnable.h"

void PostTaskWrapper(int threadId, int taskId) {
    // Calling CefPostDelayedTask with 0ms delay seems to give 
    // better responsiveness than CefPostTask. In wxpython.py 
    // on Windows the freeze when creating popup window feels 
    // shorter, when compared to a call to CefPostTask.
    CefPostDelayedTask(
            static_cast<CefThreadId>(threadId),
            NewCefRunnableFunction(&PyTaskRunnable, taskId),
            0);
}
