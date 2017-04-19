// Copyright (c) 2017 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "include/base/cef_logging.h"

void cef_log_info(char* msg) {
    LOG(INFO) << msg;
}

void cef_log_warning(char* msg) {
    LOG(WARNING) << msg;
}

void cef_log_error(char* msg) {
    LOG(ERROR) << msg;
}
