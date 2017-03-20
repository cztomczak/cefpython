# Copyright (c) 2015 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class WindowUtils:
    # You have to overwrite this class and provide implementations
    # for these methods.

    @staticmethod
    def OnSetFocus(WindowHandle windowHandle, long msg, long wparam,
                   long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @staticmethod
    def OnSize(WindowHandle windowHandle, long msg, long wparam, long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @staticmethod
    def OnEraseBackground(WindowHandle windowHandle, long msg, long wparam,
                          long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @staticmethod
    def GetParentHandle(WindowHandle windowHandle):
        Debug("WindowUtils::GetParentHandle() not implemented (returns 0)")
        return 0

    @staticmethod
    def IsWindowHandle(WindowHandle windowHandle):
        Debug("WindowUtils::IsWindowHandle() not implemented (always True)")
        return True

    @staticmethod
    def InstallX11ErrorHandlers():
        pass
