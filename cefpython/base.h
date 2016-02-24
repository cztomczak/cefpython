// Copyright (c) 2016 The CEF Python authors. All rights reserved.

#pragma once

#define STR_(x) #x
#define STR(x) STR_(x)

#if defined(_WIN32)
    #define OS_WIN 1
    #define OS_LINUX 0
    #define OS_MAC 0
    #define OS_POSTFIX "win"
#elif defined(__linux__)
    #define OS_WIN 0
    #define OS_LINUX 1
    #define OS_MAC 0
    #define OS_POSTFIX "linux"
#elif defined(__APPLE__)
    #define OS_WIN 0
    #define OS_LINUX 0
    #define OS_MAC 1
    #define OS_POSTFIX "mac"
#endif
