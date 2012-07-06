# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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

	def ExecuteJavascript(self, jsCode, scriptURL=None, startLine=None):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		
		cdef CefString cefJsCode
		cefJsCode.FromASCII(<char*>jsCode)
		
		if not scriptURL:
			scriptURL = ""
		cdef CefString cefScriptURL
		cefScriptURL.FromASCII(<char*>scriptURL)

		if not startLine:
			startLine = -1

		(<CefFrame*>(cefFrame.get())).ExecuteJavaScript(cefJsCode, cefScriptURL, <int>startLine)

	def GetURL(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefURL = (<CefFrame*>(cefFrame.get())).GetURL()
		return CefStringToPyString(cefURL)
		
	def IsMain(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return (<CefFrame*>(cefFrame.get())).IsMain()

