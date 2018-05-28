# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_browser cimport CefBrowser
from linux cimport XImage

cdef extern from "client_handler/x11.h" nogil:
    void InstallX11ErrorHandlers()
    void SetX11WindowBounds(CefRefPtr[CefBrowser] browser,
                            int x, int y, int width, int height)
    void SetX11WindowTitle(CefRefPtr[CefBrowser] browser, char* title)
    XImage* CefBrowser_GetImage(CefRefPtr[CefBrowser] browser)
