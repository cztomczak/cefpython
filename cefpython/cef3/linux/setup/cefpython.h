#ifndef __PYX_HAVE__cefpython_py27
#define __PYX_HAVE__cefpython_py27


#ifndef __PYX_HAVE_API__cefpython_py27

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

__PYX_EXTERN_C DL_IMPORT(void) V8ContextHandler_OnContextCreated(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>);
__PYX_EXTERN_C DL_IMPORT(void) V8ContextHandler_OnContextReleased(int, int64);
__PYX_EXTERN_C DL_IMPORT(void) V8FunctionHandler_Execute(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString &, CefRefPtr<CefListValue>);
__PYX_EXTERN_C DL_IMPORT(void) RemovePythonCallbacksForFrame(int);
__PYX_EXTERN_C DL_IMPORT(bool) ExecutePythonCallback(CefRefPtr<CefBrowser>, int, CefRefPtr<CefListValue>);
__PYX_EXTERN_C DL_IMPORT(void) LifespanHandler_OnBeforeClose(CefRefPtr<CefBrowser>);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnLoadingStateChange(CefRefPtr<CefBrowser>, bool, bool, bool);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnAddressChange(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnTitleChange(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(bool) DisplayHandler_OnTooltip(CefRefPtr<CefBrowser>, CefString &);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnStatusMessage(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(bool) DisplayHandler_OnConsoleMessage(CefRefPtr<CefBrowser>, CefString const &, CefString const &, int);
__PYX_EXTERN_C DL_IMPORT(bool) KeyboardHandler_OnPreKeyEvent(CefRefPtr<CefBrowser>, CefKeyEvent const &, CefEventHandle, bool *);
__PYX_EXTERN_C DL_IMPORT(bool) KeyboardHandler_OnKeyEvent(CefRefPtr<CefBrowser>, CefKeyEvent const &, CefEventHandle);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnBeforeResourceLoad(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefRefPtr<CefRequest>);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnResourceRedirect(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString const &, CefString &);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_GetAuthCredentials(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, bool, CefString const &, int, CefString const &, CefString const &, CefRefPtr<CefAuthCallback>);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnQuotaRequest(CefRefPtr<CefBrowser>, CefString const &, int64, CefRefPtr<CefQuotaCallback>);
__PYX_EXTERN_C DL_IMPORT(CefRefPtr<CefCookieManager>) RequestHandler_GetCookieManager(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnProtocolExecution(CefRefPtr<CefBrowser>, CefString const &, bool &);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnBeforePluginLoad(CefRefPtr<CefBrowser>, CefString const &, CefString const &, CefRefPtr<CefWebPluginInfo>);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnCertificateError(int, CefString const &, CefRefPtr<CefAllowCertificateErrorCallback>);
__PYX_EXTERN_C DL_IMPORT(bool) CookieVisitor_Visit(int, CefCookie const &, int, int, bool &);

#endif /* !__PYX_HAVE_API__cefpython_py27 */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initcefpython_py27(void);
#else
PyMODINIT_FUNC PyInit_cefpython_py27(void);
#endif

#endif /* !__PYX_HAVE__cefpython_py27 */
