// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "cefpython_app.h"
#include "v8utils.h"
#include "include/base/cef_logging.h"

bool V8FunctionHandler::Execute(const CefString& functionName,
                        CefRefPtr<CefV8Value> thisObject,
                        const CefV8ValueList& v8Arguments,
                        CefRefPtr<CefV8Value>& returnValue,
                        CefString& exception) {
    if (!CefV8Context::InContext()) {
        // CefV8Context::GetCurrentContext may not be called when
        // not in a V8 context.
        LOG(ERROR) << "[Renderer process] V8FunctionHandler::Execute():"
                      " not inside a V8 context";
        return false;
    }
    CefRefPtr<CefV8Context> context =  CefV8Context::GetCurrentContext();
    CefRefPtr<CefBrowser> browser = context.get()->GetBrowser();
    CefRefPtr<CefFrame> frame = context.get()->GetFrame();
    if (pythonCallbackId_) {
        LOG(INFO) << "[Renderer process] V8FunctionHandler::Execute():"
                     " python callback";
        CefRefPtr<CefListValue> functionArguments = V8ValueListToCefListValue(
                v8Arguments);
        CefRefPtr<CefProcessMessage> processMessage = \
                CefProcessMessage::Create("ExecutePythonCallback");
        CefRefPtr<CefListValue> messageArguments = \
                processMessage->GetArgumentList();
        messageArguments->SetInt(0, pythonCallbackId_);
        messageArguments->SetList(1, functionArguments);
        frame->SendProcessMessage(PID_BROWSER, processMessage);
        returnValue = CefV8Value::CreateNull();
        return true;
    } else {
        LOG(INFO) << "[Renderer process] V8FunctionHandler::Execute():"
                     " js binding";
        if (!(cefPythonApp_.get() \
                && cefPythonApp_->BindedFunctionExists( \
                        browser, functionName))) {
            exception = std::string("[CEF Python] " \
                    "V8FunctionHandler::Execute() FAILED: " \
                    "function does not exist: ").append(functionName) \
                    .append("()");
            // Must return true for the exception to be thrown.
            return true;
        }
        CefRefPtr<CefListValue> functionArguments = V8ValueListToCefListValue(
                v8Arguments);
        CefString frameId = frame->GetIdentifier();
        CefRefPtr<CefProcessMessage> processMessage = \
                CefProcessMessage::Create("V8FunctionHandler::Execute");
        CefRefPtr<CefListValue> messageArguments = \
                processMessage->GetArgumentList();
        messageArguments->SetString(0, frameId);
        messageArguments->SetString(1, functionName);
        messageArguments->SetList(2, functionArguments);
        frame->SendProcessMessage(PID_BROWSER, processMessage);
        returnValue = CefV8Value::CreateNull();
        return true;
    }
}
