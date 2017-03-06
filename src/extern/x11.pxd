# Copyright (c) 2016 The CEF Python authors. All rights reserved.

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_browser cimport CefBrowser

cdef extern from "client_handler/x11.h" nogil:
    void InstallX11ErrorHandlers()
    void SetX11WindowBounds(CefRefPtr[CefBrowser] browser,
                            int x, int y, int width, int height)
