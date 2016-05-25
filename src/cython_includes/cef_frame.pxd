# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_base cimport CefBase
from cef_types cimport int64
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Context
from cef_browser cimport CefBrowser
from cef_string_visitor cimport CefStringVisitor

cdef extern from "include/cef_frame.h":

  cdef cppclass CefFrame(CefBase):
      cpp_bool IsValid()
      void ExecuteJavaScript(CefString& jsCode, CefString& scriptUrl, int startLine)
      CefString GetURL()
      int64 GetIdentifier()
      CefRefPtr[CefV8Context] GetV8Context()
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
