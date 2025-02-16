# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class DpiAware:

    @classmethod
    def GetSystemDpi(cls):
        """Returns Windows DPI settings ("Custom scaling" on Win10).

        Win7 DPI (Control Panel > Appearance and Personalization > Display):
        text size Larger 150% => dpix/dpiy 144
        text size Medium 125% => dpix/dpiy 120
        text size Smaller 100% => dpix/dpiy 96

        DPI settings should not be cached. When SetProcessDpiAware
        is not yet called, then OS returns 96 DPI, even though it
        is set to 144 DPI. After DPI Awareness is enabled for the
        running process it will return the correct 144 DPI.
        """
        cdef int dpix = 0
        cdef int dpiy = 0
        GetSystemDpi(&dpix, &dpiy)
        return dpix, dpiy

    @classmethod
    def CalculateWindowSize(cls, int width, int height):
        """@DEPRECATED. Use Scale() method instead."""
        # Calculation for DPI < 96 is not yet supported.
        GetDpiAwareWindowSize(&width, &height)
        return width, height

    @classmethod
    def Scale(cls, arg):
        """Scale units for high DPI devices. Argument can be an int,
        tuple or list."""
        (dpix, dpiy) = DpiAware.GetSystemDpi()
        # - Using only "dpix" value to calculate zoom level since all
        #   modern displays have equal horizontal and vertical resolution.
        default_dpix = 96
        scale = MulDiv(dpix, 100, default_dpix)
        if isinstance(arg, (int, long)):
            v = arg
            new_value = MulDiv(v, scale, 100)
            return new_value
        ret_tuple = isinstance(arg, tuple)
        ret = list()
        for i,v in enumerate(arg):
            v = int(v)
            ret.append(MulDiv(v, scale, 100))
        if ret_tuple:
            return tuple(ret)
        return ret

    @classmethod
    def IsProcessDpiAware(cls):
        return IsProcessDpiAware()

    @classmethod
    def SetProcessDpiAware(cls):
        """Deprecated."""
        DpiAware.EnableHighDpiSupport()

