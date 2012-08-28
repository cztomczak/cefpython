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
	__browserCreated = False # After browser is created you are not allowed to call SetFunction() or SetProperty().

	def __init__(self, bindToFrames=False, bindToPopups=False):

		self.__bindToFrames = bindToFrames
		self.__bindToPopups = bindToPopups

	# Internal.
	def SetBrowserCreated(self, browserCreated):

		self.__browserCreated = browserCreated

	def GetBindToFrames(self):

		return self.__bindToFrames

	def GetBindToPopups(self):

		return self.__bindToPopups

	def SetFunction(self, name, func):

		if self.__browserCreated:
			raise Exception("JavascriptBindings.SetFunction() failed: browser was already created, you are not"
					" allowed to call this function now.")
		if type(func) == types.FunctionType or type(func) == types.MethodType:
			self.__functions[name] = func
		else:
			raise Exception("JavascriptBindings.SetFunction() failed: not allowed type: %s" % type(func).__name__)

	def GetFunction(self, name):

		if name in self.__functions:
			return self.__functions[name]

	def GetFunctions(self):

		return self.__functions

	def SetProperty(self, name, value):

		if self.__browserCreated:
			raise Exception("JavascriptBindings.SetProperty() failed: you cannot call this method after the browser"
			                " was created, you should call instead: Browser.GetMainFrame().SetProperty().")
		allowed = self.__IsTypeAllowed(value) # returns True or string.
		if allowed is not True:
			raise Exception("JavascriptBindings.SetProperty() failed: not allowed type: %s" % allowed)
		self.__properties[name] = value
	
	def GetProperties(self):

		return self.__properties

	def __IsTypeAllowed(self, value):

		# Return value: True - allowed, string - not allowed
		# Function is not allowed here.

		# Not using type().__name__ here as it is not consistent, for int it is "int" but for None it is "NoneType".

		valueType = type(value) 
		if valueType == list:
			for val in value:
				valueType2 = self.__IsTypeAllowed(val)
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
			return True
		elif valueType == dict:
			for key in value:
				valueType2 = self.__IsTypeAllowed(value[key])
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
