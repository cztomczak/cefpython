# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"

class JavascriptBindings:

	# By default we bind only to top frame.
	__bindToFrames = False
	__bindToPopups = False
	__functions = {}
	__properties = {}
	__objects = {}
	
	# Many browsers may have the same JavascriptBindings object.
	# __browsers = [] # currently not used, no browser is inserted here.
	
	# V8ContextHandler_OnContextCreated inserts frames here that should have javascript bindings,
	# it is later needed to do rebinding using Rebind() method. All frames are here, the main too,
	# frames may be from different Browser objects.
	__frames = {} # frameIdentifier(int64) : tuple(PyBrowser, PyFrame())

	def __init__(self, bindToFrames=False, bindToPopups=False):

		self.__bindToFrames = bindToFrames
		self.__bindToPopups = bindToPopups

	def GetBindToFrames(self):

		return self.__bindToFrames

	def GetBindToPopups(self):

		return self.__bindToPopups

	def SetFunction(self, name, func):

		self.SetProperty(name, func)

	def SetObject(self, name, object):

		self.SetProperty(name, object)

	def GetFunction(self, name):

		if name in self.__functions:
			return self.__functions[name]

	def GetFunctions(self):

		return self.__functions

	def GetObjects(self):

		return self.__objects

	def GetObjectMethod(self, objectName, methodName):

		if objectName in self.__objects:
			if methodName in self.__objects[objectName]:
				return self.__objects[objectName][methodName]

	def SetProperty(self, name, value):

		allowed = self.__IsValueAllowed(value) # returns True or string.
		if allowed is not True:
			raise Exception("JavascriptBindings.SetProperty() failed: name=%s, not allowed type: %s (this may be a type of a nested value)" % (name, allowed))
		
		valueType = type(value)
		if valueType == types.FunctionType or valueType == types.MethodType:
			self.__functions[name] = value
		elif valueType == types.InstanceType:
			self.__SetObjectMethods(name, value)
		else:
			self.__properties[name] = value

	def __SetObjectMethods(self, name, obj):

		methods = {}
		for value in inspect.getmembers(obj, predicate=inspect.ismethod):
			key = value[0]
			method = value[1]
			methods[key] = method
		self.__objects[name] = methods

	def AddFrame(self, pyBrowser, pyFrame):

		if pyFrame.GetIdentifier() not in self.__frames:
			self.__frames[pyFrame.GetIdentifier()] = (pyBrowser, pyFrame)

	def Rebind(self):
		
		assert CurrentlyOn(TID_UI), "JavascriptBindings.Rebind() may only be called on the UI thread"

		cdef CefRefPtr[CefBrowser] cefBrowser
		cdef CefRefPtr[CefFrame] cefFrame
		cdef CefRefPtr[CefV8Context] v8Context
		cdef cbool sameContext

		for frameID in self.__frames:
			
			pyBrowser = self.__frames[frameID][0]
			pyFrame = self.__frames[frameID][1]
			
			cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(pyBrowser.GetInnerWindowID()))
			cefFrame = GetCefFrameByFrameID(CheckFrameID(pyFrame.GetIdentifier()))
			v8Context = (<CefFrame*>(cefFrame.get())).GetV8Context()

			sameContext = (<CefV8Context*>(v8Context.get())).IsSame(cef_v8_static.GetCurrentContext())

			if not sameContext:
				if __debug: print("JavascriptBindings.Rebind(): different context, calling v8Context.Enter()")
				assert (<CefV8Context*>(v8Context.get())).Enter(), "v8Context.Enter() failed"

			V8ContextHandler_OnContextCreated(cefBrowser, cefFrame, v8Context)

			if not sameContext:
				assert (<CefV8Context*>(v8Context.get())).Exit(), "v8Context.Exit() failed"

	def GetProperties(self):

		return self.__properties

	@staticmethod
	def IsValueAllowed(value):

		return JavascriptBindings.__IsValueAllowed(value) is True

	@staticmethod
	def __IsValueAllowed(value, recursion=False) :

		# !! When making changes here also check: Frame.SetProperty() 
		#    as it checks for FunctionType, MethodType and InstanceType.
		
		# - Return value: True - allowed, string - not allowed
		# - Not using type().__name__ here as it is not consistent, for int it is "int" but for None it is "NoneType".

		valueType = type(value)
		if valueType == list:
			for val in value:
				valueType2 = JavascriptBindings.__IsValueAllowed(val, True)
				if valueType2 is not True:
					return valueType2.__name__
			return True
		elif valueType == bool:
			return True
		elif valueType == float:
			return True
		elif valueType == int:
			return True
		elif valueType == type(None):
			return True
		elif valueType == types.FunctionType or valueType == types.MethodType:
			if recursion:
				return valueType.__name__
			else:
				return True
		elif valueType == types.InstanceType: # binding object (its methods and properties)
			if recursion:
				return valueType.__name__
			else:
				return True
		elif valueType == dict:
			for key in value:
				valueType2 = JavascriptBindings.__IsValueAllowed(value[key], True)
				if valueType2 is not True:
					return valueType2.__name__
			return True
		elif valueType == str:
			return True
		elif valueType == unicode:
			return True
		elif valueType == tuple:
			return True
		else:
			return valueType.__name__
