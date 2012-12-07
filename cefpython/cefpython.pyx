# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# IMPORTANT notes:
#
# - cdef functions returning types other than "object" (a python object)
#   should have in its declaration "except *", otherwise exceptions are ignored.
#   Those cdef that return "object" have "except *" by default.
#
# - about acquiring/releasing GIL lock, see discussion here:
#   https://groups.google.com/forum/?fromgroups=#!topic/cython-users/jcvjpSOZPp0
#
# - <CefRefPtr[ClientHandler]?>new ClientHandler() 
#   <...?> means to throw an error if the cast is not allowed
#
# - in client handler callbacks must embrace all code in try..except otherwise 
#   the error will  be ignored, only printed to the output console, this is the 
#   default behavior of Cython, to remedy this you are supposed to add "except *"
#   in function declaration, unfortunately it does not work, some conflict with
#   CEF threading, see topic at cython-users for more details: 
#   https://groups.google.com/d/msg/cython-users/CRxWoX57dnM/aufW3gXMhOUJ.
#

# Global variables.

g_debug = False

# When put None here and assigned a local dictionary in Initialize(), later while
# running app this global variable was garbage collected, see this topic:
# https://groups.google.com/d/topic/cython-users/0dw3UASh7HY/discussion
g_applicationSettings = {}

# All .pyx files need to be included here.

include "include_cython/compile_time_constants.pxi"
include "imports.pyx"

include "utils.pyx"
include "string_utils.pyx"

include "window_info.pyx"
include "browser.pyx"
include "frame.pyx"

include "settings.pyx"

IF UNAME_SYSNAME == "Windows":
	include "window_utils_win.pyx"
	IF CEF_VERSION == 1:
		include "http_authentication_win.pyx"

IF CEF_VERSION == 1:
	include "load_handler.pyx"
	include "keyboard_handler.pyx"
	include "virtual_keys.pyx"
	include "request_handler.pyx"
	include "response.pyx"
	include "display_handler.pyx"
	include "lifespan_handler.pyx"

IF CEF_VERSION == 1:
	include "v8context_handler.pyx"
	include "v8function_handler.pyx"
	include "v8utils.pyx"
	include "javascript_bindings.pyx"
	include "javascript_callback.pyx"
	include "python_callback.pyx"

# Client handler.
cdef CefRefPtr[ClientHandler] g_clientHandler = <CefRefPtr[ClientHandler]?> new ClientHandler()

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

	Debug("thread in initialize: %s" % win32api.GetCurrentThreadId())

	Debug("-" * 80)
	Debug("Initialize() called")

	cdef CefRefPtr[CefApp] cefApp

	IF CEF_VERSION == 3:
		cdef HINSTANCE hInstance = GetModuleHandle(NULL)
		cdef CefMainArgs cefMainArgs = CefMainArgs(hInstance)
		cdef int exitCode
		exitCode = CefExecuteProcess(cefMainArgs, cefApp)
		Debug("CefExecuteProcess(): exitCode = %s" % exitCode)
		if exitCode >= 0:
			exit(exitCode)

	if not applicationSettings:
		applicationSettings = {}

	if not "multi_threaded_message_loop" in applicationSettings:
		applicationSettings["multi_threaded_message_loop"] = False

	# Issue 10: support for unicode when passing to javascript.
	if not "unicode_to_bytes_encoding" in applicationSettings:
		applicationSettings["unicode_to_bytes_encoding"] = "utf-8"

	IF CEF_VERSION == 3:
		if not "single_process" in applicationSettings:
			applicationSettings["single_process"] = False

	# We must make a copy as applicationSettings is a reference only that might get destroyed.
	global g_applicationSettings
	for key in applicationSettings:
		g_applicationSettings[key] = copy.deepcopy(applicationSettings[key])

	cdef CefSettings cefApplicationSettings
	SetApplicationSettings(applicationSettings, &cefApplicationSettings)

	Debug("CefInitialize()")
	
	cdef c_bool ret
	IF CEF_VERSION == 1:
		ret = CefInitialize(cefApplicationSettings, cefApp)
	ELIF CEF_VERSION == 3:
		ret = CefInitialize(cefMainArgs, cefApplicationSettings, cefApp)

	if not ret: Debug("CefInitialize() failed")
	return ret

def CreateBrowserSync(windowInfo, browserSettings, navigateURL):

	Debug("CreateBrowserSync() called")
	assert IsCurrentThread(TID_UI), "cefpython.CreateBrowserSync() can only be called on UI thread"
	
	if not isinstance(windowInfo, WindowInfo):
		raise Exception("CreateBrowserSync() failed: windowInfo: invalid object")
	
	cdef CefBrowserSettings cefBrowserSettings
	SetBrowserSettings(browserSettings, &cefBrowserSettings)	

	cdef CefWindowInfo cefWindowInfo
	SetCefWindowInfo(cefWindowInfo, windowInfo)

	navigateURL = GetRealPath(file=navigateURL, encodeURL=True)
	Debug("navigateURL: %s" % navigateURL)
	
	cdef CefString cefNavigateURL
	ToCefString(navigateURL, cefNavigateURL)

	Debug("CefBrowser::CreateBrowserSync()")
	cdef CefRefPtr[CefBrowser] cefBrowser = cef_browser_static.CreateBrowserSync(
			cefWindowInfo, <CefRefPtr[CefClient]?>g_clientHandler, cefNavigateURL,
			cefBrowserSettings)

	if <void*>cefBrowser == NULL: 
		Debug("CefBrowser::CreateBrowserSync() failed")
		return None
	else:
		Debug("CefBrowser::CreateBrowserSync() succeeded")

	cdef PyBrowser pyBrowser = GetPyBrowser(cefBrowser)
	pyBrowser.SetUserData("__outerWindowHandle", windowInfo.parentWindowHandle)
	return pyBrowser

def MessageLoop():

	Debug("MessageLoop()")
	with nogil:
		CefRunMessageLoop()

def SingleMessageLoop():

	# Perform a single iteration of CEF message loop processing. This function is
	# used to integrate the CEF message loop into an existing application message
	# loop. 

	# anything that (1) can block for a significant amount of time and (2) is thread-safe should release the GIL:
	# https://groups.google.com/d/msg/cython-users/jcvjpSOZPp0/KHpUEX8IhnAJ

	# We must release the GIL in message loop otherwise we will get dead lock when
	# calling from c++ to python.

	with nogil:
		CefDoMessageLoopWork();

def QuitMessageLoop():

	Debug("QuitMessageLoop()")
	CefQuitMessageLoop()


def Shutdown():

	Debug("Shutdown()")
	CefShutdown()

IF CEF_VERSION == 1:

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

IF CEF_VERSION == 1:

	cdef object CefV8StackTraceToPython(CefRefPtr[CefV8StackTrace] cefTrace):

		cdef int frameCount = cefTrace.get().GetFrameCount()
		cdef CefRefPtr[CefV8StackFrame] cefFrame
		cdef CefV8StackFrame* framePtr
		pyTrace = []

		for frameNo in range(0, frameCount):
			cefFrame = cefTrace.get().GetFrame(frameNo)
			framePtr = cefFrame.get()
			pyFrame = {}		
			pyFrame["script"] = ToPyString(framePtr.GetScriptName())
			pyFrame["scriptOrSourceURL"] = ToPyString(framePtr.GetScriptNameOrSourceURL())
			pyFrame["function"] = ToPyString(framePtr.GetFunctionName())
			pyFrame["line"] = framePtr.GetLineNumber()
			pyFrame["column"] = framePtr.GetColumn()
			pyFrame["isEval"] = framePtr.IsEval()
			pyFrame["isConstructor"] = framePtr.IsConstructor()
			pyTrace.append(pyFrame)
		
		return pyTrace

	def GetJavascriptStackTrace(frameLimit=100):

		assert IsCurrentThread(TID_UI), "cefpython.GetJavascriptStackTrace() may only be called on the UI thread"
		cdef CefRefPtr[CefV8StackTrace] cefTrace = cef_v8_stack_trace.GetCurrent(int(frameLimit))
		return CefV8StackTraceToPython(cefTrace)

	def FormatJavascriptStackTrace(stackTrace):

		formatted = ""
		for frameNo, frame in enumerate(stackTrace):
			formatted += "\t[%s] %s() in %s on line %s (col:%s)\n" % (
					frameNo, frame["function"], frame["scriptOrSourceURL"], frame["line"], frame["column"])
		return formatted

