// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "task.h"
#include "include/wrapper/cef_closure_task.h"
#include "include/base/cef_bind.h"

void PostTaskWrapper(int threadId, int taskId) {
    CefPostTask(
            static_cast<CefThreadId>(threadId),
            CefCreateClosureTask(base::Bind(
                    &PyTaskRunnable,
                    taskId
            ))
    );
}

void PostDelayedTaskWrapper(int threadId, int64 delay_ms, int taskId) {
    CefPostDelayedTask(
            static_cast<CefThreadId>(threadId),
            CefCreateClosureTask(base::Bind(
                    &PyTaskRunnable,
                    taskId
            )),
            delay_ms
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
