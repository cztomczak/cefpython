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
// are required when including "cefpython.h", CefWebURLRequest
// is also declared in "cefpython.h".
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

class ContentFilterHandler : public CefContentFilter
{
public:
    int contentFilterId_;
public:
    ContentFilterHandler(int contentFilterId) :
            contentFilterId_(contentFilterId) {
    }    
    virtual ~ContentFilterHandler(){}

    virtual void ProcessData(const void* data, int data_size,
                           CefRefPtr<CefStreamReader>& substitute_data) OVERRIDE;

    virtual void Drain(CefRefPtr<CefStreamReader>& remainder) OVERRIDE;
    
protected:

  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ContentFilterHandler);

  // Include the default locking implementation.
  IMPLEMENT_LOCKING(ContentFilterHandler);

};
