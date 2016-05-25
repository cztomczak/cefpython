# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class WindowUtils:
    # You have to overwrite this class and provide implementations
    # for these methods.

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
        gtk_widget_show(<GtkWidget*>gtkWidgetPtr)
