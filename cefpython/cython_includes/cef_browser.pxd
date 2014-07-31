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

IF CEF_VERSION == 1:
    from cef_types_wrappers cimport CefRect

IF CEF_VERSION == 3:
    from cef_process_message cimport CefProcessMessage, CefProcessId

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefWindowHandle, CefWindowInfo

cdef extern from "include/cef_browser.h":

    IF CEF_VERSION == 1:

        cdef cppclass CefBrowser(CefBase):

            cpp_bool CanGoBack()
            cpp_bool CanGoForward()
            void ClearHistory()
            void CloseBrowser()
            void CloseDevTools()
            void Find(int identifier, CefString& searchText, cpp_bool forward,
                    cpp_bool matchCase, cpp_bool findNext)
            CefRefPtr[CefFrame] GetFocusedFrame()
            CefRefPtr[CefFrame] GetFrame(CefString& name)
            void GetFrameNames(cpp_vector[CefString]& names)
            CefRefPtr[CefFrame] GetMainFrame()
            CefWindowHandle GetOpenerWindowHandle()
            CefWindowHandle GetWindowHandle()
            double GetZoomLevel()
            void GoBack()
            void GoForward()
            cpp_bool HasDocument()
            void HidePopup()
            cpp_bool IsPopup()
            void ParentWindowWillClose()
            void Reload()
            void ReloadIgnoreCache()
            void SetFocus(cpp_bool enable)
            void SetZoomLevel(double zoomLevel)
            void ShowDevTools()
            void StopLoad()
            void StopFinding(cpp_bool clearSelection)
            cpp_bool IsWindowRenderingDisabled()
            cpp_bool IsPopupVisible()
            int GetIdentifier()

            # Off-screen rendering.

            cpp_bool GetSize(cef_types.cef_paint_element_type_t type,
                           int& width, int& height)
            void SetSize(cef_types.cef_paint_element_type_t type,
                         int width, int height)
            void Invalidate(CefRect& dirtyRect)
            cpp_bool GetImage(cef_types.cef_paint_element_type_t type,
                          int width, int height, void* buffer)

            # Sending mouse/key events.
            void SendKeyEvent(cef_types.cef_key_type_t type,
                    CefKeyInfo& keyInfo, int modifiers)
            void SendMouseClickEvent(int x, int y,
                    cef_types.cef_mouse_button_type_t type,
                    cpp_bool mouseUp, int clickCount)
            void SendMouseMoveEvent(int x, int y, cpp_bool mouseLeave)
            void SendMouseWheelEvent(int x, int y, int deltaX, int deltaY)
            void SendFocusEvent(cpp_bool setFocus)
            void SendCaptureLostEvent()

            # virtual CefRefPtr<CefClient> GetClient() =0;

    ELIF CEF_VERSION == 3:

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
            # virtual void RunFileDialog(FileDialogMode mode,
            #                 const CefString& title,
            #                 const CefString& default_file_name,
            #                 const std::vector<CefString>& accept_types,
            #                 CefRefPtr<CefRunFileDialogCallback> callback) =0;
            # typedef cef_file_dialog_mode_t FileDialogMode;

            void StartDownload(const CefString& url)
            void SetMouseCursorChangeDisabled(cpp_bool disabled)
            cpp_bool IsMouseCursorChangeDisabled()
            cpp_bool IsWindowRenderingDisabled()
            void WasResized()
            void WasHidden(cpp_bool hidden)
            void NotifyScreenInfoChanged()

            # Sending mouse/key events.
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

            # CefRefPtr<CefFrame> GetFrame(int64 identifier) =0;
            # virtual CefRefPtr<CefClient> GetClient() =0;
            cpp_bool SendProcessMessage(CefProcessId target_process,
                                        CefRefPtr[CefProcessMessage] message)

        # class CefRunFileDialogCallback : public virtual CefBase {
        #    virtual void OnFileDialogDismissed(
        #    CefRefPtr<CefBrowserHost> browser_host,
        #    const std::vector<CefString>& file_paths) =0;
