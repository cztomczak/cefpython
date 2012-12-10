# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_ptr cimport CefRefPtr
from cef_base cimport CefBase
from cef_string cimport CefString
from cef_client cimport CefClient
from libcpp cimport bool as c_bool
from libcpp.vector cimport vector as c_vector
from cef_frame cimport CefFrame

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefWindowInfo

cdef extern from "include/cef_browser.h":

    IF CEF_VERSION == 1:

        cdef cppclass CefBrowser(CefBase):

            c_bool CanGoBack()
            c_bool CanGoForward()
            void ClearHistory()
            void CloseBrowser()
            void CloseDevTools()
            void Find(int identifier, CefString& searchText, c_bool forward,
                    c_bool matchCase, c_bool findNext)
            CefRefPtr[CefFrame] GetFocusedFrame()
            CefRefPtr[CefFrame] GetFrame(CefString& name)
            void GetFrameNames(c_vector[CefString]& names)
            CefRefPtr[CefFrame] GetMainFrame()
            CefWindowHandle GetOpenerWindowHandle()
            CefWindowHandle GetWindowHandle()
            double GetZoomLevel()
            void GoBack()
            void GoForward()
            c_bool HasDocument()
            void HidePopup()
            c_bool IsPopup()
            void ParentWindowWillClose()
            void Reload()
            void ReloadIgnoreCache()
            void SetFocus(c_bool enable)
            void SetZoomLevel(double zoomLevel)
            void ShowDevTools()
            void StopLoad()
            void StopFinding(c_bool clearSelection)
            c_bool IsWindowRenderingDisabled()
            c_bool IsPopupVisible()
            int GetIdentifier()

            # virtual CefRefPtr<CefClient> GetClient() =0;

    ELIF CEF_VERSION == 3:

        cdef cppclass CefBrowserHost(CefBase):

            void CloseBrowser()
            void ParentWindowWillClose()
            CefRefPtr[CefBrowser] GetBrowser()
            void SetFocus(c_bool enable)
            CefWindowHandle GetWindowHandle()
            CefWindowHandle GetOpenerWindowHandle()
            double GetZoomLevel()
            void SetZoomLevel(double zoomLevel)

            # virtual CefString GetDevToolsURL(bool http_scheme) =0;
            # virtual void RunFileDialog(FileDialogMode mode,
            #                 const CefString& title,
            #                 const CefString& default_file_name,
            #                 const std::vector<CefString>& accept_types,
            #                 CefRefPtr<CefRunFileDialogCallback> callback) =0;
            # typedef cef_file_dialog_mode_t FileDialogMode;

        cdef cppclass CefBrowser(CefBase):

            CefRefPtr[CefBrowserHost] GetHost()
            c_bool CanGoBack()
            c_bool CanGoForward()
            CefRefPtr[CefFrame] GetFocusedFrame()
            CefRefPtr[CefFrame] GetFrame(CefString& name)
            void GetFrameNames(c_vector[CefString]& names)
            CefRefPtr[CefFrame] GetMainFrame()
            void GoBack()
            void GoForward()
            c_bool HasDocument()
            c_bool IsPopup()
            void Reload()
            void ReloadIgnoreCache()
            void StopLoad()
            c_bool IsLoading()
            int GetIdentifier()

            # CefRefPtr<CefFrame> GetFrame(int64 identifier) =0;
            # virtual CefRefPtr<CefClient> GetClient() =0;
            # virtual bool SendProcessMessage(CefProcessId target_process,
            #                           CefRefPtr<CefProcessMessage> message) =0;

        # class CefRunFileDialogCallback : public virtual CefBase {
        #    virtual void OnFileDialogDismissed(
        #    CefRefPtr<CefBrowserHost> browser_host,
        #    const std::vector<CefString>& file_paths) =0;
