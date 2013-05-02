// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

// d:\cefpython\src\setup/cefpython.h(22) : warning C4190: 'RequestHandler_GetCookieManager' 
// has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is incompatible with C
#pragma warning(disable:4190)

#include "include/cef_base.h"
#include "include/cef_browser.h"
#include "include/cef_frame.h"
#include "include/cef_v8.h"
#include "include/cef_v8context_handler.h"
#include "include/cef_client.h"
#include <vector>
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

typedef void (*RemovePythonCallback_type)(
		int callbackID
);

class V8FunctionHandler : public CefV8Handler
{
public:
	V8FunctionHandler()
	{
		this->removePythonCallback = NULL;
		this->pythonCallbackID = 0;
	}
	virtual ~V8FunctionHandler()
	{
		if (this->removePythonCallback) {
			this->removePythonCallback(this->pythonCallbackID);
		}
	}

	CefRefPtr<CefV8Context> __context;

	void SetContext(CefRefPtr<CefV8Context> context)
	{
		this->__context = context;
	}
	CefRefPtr<CefV8Context> GetContext()
	{
		return this->__context;
	}


	// CefV8Handler methods.

	RemovePythonCallback_type removePythonCallback;
	int pythonCallbackID;

	void SetCallback_RemovePythonCallback(RemovePythonCallback_type callback)
	{
		this->removePythonCallback = callback;
	}
	void SetPythonCallbackID(int callbackID)
	{
		this->pythonCallbackID = callbackID;
	}
	virtual bool Execute(
			const CefString& name,
			CefRefPtr<CefV8Value> object,
			const CefV8ValueList& arguments,
			CefRefPtr<CefV8Value>& retval,
			CefString& exception) OVERRIDE;	

protected:
  IMPLEMENT_REFCOUNTING(V8FunctionHandler);
};
