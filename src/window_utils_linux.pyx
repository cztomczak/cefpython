# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "cefpython.pyx"

IF UNAME_SYSNAME == "Linux":
    cimport x11

class WindowUtils:
    # You have to overwrite this class and provide implementations
    # for these methods.

    @staticmethod
    def OnSetFocus(long windowHandle, long msg, long wparam, long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @staticmethod
    def OnSize(long windowHandle, long msg, long wparam, long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @staticmethod
    def OnEraseBackground(long windowHandle, long msg, long wparam,
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
    def gtk_plug_new(long long gdkNativeWindow):
        return <long long>gtk_plug_new(<GdkNativeWindow>gdkNativeWindow)

    @staticmethod
    def gtk_widget_show(long long gtkWidgetPtr):
        with nogil:
            gtk_widget_show(<GtkWidget*>gtkWidgetPtr)

    @staticmethod
    def InstallX11ErrorHandlers():
        with nogil:
            x11.InstallX11ErrorHandlers()
