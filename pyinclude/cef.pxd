# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# All cimports here will be visible in cefpython.pyx (which cimports this file).

from libcpp cimport bool as cbool
from stddef cimport wchar_t
from windows cimport * # must import all otherwise errors in CefWindowInfo.setAsChild()
from cef_string cimport CefString, cef_string_t
from cef_type_wrappers cimport * # must import all otherwise errors in CreateBrowserSync()
from cef_task cimport *
from cef_win cimport *

# Everything that is using templates CefRefPtr[] must stay in this file, 
# otherwise strange errors appear, the same for other stuff that depends
# on stuff that use templates. For example: CefClient that inherits from
# CefBase that is defined here in cef.pxd because CefInitialize() is using
# template.

# -- cef_ptr

cdef extern from "include/internal/cef_ptr.h":
	cdef cppclass CefRefPtr[T]:
		T* get()

# -- cef_app

cdef extern from "include/cef_app.h":
	cdef cppclass CefApp:
		pass
	cdef int CefInitialize(CefSettings, CefRefPtr[CefApp])
	cdef void CefRunMessageLoop()
	cdef void CefQuitMessageLoop()
	cdef void CefShutdown()
	cdef cppclass CefBase:
		pass


# -- cef_browser

cdef extern from "include/cef_browser.h":
	cdef cppclass CefBrowser:
		void ParentWindowWillClose()
		void CloseBrowser()

# Namespace means that these are methods to cppclass CefBrowser.

cdef extern from "include/cef_browser.h" namespace "CefBrowser":
	cdef CefRefPtr[CefBrowser] CreateBrowserSync(CefWindowInfo, CefRefPtr[CefClient], CefString, CefBrowserSettings)


# -- cef_client

cdef extern from "include/cef_client.h":
	cdef cppclass CefClient(CefBase):
		pass

# -- cef_client2

cdef extern from "cef_client2.h":
	cdef cppclass CefClient2(CefClient):
		pass

# -- CefRefPtr templates

ctypedef CefRefPtr[CefClient] cefrefptr_cefclient_t
ctypedef CefRefPtr[CefClient2] cefrefptr_cefclient2_t
ctypedef CefRefPtr[CefApp] cefrefptr_cefapp_t
ctypedef CefRefPtr[CefBrowser] cefrefptr_cefbrowser_t
