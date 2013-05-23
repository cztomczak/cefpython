// Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

// d:\cefpython\src\setup/cefpython.h(22) : warning C4190: 'RequestHandler_GetCookieManager'
// has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is incompatible with C
#if defined(OS_WIN)
#pragma warning(disable:4190)
#endif

// "cef_client.h" will import CefBrowser and others that
// are required when including "cefpython.h"
#include "include/cef_client.h"
#include "include/cef_web_urlrequest.h"
#include "util.h"

// To be able to use 'public' declarations you need to include Python.h and cefpython.h.
#include "Python.h"

// Python 3.2 fix - DL_IMPORT is not defined in Python.h
#ifndef DL_IMPORT /* declarations for DLL import/export */
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT /* declarations for DLL import/export */
#define DL_EXPORT(RTYPE) RTYPE
#endif

#if defined(OS_WIN)
#include "windows/setup/cefpython.h"
#endif

#if defined(OS_LINUX)
#include "linux/setup/cefpython.h"
#endif

class WebRequestClient : public CefWebURLRequestClient
{
public:
    int webRequestId_;
public:
    WebRequestClient(int webRequestId) :
            webRequestId_(webRequestId) {
    }    
    virtual ~WebRequestClient(){}

    virtual void OnStateChange(CefRefPtr<CefWebURLRequest> requester,
                             RequestState state) OVERRIDE;

    virtual void OnRedirect(CefRefPtr<CefWebURLRequest> requester,
                          CefRefPtr<CefRequest> request,
                          CefRefPtr<CefResponse> response) OVERRIDE;

    virtual void OnHeadersReceived(CefRefPtr<CefWebURLRequest> requester,
                                 CefRefPtr<CefResponse> response) OVERRIDE;

    virtual void OnProgress(CefRefPtr<CefWebURLRequest> requester,
                          uint64 bytesSent, uint64 totalBytesToBeSent) OVERRIDE;

    virtual void OnData(CefRefPtr<CefWebURLRequest> requester,
                      const void* data, int dataLength) OVERRIDE;

    virtual void OnError(CefRefPtr<CefWebURLRequest> requester,
                       ErrorCode errorCode) OVERRIDE;
protected:

  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(WebRequestClient);

  // Include the default locking implementation.
  IMPLEMENT_LOCKING(WebRequestClient);

};
