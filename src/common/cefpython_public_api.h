// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

/* This is a wrapper around including cefpython_fixed.h that is generated
   by Cython. Functions marked with the 'public' keyword are exposed
   to C through that header file. */

#ifndef CEFPYTHON_PUBLIC_API_H
#define CEFPYTHON_PUBLIC_API_H

#if defined(OS_WIN)
#pragma warning(disable:4190)  // cefpython API extern C-linkage warnings
#endif

// Python.h must be included first otherwise error on Linux:
// >> error: "_POSIX_C_SOURCE" redefined
#include "Python.h"


// Includes required by "cefpython_fixed.h".
#include "include/cef_client.h"
#include "include/cef_urlrequest.h"
#include "include/cef_command_line.h"
#include "util.h"

// cefpython_fixed.h declares public functions using DL_IMPORT and these
// macros are not available in Python 3.
#ifndef DL_IMPORT
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT
#define DL_EXPORT(RTYPE) RTYPE
#endif

#if PY_MAJOR_VERSION == 2
#if PY_MINOR_VERSION == 7
#include "../../build/build_cefpython/cefpython_py27_fixed.h"
#endif // PY_MINOR_VERSION
#elif PY_MAJOR_VERSION == 3
#if PY_MINOR_VERSION == 4
#include "../../build/build_cefpython/cefpython_py34_fixed.h"
#elif PY_MINOR_VERSION == 5
#include "../../build/build_cefpython/cefpython_py35_fixed.h"
#elif PY_MINOR_VERSION == 6
#include "../../build/build_cefpython/cefpython_py36_fixed.h"
#elif PY_MINOR_VERSION == 7
#include "../../build/build_cefpython/cefpython_py37_fixed.h"
#elif PY_MINOR_VERSION == 8
#include "../../build/build_cefpython/cefpython_py38_fixed.h"
#elif PY_MINOR_VERSION == 9
#include "../../build/build_cefpython/cefpython_py39_fixed.h"
#endif // PY_MINOR_VERSION
#endif // PY_MAJOR_VERSION

#endif // CEFPYTHON_PUBLIC_API_H
