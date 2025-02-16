// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#include "common/cefpython_public_api.h"
#include "include/cef_cookie.h"
#include "include/cef_task.h"

void PostTaskWrapper(int threadId, int taskId);
void PostDelayedTaskWrapper(int threadId, int64_t delay_ms, int taskId);

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
