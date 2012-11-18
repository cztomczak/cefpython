# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

g_PythonCallbacks = {}
g_PythonCallbackCount = 0 # next callbackID

def PutPythonCallback(pythonCallback):

	global g_PythonCallbacks
	global g_PythonCallbackCount
	g_PythonCallbackCount += 1
	callbackID = g_PythonCallbackCount
	g_PythonCallbacks[callbackID] = pythonCallback
	return callbackID

def GetPythonCallback(callbackID):

	global g_PythonCallbacks
	if callbackID not in g_PythonCallbacks:
		raise Exception("GetPythonCallback() failed: invalid callbackID: %s" % callbackID)
	return g_PythonCallbacks[callbackID]

# We call it through V8FunctionHandler's detructor, see v8functionhandler.h > ~V8FunctionHandler().
# "with gil" must be added as we call it from c++.
cdef void DelPythonCallback(int callbackID) except * with gil:

	global g_PythonCallbacks
	del g_PythonCallbacks[callbackID]

