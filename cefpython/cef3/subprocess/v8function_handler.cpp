// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_public_api.h"
#include "v8function_handler.h"
#include "v8utils.h"
#include "cefpython_app.h"

// Defined as "inline" to get rid of the "already defined" errors
// when linking.
inline void DebugLog(const char* szString)
{
  // TODO: get the log_file option from CefSettings.
  printf("cefpython: %s\n", szString);
  FILE* pFile = fopen("debug.log", "a");
  fprintf(pFile, "cefpython_app: %s\n", szString);
  fclose(pFile);
}

bool V8FunctionHandler::Execute(const CefString& funcName,
                        CefRefPtr<CefV8Value> object,
                        const CefV8ValueList& v8Arguments,
                        CefRefPtr<CefV8Value>& retval,
                        CefString& exception) {
    DebugLog("Renderer: V8FunctionHandler::Execute()");
    CefRefPtr<CefV8Context> context =  CefV8Context::GetCurrentContext();
    CefRefPtr<CefBrowser> browser = context.get()->GetBrowser();
    CefRefPtr<CefFrame> frame = context.get()->GetFrame();    
    if (!cefPythonApp_->BindedFunctionExists(browser, funcName)) {
        return false;
    }
    CefRefPtr<CefListValue> funcArguments = V8ValueListToCefListValue(
            v8Arguments);
    // TODO: losing int64 precision here.
    int frameId = (int)frame->GetIdentifier();
    CefRefPtr<CefProcessMessage> processMessage = CefProcessMessage::Create(
        "V8FunctionHandler::Execute");
    CefRefPtr<CefListValue> messageArguments = processMessage->GetArgumentList();
    messageArguments->SetInt(0, frameId);
    messageArguments->SetString(1, funcName);
    messageArguments->SetList(2, funcArguments);
    browser->SendProcessMessage(PID_BROWSER, processMessage);
    retval = CefV8Value::CreateNull();
    return true;
}
