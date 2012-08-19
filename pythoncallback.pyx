# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

__PythonCallbacks = {}
__PythonCallbackCount = 0 # next callbackID

def PutPythonCallback(pythonCallback):

	global __PythonCallbacks
	global __PythonCallbackCount
	__PythonCallbackCount += 1
	callbackID = __PythonCallbackCount
	__PythonCallbacks[callbackID] = pythonCallback
	return callbackID

def GetPythonCallback(callbackID):

	global __PythonCallbacks
	if callbackID not in __PythonCallbacks:
		raise Exception("GetPythonCallback() failed: invalid callbackID: %s" % callbackID)
	return __PythonCallbacks[callbackID]

# We call it through V8FunctionHandler's detructor, see v8functionhandler.h > ~V8FunctionHandler().
cdef void DelPythonCallback(int callbackID) except * with gil:

	global __PythonCallbacks
	global __debug
	if __debug:
		print("del __PythonCallbacks[%s]" % callbackID)
	del __PythonCallbacks[callbackID]

