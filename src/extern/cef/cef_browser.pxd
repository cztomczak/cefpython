# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from cef_ptr cimport CefRefPtr
from cef_string cimport CefString
from cef_client cimport CefClient
from libcpp cimport bool as cpp_bool
from libcpp.vector cimport vector as cpp_vector
from cef_frame cimport CefFrame
cimport cef_types
from cef_types cimport int64
from cef_types cimport CefPdfPrintSettings
from cef_types cimport CefBrowserSettings, CefPoint
from cef_drag_data cimport CefDragData
from cef_types cimport CefMouseEvent

from cef_process_message cimport CefProcessMessage, CefProcessId

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport CefWindowHandle, CefWindowInfo

cdef extern from "include/cef_browser.h":

    cdef cppclass CefPdfPrintCallback:

        void OnPdfPrintFinished(const CefString& path, cpp_bool ok)

    cdef cppclass CefBrowserHost:

        void CloseBrowser(cpp_bool force_close)
        CefRefPtr[CefBrowser] GetBrowser()
        void SetFocus(cpp_bool enable)
        CefWindowHandle GetWindowHandle()
        CefWindowHandle GetOpenerWindowHandle()
        double GetZoomLevel()
        void SetZoomLevel(double zoomLevel)
        void StartDownload(const CefString& url)
        void SetMouseCursorChangeDisabled(cpp_bool disabled)
        cpp_bool IsMouseCursorChangeDisabled()
        cpp_bool IsWindowRenderingDisabled()
        void WasResized()
        void WasHidden(cpp_bool hidden)
        void NotifyScreenInfoChanged()
        void NotifyMoveOrResizeStarted()

        void SendKeyEvent(cef_types.CefKeyEvent)
        void SendMouseClickEvent(cef_types.CefMouseEvent,
                cef_types.cef_mouse_button_type_t mbtype,
                cpp_bool mouseUp, int clickCount)
        void SendMouseMoveEvent(cef_types.CefMouseEvent,
                cpp_bool mouseLeave)
        void SendMouseWheelEvent(cef_types.CefMouseEvent, int deltaX,
                int deltaY)
        void SendFocusEvent(cpp_bool setFocus)
        void SendCaptureLostEvent()

        void ShowDevTools(const CefWindowInfo& windowInfo,
                          CefRefPtr[CefClient] client,
                          const CefBrowserSettings& settings,
                          const CefPoint& inspect_element_at)
        void CloseDevTools()

        void Find(int identifier, const CefString& searchText, cpp_bool forward,
                cpp_bool matchCase, cpp_bool findNext)
        void StopFinding(cpp_bool clearSelection)
        void Print()
        void PrintToPDF(const CefString& path,
                        const CefPdfPrintSettings& settings,
                        CefRefPtr[CefPdfPrintCallback] callback)
        cpp_bool TryCloseBrowser()

        # Drag & drop OSR
        void DragTargetDragEnter(CefRefPtr[CefDragData] drag_data,
                                 const CefMouseEvent& event,
                                 cef_types.cef_drag_operations_mask_t allowed_ops)
        void DragTargetDragOver(const CefMouseEvent& event,
                                cef_types.cef_drag_operations_mask_t allowed_ops)
        void DragTargetDragLeave()
        void DragTargetDrop(const CefMouseEvent& event)
        void DragSourceEndedAt(int x, int y, cef_types.cef_drag_operations_mask_t op)
        void DragSourceSystemDragEnded()

        # Spell checking
        void ReplaceMisspelling(const CefString& word)
        void AddWordToDictionary(const CefString& word)


    cdef cppclass CefBrowser:

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
