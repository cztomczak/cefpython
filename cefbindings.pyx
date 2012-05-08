from libcpp cimport bool

cdef extern from *:
	ctypedef char* const_char_ptr "const char*"

cdef extern from "stddef.h":
	ctypedef void wchar_t

cdef extern from "include/internal/cef_ptr.h":
	cdef cppclass CefRefPtr[T]:
		T* get()

cdef extern from "include/internal/cef_types_wrappers.h":
	ctypedef struct CefSettings:
		pass
	ctypedef struct CefBrowserSettings:
		pass

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

cdef extern from "include/internal/cef_string.h":
	cdef cppclass CefString:
		CefString()
		bool FromASCII(char*)
		bool FromString(wchar_t*, size_t, bool)
		wchar_t* ToWString()
		char* c_str()
