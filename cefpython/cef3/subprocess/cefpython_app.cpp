// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_app.h"
#include "util.h"
#include "include/cef_runnable.h"
#include <stdio.h>
#include <vector>

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

// -----------------------------------------------------------------------------
// CefApp
// -----------------------------------------------------------------------------

void CefPythonApp::OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) {
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
    DebugLog("Renderer: GetRenderProcessHandler()");
    return this;
}

// -----------------------------------------------------------------------------
// CefBrowserProcessHandler
// -----------------------------------------------------------------------------

void CefPythonApp::OnContextInitialized() {
    REQUIRE_UI_THREAD();
}

void CefPythonApp::OnBeforeChildProcessLaunch(
        CefRefPtr<CefCommandLine> command_line) {}

///
// Called on the browser process IO thread after the main thread has been
// created for a new render process. Provides an opportunity to specify extra
// information that will be passed to
// CefRenderProcessHandler::OnRenderThreadCreated() in the render process. Do
// not keep a reference to |extra_info| outside of this method.
///
void CefPythonApp::OnRenderProcessThreadCreated(
        CefRefPtr<CefListValue> extra_info) {
    // If you have an existing CefListValue that you would like
    // to provide, do this:
    // | extra_info = mylist.get()
    // The equivalent in Cython is:
    // | extra_info.Assign(mylist.get())
    REQUIRE_IO_THREAD();
    DebugLog("Browser: OnRenderProcessThreadCreated()");
}

// -----------------------------------------------------------------------------
// CefRenderProcessHandler
// -----------------------------------------------------------------------------

///
// Called after the render process main thread has been created. |extra_info|
// is a read-only value originating from
// CefBrowserProcessHandler::OnRenderProcessThreadCreated(). Do not keep a
// reference to |extra_info| outside of this method.
///
void CefPythonApp::OnRenderThreadCreated(CefRefPtr<CefListValue> extra_info) {
}

void CefPythonApp::OnWebKitInitialized() {
}

void CefPythonApp::OnBrowserCreated(CefRefPtr<CefBrowser> browser) {
}

void CefPythonApp::OnBrowserDestroyed(CefRefPtr<CefBrowser> browser) {
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
    CefRefPtr<CefListValue> args = message->GetArgumentList();
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
    args->SetInt(0, (int)(frame->GetIdentifier()));
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
    CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(
            "OnContextReleased");
    CefRefPtr<CefListValue> args = message->GetArgumentList();
    // TODO: losing int64 precision, the solution is to convert
    //       it to string and then in the Browser process back
    //       from string to int64. But it is rather unlikely
    //       that number of frames will exceed int range, so
    //       casting it to int for now.
    args->SetInt(0, (int)(frame->GetIdentifier()));
    browser->SendProcessMessage(PID_BROWSER, message);
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

///
// Called when a new message is received from a different process. Return true
// if the message was handled or false otherwise. Do not keep a reference to
// or attempt to access the message outside of this callback.
///
bool CefPythonApp::OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    std::string messageName = message->GetName().ToString();
    std::string logMessage = "Renderer: OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    DebugLog(logMessage.c_str());
    if (messageName == "DoJavascriptBindings") {
        CefRefPtr<CefListValue> args = message->GetArgumentList();
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
    }
    return false;
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
                                        const CefString& funcName) {
    CefRefPtr<CefDictionaryValue> jsBindings = GetJavascriptBindings(browser);
    if (!jsBindings.get()) {
        return false;
    }
    std::string strFuncName = funcName.ToString();
    size_t dotPosition = strFuncName.find(".");
    if (std::string::npos != dotPosition) {
        // This is a method call, funcName == "object.method".
        CefString objectName(strFuncName.substr(0, dotPosition));
        CefString methodName(strFuncName.substr(dotPosition, std::string::npos));
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
        return functions->HasKey(funcName);
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
    if (jsBindings->HasKey("bindToFrames")
            && jsBindings->GetType("bindToFrames") == VTYPE_BOOL
            && jsBindings->GetBool("bindToFrames")) {
        browser->GetFrameIdentifiers(frameIds);
    } else {
        frameIds.push_back(browser->GetMainFrame()->GetIdentifier());
    }
    /*
    Another way:
    | for (std::vector<int64>::iterator it = v.begin(); it != v.end(); ++it) {
    |     CefRefPtr<CefFrame> frame = browser->GetFrame(*it);
    */
    for (std::vector<int>::size_type i = 0; i != frameIds.size(); i++) {
        CefRefPtr<CefFrame> frame = browser->GetFrame(frameIds[i]);
        CefRefPtr<CefV8Context> context = frame->GetV8Context();
        CefRefPtr<CefTaskRunner> taskRunner = context->GetTaskRunner();
        taskRunner->PostTask(NewCefRunnableMethod(
                this, &CefPythonApp::DoJavascriptBindingsForFrame,
                browser, frame, context));
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
    bool enteredContext = false;
    if (!context->IsSame(CefV8Context::GetCurrentContext())) {
        enteredContext = true;
        context->Enter();
    }
    // TODO: properties, objects, other frames.
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
        if (enteredContext)
            context->Exit();
        return;
    }
    CefRefPtr<CefV8Value> v8Window = context->GetGlobal();
    CefRefPtr<CefV8Value> v8Function;
    CefRefPtr<CefV8Handler> v8FunctionHandler(new V8FunctionHandler(this));
    // FUNCTIONS.
    std::vector<CefString> functionsVector;
    if (!functions->GetKeys(functionsVector)) {
        DebugLog("Renderer: DoJavascriptBindingsForFrame(): " \
                "functions->GetKeys() FAILED");
        if (enteredContext)
            context->Exit();
        return;
    }
    for (std::vector<CefString>::iterator it = functionsVector.begin(); \
            it != functionsVector.end(); ++it) {
        CefString funcName = *it;
        v8Function = CefV8Value::CreateFunction(funcName, v8FunctionHandler);
        v8Window->SetValue(funcName, v8Function, 
                V8_PROPERTY_ATTRIBUTE_NONE);
    }
    if (enteredContext)
        context->Exit();
}
