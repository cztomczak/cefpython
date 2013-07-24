// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#include "include/cef_app.h"
#include "v8function_handler.h"
#include <map>

// CefPythonApp class is instantiated in subprocess and in 
// cefpython.pyx for the browser process, so the code is shared.
// Using printf() in CefRenderProcessHandler won't work, use
// the DebugLog() function instead, it will write the message
// to the "debug.log" file.

///
// Implement this interface to provide handler implementations. Methods will be
// called by the process and/or thread indicated.
///
/*--cef(source=client,no_debugct_check)--*/
class CefPythonApp : 
        public CefApp,
        public CefBrowserProcessHandler,
        public CefRenderProcessHandler {
 public:
  CefPythonApp()
    : v8FunctionHandler_(new V8FunctionHandler()) {
  }

  virtual void OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) OVERRIDE;

  virtual void OnRegisterCustomSchemes(
      CefRefPtr<CefSchemeRegistrar> registrar) OVERRIDE;

  virtual CefRefPtr<CefResourceBundleHandler> GetResourceBundleHandler() 
        OVERRIDE;

  virtual CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler()
        OVERRIDE;

  virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() 
        OVERRIDE;

  // ---------------------------------------------------------------------------
  // CefBrowserProcessHandler
  // ---------------------------------------------------------------------------

  virtual void OnContextInitialized() OVERRIDE;

  virtual void OnBeforeChildProcessLaunch(
      CefRefPtr<CefCommandLine> command_line) OVERRIDE;

  virtual void OnRenderProcessThreadCreated(
      CefRefPtr<CefListValue> extra_info) OVERRIDE;

  // ---------------------------------------------------------------------------
  // CefRenderProcessHandler
  // ---------------------------------------------------------------------------

  virtual void OnRenderThreadCreated(CefRefPtr<CefListValue> extra_info) 
        OVERRIDE;

  virtual void OnWebKitInitialized()
        OVERRIDE;

  virtual void OnBrowserCreated(CefRefPtr<CefBrowser> browser)
        OVERRIDE;

  virtual void OnBrowserDestroyed(CefRefPtr<CefBrowser> browser)
        OVERRIDE;

  virtual bool OnBeforeNavigation(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  CefRefPtr<CefRequest> request,
                                  cef_navigation_type_t navigation_type,
                                  bool is_redirect)
        OVERRIDE;

  virtual void OnContextCreated(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefV8Context> context)
        OVERRIDE;

  virtual void OnContextReleased(CefRefPtr<CefBrowser> browser,
                                 CefRefPtr<CefFrame> frame,
                                 CefRefPtr<CefV8Context> context)
        OVERRIDE;

  virtual void OnUncaughtException(CefRefPtr<CefBrowser> browser,
                                   CefRefPtr<CefFrame> frame,
                                   CefRefPtr<CefV8Context> context,
                                   CefRefPtr<CefV8Exception> exception,
                                   CefRefPtr<CefV8StackTrace> stackTrace)
        OVERRIDE;

  virtual void OnFocusedNodeChanged(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefDOMNode> node)
        OVERRIDE;

  virtual bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message)
        OVERRIDE;

  // ---------------------------------------------------------------------------
  // Javascript bindings
  // ---------------------------------------------------------------------------

  virtual void SetJavascriptBindings(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefDictionaryValue> data) 
                                    OVERRIDE;
  virtual CefRefPtr<CefDictionaryValue> GetJavascriptBindings(
                                    CefRefPtr<CefBrowser> browser) OVERRIDE;

  virtual void RemoveJavascriptBindings(CefRefPtr<CefBrowser> browser) OVERRIDE;

  virtual void DoJavascriptBindingsForBrowser(CefRefPtr<CefBrowser> browser) 
                                            OVERRIDE;
  
  virtual void DoJavascriptBindingsForFrame(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefV8Context> context) OVERRIDE;


protected:
  std::map<int, CefRefPtr<CefDictionaryValue> > javascriptBindings_;
  CefRefPtr<CefV8Handler> v8FunctionHandler_;

private:
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(CefPythonApp); 
};
