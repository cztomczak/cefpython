# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

IF CEF_VERSION == 1:
    from cef_types_cef1 cimport *
ELIF CEF_VERSION == 3:
    from cef_types_cef3 cimport *
