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

// CMake builds define CEFPYTHON_API_H_FILE to "cefpython_api_fixed.h", a
// generated stable-name wrapper in the pyx_stage/ build directory that is
// resolved via the target's include path.
// Legacy build.py builds fall back to the hardcoded version-specific paths.
#ifdef CEFPYTHON_API_H_FILE
#include CEFPYTHON_API_H_FILE
#else
#if PY_MAJOR_VERSION == 3
#if PY_MINOR_VERSION == 10
#include "../../build/build_cefpython/cefpython_py310_fixed.h"
#elif PY_MINOR_VERSION == 11
#include "../../build/build_cefpython/cefpython_py311_fixed.h"
#elif PY_MINOR_VERSION == 12
#include "../../build/build_cefpython/cefpython_py312_fixed.h"
#elif PY_MINOR_VERSION == 13
#include "../../build/build_cefpython/cefpython_py313_fixed.h"
#elif PY_MINOR_VERSION == 14
#include "../../build/build_cefpython/cefpython_py314_fixed.h"
#endif // PY_MINOR_VERSION
#endif // PY_MAJOR_VERSION
#endif // CEFPYTHON_API_H_FILE

#endif // CEFPYTHON_PUBLIC_API_H
