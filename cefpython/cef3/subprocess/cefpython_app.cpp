// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_app.h"
#include "util.h"
#include <stdio.h>

void DebugLog(const char* szString)
{
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

void CefPythonApp::OnRenderProcessThreadCreated(
        CefRefPtr<CefListValue> extra_info) {
    REQUIRE_IO_THREAD();
}

// -----------------------------------------------------------------------------
// CefRenderProcessHandler
// -----------------------------------------------------------------------------

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
    CefRefPtr<CefProcessMessage> msg = CefProcessMessage::Create(
            "OnContextCreated");
    browser.get()->SendProcessMessage(PID_BROWSER, msg);
}

void CefPythonApp::OnContextReleased(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefV8Context> context) {
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
    return false;
}
