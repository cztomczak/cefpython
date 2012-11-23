#include "v8function_handler.h"

// Implementation cannot be in .h as it is included by cython's setup script and
// V8FunctionHandler_Execute() is not visible at that time.
bool V8FunctionHandler::Execute(
			const CefString& name,
			CefRefPtr<CefV8Value> object,
			const CefV8ValueList& arguments,
			CefRefPtr<CefV8Value>& retval,
			CefString& exception)
{
	// The methods of this class will always be called on the UI thread, no need to call REQUIRE_UI_THREAD().
	return V8FunctionHandler_Execute(this->GetContext(), this->pythonCallbackID, 
      const_cast<CefString&>(name), object, const_cast<CefV8ValueList&>(arguments), retval, exception);
}
