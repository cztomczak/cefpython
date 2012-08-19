# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "v8utils.pyx"
include "v8contexthandler.pyx"

# id: (int64 = long in python) CefFrame.GetIdentifier() - globally unique identifier.
# In Python 2 there is: int (32 bit) long (64 bit).
# In Python 3 there will be only int (64 bit).
# long has no limit in python.

cdef map[cef_types.int64, CefRefPtr[CefFrame]] __cefFrames
__pyFrames = {}

class PyFrame:

	frameID = 0

	def __init__(self, frameID):

		self.frameID = frameID

	def CallFunction(self, funcName):

		# CefV8 Objects, Arrays and Functions can be created only inside V8 context,
		# you need to call CefV8Context::Enter() and CefV8Context::Exit():
		# http://code.google.com/p/chromiumembedded/issues/detail?id=203
		# Entering context should be done for Frame::CallFunction().

		# You must enter CefV8Context before calling PyValueToV8Value().

		pass

	def ExecuteJavascript(self, jsCode, scriptURL=None, startLine=None):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		
		cdef CefString cefJsCode
		bytesJsCode = jsCode.encode("utf-8") # Python 3 requires bytes when converting to char*
		cefJsCode.FromASCII(<char*>bytesJsCode)
		
		if not scriptURL:
			scriptURL = ""
		cdef CefString cefScriptURL
		PyStringToCefString(scriptURL, cefScriptURL)

		if not startLine:
			startLine = -1

		(<CefFrame*>(cefFrame.get())).ExecuteJavaScript(cefJsCode, cefScriptURL, <int>startLine)

	def GetURL(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefURL = (<CefFrame*>(cefFrame.get())).GetURL()
		return CefStringToPyString(cefURL)
		
	def GetIdentifier(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return <long long>((<CefFrame*>(cefFrame.get())).GetIdentifier())

	def GetProperty(self, name):

		# GetV8Context() requires UI thread.
		assert CurrentlyOn(TID_UI), "Frame.SetProperty() should only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefRefPtr[CefV8Context] v8Context = (<CefFrame*>(cefFrame.get())).GetV8Context()
		window = (<CefV8Context*>(v8Context.get())).GetGlobal()

		cdef CefString cefPropertyName
		name = str(name)
		PyStringToCefString(name, cefPropertyName)
		
		cdef CefRefPtr[CefV8Value] v8Value
		v8Value = (<CefV8Value*>(window.get())).GetValue(cefPropertyName)

		return V8ValueToPyValue(v8Value, v8Context)

	def IsMain(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return (<CefFrame*>(cefFrame.get())).IsMain()

	def LoadURL(self, URL):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefURL
		PyStringToCefString(URL, cefURL)
		(<CefFrame*>(cefFrame.get())).LoadURL(cefURL)

	def SetProperty(self, name, value):

		# GetV8Context() requires UI thread.
		assert CurrentlyOn(TID_UI), "Frame.SetProperty() should only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefRefPtr[CefV8Context] v8Context = (<CefFrame*>(cefFrame.get())).GetV8Context()

		window = (<CefV8Context*>(v8Context.get())).GetGlobal()

		cdef CefString cefPropertyName
		name = str(name)
		PyStringToCefString(name, cefPropertyName)
		
		(<CefV8Value*>(window.get())).SetValue(cefPropertyName, PyValueToV8Value(value, v8Context), V8_PROPERTY_ATTRIBUTE_NONE)

