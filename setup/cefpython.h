#ifndef __PYX_HAVE__cefpython
#define __PYX_HAVE__cefpython


#ifndef __PYX_HAVE_API__cefpython

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

__PYX_EXTERN_C DL_IMPORT(int) LoadHandler_OnLoadEnd(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, int);

#endif /* !__PYX_HAVE_API__cefpython */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initcefpython(void);
#else
PyMODINIT_FUNC PyInit_cefpython(void);
#endif

#endif /* !__PYX_HAVE__cefpython */
