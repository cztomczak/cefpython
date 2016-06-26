// Copyright (c) 2012-2016 CEF Python. All rights reserved.

#include "task.h"
#include "include/wrapper/cef_closure_task.h"
#include "include/base/cef_bind.h"

void PostTaskWrapper(int threadId, int taskId) {
    // Calling CefPostDelayedTask with 0ms delay seems to give 
    // better responsiveness than CefPostTask. In wxpython.py 
    // on Windows the freeze when creating popup window feels 
    // shorter, when compared to a call to CefPostTask.
    CefPostDelayedTask(
            static_cast<CefThreadId>(threadId),
            CefCreateClosureTask(base::Bind(
                    &PyTaskRunnable,
                    taskId
            )),
            0
    );
}

CefRefPtr<CefTask> CreateTask_SetCookie(
        CefCookieManager* obj,
        const CefString& url,
        const CefCookie& cookie,
        CefRefPtr<CefSetCookieCallback> callback)
{
    return CefCreateClosureTask(base::Bind(
            base::IgnoreResult(&CefCookieManager::SetCookie), obj,
            url,
            cookie,
            callback
    ));
}

CefRefPtr<CefTask> CreateTask_DeleteCookies(
        CefCookieManager* obj,
        const CefString& url,
        const CefString& cookie_name,
        CefRefPtr<CefDeleteCookiesCallback> callback)
{
    return CefCreateClosureTask(base::Bind(
            base::IgnoreResult(&CefCookieManager::DeleteCookies), obj,
            url,
            cookie_name,
            callback
    ));
}
