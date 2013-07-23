// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_app.h"
#include "util.h"
#include <stdio.h>

// Declared "inline" to get rid of the "already defined" errors when linking.
inline void DebugLog(const char* szString)
{
  // TODO: get the log_file option from CefSettings.
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
    DebugLog("GetRenderProcessHandler() called");
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
    REQUIRE_IO_THREAD();
    printf("OnRenderProcessThreadCreated()\n");
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
    DebugLog("OnContextCreated() called");
    CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(
            "OnContextCreated");
    CefRefPtr<CefListValue> args = message.get()->GetArgumentList();
    // TODO: losing int64 precision
    args.get()->SetInt(0, (int)(frame.get()->GetIdentifier()));
    browser.get()->SendProcessMessage(PID_BROWSER, message);
}

void CefPythonApp::OnContextReleased(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefV8Context> context) {
    DebugLog("OnContextReleased() called");
    CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(
            "OnContextReleased");
    CefRefPtr<CefListValue> args = message.get()->GetArgumentList();
    // TODO: losing int64 precision
    args.get()->SetInt(0, (int)(frame.get()->GetIdentifier()));
    browser.get()->SendProcessMessage(PID_BROWSER, message);
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
    std::string name = message.get()->GetName().ToString();
    printf("Renderer: OnProcessMessageReceived(): %s\n", name.c_str());
    return false;
}

void DoJavascriptBindings(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefV8Context> context) {

}

void RedoJavascriptBindings(CefRefPtr<CefBrowser> browser) {

}
