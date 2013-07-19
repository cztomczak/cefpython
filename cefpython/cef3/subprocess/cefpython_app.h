// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#include "include/cef_app.h"

// CefPythonApp class is also instantiated in cefpython.pyx for the 
// browser process.

///
// Implement this interface to provide handler implementations. Methods will be
// called by the process and/or thread indicated.
///
/*--cef(source=client,no_debugct_check)--*/
class CefPythonApp : public CefApp {
 public:
  ///
  // Provides an opportunity to view and/or modify command-line arguments before
  // processing by CEF and Chromium. The |process_type| value will be empty for
  // the browser process. Do not keep a reference to the CefCommandLine object
  // passed to this method. The CefSettings.command_line_args_disabled value
  // can be used to start with an empty command-line object. Any values
  // specified in CefSettings that equate to command-line arguments will be set
  // before this method is called. Be cautious when using this method to modify
  // command-line arguments for non-browser processes as this may result in
  // undefined behavior including crashes.
  ///
  /*--cef(optional_param=process_type)--*/
  virtual void OnBeforeCommandLineProcessing(
      const CefString& process_type,
      CefRefPtr<CefCommandLine> command_line) {
  }

  ///
  // Provides an opportunity to register custom schemes. Do not keep a reference
  // to the |registrar| object. This method is called on the main thread for
  // each process and the registered schemes should be the same across all
  // processes.
  ///
  /*--cef()--*/
  virtual void OnRegisterCustomSchemes(
      CefRefPtr<CefSchemeRegistrar> registrar) {
  }

  ///
  // Return the handler for resource bundle events. If
  // CefSettings.pack_loading_disabled is true a handler must be returned. If no
  // handler is returned resources will be loaded from pack files. This method
  // is called by the browser and render processes on multiple threads.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefResourceBundleHandler> GetResourceBundleHandler() {
    return NULL;
  }

  ///
  // Return the handler for functionality specific to the browser process. This
  // method is called on multiple threads in the browser process.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() {
    return NULL;
  }

  ///
  // Return the handler for functionality specific to the render process. This
  // method is called on the render process main thread.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() {
    return NULL;
  }
};

class ClientApp : public CefApp {
public:
private:
  IMPLEMENT_REFCOUNTING(ClientApp); 
};
