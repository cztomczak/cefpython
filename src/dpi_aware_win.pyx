# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class DpiAware:

    @staticmethod
    def GetSystemDpi():
        # Win7 DPI (Control Panel > Appearance and Personalization > Display):
        # text size Larger 150% => dpix/dpiy 144
        # text size Medium 125% => dpix/dpiy 120
        # text size Smaller 100% => dpix/dpiy 96
        #
        # dpix=96 zoomlevel=0.0
        # dpix=120 zoomlevel=1.0
        # dpix=144 zoomlevel=2.0
        # dpix=72 zoomlevel=-1.0
        #
        # If DPI awareness wasn't yet enabled, then GetSystemDpi
        # will always return a default 96 DPI.
        cdef int dpix = 0
        cdef int dpiy = 0
        GetSystemDpi(&dpix, &dpiy)
        return tuple(dpix, dpiy)

    @staticmethod
    def CalculateWindowSize(int width, int height):
        # Calculation for DPI < 96 is not yet supported.
        GetDpiAwareWindowSize(&width, &height)
        return tuple(width, height)

    @staticmethod
    def IsProcessDpiAware():
        return IsProcessDpiAware()

    @staticmethod
    def SetProcessDpiAware():
        """Deprecated."""
        DpiAware.EnableHighDpiSupport()

    @staticmethod
    def EnableHighDpiSupport():
        # This CEF function sets process to be DPI aware. This
        # CEF func is also called in subprocesses.
        CefEnableHighDPISupport()
