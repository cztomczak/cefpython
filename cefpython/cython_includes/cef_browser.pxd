# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_ptr cimport CefRefPtr
from cef_base cimport CefBase
from cef_string cimport CefString
from cef_client cimport CefClient
from libcpp cimport bool as cpp_bool
from libcpp.vector cimport vector as cpp_vector
from cef_frame cimport CefFrame
cimport cef_types
from cef_platform cimport CefKeyInfo
from cef_types cimport int64

from cef_process_message cimport CefProcessMessage, CefProcessId

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport CefWindowHandle, CefWindowInfo

cdef extern from "include/cef_browser.h":

    cdef cppclass CefBrowserHost(CefBase):

        void CloseBrowser(cpp_bool force_close)
        void ParentWindowWillClose()
        CefRefPtr[CefBrowser] GetBrowser()
        void SetFocus(cpp_bool enable)
        CefWindowHandle GetWindowHandle()
        CefWindowHandle GetOpenerWindowHandle()
        double GetZoomLevel()
        void SetZoomLevel(double zoomLevel)

        CefString GetDevToolsURL(cpp_bool http_scheme)

        void StartDownload(const CefString& url)
        void SetMouseCursorChangeDisabled(cpp_bool disabled)
        cpp_bool IsMouseCursorChangeDisabled()
        cpp_bool IsWindowRenderingDisabled()
        void WasResized()
        void WasHidden(cpp_bool hidden)
        void NotifyScreenInfoChanged()

        void SendKeyEvent(cef_types.CefKeyEvent)
        void SendMouseClickEvent(cef_types.CefMouseEvent,
                cef_types.cef_mouse_button_type_t type,
                cpp_bool mouseUp, int clickCount)
        void SendMouseMoveEvent(cef_types.CefMouseEvent, \
                cpp_bool mouseLeave)
        void SendMouseWheelEvent(cef_types.CefMouseEvent, int deltaX, \
                int deltaY)
        void SendFocusEvent(cpp_bool setFocus)
        void SendCaptureLostEvent()

        void Find(int identifier, const CefString& searchText, cpp_bool forward,
                cpp_bool matchCase, cpp_bool findNext)
        void StopFinding(cpp_bool clearSelection)
        void Print()

    cdef cppclass CefBrowser(CefBase):

        CefRefPtr[CefBrowserHost] GetHost()
        cpp_bool CanGoBack()
        cpp_bool CanGoForward()
        CefRefPtr[CefFrame] GetFocusedFrame()
        CefRefPtr[CefFrame] GetFrame(CefString& name)
        CefRefPtr[CefFrame] GetFrame(int64 identifier)
        void GetFrameNames(cpp_vector[CefString]& names)
        CefRefPtr[CefFrame] GetMainFrame()
        void GoBack()
        void GoForward()
        cpp_bool HasDocument()
        cpp_bool IsPopup()
        void Reload()
        void ReloadIgnoreCache()
        void StopLoad()
        cpp_bool IsLoading()
        int GetIdentifier()
        cpp_bool SendProcessMessage(CefProcessId target_process,
                                    CefRefPtr[CefProcessMessage] message)
