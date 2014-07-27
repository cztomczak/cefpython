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
__PYX_EXTERN_C DL_IMPORT(bool) LifespanHandler_OnBeforePopup(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString const &, CefString const &, int const , CefWindowInfo &, CefRefPtr<CefClient> &, CefBrowserSettings &, bool *);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnAddressChange(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnTitleChange(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(bool) DisplayHandler_OnTooltip(CefRefPtr<CefBrowser>, CefString &);
__PYX_EXTERN_C DL_IMPORT(void) DisplayHandler_OnStatusMessage(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(bool) DisplayHandler_OnConsoleMessage(CefRefPtr<CefBrowser>, CefString const &, CefString const &, int);
__PYX_EXTERN_C DL_IMPORT(bool) KeyboardHandler_OnPreKeyEvent(CefRefPtr<CefBrowser>, CefKeyEvent const &, CefEventHandle, bool *);
__PYX_EXTERN_C DL_IMPORT(bool) KeyboardHandler_OnKeyEvent(CefRefPtr<CefBrowser>, CefKeyEvent const &, CefEventHandle);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnBeforeResourceLoad(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefRefPtr<CefRequest>);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnBeforeBrowse(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefRefPtr<CefRequest>, bool);
__PYX_EXTERN_C DL_IMPORT(CefRefPtr<CefResourceHandler>) RequestHandler_GetResourceHandler(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefRefPtr<CefRequest>);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnResourceRedirect(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, CefString const &, CefString &);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_GetAuthCredentials(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, bool, CefString const &, int, CefString const &, CefString const &, CefRefPtr<CefAuthCallback>);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnQuotaRequest(CefRefPtr<CefBrowser>, CefString const &, int64, CefRefPtr<CefQuotaCallback>);
__PYX_EXTERN_C DL_IMPORT(CefRefPtr<CefCookieManager>) RequestHandler_GetCookieManager(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnProtocolExecution(CefRefPtr<CefBrowser>, CefString const &, bool &);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnBeforePluginLoad(CefRefPtr<CefBrowser>, CefString const &, CefString const &, CefRefPtr<CefWebPluginInfo>);
__PYX_EXTERN_C DL_IMPORT(bool) RequestHandler_OnCertificateError(int, CefString const &, CefRefPtr<CefAllowCertificateErrorCallback>);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnRendererProcessTerminated(CefRefPtr<CefBrowser>, enum cef_termination_status_t);
__PYX_EXTERN_C DL_IMPORT(void) RequestHandler_OnPluginCrashed(CefRefPtr<CefBrowser>, CefString const &);
__PYX_EXTERN_C DL_IMPORT(bool) CookieVisitor_Visit(int, CefCookie const &, int, int, bool &);
__PYX_EXTERN_C DL_IMPORT(void) StringVisitor_Visit(int, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) LoadHandler_OnLoadingStateChange(CefRefPtr<CefBrowser>, bool, bool, bool);
__PYX_EXTERN_C DL_IMPORT(void) LoadHandler_OnLoadStart(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>);
__PYX_EXTERN_C DL_IMPORT(void) LoadHandler_OnLoadEnd(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, int);
__PYX_EXTERN_C DL_IMPORT(void) LoadHandler_OnLoadError(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, enum cef_errorcode_t, CefString const &, CefString const &);
__PYX_EXTERN_C DL_IMPORT(void) BrowserProcessHandler_OnRenderProcessThreadCreated(CefRefPtr<CefListValue>);
__PYX_EXTERN_C DL_IMPORT(void) BrowserProcessHandler_OnBeforeChildProcessLaunch(CefRefPtr<CefCommandLine>);
__PYX_EXTERN_C DL_IMPORT(bool) RenderHandler_GetRootScreenRect(CefRefPtr<CefBrowser>, CefRect &);
__PYX_EXTERN_C DL_IMPORT(bool) RenderHandler_GetViewRect(CefRefPtr<CefBrowser>, CefRect &);
__PYX_EXTERN_C DL_IMPORT(bool) RenderHandler_GetScreenRect(CefRefPtr<CefBrowser>, CefRect &);
__PYX_EXTERN_C DL_IMPORT(bool) RenderHandler_GetScreenPoint(CefRefPtr<CefBrowser>, int, int, int &, int &);
__PYX_EXTERN_C DL_IMPORT(bool) RenderHandler_GetScreenInfo(CefRefPtr<CefBrowser>, CefScreenInfo &);
__PYX_EXTERN_C DL_IMPORT(void) RenderHandler_OnPopupShow(CefRefPtr<CefBrowser>, bool);
__PYX_EXTERN_C DL_IMPORT(void) RenderHandler_OnPopupSize(CefRefPtr<CefBrowser>, CefRect const &);
__PYX_EXTERN_C DL_IMPORT(void) RenderHandler_OnPaint(CefRefPtr<CefBrowser>, cef_paint_element_type_t, std::vector<CefRect> &, void const *, int, int);
__PYX_EXTERN_C DL_IMPORT(void) RenderHandler_OnCursorChange(CefRefPtr<CefBrowser>, CefCursorHandle);
__PYX_EXTERN_C DL_IMPORT(void) RenderHandler_OnScrollOffsetChanged(CefRefPtr<CefBrowser>);
__PYX_EXTERN_C DL_IMPORT(bool) ResourceHandler_ProcessRequest(int, CefRefPtr<CefRequest>, CefRefPtr<CefCallback>);
__PYX_EXTERN_C DL_IMPORT(void) ResourceHandler_GetResponseHeaders(int, CefRefPtr<CefResponse>, int64 &, CefString &);
__PYX_EXTERN_C DL_IMPORT(bool) ResourceHandler_ReadResponse(int, void *, int, int &, CefRefPtr<CefCallback>);
__PYX_EXTERN_C DL_IMPORT(bool) ResourceHandler_CanGetCookie(int, CefCookie const &);
__PYX_EXTERN_C DL_IMPORT(bool) ResourceHandler_CanSetCookie(int, CefCookie const &);
__PYX_EXTERN_C DL_IMPORT(void) ResourceHandler_Cancel(int);
__PYX_EXTERN_C DL_IMPORT(void) WebRequestClient_OnUploadProgress(int, CefRefPtr<CefURLRequest>, uint64, uint64);
__PYX_EXTERN_C DL_IMPORT(void) WebRequestClient_OnDownloadProgress(int, CefRefPtr<CefURLRequest>, uint64, uint64);
__PYX_EXTERN_C DL_IMPORT(void) WebRequestClient_OnDownloadData(int, CefRefPtr<CefURLRequest>, void const *, size_t);
__PYX_EXTERN_C DL_IMPORT(void) WebRequestClient_OnRequestComplete(int, CefRefPtr<CefURLRequest>);
__PYX_EXTERN_C DL_IMPORT(void) App_OnBeforeCommandLineProcessing_BrowserProcess(CefRefPtr<CefCommandLine>);
__PYX_EXTERN_C DL_IMPORT(void) cefpython_GetDebugOptions(bool *, std::string *);

#endif /* !__PYX_HAVE_API__cefpython_py27 */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initcefpython_py27(void);
#else
PyMODINIT_FUNC PyInit_cefpython_py27(void);
#endif

#endif /* !__PYX_HAVE__cefpython_py27 */
