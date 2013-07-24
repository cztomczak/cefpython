// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "v8function_handler.h"

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

bool V8FunctionHandler::Execute(const CefString& name,
                        CefRefPtr<CefV8Value> object,
                        const CefV8ValueList& arguments,
                        CefRefPtr<CefV8Value>& retval,
                        CefString& exception) {
    DebugLog("V8FunctionHandler::Execute()");
    CefRefPtr<CefV8Context> context =  CefV8Context::GetCurrentContext();
    CefRefPtr<CefBrowser> browser = context.get()->GetBrowser();
    CefRefPtr<CefFrame> frame = context.get()->GetFrame();
    // convert arguments to CefListValue
    // set retval to null
    // send process message: frameId, funcName, funcArgs
    return false;
}
