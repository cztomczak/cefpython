// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

// BROWSER_PROCESS macro is defined when compiling the libcefpythonapp library.
// RENDERER_PROCESS macro is define when compiling the subprocess executable.

#ifdef BROWSER_PROCESS
#include "common/cefpython_public_api.h"
#endif

#include "cefpython_app.h"
#include "util.h"
#include "include/wrapper/cef_closure_task.h"
#include "include/base/cef_bind.h"
#include "DebugLog.h"
#include "LOG_DEBUG.h"
#include <vector>
#include <algorithm>
#include "v8utils.h"
#include "javascript_callback.h"
#include "v8function_handler.h"

#ifdef BROWSER_PROCESS
#include "main_message_loop/main_message_loop_external_pump.h"
#endif

bool g_debug = false;
std::string g_logFile = "debug.log";

CefPythonApp::CefPythonApp() {
#ifdef BROWSER_PROCESS
    cefpython_GetDebugOptions(&g_debug, &g_logFile);
#endif
}

// -----------------------------------------------------------------------------
// CefApp
// -----------------------------------------------------------------------------

void CefPythonApp::OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) {
#ifdef BROWSER_PROCESS
    // This is included only in the Browser process, when building
    // the libcefpythonapp library.
    if (process_type.empty()) {
        // Empty proc type, so this must be the main browser process.
        App_OnBeforeCommandLineProcessing_BrowserProcess(command_line);
    }
#endif
    std::string process_name = process_type.ToString();
    if (process_name.empty()) {
        process_name = "browser";
    }
    std::string logMessage = "Command line string for the ";
    logMessage.append(process_name);
    logMessage.append(" process: ");
    std::string clString = command_line->GetCommandLineString().ToString();
    logMessage.append(clString.c_str());
    // OnBeforeCommandLineProcessing() is called before
    // CefRenderHandler::OnRenderThreadCreated() which sets
    // the debug options. Thus debugging will always be Off
    // at the time this method is called. The fix for that
    // is to keep the command line string somewhere and call
    // DebugLog later in OnRenderThreadCreated().
    if (g_debug) {
        DebugLog(logMessage.c_str());
    } else {
        commandLineString_ = logMessage;
    }
}

void CefPythonApp::OnRegisterCustomSchemes(
  CefRefPtr<CefSchemeRegistrar> registrar) {
}

CefRefPtr<CefResourceBundleHandler> CefPythonApp::GetResourceBundleHandler() {
    return NULL;
}

CefRefPtr<CefBrowserProcessHandler> CefPythonApp::GetBrowserProcessHandler() {
    return this;
}

CefRefPtr<CefRenderProcessHandler> CefPythonApp::GetRenderProcessHandler() {
    return this;
}

// ----------------------------------------------------------------------------
// CefBrowserProcessHandler
// ----------------------------------------------------------------------------

void CefPythonApp::OnContextInitialized() {
#ifdef BROWSER_PROCESS
    REQUIRE_UI_THREAD();
#if defined(OS_LINUX)
    print_handler_ = new ClientPrintHandlerGtk();
#endif // OS_LINUX
#endif // BROWSER_PROCESS
}

void CefPythonApp::OnBeforeChildProcessLaunch(
        CefRefPtr<CefCommandLine> command_line) {
#ifdef BROWSER_PROCESS
    // This is included only in the Browser process, when building
    // the libcefpythonapp library.
    BrowserProcessHandler_OnBeforeChildProcessLaunch(command_line);
#endif // BROWSER_PROCESS
}

void CefPythonApp::OnRenderProcessThreadCreated(
        CefRefPtr<CefListValue> extra_info) {
#ifdef BROWSER_PROCESS
    // If you have an existing CefListValue that you would like
    // to provide, do this:
    // | extra_info = mylist.get()
    // The equivalent in Cython is:
    // | extra_info.Assign(mylist.get())
    REQUIRE_IO_THREAD();
    extra_info->SetBool(0, g_debug);
    extra_info->SetString(1, g_logFile);
    // This is included only in the Browser process, when building
    // the libcefpythonapp library.
    BrowserProcessHandler_OnRenderProcessThreadCreated(extra_info);
#endif // BROWSER_PROCESS
}

CefRefPtr<CefPrintHandler> CefPythonApp::GetPrintHandler() {
    return print_handler_;
}

void CefPythonApp::OnScheduleMessagePumpWork(int64 delay_ms) {
#ifdef BROWSER_PROCESS
    MainMessageLoopExternalPump* message_pump =\
            MainMessageLoopExternalPump::Get();
    if (message_pump) {
        message_pump->OnScheduleMessagePumpWork(delay_ms);
    }
#endif // BROWSER_PROCESS
}

// -----------------------------------------------------------------------------
// CefRenderProcessHandler
// -----------------------------------------------------------------------------

void CefPythonApp::OnRenderThreadCreated(CefRefPtr<CefListValue> extra_info) {
    if (extra_info->GetType(0) == VTYPE_BOOL) {
        g_debug = extra_info->GetBool(0);
        if (g_debug) {
            FILELog::ReportingLevel() = logDEBUG;
        } else {
            // In reality this disables logging in LOG_DEBUG.h, as
            // we're using only LOG_DEBUG macro.
            FILELog::ReportingLevel() = logERROR;
        }
    }
    if (extra_info->GetType(1) == VTYPE_STRING) {
        g_logFile = extra_info->GetString(1).ToString();
    }
    if (!commandLineString_.empty()) {
        // See comment in OnBeforeCommandLineProcessing().
        DebugLog(commandLineString_.c_str());
        commandLineString_ = "";
    }
}

void CefPythonApp::OnWebKitInitialized() {
}

void CefPythonApp::OnBrowserCreated(CefRefPtr<CefBrowser> browser) {
}

void CefPythonApp::OnBrowserDestroyed(CefRefPtr<CefBrowser> browser) {
    DebugLog("Renderer: OnBrowserDestroyed()");
    RemoveJavascriptBindings(browser);
}

bool CefPythonApp::OnBeforeNavigation(CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame,
                                      CefRefPtr<CefRequest> request,
                                      cef_navigation_type_t navigation_type,
                                      bool is_redirect) {
    return false;
}

void CefPythonApp::OnContextCreated(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefV8Context> context) {
    DebugLog("Renderer: OnContextCreated()");
    CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(
            "OnContextCreated");
    CefRefPtr<CefListValue> arguments = message->GetArgumentList();
    /*
    Sending int64 type using process messaging would require
    converting it to a string or a binary, or you could send
    two ints, see this topic:
    http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10869
    */
    /*
    // Example of converting int64 to string. Still need an
    // example of converting it back from string.
    std::string logMessage = "OnContextCreated(): frameId=";
    stringstream stream;
    int64 value = frame->GetIdentifier();
    stream << value;
    logMessage.append(stream.str());
    DebugLog(logMessage.c_str());
    */
    // TODO: losing int64 precision, the solution is to convert
    //       it to string and then in the Browser process back
    //       from string to int64. But it is rather unlikely
    //       that number of frames will exceed int range, so
    //       casting it to int for now.
    arguments->SetInt(0, (int)(frame->GetIdentifier()));
    browser->SendProcessMessage(PID_BROWSER, message);
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (jsBindings.get()) {
        // Javascript bindings are most probably not yet set for
        // the main frame, they will be set a moment later due to
        // process messaging delay. The code seems to be executed
        // only for iframes.
        if (frame->IsMain()) {
            DoJavascriptBindingsForFrame(browser, frame, context);
        } else {
            if (jsBindings->HasKey("bindToFrames")
                    && jsBindings->GetType("bindToFrames") == VTYPE_BOOL
                    && jsBindings->GetBool("bindToFrames")) {
                DoJavascriptBindingsForFrame(browser, frame, context);
            }
        }
    }
}

void CefPythonApp::OnContextReleased(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefV8Context> context) {
    DebugLog("Renderer: OnContextReleased()");
    CefRefPtr<CefProcessMessage> message;
    CefRefPtr<CefListValue> arguments;
    // ------------------------------------------------------------------------
    // 1. Send "OnContextReleased" message.
    // ------------------------------------------------------------------------
    message = CefProcessMessage::Create("OnContextReleased");
    arguments = message->GetArgumentList();
    arguments->SetInt(0, browser->GetIdentifier());
    // TODO: losing int64 precision, the solution is to convert
    //       it to string and then in the Browser process back
    //       from string to int64. But it is rather unlikely
    //       that number of frames will exceed int range, so
    //       casting it to int for now.
    arguments->SetInt(1, (int)(frame->GetIdentifier()));
    // Should we send the message using current "browser"
    // when this is not the main frame? It could fail, so
    // it is more reliable to always use the main browser.
    browser->SendProcessMessage(PID_BROWSER, message);
    // ------------------------------------------------------------------------
    // 2. Remove python callbacks for a frame.
    // ------------------------------------------------------------------------
    // If this is the main frame then the message won't arrive
    // to the browser process, as browser is being destroyed,
    // but it doesn't matter because in LifespanHandler_BeforeClose()
    // we're calling RemovePythonCallbacksForBrowser().
    message = CefProcessMessage::Create("RemovePythonCallbacksForFrame");
    arguments = message->GetArgumentList();
    // TODO: int64 precision lost
    arguments->SetInt(0, (int)(frame->GetIdentifier()));
    browser->SendProcessMessage(PID_BROWSER, message);
    // ------------------------------------------------------------------------
    // 3. Clear javascript callbacks.
    // ------------------------------------------------------------------------
    RemoveJavascriptCallbacksForFrame(frame);
}

void CefPythonApp::OnUncaughtException(CefRefPtr<CefBrowser> browser,
                                       CefRefPtr<CefFrame> frame,
                                       CefRefPtr<CefV8Context> context,
                                       CefRefPtr<CefV8Exception> exception,
                                       CefRefPtr<CefV8StackTrace> stackTrace) {
}

void CefPythonApp::OnFocusedNodeChanged(CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefDOMNode> node) {
}

bool CefPythonApp::OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    std::string messageName = message->GetName().ToString();
    std::string logMessage = "Renderer: OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    DebugLog(logMessage.c_str());
    CefRefPtr<CefListValue> args = message->GetArgumentList();
    if (messageName == "DoJavascriptBindings") {
        if (args->GetSize() == 1
                && args->GetType(0) == VTYPE_DICTIONARY
                && args->GetDictionary(0)->IsValid()) {
            // Is it necessary to make a copy? It won't harm.
            SetJavascriptBindings(browser,
                    args->GetDictionary(0)->Copy(false));
            DoJavascriptBindingsForBrowser(browser);
        } else {
            DebugLog("Renderer: OnProcessMessageReceived(): invalid arguments,"\
                    " messageName=DoJavascriptBindings");
            return false;
        }
    } else if (messageName == "ExecuteJavascriptCallback") {
        if (args->GetType(0) == VTYPE_INT) {
            int jsCallbackId = args->GetInt(0);
            CefRefPtr<CefListValue> jsArgs;
            if (args->IsReadOnly()) {
                jsArgs = args->Copy();
            } else {
                jsArgs = args;
            }
            // Remove jsCallbackId.
            jsArgs->Remove(0);
            ExecuteJavascriptCallback(jsCallbackId, jsArgs);
        } else {
            DebugLog("Renderer: OnProcessMessageReceived: invalid arguments," \
                    "expected first argument to be a javascript callback " \
                    "(int)");
            return false;
        }
    }
    return true;
}

void CefPythonApp::SetJavascriptBindings(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefDictionaryValue> data) {
    javascriptBindings_[browser->GetIdentifier()] = data;
}

CefRefPtr<CefDictionaryValue> CefPythonApp::GetJavascriptBindings(
                                    CefRefPtr<CefBrowser> browser) {
    int browserId = browser->GetIdentifier();
    if (javascriptBindings_.find(browserId) != javascriptBindings_.end()) {
        return javascriptBindings_[browserId];
    }
    return NULL;
}

void CefPythonApp::RemoveJavascriptBindings(CefRefPtr<CefBrowser> browser) {
    int browserId = browser->GetIdentifier();
    if (javascriptBindings_.find(browserId) != javascriptBindings_.end()) {
        javascriptBindings_.erase(browserId);
    }
}

bool CefPythonApp::BindedFunctionExists(CefRefPtr<CefBrowser> browser,
                                        const CefString& functionName) {
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (!jsBindings.get()) {
        return false;
    }
    std::string strFunctionName = functionName.ToString();
    size_t dotPosition = strFunctionName.find(".");
    if (std::string::npos != dotPosition) {
        // This is a method call, functionName == "object.method".
        CefString objectName(strFunctionName.substr(0, dotPosition));
        CefString methodName(strFunctionName.substr(dotPosition + 1,
                                                    std::string::npos));
        if (!(jsBindings->HasKey("objects")
                && jsBindings->GetType("objects") == VTYPE_DICTIONARY)) {
            DebugLog("Renderer: BindedFunctionExists() FAILED: "\
                    "objects dictionary not found");
            return false;
        }
        CefRefPtr<CefDictionaryValue> objects = \
                jsBindings->GetDictionary("objects");
        if (objects->HasKey(objectName)) {
            if (!(objects->GetType(objectName) == VTYPE_DICTIONARY)) {
                DebugLog("Renderer: BindedFunctionExists() FAILED: "\
                    "objects dictionary has invalid type");
                return false;
            }
            CefRefPtr<CefDictionaryValue> methods = \
                    objects->GetDictionary(objectName);
            return methods->HasKey(methodName);
        } else {
            return false;
        }
    } else {
        // This is a function call.
        if (!(jsBindings->HasKey("functions")
                && jsBindings->GetType("functions") == VTYPE_DICTIONARY)) {
            DebugLog("Renderer: BindedFunctionExists() FAILED: "\
                    "functions dictionary not found");
            return false;
        }
        CefRefPtr<CefDictionaryValue> functions = \
                jsBindings->GetDictionary("functions");
        return functions->HasKey(functionName);
    }
}

void CefPythonApp::DoJavascriptBindingsForBrowser(
                        CefRefPtr<CefBrowser> browser) {
    // get frame
    // get context
    // if bindToFrames is true loop through all frames,
    //      otherwise just the main frame.
    // post task on a valid v8 thread
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (!jsBindings.get()) {
        // Bindings must be set before this function is called.
        DebugLog("Renderer: DoJavascriptBindingsForBrowser() FAILED: " \
                "bindings not set");
        return;
    }
    std::vector<int64> frameIds;
    std::vector<CefString> frameNames;
    if (jsBindings->HasKey("bindToFrames")
            && jsBindings->GetType("bindToFrames") == VTYPE_BOOL
            && jsBindings->GetBool("bindToFrames")) {
        // GetFrameIdentifiers() is buggy, returns always a vector
        // filled with zeroes (as of revision 1448). Use GetFrameNames()
        // instead.
        browser->GetFrameNames(frameNames);
        for (std::vector<CefString>::iterator it = frameNames.begin(); \
                it != frameNames.end(); ++it) {
            CefRefPtr<CefFrame> frame = browser->GetFrame(*it);
            if (frame.get()) {
                frameIds.push_back(frame->GetIdentifier());
                // | printf("GetFrameNames(): frameId = %lu\n",
                // |         frame->GetIdentifier());
            }
        }
    }
    // BUG in CEF:
    //   GetFrameNames() does not return the main frame (as of revision 1448).
    //   Make it work for the future when this bug gets fixed.
    std::vector<int64>::iterator find_it = std::find(
            frameIds.begin(), frameIds.end(),
            browser->GetMainFrame()->GetIdentifier());
    if (find_it == frameIds.end()) {
        // Main frame not found in frameIds vector, add it now.
        // | printf("Adding main frame to frameIds: %lu\n",
        // |         browser->GetMainFrame()->GetIdentifier());
        frameIds.push_back(browser->GetMainFrame()->GetIdentifier());
    }
    if (!frameIds.size()) {
        DebugLog("Renderer: DoJavascriptBindingsForBrowser() FAILED: " \
                "frameIds.size() == 0");
        return;
    }
    for (std::vector<int64>::iterator it = frameIds.begin(); \
            it != frameIds.end(); ++it) {
        if (*it <= 0) {
            // GetFrameIdentifiers() bug that returned a vector
            // filled with zeros. This problem was fixed by using'
            // GetFrameNames() so this block of code should not
            // be executed anymore.
            DebugLog("Renderer: DoJavascriptBindingsForBrowser() WARNING: " \
                "frameId <= 0");
            // printf("[CEF Python] Renderer: frameId = %lli\n", *it);
            continue;
        }
        CefRefPtr<CefFrame> frame = browser->GetFrame(*it);
        if (!frame.get()) {
            DebugLog("Renderer: DoJavascriptBindingsForBrowser() WARNING: " \
                    "GetFrame() failed");
            continue;
        }
        CefRefPtr<CefV8Context> context = frame->GetV8Context();
        CefRefPtr<CefTaskRunner> taskRunner = context->GetTaskRunner();
        taskRunner->PostTask(CefCreateClosureTask(base::Bind(
                &CefPythonApp::DoJavascriptBindingsForFrame, this,
                browser, frame, context
        )));
    }
}

void CefPythonApp::DoJavascriptBindingsForFrame(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefV8Context> context) {
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (!jsBindings.get()) {
        // Bindings may not yet be set, it's okay.
        DebugLog("Renderer: DoJavascriptBindingsForFrame(): bindings not set");
        return;
    }
    DebugLog("Renderer: DoJavascriptBindingsForFrame(): bindings are set");
    if (!(jsBindings->HasKey("functions")
            && jsBindings->GetType("functions") == VTYPE_DICTIONARY
            && jsBindings->HasKey("properties")
            && jsBindings->GetType("properties") == VTYPE_DICTIONARY
            && jsBindings->HasKey("objects")
            && jsBindings->GetType("objects") == VTYPE_DICTIONARY
            && jsBindings->HasKey("bindToFrames")
            && jsBindings->GetType("bindToFrames") == VTYPE_BOOL)) {
        DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED: " \
                "invalid data [1]");
        return;
    }

    // A context must be explicitly entered before creating a
    // V8 Object, Array, Function or Date asynchronously.
    // NOTE: you cannot call CefV8Context::GetEnteredContext
    //       or GetCurrentContext when CefV8Context::InContext
    //       returns false, as it will result in crashes.
    bool didEnterContext = false;
    if (!CefV8Context::InContext()) {
        if (!context->IsValid()) {
            // BUG in CEF (Issue 130), the "context" provided by CEF may
            // not be valid. May be a timing issue. Or may be caused by
            // a redirect to a different origin and that creates a new
            // renderer process.
            DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED:"\
                    " V8 context provided by CEF is invalid");
            return;
        }
        context->Enter();
        didEnterContext = true;
    }
    CefRefPtr<CefDictionaryValue> functions = \
            jsBindings->GetDictionary("functions");
    CefRefPtr<CefDictionaryValue> properties = \
            jsBindings->GetDictionary("properties");
    CefRefPtr<CefDictionaryValue> objects = \
            jsBindings->GetDictionary("objects");
    // Here in this function we bind only for the current frame.
    // | bool bindToFrames = jsBindings->GetBool("bindToFrames");
    if (!(functions->IsValid() && properties->IsValid()
            && objects->IsValid())) {
        DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED: " \
                "invalid data [2]");
        if (didEnterContext)
            context->Exit();
        return;
    }
    CefRefPtr<CefV8Value> v8Window = context->GetGlobal();
    CefRefPtr<CefV8Value> v8Function;
    CefRefPtr<CefV8Handler> v8FunctionHandler(new V8FunctionHandler(this, 0));
    // FUNCTIONS.
    std::vector<CefString> functionsVector;
    if (!functions->GetKeys(functionsVector)) {
        DebugLog("Renderer: DoJavascriptBindingsForFrame(): " \
                "functions->GetKeys() FAILED");
        if (didEnterContext)
            context->Exit();
        return;
    }
    for (std::vector<CefString>::iterator it = functionsVector.begin(); \
            it != functionsVector.end(); ++it) {
        CefString functionName = *it;
        v8Function = CefV8Value::CreateFunction(functionName,
                v8FunctionHandler);
        v8Window->SetValue(functionName, v8Function,
                V8_PROPERTY_ATTRIBUTE_NONE);
    }
    // PROPERTIES.
    CefRefPtr<CefV8Value> v8Properties = CefDictionaryValueToV8Value(
            properties);
    std::vector<CefString> v8Keys;
    if (!v8Properties->GetKeys(v8Keys)) {
        DebugLog("DoJavascriptBindingsForFrame() FAILED: " \
                "v8Properties->GetKeys() failed");
        if (didEnterContext)
            context->Exit();
        return;
    }
    for (std::vector<CefString>::iterator it = v8Keys.begin(); \
            it != v8Keys.end(); ++it) {
        CefString v8Key = *it;
        CefRefPtr<CefV8Value> v8Value = v8Properties->GetValue(v8Key);
        v8Window->SetValue(v8Key, v8Value, V8_PROPERTY_ATTRIBUTE_NONE);
    }
    // OBJECTS AND ITS METHODS.
    std::vector<CefString> objectsVector;
    if (!objects->GetKeys(objectsVector)) {
        DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED: " \
                "objects->GetKeys() failed");
        if (didEnterContext)
            context->Exit();
        return;
    }
    for (std::vector<CefString>::iterator it = objectsVector.begin(); \
            it != objectsVector.end(); ++it) {
        CefString objectName = *it;
        CefRefPtr<CefV8Value> v8Object = CefV8Value::CreateObject(NULL, NULL);
        v8Window->SetValue(objectName, v8Object, V8_PROPERTY_ATTRIBUTE_NONE);
        // METHODS.
        if (!(objects->GetType(objectName) == VTYPE_DICTIONARY)) {
            DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED: " \
                    "objects->GetType() != VTYPE_DICTIONARY");
            if (didEnterContext)
                context->Exit();
            return;
        }
        CefRefPtr<CefDictionaryValue> methods = \
                objects->GetDictionary(objectName);
        std::vector<CefString> methodsVector;
        if (!(methods->IsValid() && methods->GetKeys(methodsVector))) {
            DebugLog("Renderer: DoJavascriptBindingsForFrame() FAILED: " \
                    "methods->GetKeys() failed");
            if (didEnterContext)
                context->Exit();
            return;
        }
        for (std::vector<CefString>::iterator it = methodsVector.begin(); \
                it != methodsVector.end(); ++it) {
            CefString methodName = *it;
            // fullMethodName = "object.method"
            std::string fullMethodName = objectName.ToString().append(".") \
                    .append(methodName.ToString());
            v8Function = CefV8Value::CreateFunction(fullMethodName,
                    v8FunctionHandler);
            v8Object->SetValue(methodName, v8Function,
                    V8_PROPERTY_ATTRIBUTE_NONE);
        }
    }
    // END.
    if (didEnterContext)
        context->Exit();
}
