/* This is a wrapper around including cefpython.h that is generated
   by Cython. Functions marked with the 'public' keyword are exposed
   to C through that header file. */

#ifndef CEFPYTHON_PUBLIC_API_H
#define CEFPYTHON_PUBLIC_API_H

#if defined(OS_WIN)
#pragma warning(disable:4190)  // cefpython.h extern C-linkage warnings
#endif

#include "Python.h"

// cefpython.h declares public functions using DL_IMPORT and these
// macros are not available in Python 3.
#ifndef DL_IMPORT
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT
#define DL_EXPORT(RTYPE) RTYPE
#endif

// Includes required by "cefpython.h".
#include "include/cef_client.h"
#include "include/cef_urlrequest.h"
#include "include/cef_command_line.h"
#include "util.h"

#include "../../build/build_cefpython/cefpython.h"

#endif // CEFPYTHON_PUBLIC_API_H
