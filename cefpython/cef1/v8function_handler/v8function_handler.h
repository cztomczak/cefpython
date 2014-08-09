// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

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
