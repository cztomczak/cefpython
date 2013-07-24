// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "include/cef_v8.h"
#include "util.h"

class V8FunctionHandler 
        : public CefV8Handler {
public:
    virtual bool Execute(const CefString& name,
                        CefRefPtr<CefV8Value> object,
                        const CefV8ValueList& arguments,
                        CefRefPtr<CefV8Value>& retval,
                        CefString& exception) OVERRIDE;
private:
  IMPLEMENT_REFCOUNTING(V8FunctionHandler);
};
