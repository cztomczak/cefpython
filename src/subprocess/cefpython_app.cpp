// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// BROWSER_PROCESS macro is defined when compiling the libcefpythonapp library.
// RENDERER_PROCESS macro is define when compiling the subprocess executable.

#ifdef BROWSER_PROCESS
#include "common/cefpython_public_api.h"
#endif

#if defined(OS_WIN)
#include <Shobjidl.h>
#pragma comment(lib, "Shell32.lib")
#endif  // OS_WIN

#ifdef BROWSER_PROCESS
#ifdef OS_WIN
#include "client_handler/dpi_aware.h"
#elif OS_LINUX  // OS_WIN
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <gdk/gdkx.h>
#include "client_handler/x11.h"
#include "print_handler_gtk.h"
#endif  // OS_LINUX
#endif  // BROWSER_PROCESS

#include "cefpython_app.h"
#include "util.h"
#include "include/wrapper/cef_closure_task.h"
#include "include/base/cef_bind.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_callback.h"
#include <vector>
#include <algorithm>
#include "v8utils.h"
#include "javascript_callback.h"
#include "v8function_handler.h"

#ifdef BROWSER_PROCESS
#include "main_message_loop/main_message_loop_external_pump.h"
#endif

// GLOBALS
bool g_debug = false;

CefPythonApp::CefPythonApp() {
#ifdef BROWSER_PROCESS
    cefpython_GetDebugOptions(&g_debug);
#endif
}

// -----------------------------------------------------------------------------
// CefApp
// -----------------------------------------------------------------------------

void CefPythonApp::OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) {
    // IMPORTANT NOTES
    // ---------------
    // NOTE 1: Currently CEF logging is limited and you cannot log
    //         info messages during execution of this function. The
    //         default log severity in Chromium is LOG_ERROR, thus
    //         you can will only see log messages when using LOG(ERROR)
    //         here. You won't see LOG(WARNING) nor LOG(INFO) messages
    //         here.
    // NOTE 2: The "g_debug" variable is never set at this moment
    //         due to IPC messaging delay. There is some code here
    //         that depends on this variable, but it is currently
    //         never executed.

#ifdef BROWSER_PROCESS
    // This is included only in the Browser process, when building
    // the libcefpythonapp library.
    if (process_type.empty()) {
        // Empty proc type, so this must be the main browser process.
        App_OnBeforeCommandLineProcessing_BrowserProcess(command_line);
    }
#endif  // BROWSER_PROCESS

    // IMPORTANT: This code is currently dead due to g_debug and
    //            LOG(INFO) issues described at the top of this
    //            function. Command line string for subprocesses are
    //            are currently logged in OnBeforeChildProcess().
    //            Command line string for the main browser process
    //            is currently never logged.
    std::string process_name = process_type.ToString();
    if (process_name.empty()) {
        process_name = "browser";
    }
#ifdef BROWSER_PROCESS
    std::string logMessage = "[Browser process] ";
#else  // BROWSER_PROCESS
    std::string logMessage = "[Non-browser process] ";
#endif  // BROWSER_PROCESS
    logMessage.append("Command line string for the ");
    logMessage.append(process_name);
    logMessage.append(" process: ");
    std::string clString = command_line->GetCommandLineString().ToString();
    logMessage.append(clString.c_str());
    if (g_debug) {
        // This code is currently never executed, see the "IMPORTANT"
        // comment above and comments at the top of this function.
        LOG(INFO) << logMessage.c_str();
    }

#ifdef OS_WIN
    // Set AppUserModelID (AppID) when "--app-user-model-id" switch
    // is provided. This fixes pinning to taskbar issues on Windows 10.
    // See Issue #395 for details.
    //
    // AppID here is set in all processes (Browser, Renderer, GPU, etc.).
    //
    // When compiling under Python 2.7 (VS2008) using Visual C++ for
    // Python, it seems you can't use WINSDK 7 header files even though
    // WINVER was specified in build_cpp_projects.py macros. Thus calling
    // using proc address. Specifying full path to Shell32.dll is not
    // required, in Chromium's source code full paths are not used.
    //
    // Note:
    //   subprocess.exe is built with UNICODE defined, however the
    //   cefpython_app library that is shared between subprocess and
    //   python process does not define UNICODE macro. Thus it is required
    //   to call LoadLibraryW explicitilly here.
    HINSTANCE shell32 = LoadLibraryW(L"shell32.dll");
    CefString app_id = command_line->GetSwitchValue("app-user-model-id");
    if (app_id.length()) {
        typedef HRESULT (WINAPI *SetAppUserModelID_Type)(PCWSTR);
        static SetAppUserModelID_Type SetAppUserModelID;
        SetAppUserModelID = (SetAppUserModelID_Type)GetProcAddress(
                shell32, "SetCurrentProcessExplicitAppUserModelID");
        HRESULT hr = (*SetAppUserModelID)(app_id.ToWString().c_str());
        if (hr == S_OK) {
            if (g_debug) {
                // This code is currently never executed, see comments
                // at the top of this function.
                LOG(INFO) << "SetCurrentProcessExplicitAppUserModelID ok";
            }
        } else {
            LOG(ERROR) << "SetCurrentProcessExplicitAppUserModelID failed";
        }
    }
#endif  // OS_WIN
}

void CefPythonApp::OnRegisterCustomSchemes(
        CefRawPtr<CefSchemeRegistrar> registrar) {
}

CefRefPtr<CefResourceBundleHandler> CefPythonApp::GetResourceBundleHandler() {
    return nullptr;
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
#if defined(OS_WINDOWS)
    if (IsProcessDpiAware()) {
        // It is required to set DPI awareness in subprocesses
        // as well, see Issue #358.
        command_line->AppendSwitch("enable-high-dpi-support");
    }
#endif // OS_WINDOWS
    BrowserProcessHandler_OnBeforeChildProcessLaunch(command_line);
#endif // BROWSER_PROCESS

#ifdef BROWSER_PROCESS
    std::string logMessage = "[Browser process] ";
#else
    std::string logMessage = "[Non-browser process] ";
#endif // BROWSER_PROCESS
    logMessage.append("OnBeforeChildProcessLaunch() command line: ");
    std::string clString = command_line->GetCommandLineString().ToString();
    logMessage.append(clString.c_str());
    LOG(INFO) << logMessage.c_str();
}

CefRefPtr<CefPrintHandler> CefPythonApp::GetPrintHandler() {
#ifdef BROWSER_PROCESS
#if defined(OS_LINUX)
    // For print handler to work GTK must be initialized. This is
    // required for some of the examples.
    // --
    // A similar code is in client_handler/x11.cpp. If making changes here,
    // make changes there as well.
    GdkDisplay* gdk_display = gdk_display_get_default();
    if (!gdk_display) {
        LOG(INFO) << "[Browser process] Initialize GTK";
        gtk_init(0, NULL);
        InstallX11ErrorHandlers();
    }
#endif
#endif
    return print_handler_;
}

void CefPythonApp::OnScheduleMessagePumpWork(int64_t delay_ms) {
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

void CefPythonApp::OnWebKitInitialized() {
}

void CefPythonApp::OnBrowserCreated(CefRefPtr<CefBrowser> browser, CefRefPtr<CefDictionaryValue> extra_info) {
}

void CefPythonApp::OnBrowserDestroyed(CefRefPtr<CefBrowser> browser) {
    LOG(INFO) << "[Renderer process] OnBrowserDestroyed()";
    RemoveJavascriptBindings(browser);
}

void CefPythonApp::OnContextCreated(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefV8Context> context) {
    LOG(INFO) << "[Renderer process] OnContextCreated()";
    CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(
            "OnContextCreated");
    CefRefPtr<CefListValue> arguments = message->GetArgumentList();
    arguments->SetString(0, frame->GetIdentifier());
    frame->SendProcessMessage(PID_BROWSER, message);
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
    LOG(INFO) << "[Renderer process] OnContextReleased()";
    CefRefPtr<CefProcessMessage> message;
    CefRefPtr<CefListValue> arguments;
    // ------------------------------------------------------------------------
    // 1. Send "OnContextReleased" message.
    // ------------------------------------------------------------------------
    message = CefProcessMessage::Create("OnContextReleased");
    arguments = message->GetArgumentList();
    arguments->SetInt(0, browser->GetIdentifier());
    arguments->SetString(1, frame->GetIdentifier());
    // Should we send the message using current "browser"
    // when this is not the main frame? It could fail, so
    // it is more reliable to always use the main browser.
    frame->SendProcessMessage(PID_BROWSER, message);
    // ------------------------------------------------------------------------
    // 2. Remove python callbacks for a frame.
    // ------------------------------------------------------------------------
    // This is already done via RemovePyFrame called from
    // V8ContextHandler_OnContextReleased.
    // If this is the main frame then in LifespanHandler_BeforeClose()
    // we're calling RemovePythonCallbacksForBrowser().
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
                                        CefRefPtr<CefFrame> frame,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    const std::string& messageName = message->GetName();
    std::string logMessage = "[Renderer process] OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    LOG(INFO) << logMessage.c_str();
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
            LOG(ERROR) << "[Renderer process] OnProcessMessageReceived():"
                          " invalid arguments,"
                          " messageName=DoJavascriptBindings";
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
            LOG(ERROR) << "[Renderer process] OnProcessMessageReceived:"
                          " invalid arguments, expected first argument to be"
                          " a javascript callback (int)";
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
    return nullptr;
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
            LOG(ERROR) << "[Renderer process] BindedFunctionExists():"
                          " objects dictionary not found";
            return false;
        }
        CefRefPtr<CefDictionaryValue> objects = \
                jsBindings->GetDictionary("objects");
        if (objects->HasKey(objectName)) {
            if (!(objects->GetType(objectName) == VTYPE_DICTIONARY)) {
                LOG(ERROR) << "[Renderer process] BindedFunctionExists():"
                              " objects dictionary has invalid type";
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
            LOG(ERROR) << "[Renderer process] BindedFunctionExists():"
                          " functions dictionary not found";
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
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForBrowser():"
                      " bindings not set";
        return;
    }
    std::vector<CefString> frameIds;
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
            CefRefPtr<CefFrame> frame = browser->GetFrameByName(*it);
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
    std::vector<CefString>::iterator find_it = std::find(
            frameIds.begin(), frameIds.end(),
            browser->GetMainFrame()->GetIdentifier());
    if (find_it == frameIds.end()) {
        // Main frame not found in frameIds vector, add it now.
        // | printf("Adding main frame to frameIds: %lu\n",
        // |         browser->GetMainFrame()->GetIdentifier());
        frameIds.push_back(browser->GetMainFrame()->GetIdentifier());
    }
    if (!frameIds.size()) {
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForBrowser():"
                      " frameIds.size() == 0";
        return;
    }
    for (std::vector<CefString>::iterator it = frameIds.begin(); \
            it != frameIds.end(); ++it) {
        if (it->empty()) {
            // GetFrameIdentifiers() bug that returned a vector
            // filled with zeros. This problem was fixed by using'
            // GetFrameNames() so this block of code should not
            // be executed anymore.
            LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForBrowser():"
                          " frameId empty";
            // printf("[CEF Python] Renderer: frameId = %lli\n", *it);
            continue;
        }
        CefRefPtr<CefFrame> frame = browser->GetFrameByIdentifier(*it);
        if (!frame.get()) {
            LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForBrowser():"
                          " GetFrameByIdentifier() failed";
            continue;
        }
        CefRefPtr<CefV8Context> context = frame->GetV8Context();
        CefRefPtr<CefTaskRunner> taskRunner = context->GetTaskRunner();
        taskRunner->PostTask(
            CefCreateClosureTask(
                base::BindOnce(
                    &CefPythonApp::DoJavascriptBindingsForFrame, this,
                    browser, frame, context)));
    }
}

void CefPythonApp::DoJavascriptBindingsForFrame(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefV8Context> context) {
    LOG(INFO) << "[Renderer process] in DoJavascriptBindingsForFrame()";
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (!jsBindings.get()) {
        // Bindings may not yet be set, it's okay.
        LOG(INFO) << "[Renderer process] DoJavascriptBindingsForFrame():"
                     " bindings not set yet";
        return;
    }
    LOG(INFO) << "[Renderer process] DoJavascriptBindingsForFrame():"
                 " bindings are set";
    if (!(jsBindings->HasKey("functions")
            && jsBindings->GetType("functions") == VTYPE_DICTIONARY
            && jsBindings->HasKey("properties")
            && jsBindings->GetType("properties") == VTYPE_DICTIONARY
            && jsBindings->HasKey("objects")
            && jsBindings->GetType("objects") == VTYPE_DICTIONARY
            && jsBindings->HasKey("bindToFrames")
            && jsBindings->GetType("bindToFrames") == VTYPE_BOOL)) {
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                      " invalid data [1]";
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
            // This message is logged in the tutorial.py example which
            // uses data uri created from html string.
            LOG(INFO) << "[Renderer process] DoJavascriptBindingsForFrame():"
                         " V8 context provided by CEF is invalid";
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
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                      " invalid data [2]";
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
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                      " functions->GetKeys() failed";
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
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                      " v8Properties->GetKeys() failed";
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
        LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                      " objects->GetKeys() failed";
        if (didEnterContext)
            context->Exit();
        return;
    }
    for (std::vector<CefString>::iterator it = objectsVector.begin(); \
            it != objectsVector.end(); ++it) {
        CefString objectName = *it;
        CefRefPtr<CefV8Value> v8Object = CefV8Value::CreateObject(nullptr, nullptr);
        v8Window->SetValue(objectName, v8Object, V8_PROPERTY_ATTRIBUTE_NONE);
        // METHODS.
        if (!(objects->GetType(objectName) == VTYPE_DICTIONARY)) {
            LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                          " objects->GetType() != VTYPE_DICTIONARY";
            if (didEnterContext)
                context->Exit();
            return;
        }
        CefRefPtr<CefDictionaryValue> methods = \
                objects->GetDictionary(objectName);
        std::vector<CefString> methodsVector;
        if (!(methods->IsValid() && methods->GetKeys(methodsVector))) {
            LOG(ERROR) << "[Renderer process] DoJavascriptBindingsForFrame():"
                          " methods->GetKeys() failed";
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
