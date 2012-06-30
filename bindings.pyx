# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool

cdef extern from *:
	ctypedef char* const_char_ptr "const char*"

cdef extern from "stddef.h":
	ctypedef void wchar_t

cdef extern from "include/internal/cef_ptr.h":
	cdef cppclass CefRefPtr[T]:
		T* get()

cdef extern from "include/internal/cef_string.h":
	ctypedef struct cef_string_t:
		pass
	cdef cppclass CefString:
		CefString()
		CefString(cef_string_t*)
		bool FromASCII(char*)
		bool FromString(wchar_t*, size_t, bool)
		wchar_t* ToWString()
		char* c_str()

cdef extern from "include/internal/cef_types_wrappers.h":
	
	ctypedef struct CefSettings:
		bool multi_threaded_message_loop
		cef_string_t cache_path
		cef_string_t user_agent
		cef_string_t product_version
		cef_string_t locale
		cef_string_t log_file
		int log_severity
		int graphics_implementation
		unsigned int local_storage_quota
		unsigned int session_storage_quota
		cef_string_t javascript_flags
		cef_string_t pack_file_path
		cef_string_t locales_dir_path

	ctypedef struct CefBrowserSettings:
		bool drag_drop_disabled
		bool load_drops_disabled
		bool history_disabled
		cef_string_t standard_font_family
		cef_string_t fixed_font_family
		cef_string_t serif_font_family
		cef_string_t sans_serif_font_family
		cef_string_t cursive_font_family
		cef_string_t fantasy_font_family
		int default_font_size
		int default_fixed_font_size
		int minimum_font_size
		int minimum_logical_font_size
		bool remote_fonts_disabled
		cef_string_t default_encoding
		bool encoding_detector_enabled
		bool javascript_disabled
		bool javascript_open_windows_disallowed
		bool javascript_close_windows_disallowed
		bool javascript_access_clipboard_disallowed
		bool dom_paste_disabled
		bool caret_browsing_enabled
		bool java_disabled
		bool plugins_disabled
		bool universal_access_from_file_urls_allowed
		bool file_access_from_file_urls_allowed
		bool web_security_disabled
		bool xss_auditor_enabled
		bool image_load_disabled
		bool shrink_standalone_images_to_fit
		bool site_specific_quirks_disabled
		bool text_area_resize_disabled
		bool page_cache_disabled
		bool tab_to_links_disabled
		bool hyperlink_auditing_disabled
		bool user_style_sheet_enabled
		cef_string_t user_style_sheet_location
		bool author_and_user_styles_disabled
		bool local_storage_disabled
		bool databases_disabled
		bool application_cache_disabled
		bool webgl_disabled
		bool accelerated_compositing_enabled
		bool threaded_compositing_enabled
		bool accelerated_layers_disabled
		bool accelerated_video_disabled
		bool accelerated_2d_canvas_disabled
		bool accelerated_painting_disabled
		bool accelerated_filters_disabled
		bool accelerated_plugins_disabled
		bool developer_tools_disabled
		bool fullscreen_enabled


cdef extern from "include/cef.h":
	cdef cppclass CefApp:
		pass
	cdef int CefInitialize(CefSettings, CefRefPtr[CefApp])
	cdef void CefRunMessageLoop()
	cdef void CefShutdown()
	cdef cppclass CefBase:
		pass
	cdef cppclass CefClient(CefBase):
		pass
	ctypedef int CefThreadId
	cdef bool CefCurrentlyOn(CefThreadId)
	cdef cppclass CefBrowser:
		void ParentWindowWillClose()
		void CloseBrowser()

cdef extern from "cefclient2.h":
	cdef cppclass CefClient2(CefClient):
		pass

ctypedef CefRefPtr[CefClient] cefrefptr_cefclient_t
ctypedef CefRefPtr[CefClient2] cefrefptr_cefclient2_t
ctypedef CefRefPtr[CefApp] cefrefptr_cefapp_t
ctypedef CefRefPtr[CefBrowser] cefrefptr_cefbrowser_t

cdef extern from "include/cef.h" namespace "CefBrowser":
	cdef bool CreateBrowser(CefWindowInfo, CefRefPtr[CefClient], CefString, CefBrowserSettings)
	cdef CefRefPtr[CefBrowser] CreateBrowserSync(CefWindowInfo, CefRefPtr[CefClient], CefString, CefBrowserSettings)

cdef extern from "windows.h":
	ctypedef void *HWND
	ctypedef struct RECT:
		long left
		long top
		long right
		long bottom
	ctypedef char* LPCTSTR
	cdef HWND FindWindowA(LPCTSTR, LPCTSTR)
	cdef int CP_UTF8
	cdef int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)

cdef extern from "include/internal/cef_win.h":
	ctypedef void* CefWindowHandle
	cdef cppclass CefWindowInfo:
		void SetAsChild(HWND, RECT)
		void SetAsOffScreen(HWND)
		HWND m_hWndParent
		HWND m_hWnd
		int m_x
		int m_y
		int m_nWidth
		int m_nHeight

