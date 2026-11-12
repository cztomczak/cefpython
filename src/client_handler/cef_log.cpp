// Copyright (c) 2017 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "include/base/cef_logging.h"
#include "client_handler/cef_log.h"

void cef_log_info(const char* tag, const char* msg) {
    if (LOG_IS_ON(INFO)) {
        ::cef::logging::LogMessage(tag, 0, ::cef::logging::LOG_INFO).stream() << msg;
    }
}

void cef_log_warning(const char* tag, const char* msg) {
    if (LOG_IS_ON(WARNING)) {
        ::cef::logging::LogMessage(tag, 0, ::cef::logging::LOG_WARNING).stream() << msg;
    }
}

void cef_log_error(const char* tag, const char* msg) {
    if (LOG_IS_ON(ERROR)) {
        ::cef::logging::LogMessage(tag, 0, ::cef::logging::LOG_ERROR).stream() << msg;
    }
}
