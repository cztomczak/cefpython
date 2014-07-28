# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class WindowUtils:

    # You have to overwrite this class and provide implementations
    # for these methods.

    @staticmethod
    def GetParentHandle(WindowHandle windowHandle):
        Debug("WindowUtils::GetParentHandle() not implemented!")
        return 0

    @staticmethod
    def IsWindowHandle(WindowHandle windowHandle):
        Debug("WindowUtils::IsWindowHandle() not implemented!")
        return True
