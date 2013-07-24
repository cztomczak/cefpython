// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "client_handler.h"
#include "cefpython_public_api.h"
#include <stdio.h>

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

bool ClientHandler::OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    std::string messageName = message->GetName().ToString();
    std::string logMessage = "Browser: OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    DebugLog(logMessage.c_str());
    if (messageName == "OnContextCreated") {
        CefRefPtr<CefListValue> args = message->GetArgumentList();
        if (args->GetSize() == 1 && args->GetType(0) == VTYPE_INT) {
            int64 frameId = args->GetInt(0);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8ContextHandler_OnContextCreated(browser, frame);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments," \
                    " messageName=OnContextCreated");
            return false;
        }
    } else if (messageName == "OnContextReleased") {
        CefRefPtr<CefListValue> args = message->GetArgumentList();
        if (args->GetSize() == 1 && args->GetType(0) == VTYPE_INT) {
            int64 frameId = args->GetInt(0);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8ContextHandler_OnContextReleased(browser, frame);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments," \
                    " messageName=OnContextReleased");
            return false;
        }
    } else if (messageName == "V8FunctionHandler::Execute") {
        CefRefPtr<CefListValue> args = message->GetArgumentList();
        if (args->GetSize() == 3
                && args->GetType(0) == VTYPE_INT // frameId
                && args->GetType(1) == VTYPE_STRING // funcName
                && args->GetType(2) == VTYPE_LIST) { // funcArgs
            int64 frameId = args->GetInt(0);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            CefString funcName = args->GetString(1);
            CefRefPtr<CefListValue> funcArgs = args->GetList(2);
            V8FunctionHandler_Execute(browser, frame, funcName, funcArgs);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments," \
                    " messageName=V8FunctionHandler::Execute");
            return false;
        }
    }
    return false;
}
