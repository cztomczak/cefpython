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

__PYX_EXTERN_C DL_IMPORT(void) V8ContextHandler_OnContextCreated(CefRefPtr<CefBrowser>, int64);
__PYX_EXTERN_C DL_IMPORT(void) V8ContextHandler_OnContextReleased(CefRefPtr<CefBrowser>, int64);

#endif /* !__PYX_HAVE_API__cefpython_py27 */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initcefpython_py27(void);
#else
PyMODINIT_FUNC PyInit_cefpython_py27(void);
#endif

#endif /* !__PYX_HAVE__cefpython_py27 */
