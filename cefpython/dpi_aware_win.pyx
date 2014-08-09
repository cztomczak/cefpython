# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class DpiAware:

    @staticmethod
    def SetProcessDpiAware():
        SetProcessDpiAware()

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
        return (dpix, dpiy)

    @staticmethod
    def CalculateWindowSize(int width, int height):
        # Calculation for DPI < 96 is not yet supported.
        GetDpiAwareWindowSize(&width, &height)
        return (width, height)
