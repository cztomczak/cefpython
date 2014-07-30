// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_app.h"
#include "v8utils.h"
#include "DebugLog.h"

bool V8FunctionHandler::Execute(const CefString& functionName,
                        CefRefPtr<CefV8Value> thisObject,
                        const CefV8ValueList& v8Arguments,
                        CefRefPtr<CefV8Value>& returnValue,
                        CefString& exception) {
    if (!CefV8Context::InContext()) {
        // CefV8Context::GetCurrentContext may not be called when
        // not in a V8 context.
        DebugLog("Renderer: V8FunctionHandler::Execute() FAILED:"\
                " not inside a V8 context");
        return false;
    }
    CefRefPtr<CefV8Context> context =  CefV8Context::GetCurrentContext();
    CefRefPtr<CefBrowser> browser = context.get()->GetBrowser();
    CefRefPtr<CefFrame> frame = context.get()->GetFrame();
    if (pythonCallbackId_) {
        DebugLog("Renderer: V8FunctionHandler::Execute(): python callback");
        CefRefPtr<CefListValue> functionArguments = V8ValueListToCefListValue(
                v8Arguments);
        CefRefPtr<CefProcessMessage> processMessage = \
                CefProcessMessage::Create("ExecutePythonCallback");
        CefRefPtr<CefListValue> messageArguments = \
                processMessage->GetArgumentList();
        messageArguments->SetInt(0, pythonCallbackId_);
        messageArguments->SetList(1, functionArguments);
        browser->SendProcessMessage(PID_BROWSER, processMessage);
        returnValue = CefV8Value::CreateNull();
        return true;
    } else {
        DebugLog("Renderer: V8FunctionHandler::Execute(): js binding");
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
        // TODO: losing int64 precision here.
        int frameId = (int)frame->GetIdentifier();
        CefRefPtr<CefProcessMessage> processMessage = \
                CefProcessMessage::Create("V8FunctionHandler::Execute");
        CefRefPtr<CefListValue> messageArguments = \
                processMessage->GetArgumentList();
        messageArguments->SetInt(0, frameId);
        messageArguments->SetString(1, functionName);
        messageArguments->SetList(2, functionArguments);
        browser->SendProcessMessage(PID_BROWSER, processMessage);
        returnValue = CefV8Value::CreateNull();
        return true;
    }
}
