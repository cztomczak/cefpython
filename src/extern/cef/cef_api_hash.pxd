# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# CEF's compiled API version and its hash, read by GetVersion().
cdef extern from "include/cef_api_hash.h":
    int CEF_API_VERSION
    const char* CEF_API_HASH_PLATFORM
