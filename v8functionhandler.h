// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "include/cef_base.h"
#include "include/cef_browser.h"
#include "include/cef_frame.h"
#include "include/cef_v8.h"
#include "include/cef_v8context_handler.h"
#include <vector>
#include "util.h"
#include "setup/cefpython_api.h"

// CefV8Handler.Execute() type.
typedef bool (*V8Execute_type)(
		CefRefPtr<CefV8Context> context,
		const CefString& name,
		CefRefPtr< CefV8Value > object,
		const CefV8ValueList& arguments,
		CefRefPtr< CefV8Value >& retval,
		CefString& exception);

class V8FunctionHandler : public CefV8Handler
{
public:
	V8FunctionHandler(){}
	virtual ~V8FunctionHandler(){}

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
	V8Execute_type V8Execute_callback;
	void SetCallback_V8Execute(V8Execute_type callback)
	{
		this->V8Execute_callback = callback;
	}
	virtual bool Execute(
			const CefString& name,
			CefRefPtr<CefV8Value> object,
			const CefV8ValueList& arguments,
			CefRefPtr<CefV8Value>& retval,
			CefString& exception) OVERRIDE
	{
		// The methods of this class will always be called on the UI thread, no need to call REQUIRE_UI_THREAD().
		return this->V8Execute_callback(this->GetContext(), name, object, arguments, retval, exception);
	}

	IMPLEMENT_REFCOUNTING(V8FunctionHandler);
};
