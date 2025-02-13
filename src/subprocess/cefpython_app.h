// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once
#include "include/cef_app.h"
#include "include/cef_print_handler.h"

#include <map>

// CefPythonApp class is instantiated in subprocess and in
// cefpython.pyx for the browser process, so the code is shared.
// Using printf() in CefRenderProcessHandler won't work on some
// operating systems, use LOG(INFO) macro instead, it will write
// the message to the "debug.log" file.

class CefPythonApp :
        public CefApp,
        public CefBrowserProcessHandler,
        public CefRenderProcessHandler {
 protected:
  std::map<int, CefRefPtr<CefDictionaryValue> > javascriptBindings_;
  CefRefPtr<CefPrintHandler> print_handler_;

 public:
  CefPythonApp();

  void OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) override;

  void OnRegisterCustomSchemes(
      CefRawPtr<CefSchemeRegistrar> registrar) override;

  CefRefPtr<CefResourceBundleHandler> GetResourceBundleHandler()
        override;

  CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler()
        override;

  CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler()
        override;

  // ---------------------------------------------------------------------------
  // CefBrowserProcessHandler
  // ---------------------------------------------------------------------------

  void OnContextInitialized() override;

  void OnBeforeChildProcessLaunch(
      CefRefPtr<CefCommandLine> command_line) override;

  CefRefPtr<CefPrintHandler> GetPrintHandler();

  void OnScheduleMessagePumpWork(int64_t delay_ms) override;


  // ---------------------------------------------------------------------------
  // CefRenderProcessHandler
  // ---------------------------------------------------------------------------

  void OnWebKitInitialized()
        override;

  void OnBrowserCreated(CefRefPtr<CefBrowser> browser, CefRefPtr<CefDictionaryValue> extra_info)
        override;

  void OnBrowserDestroyed(CefRefPtr<CefBrowser> browser)
        override;

  void OnContextCreated(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefV8Context> context)
        override;

  void OnContextReleased(CefRefPtr<CefBrowser> browser,
                                 CefRefPtr<CefFrame> frame,
                                 CefRefPtr<CefV8Context> context)
        override;

  void OnUncaughtException(CefRefPtr<CefBrowser> browser,
                                   CefRefPtr<CefFrame> frame,
                                   CefRefPtr<CefV8Context> context,
                                   CefRefPtr<CefV8Exception> exception,
                                   CefRefPtr<CefV8StackTrace> stackTrace)
        override;

  void OnFocusedNodeChanged(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefDOMNode> node)
        override;

  bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message)
        override;

  // ---------------------------------------------------------------------------
  // Javascript bindings
  // ---------------------------------------------------------------------------

  void SetJavascriptBindings(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefDictionaryValue> data);
  CefRefPtr<CefDictionaryValue> GetJavascriptBindings(
                                    CefRefPtr<CefBrowser> browser);

  void RemoveJavascriptBindings(CefRefPtr<CefBrowser> browser);

  bool BindedFunctionExists(CefRefPtr<CefBrowser> browser,
                                    const CefString& funcName);

  void DoJavascriptBindingsForBrowser(CefRefPtr<CefBrowser> browser);

  void DoJavascriptBindingsForFrame(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefV8Context> context);

private:
  IMPLEMENT_REFCOUNTING(CefPythonApp);
};
