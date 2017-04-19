// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// NOTE: clienthandler code is running only in the BROWSER PROCESS.
//       cefpythonapp code is running in both BROWSER PROCESS and subprocess
//       (see the subprocess/ directory).

#include "client_handler.h"
#include "common/cefpython_public_api.h"
#include "include/base/cef_logging.h"

#if defined(OS_WIN)
#include <Shellapi.h>
#pragma comment(lib, "Shell32.lib")
#include "dpi_aware.h"
#elif defined(OS_LINUX)
#include <unistd.h>
#include <stdlib.h>
#endif // OS_WIN


// ----------------------------------------------------------------------------
// CefClient
// ----------------------------------------------------------------------------


bool ClientHandler::OnProcessMessageReceived(
                                        CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message)
{
    if (source_process != PID_RENDERER) {
        return false;
    }
    std::string messageName = message->GetName().ToString();
    std::string logMessage = "[Browser process] OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    LOG(INFO) << logMessage.c_str();
    if (messageName == "OnContextCreated") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 1 && arguments->GetType(0) == VTYPE_INT) {
            int64 frameId = arguments->GetInt(0);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8ContextHandler_OnContextCreated(browser, frame);
            return true;
        } else {
            LOG(ERROR) << "[Browser process] OnProcessMessageReceived():"
                          " invalid arguments, messageName=OnContextCreated";
            return false;
        }
    } else if (messageName == "OnContextReleased") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 2 \
                && arguments->GetType(0) == VTYPE_INT \
                && arguments->GetType(1) == VTYPE_INT) {
            int browserId = arguments->GetInt(0);
            int64 frameId = arguments->GetInt(1);
            V8ContextHandler_OnContextReleased(browserId, frameId);
            return true;
        } else {
            LOG(ERROR) << "[Browser process] OnProcessMessageReceived():"
                          " invalid arguments, messageName=OnContextReleased";
            return false;
        }
    } else if (messageName == "V8FunctionHandler::Execute") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 3
                    // frameId
                    && arguments->GetType(0) == VTYPE_INT
                    // functionName
                    && arguments->GetType(1) == VTYPE_STRING
                    // functionArguments
                    && arguments->GetType(2) == VTYPE_LIST) {
            int64 frameId = arguments->GetInt(0);
            CefString functionName = arguments->GetString(1);
            CefRefPtr<CefListValue> functionArguments = arguments->GetList(2);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8FunctionHandler_Execute(browser, frame, functionName,
                                      functionArguments);
            return true;
        } else {
            LOG(ERROR) << "[Browser process] OnProcessMessageReceived():"
                          " invalid arguments,"
                          " messageName=V8FunctionHandler::Execute";
            return false;
        }
    } else if (messageName == "ExecutePythonCallback") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 2
                && arguments->GetType(0) == VTYPE_INT // callbackId
                && arguments->GetType(1) == VTYPE_LIST) { // functionArguments
            int callbackId = arguments->GetInt(0);
            CefRefPtr<CefListValue> functionArguments = arguments->GetList(1);
            ExecutePythonCallback(browser, callbackId, functionArguments);
            return true;
        } else {
            LOG(ERROR) << "[Browser process] OnProcessMessageReceived():"
                          " invalid arguments,"
                          " messageName=ExecutePythonCallback";
            return false;
        }
    } else if (messageName == "RemovePythonCallbacksForFrame") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 1 && arguments->GetType(0) == VTYPE_INT) {
            int frameId = arguments->GetInt(0);
            RemovePythonCallbacksForFrame(frameId);
            return true;
        } else {
            LOG(ERROR) << "[Browser process] OnProcessMessageReceived():"
                          " invalid arguments,"
                          " messageName=ExecutePythonCallback";
            return false;
        }
    }
    return false;
}
