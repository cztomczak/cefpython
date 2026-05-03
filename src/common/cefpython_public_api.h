// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

/* Wrapper around the Cython-generated public API header.
   Functions marked 'public' in cefpython.pyx are exposed to C++ through it. */

#ifndef CEFPYTHON_PUBLIC_API_H
#define CEFPYTHON_PUBLIC_API_H

#if defined(OS_WIN)
#pragma warning(disable:4190)  // cefpython API extern C-linkage warnings
#endif

// Python.h must be included first (avoids _POSIX_C_SOURCE redefinition on Linux)
#include "Python.h"

// Includes required by the generated cefpython_*_fixed.h
#include "include/cef_client.h"
#include "include/cef_urlrequest.h"
#include "include/cef_command_line.h"
#include "util.h"

// cefpython_fixed.h uses DL_IMPORT/DL_EXPORT which were removed in Python 3.
#ifndef DL_IMPORT
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT
#define DL_EXPORT(RTYPE) RTYPE
#endif

// CMake sets CEFPYTHON_API_H_FILE to "cefpython_api_fixed.h", a generated
// stable-name wrapper in the pyx_stage/ build directory resolved via the
// target's include path.
#include CEFPYTHON_API_H_FILE

#endif // CEFPYTHON_PUBLIC_API_H
