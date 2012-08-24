# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# IMPORTANT notes:
#
# - cdef functions that are called from c++ need to embrace whole function's
#   code inside try..except, otherwise exceptions are ignored.
#
# - additionally all cdef functions that are returning types other than "object"
#   (a python object) should have in its declaration "except *", otherwise
#   exceptions may be ignored. Those cdef that return "object" have "except *"
#   by default.
#
# - you should try running Cython code after all even small changes, otherwise
#   you will get into big trouble, error messages are so much obfuscated and info
#   is missing that you will have no idea which chunk of code caused that error.

# All .pyx files need to be included here for Cython compiler.
include "imports.pyx"
include "browser.pyx"
include "frame.pyx"
include "javascriptbindings.pyx"
include "settings.pyx"
include "utils.pyx"
include "wndproc.pyx"

include "loadhandler.pyx"
include "keyboardhandler.pyx"
include "virtualkeys.pyx"
include "v8contexthandler.pyx"
include "functionhandler.pyx"

include "v8utils.pyx"
include "javascriptcallback.pyx"
include "pythoncallback.pyx"
include "requesthandler.pyx"

# Global variables.
__debug = False

# Client handler.
cdef CefRefPtr[ClientHandler] __clientHandler = <CefRefPtr[ClientHandler]>new ClientHandler()

def FixUIThreadResponsiveness(windowID):
	
	# OnBeforeResourceLoad is called on IO thread, when we acquire gil lock and execute
	# python code then the UI thread is not executing unless you do some UI action (minimize/restore window).
	cdef HWND hwnd = <HWND><int>windowID
	SetTimer(hwnd, 1, 10, <TIMERPROC>NULL)

def GetRealPath(file=None):
	
	# This function is defined in 2 files: cefpython.pyx and cefwindow.py, if you make changes edit both files.
	# If file is None return current directory, without trailing slash.
	if file is None: file = ""
	if file.find("/") != 0 and file.find("\\") != 0 and not re.search(r"^[a-zA-Z]+:[/\\]", file):
		# not re.search(r"^[a-zA-Z]+:[/\\]", file)
		# == not (D:\\ or D:/ or http:// or ftp:// or file://)
		if hasattr(sys, "frozen"): path = os.path.dirname(sys.executable)
		elif "__file__" in globals(): path = os.path.dirname(os.path.realpath(__file__))
		else: path = os.getcwd()
		path = path + os.sep + file
		path = re.sub(r"[/\\]+", re.escape(os.sep), path)
		path = re.sub(r"[/\\]+$", "", path)
		return path
	return file

def ExceptHook(type, value, traceobject):

	error = "\n".join(traceback.format_exception(type, value, traceobject))
	with open(GetRealPath("error.log"), "a") as file:
		file.write("\n[%s] %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), error))
	print("\n"+error+"\n")
	CefQuitMessageLoop()
	CefShutdown()
	os._exit(1) # so that "finally" does not execute

def __InitializeClientHandler():

	InitializeLoadHandler()
	InitializeKeyboardHandler()
	InitializeV8ContextHandler()
	InitializeRequestHandler()

def Initialize(applicationSettings={}):

	if not "multi_threaded_message_loop" in applicationSettings:
		applicationSettings["multi_threaded_message_loop"] = False

	__InitializeClientHandler()

	if __debug:
		print("\n%s" % ("--------" * 8))
		print("Welcome to CEF Python bindings!")
		print("%s\n" % ("--------" * 8))

	cdef CefSettings cefApplicationSettings
	cdef CefRefPtr[CefApp] cefApp
	cdef CefString *cefString

	SetApplicationSettings(applicationSettings, &cefApplicationSettings)

	if __debug:
		print("CefInitialize(cefApplicationSettings, cefApp)")

	cdef cbool ret = CefInitialize(cefApplicationSettings, cefApp)

	if __debug:
		if ret: print("OK")
		else: print("ERROR")
		print("GetLastError(): %s" % GetLastError())


def CreateBrowser(windowID, browserSettings, navigateURL, clientHandlers=None, javascriptBindings=None):

	if not clientHandlers:
		clientHandlers = {}

	if __debug: print("cefpython.CreateBrowser()")

	# Later in the code we do a dangerous cast: <HWND><int>windowID,
	# so let's make sure that this is a valid window.
	if not win32gui.IsWindow(windowID):
		raise Exception("CreateBrowser() failed: invalid windowID")

	cdef CefWindowInfo info
	cdef CefBrowserSettings cefBrowserSettings
	cdef CefString *cefString

	SetBrowserSettings(browserSettings, &cefBrowserSettings)	

	if __debug: print("win32gui.GetClientRect(windowID)")
	rect1 = win32gui.GetClientRect(windowID)
	if __debug: print("GetLastError(): %s" % GetLastError())

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	if __debug: print("CefWindowInfo.SetAsChild(<HWND><int>windowID, rect2)")
	info.SetAsChild(<HWND><int>windowID, rect2)	
	if __debug: print("GetLastError(): %s" % GetLastError())

	navigateURL = GetRealPath(navigateURL)
	if __debug: print("navigateURL: %s" % navigateURL)
	if __debug: print("Creating cefNavigateURL: CefString().FromASCII(<char*>navigateURL)")
	
	cdef CefString cefNavigateURL
	PyStringToCefString(navigateURL, cefNavigateURL)

	if __debug: print("CreateBrowserSync()")

	cdef CefRefPtr[CefBrowser] cefBrowser = CreateBrowserSync(info, <CefRefPtr[CefClient]?>__clientHandler, cefNavigateURL, cefBrowserSettings)

	if <void*>cefBrowser == NULL: 
		if __debug: print("CreateBrowserSync(): NULL")
		if __debug: print("GetLastError(): %s" % GetLastError())
		return None
	else: 
		if __debug: print("CreateBrowserSync(): OK")

	cdef int innerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	__cefBrowsers[innerWindowID] = cefBrowser
	__pyBrowsers[innerWindowID] = PyBrowser(windowID, innerWindowID, clientHandlers, javascriptBindings)
	if javascriptBindings:
		javascriptBindings.SetBrowserCreated(True)
	__browserInnerWindows[windowID] = innerWindowID

	return __pyBrowsers[innerWindowID]


def GetBrowserByWindowID(windowID):

	# This is: ByTopWindowID.
	if windowID in __browserInnerWindows:
		innerWindowID = __browserInnerWindows[windowID]
		if innerWindowID in __pyBrowsers:
			return __pyBrowsers[innerWindowID]
		else:
			return None
	else:
		return None


def MessageLoop():

	if __debug: print("CefRunMessageLoop()\n")
	CefRunMessageLoop()

def SingleMessageLoop():

	# Perform a single iteration of CEF message loop processing. This function is
	# used to integrate the CEF message loop into an existing application message
	# loop. 

	if __debug: print("CefDoMessageLoopWork()\n")
	CefDoMessageLoopWork();

def QuitMessageLoop():

	if __debug: print("QuitMessageLoop()")
	CefQuitMessageLoop()


def Shutdown():

	if __debug: print("CefShutdown()")
	CefShutdown()
	if __debug: print("GetLastError(): %s" % GetLastError())

