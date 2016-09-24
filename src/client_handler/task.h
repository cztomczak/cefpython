// Copyright (c) 2012-2016 CEF Python. All rights reserved.

#pragma once

#include "common/cefpython_public_api.h"
#include "include/cef_cookie.h"
#include "include/cef_task.h"

void PostTaskWrapper(int threadId, int taskId);

CefRefPtr<CefTask> CreateTask_SetCookie(
        CefCookieManager* obj,
        const CefString& url,
        const CefCookie& cookie,
        CefRefPtr<CefSetCookieCallback> callback);

CefRefPtr<CefTask> CreateTask_DeleteCookies(
        CefCookieManager* obj,
        const CefString& url,
        const CefString& cookie_name,
        CefRefPtr<CefDeleteCookiesCallback> callback);
