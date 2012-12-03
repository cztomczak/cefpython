// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

// d:\cefpython\src\setup/cefpython.h(22) : warning C4190: 'RequestHandler_GetCookieManager' 
// has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is incompatible with C
#pragma warning(disable:4190)

#include "include/cef_client.h"
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

class ClientHandler : public CefClient
{
public:
  ClientHandler(){}
  virtual ~ClientHandler(){}

protected:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  IMPLEMENT_LOCKING(ClientHandler);

};
