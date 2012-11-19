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
# - you should try running Cython code after even small changes, otherwise
#   you might get into big trouble, error messages are often obfuscated and info
#   is missing, so you will have no idea which chunk of code caused that error.
#
# - about acquiring/releasing GIL lock, see discussion here:
#   https://groups.google.com/forum/?fromgroups=#!topic/cython-users/jcvjpSOZPp0
#
# - <CefRefPtr[ClientHandler]?>new ClientHandler() 
#   <...?> means to throw an error if the cast is not allowed

# Global variables.

global g_debug
g_debug = False

global g_applicationSettings
g_applicationSettings = None

# All .pyx files need to be included here.

include "imports.pyx"
include "browser.pyx"
include "frame.pyx"
include "javascriptbindings.pyx"
include "settings.pyx"
include "utils.pyx"

IF UNAME_SYSNAME == "Windows":
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
include "response.pyx"
include "displayhandler.pyx"

# Client handler.
cdef CefRefPtr[ClientHandler] g_clientHandler = <CefRefPtr[ClientHandler]>new ClientHandler()

def GetRealPath(file=None, encodeURL=False):
	
	# This function is defined in 2 files: cefpython.pyx and cefwindow.py, if you make changes edit both files.
	# If file is None return current directory, without trailing slash.
	
	# encodeURL param - will call urllib.pathname2url(), only when file is empty (current dir) 
	# or is relative path ("test.html", "some/test.html"), we need to encode it before passing
	# to CreateBrowser(), otherwise it is encoded by CEF internally and becomes (chinese characters):
	# >> %EF%BF%97%EF%BF%80%EF%BF%83%EF%BF%A6
	# but should be:
	# >> %E6%A1%8C%E9%9D%A2

	if file is None: file = ""
	if file.find("/") != 0 and file.find("\\") != 0 and not re.search(r"^[a-zA-Z]+:[/\\]?", file):
		# Execute this block only when relative path ("test.html", "some\test.html") or file is empty (current dir).
		# 1. find != 0 >> not starting with / or \ (/ - linux absolute path, \ - just to be sure)
		# 2. not re.search >> not (D:\\ or D:/ or D: or http:// or ftp:// or file://), 
		#     "D:" is also valid absolute path ("D:cefpython" in chrome becomes "file:///D:/cefpython/")		
		if hasattr(sys, "frozen"): path = os.path.dirname(sys.executable)
		elif "__file__" in globals(): path = os.path.dirname(os.path.realpath(__file__))
		else: path = os.getcwd()
		path = path + os.sep + file
		path = re.sub(r"[/\\]+", re.escape(os.sep), path)
		path = re.sub(r"[/\\]+$", "", path) # directory without trailing slash.
		if encodeURL:
			return urllib_pathname2url(path)
		else:
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

def Initialize(applicationSettings=None):

	if not applicationSettings:
		applicationSettings = {}

	if not "multi_threaded_message_loop" in applicationSettings:
		applicationSettings["multi_threaded_message_loop"] = False

	# Issue 10: support for unicode when passing to javascript.
	if not "unicode_to_bytes_encoding" in applicationSettings:
		applicationSettings["unicode_to_bytes_encoding"] = "utf-8"

	# We must make a copy as applicationSettings is a reference only that might get destroyed.
	global g_applicationSettings
	g_applicationSettings = copy.deepcopy(applicationSettings)

	if g_debug:
		print("\n%s" % ("--------" * 8))
		print("Welcome to CEF Python bindings!")
		print("%s\n" % ("--------" * 8))

	cdef CefSettings cefApplicationSettings
	cdef CefRefPtr[CefApp] cefApp
	cdef CefString *cefString

	SetApplicationSettings(applicationSettings, &cefApplicationSettings)

	if g_debug:
		print("CefInitialize(cefApplicationSettings, cefApp)")

	cdef cbool ret = CefInitialize(cefApplicationSettings, cefApp)

	if g_debug:
		if ret: print("OK")
		else: print("ERROR")
		print("GetLastError(): %s" % GetLastError())


def CreateBrowser(windowID, browserSettings, navigateURL, clientHandlers=None, javascriptBindings=None):

	if not clientHandlers:
		clientHandlers = {}

	if g_debug: print("cefpython.CreateBrowser()")

	if not win32gui.IsWindow(windowID):
		raise Exception("CreateBrowser() failed: invalid windowID")

	cdef CefWindowInfo info
	cdef CefBrowserSettings cefBrowserSettings
	cdef CefString *cefString

	SetBrowserSettings(browserSettings, &cefBrowserSettings)	

	if g_debug: print("win32gui.GetClientRect(windowID)")
	rect1 = win32gui.GetClientRect(windowID)
	if g_debug: print("GetLastError(): %s" % GetLastError())

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	if g_debug: print("CefWindowInfo.SetAsChild(<CefWindowHandle><int>windowID, rect2)")
	info.SetAsChild(<CefWindowHandle><int>windowID, rect2)	
	if g_debug: print("GetLastError(): %s" % GetLastError())

	navigateURL = GetRealPath(file=navigateURL, encodeURL=True)
	if g_debug: print("navigateURL: %s" % navigateURL)
	if g_debug: print("Creating cefNavigateURL: CefString().FromASCII(<char*>navigateURL)")
	
	cdef CefString cefNavigateURL
	PyStringToCefString(navigateURL, cefNavigateURL)

	if g_debug: print("CreateBrowserSync in a moment ...")

	cdef CefRefPtr[CefBrowser] cefBrowser = CreateBrowserSync(info, <CefRefPtr[CefClient]?>g_clientHandler, cefNavigateURL, cefBrowserSettings)

	if <void*>cefBrowser == NULL: 
		if g_debug: print("CreateBrowserSync(): NULL")
		if g_debug: print("GetLastError(): %s" % GetLastError())
		return None
	else: 
		if g_debug: print("CreateBrowserSync(): OK")

	cdef int innerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	g_cefBrowsers[innerWindowID] = cefBrowser
	g_pyBrowsers[innerWindowID] = PyBrowser(windowID, innerWindowID, clientHandlers, javascriptBindings)
	g_browserInnerWindows[windowID] = innerWindowID

	return g_pyBrowsers[innerWindowID]


def GetBrowserByWindowID(windowID):

	# This is: ByTopWindowID.
	if windowID in g_browserInnerWindows:
		innerWindowID = g_browserInnerWindows[windowID]
		if innerWindowID in g_pyBrowsers:
			return g_pyBrowsers[innerWindowID]
		else:
			return None
	else:
		return None

def MessageLoop():

	if g_debug: print("CefRunMessageLoop()\n")
	with nogil:
		CefRunMessageLoop()

def SingleMessageLoop():

	# Perform a single iteration of CEF message loop processing. This function is
	# used to integrate the CEF message loop into an existing application message
	# loop. 

	# Message loop dooes significant amount of work so releasing GIL is worth it.
	
	# anything that (1) can block for a significant amount of time and (2) is thread-safe should release the GIL:
	# https://groups.google.com/d/msg/cython-users/jcvjpSOZPp0/KHpUEX8IhnAJ

	with nogil:
		CefDoMessageLoopWork();

def QuitMessageLoop():

	if g_debug: print("QuitMessageLoop()")
	CefQuitMessageLoop()


def Shutdown():

	if g_debug: print("CefShutdown()")
	CefShutdown()
	if g_debug: print("GetLastError(): %s" % GetLastError())

def IsKeyModifier(key, modifiers):

	'''
	cefpython.KEYEVENT_RAWKEYDOWN=0
	cefpython.KEYEVENT_KEYDOWN=1
	cefpython.KEYEVENT_KEYUP=2
	cefpython.KEYEVENT_CHAR=3
	cefpython.KEY_SHIFT=1
	cefpython.KEY_CTRL=2
	cefpython.KEY_ALT=4
	cefpython.KEY_META=8
	cefpython.KEY_KEYPAD=16
	NumLock=1024
	WindowsKey=16 (KEY_KEYPAD?)
	'''

	if key == KEY_NONE:
		return ((KEY_SHIFT  | KEY_CTRL | KEY_ALT) & modifiers) == 0
		# Same as: return (KEY_CTRL & modifiers) != KEY_CTRL and (KEY_ALT & modifiers) != KEY_ALT and (KEY_SHIFT & modifiers) != KEY_SHIFT
	return (key & modifiers) == key

def GetJavascriptStackTrace(frameLimit=100):

	assert CurrentlyOn(TID_UI), "cefpython.GetJavascriptStackTrace() may only be called on the UI thread"

	cdef CefRefPtr[CefV8StackTrace] cefTrace = cef_v8_stack.GetCurrent(int(frameLimit))
	cdef int frameCount = (<CefV8StackTrace*>(cefTrace.get())).GetFrameCount()
	cdef CefRefPtr[CefV8StackFrame] cefFrame
	cdef CefV8StackFrame* framePtr
	pyTrace = []

	for frameNo in range(0, frameCount):
		cefFrame = (<CefV8StackTrace*>(cefTrace.get())).GetFrame(frameNo)
		framePtr = <CefV8StackFrame*>(cefFrame.get())
		pyFrame = {}		
		pyFrame["script"] = CefStringToPyString(framePtr.GetScriptName())
		pyFrame["scriptOrSourceURL"] = CefStringToPyString(framePtr.GetScriptNameOrSourceURL())
		pyFrame["function"] = CefStringToPyString(framePtr.GetFunctionName())
		pyFrame["line"] = framePtr.GetLineNumber()
		pyFrame["column"] = framePtr.GetColumn()
		pyFrame["isEval"] = framePtr.IsEval()
		pyFrame["isConstructor"] = framePtr.IsConstructor()
		pyTrace.append(pyFrame)
	
	return pyTrace

def GetJavascriptStackTraceFormatted(frameLimit=100):

	trace = GetJavascriptStackTrace(frameLimit)
	formatted = "Stack trace:\n"
	for frameNo, frame in enumerate(trace):
		formatted += "\t[%s] %s() in %s on line %s (col:%s)\n" % (frameNo, frame["function"], frame["scriptOrSourceURL"], frame["line"], frame["column"])
	return formatted
