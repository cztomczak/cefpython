// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once
#include <stdio.h>

extern bool g_debug;
extern std::string g_logFile;

// Defined as "inline" to get rid of the "already defined" errors
// when linking.
inline void DebugLog(const char* szString)
{
    if (!g_debug)
        return;
    // TODO: get the log_file option from CefSettings.
    printf("[CEF Python] %s\n", szString);
    if (g_logFile.length()) {
        FILE* pFile = fopen(g_logFile.c_str(), "a");
        fprintf(pFile, "[CEF Python] App: %s\n", szString);
        fclose(pFile);
    }
}
