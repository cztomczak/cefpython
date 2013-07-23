// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "client_handler.h"
#include "cefpython_public_api.h"
#include <stdio.h>

// Declared "inline" to get rid of the "already defined" errors when linking.
inline void DebugLog(const char* szString)
{
  // TODO: get the log_file option from CefSettings.
  FILE* pFile = fopen("debug.log", "a");
  fprintf(pFile, "cefpython_app: %s\n", szString);
  fclose(pFile);
}

bool ClientHandler::OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    std::string messageName = message.get()->GetName().ToString();
    printf("Browser: OnProcessMessageReceived(): %s\n", messageName.c_str());
    if (messageName == "OnContextCreated") {
        CefRefPtr<CefListValue> args = message.get()->GetArgumentList();
        if (args.get()->GetSize() == 1 
                && args.get()->GetType(0) == VTYPE_INT) {
            int64 frameIdentifier = args.get()->GetInt(0);
            V8ContextHandler_OnContextCreated(browser, frameIdentifier);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments,"\
                    " messageName=OnContextCreated");
            return false;
        }
    } else if (messageName == "OnContextReleased") {
        CefRefPtr<CefListValue> args = message.get()->GetArgumentList();
        if (args.get()->GetSize() == 1 
                && args.get()->GetType(0) == VTYPE_INT) {
            int64 frameIdentifier = args.get()->GetInt(0);
            V8ContextHandler_OnContextReleased(browser, frameIdentifier);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments,"\
                    " messageName=OnContextReleased");
            return false;
        }
    }
    return false;
}
