# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef dict g_pyFrames = {}

cdef PyFrame GetPyFrame(CefRefPtr[CefFrame] cefFrame):

	global g_pyFrames

	if <void*>cefFrame == NULL or not cefFrame.get():
		Debug("GetPyFrame(): returning None")
		return None

	cdef PyFrame pyFrame
	cdef str frameId # long long

	frameId = str(cefFrame.get().GetIdentifier())
	if frameId in g_pyFrames:
		return g_pyFrames[frameId]

	for id, pyFrame in g_pyFrames.items():
		if not pyFrame.cefFrame.get():
			Debug("GetPyFrame(): removing an empty CefFrame reference, frameId=%s" % id)
			del g_pyFrames[id]

	Debug("GetPyFrame(): creating new PyFrame, frameId=%s" % frameId)
	pyFrame = PyFrame()
	pyFrame.cefFrame = cefFrame
	g_pyFrames[frameId] = pyFrame
	return pyFrame

cdef class PyFrame:

	cdef CefRefPtr[CefFrame] cefFrame

	cdef CefRefPtr[CefFrame] GetCefFrame(self) except *:

		if <void*>self.cefFrame != NULL and self.cefFrame.get():
			return self.cefFrame
		raise Exception("PyFrame.GetCefFrame() failed: CefFrame was destroyed")

	def __init__(self):

		pass

	cpdef py_void CallFunction(self, funcName, *args):

		pass

	cpdef object CallFunctionSync(self, funcName, *args):

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

		self.GetCefFrame().get().Copy()

	def Cut(self):

		self.GetCefFrame().get().Cut()

	def Delete(self):

		self.GetCefFrame().get().Delete()

	def ExecuteJavascript(self, jsCode, scriptUrl=None, startLine=None):

		cdef CefString cefJsCode

		if bytes == str:
			cefJsCode.FromASCII(<char*>jsCode) # Python 2.7
		else:
			bytesJsCode = jsCode.encode("utf-8") # Python 3 requires bytes when converting to char*
			cefJsCode.FromASCII(<char*>bytesJsCode)

		if not scriptUrl:
			scriptUrl = ""
		cdef CefString cefScriptUrl
		ToCefString(scriptUrl, cefScriptUrl)

		if not startLine:
			startLine = -1

		self.GetCefFrame().get().ExecuteJavaScript(cefJsCode, cefScriptUrl, <int>startLine)

	def EvalJavascript(self):

		# TODO: CefV8Context > Eval
		pass

	def GetIdentifier(self):

		return self.GetCefFrame().get().GetIdentifier()

	def GetName(self):

		return ToPyString(self.GetCefFrame().get().GetName())

	IF CEF_VERSION == 1:

		def GetProperty(self, name):

			assert IsCurrentThread(TID_UI), "Frame.GetProperty() may only be called on the UI thread"
			cdef CefRefPtr[CefV8Context] v8Context = self.GetCefFrame().get().GetV8Context()
			window = v8Context.get().GetGlobal()

			cdef CefString cefPropertyName
			name = str(name)
			ToCefString(name, cefPropertyName)

			cdef CefRefPtr[CefV8Value] v8Value
			v8Value = window.get().GetValue(cefPropertyName)

			return V8ValueToPyValue(v8Value, v8Context)

	IF CEF_VERSION == 1:

		def GetSource(self):

			IF CEF_VERSION == 1:
				assert IsCurrentThread(TID_UI), "Frame.GetSource() may only be called on the UI thread"
			return ToPyString(self.GetCefFrame().get().GetSource())

		def GetText(self):

			IF CEF_VERSION == 1:
				assert IsCurrentThread(TID_UI), "Frame.GetText() may only be called on the UI thread"
			return ToPyString(self.GetCefFrame().get().GetText())

	def GetUrl(self):

		return ToPyString(self.GetCefFrame().get().GetURL())

	def IsFocused(self):

		IF CEF_VERSION == 1:
			assert IsCurrentThread(TID_UI), "Frame.IsFocused() may only be called on the UI thread"
		return self.GetCefFrame().get().IsFocused()

	def IsMain(self):

		return self.GetCefFrame().get().IsMain()

	def LoadRequest(self):

		pass

	def LoadString(self, value, url):

		cdef CefString cefValue
		cdef CefString cefUrl
		ToCefString(value, cefValue)
		ToCefString(url, cefUrl)
		self.GetCefFrame().get().LoadString(cefValue, cefUrl)

	def LoadUrl(self, url):

		cdef CefString cefUrl
		ToCefString(url, cefUrl)
		self.GetCefFrame().get().LoadURL(cefUrl)

	def Paste(self):

		self.GetCefFrame().get().Paste()

	IF CEF_VERSION == 1:

		def Print(self):

			self.GetCefFrame().get().Print()

	def Redo(self):

		self.GetCefFrame().get().Redo()

	def SelectAll(self):

		self.GetCefFrame().get().SelectAll()

	IF CEF_VERSION == 1:

		def SetProperty(self, name, value):

			# GetV8Context() requires UI thread.
			assert IsCurrentThread(TID_UI), "Frame.SetProperty() may only be called on the UI thread"

			if not JavascriptBindings.IsValueAllowed(value):
				valueType = JavascriptBindings.__IsValueAllowed(value)
				raise Exception("Frame.SetProperty() failed: name=%s, not allowed type: %s (this may be a type of a nested value)" % (name, valueType))

			cdef CefRefPtr[CefV8Context] v8Context = self.GetCefFrame().get().GetV8Context()
			window = v8Context.get().GetGlobal()

			cdef CefString cefPropertyName
			name = str(name)
			ToCefString(name, cefPropertyName)

			cdef c_bool sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())
			if not sameContext:
				Debug("Frame.SetProperty(): inside a different context, calling v8Context.Enter()")
				assert v8Context.get().Enter(), "v8Context.Enter() failed"

			window.get().SetValue(cefPropertyName, PyValueToV8Value(value, v8Context), V8_PROPERTY_ATTRIBUTE_NONE)

			if not sameContext:
				assert v8Context.get().Exit(), "v8Context.Exit() failed"

	def Undo(self):

		self.GetCefFrame().get().Undo()

	def ViewSource(self):

		self.GetCefFrame().get().ViewSource()
