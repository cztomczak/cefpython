# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class WindowUtils:
    # You have to overwrite this class and provide implementations
    # for these methods.

    @classmethod
    def OnSetFocus(cls, WindowHandle windowHandle, long msg, long wparam,
                   long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def OnSize(cls, WindowHandle windowHandle, long msg, long wparam,
               long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def OnEraseBackground(cls, WindowHandle windowHandle, long msg,
                          long wparam, long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def GetParentHandle(cls, WindowHandle windowHandle):
        Debug("WindowUtils::GetParentHandle() not implemented (returns 0)")
        return 0

    @classmethod
    def IsWindowHandle(cls, WindowHandle windowHandle):
        Debug("WindowUtils::IsWindowHandle() not implemented (always True)")
        return True

    @classmethod
    def gtk_plug_new(cls, WindowHandle gdkNativeWindow):
        return <WindowHandle>gtk_plug_new(<GdkNativeWindow>gdkNativeWindow)

    @classmethod
    def gtk_widget_show(cls, WindowHandle gtkWidgetPtr):
        with nogil:
            gtk_widget_show(<GtkWidget*>gtkWidgetPtr)

    @classmethod
    def InstallX11ErrorHandlers(cls):
        with nogil:
            x11.InstallX11ErrorHandlers()
