// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once
#include "include/cef_v8.h"
#include "util.h"

class CefPythonApp;

class V8FunctionHandler 
        : public CefV8Handler {
public:
    V8FunctionHandler(CefRefPtr<CefPythonApp> cefPythonApp,
                      int pythonCallbackId)
            : cefPythonApp_(cefPythonApp),
              pythonCallbackId_(pythonCallbackId) {
    }
    virtual bool Execute(const CefString& name,
                        CefRefPtr<CefV8Value> object,
                        const CefV8ValueList& arguments,
                        CefRefPtr<CefV8Value>& retval,
                        CefString& exception) override;
protected:
    CefRefPtr<CefPythonApp> cefPythonApp_;
    int pythonCallbackId_;
private:
  IMPLEMENT_REFCOUNTING(V8FunctionHandler);
};
