/* This is a wrapper around including cefpython_fixed.h that is generated
   by Cython. Functions marked with the 'public' keyword are exposed
   to C through that header file. */

#ifndef CEFPYTHON_PUBLIC_API_H
#define CEFPYTHON_PUBLIC_API_H

#if defined(OS_WIN)
#pragma warning(disable:4190)  // cefpython_fixed.h extern C-linkage warnings
#endif

#include "Python.h"

// cefpython_fixed.h declares public functions using DL_IMPORT and these
// macros are not available in Python 3.
#ifndef DL_IMPORT
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT
#define DL_EXPORT(RTYPE) RTYPE
#endif

// Includes required by "cefpython_fixed.h".
#include "include/cef_client.h"
#include "include/cef_urlrequest.h"
#include "include/cef_command_line.h"
#include "util.h"

#include "../../build/build_cefpython/cefpython_fixed.h"

#endif // CEFPYTHON_PUBLIC_API_H
