# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser
from cef_string_visitor cimport CefStringVisitor
from cef_process_message cimport CefProcessMessage, CefProcessId

cdef extern from "include/cef_frame.h":

  cdef cppclass CefFrame:
      cpp_bool IsValid()
      void ExecuteJavaScript(CefString& jsCode, CefString& scriptUrl, int startLine)
      CefString GetURL()
      CefString GetIdentifier()
      cpp_bool IsMain()
      void LoadURL(CefString& url)
      void Undo()
      void Redo()
      void Cut()
      void Copy()
      void Paste()
      void Delete()
      void SelectAll()
      void ViewSource()
      void GetSource(CefRefPtr[CefStringVisitor] visitor)
      void GetText(CefRefPtr[CefStringVisitor] visitor)
      void LoadString(CefString& string_val, CefString& url)
      cpp_bool IsFocused()
      CefString GetName()
      CefRefPtr[CefFrame] GetParent()
      CefRefPtr[CefBrowser] GetBrowser()
      cpp_bool SendProcessMessage(CefProcessId target_process,
                                  CefRefPtr[CefProcessMessage] message)
