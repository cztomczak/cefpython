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
    def gtk_plug_new(WindowHandle gdkNativeWindow):
        return <WindowHandle>gtk_plug_new(<GdkNativeWindow>gdkNativeWindow)

    @staticmethod
    def gtk_widget_show(WindowHandle gtkWidgetPtr):
        with nogil:
            gtk_widget_show(<GtkWidget*>gtkWidgetPtr)

    @staticmethod
    def InstallX11ErrorHandlers():
        with nogil:
            x11.InstallX11ErrorHandlers()
