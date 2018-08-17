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
    // Return true if message was handled.
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
            if (!frame.get()) {
                // Frame was already destroyed while IPC messaging was
                // executing. Issue #431. User callback will not be
                // executed in such case.
                return true;
            }
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
            // Even if frame was alrady destroyed (Issue #431) you still
            // want to call V8ContextHandler_OnContextReleased as it releases
            // some resources. Thus passing IDs instead of actual
            // objects. Cython code in V8ContextHandler_OnContextReleased
            // will handle a case when frame is already destroyed.
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
            // Even if frame was already destroyed (Issue #431) you still
            // want to call V8FunctionHandler_Execute, as it can run
            // Python code without issues and doesn't require an actual
            // frame. Thus passing IDs instead of actual objects. Cython
            // code in V8FunctionHandler_Execute will handle a case when
            // frame is already destroyed.
            V8FunctionHandler_Execute(browser, frameId, functionName,
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
    }
    return false;
}
