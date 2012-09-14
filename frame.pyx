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

		# You must check current context and Enter it if not same, before calling PyValueToV8Value().

		'''TODO: call Frame->GetV8Context?()->GetGlobal?() you get a window object, 
		now iterate through its all properties and compare to funcName, you get a real javascript 
		object which you can call and be able to get return value, also you can pass python callbacks this way.'''

		pass

	def Copy(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Copy()

	def Cut(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Cut()

	def Delete(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Delete()

	def ExecuteJavascript(self, jsCode, scriptURL=None, startLine=None):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))		
		cdef CefString cefJsCode

		if bytes == str:
			cefJsCode.FromASCII(<char*>jsCode) # Python 2.7
		else:
			bytesJsCode = jsCode.encode("utf-8") # Python 3 requires bytes when converting to char*
			cefJsCode.FromASCII(<char*>bytesJsCode)
		
		if not scriptURL:
			scriptURL = ""
		cdef CefString cefScriptURL
		PyStringToCefString(scriptURL, cefScriptURL)

		if not startLine:
			startLine = -1

		(<CefFrame*>(cefFrame.get())).ExecuteJavaScript(cefJsCode, cefScriptURL, <int>startLine)

	def EvalJavascript(self):

		# TODO: CefV8Context > Eval
		pass

	def GetIdentifier(self):

		return self.frameID

		"""
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return <long long>((<CefFrame*>(cefFrame.get())).GetIdentifier())
		"""

	def GetName(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefName = ((<CefFrame*>(cefFrame.get())).GetName())
		return CefStringToPyString(cefName)

	def GetProperty(self, name):

		# GetV8Context() requires UI thread.
		assert CurrentlyOn(TID_UI), "Frame.GetProperty() may only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefRefPtr[CefV8Context] v8Context = (<CefFrame*>(cefFrame.get())).GetV8Context()
		window = (<CefV8Context*>(v8Context.get())).GetGlobal()

		cdef CefString cefPropertyName
		name = str(name)
		PyStringToCefString(name, cefPropertyName)

		cdef CefRefPtr[CefV8Value] v8Value
		v8Value = (<CefV8Value*>(window.get())).GetValue(cefPropertyName)

		return V8ValueToPyValue(v8Value, v8Context)

	def GetSource(self):
		
		assert CurrentlyOn(TID_UI), "Frame.GetSource() may only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefSource = (<CefFrame*>(cefFrame.get())).GetSource()
		return CefStringToPyString(cefSource)

	def GetText(self):
		
		assert CurrentlyOn(TID_UI), "Frame.GetText() may only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefSource = (<CefFrame*>(cefFrame.get())).GetText()
		return CefStringToPyString(cefSource)

	def GetURL(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefURL = (<CefFrame*>(cefFrame.get())).GetURL()
		return CefStringToPyString(cefURL)

	def IsFocused(self):

		assert CurrentlyOn(TID_UI), "Frame.IsFocused() may only be called on the UI thread"
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return (<CefFrame*>(cefFrame.get())).IsFocused()

	def IsMain(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		return (<CefFrame*>(cefFrame.get())).IsMain()

	def LoadRequest(self):

		pass

	def LoadString(self, value, url):
		
		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefValue
		cdef CefString cefURL
		PyStringToCefString(value, cefValue)
		PyStringToCefString(url, cefURL)		
		(<CefFrame*>(cefFrame.get())).LoadString(cefValue, cefURL)

	def LoadURL(self, url):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefString cefURL
		PyStringToCefString(url, cefURL)
		(<CefFrame*>(cefFrame.get())).LoadURL(cefURL)

	def Paste(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Paste()

	def Print(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Print()

	def Redo(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Redo()

	def SelectAll(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).SelectAll()

	def SetProperty(self, name, value):

		# GetV8Context() requires UI thread.
		assert CurrentlyOn(TID_UI), "Frame.SetProperty() may only be called on the UI thread"
		
		if not JavascriptBindings.IsValueAllowed(value):
			valueType = JavascriptBindings.__IsValueAllowed(value)
			raise Exception("Frame.SetProperty() failed: name=%s, not allowed type: %s (this may be a type of a nested value)" % (name, valueType))
		
		if type(value) == types.InstanceType:
			raise Exception("Frame.SetProperty() failed: name=%s, you cannot bind instance, to bind this type use JavascriptBindnigs.SetProperty()" % (name))

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		cdef CefRefPtr[CefV8Context] v8Context = (<CefFrame*>(cefFrame.get())).GetV8Context()
		
		window = (<CefV8Context*>(v8Context.get())).GetGlobal()

		cdef CefString cefPropertyName
		name = str(name)
		PyStringToCefString(name, cefPropertyName)

		cdef cbool sameContext = (<CefV8Context*>(v8Context.get())).IsSame(cef_v8_static.GetCurrentContext())
		
		if not sameContext:
			if __debug: print("Frame.SetProperty(): different context, calling v8Context.Enter()")
			assert (<CefV8Context*>(v8Context.get())).Enter(), "v8Context.Enter() failed"

		(<CefV8Value*>(window.get())).SetValue(cefPropertyName, PyValueToV8Value(value, v8Context), V8_PROPERTY_ATTRIBUTE_NONE)
		
		if not sameContext:
			assert (<CefV8Context*>(v8Context.get())).Exit(), "v8Context.Exit() failed"

	def Undo(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).Undo()

	def ViewSource(self):

		cdef CefRefPtr[CefFrame] cefFrame = GetCefFrameByFrameID(CheckFrameID(self.frameID))
		(<CefFrame*>(cefFrame.get())).ViewSource()
