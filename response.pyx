# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"

cdef object CreatePyResponse(CefRefPtr[CefResponse] cefResponse):

	pyResponse = PyResponse()
	pyResponse.cefResponse = cefResponse
	return pyResponse

cdef class PyResponse:

	cdef CefRefPtr[CefResponse] cefResponse

	def CheckCefResponse(self):

		if <void*>self.cefResponse != NULL and <CefResponse*>(self.cefResponse.get()):
			return True
		else:
			raise Exception("CefResponse was destroyed, you cannot use this object anymore")

	def GetStatus(self):

		self.CheckCefResponse()
		return (<CefResponse*>(self.cefResponse.get())).GetStatus()

	def SetStatus(self, status):

		self.CheckCefResponse()
		assert type(status) == int, "Response.SetStatus() failed: status param is not an int"		
		(<CefResponse*>(self.cefResponse.get())).SetStatus(int(status))

	def GetStatusText(self):

		self.CheckCefResponse()
		return CefStringToPyString((<CefResponse*>(self.cefResponse.get())).GetStatusText())

	def SetStatusText(self, statusText):

		self.CheckCefResponse()
		assert type(statusText) in (str, unicode, bytes), "Response.SetStatusText() failed: statusText param is not a string"
		cdef CefString cefStatusText
		PyStringToCefString(statusText, cefStatusText)
		(<CefResponse*>(self.cefResponse.get())).SetStatusText(cefStatusText)

	def GetMimeType(self):

		self.CheckCefResponse()
		return CefStringToPyString((<CefResponse*>(self.cefResponse.get())).GetMimeType())

	def SetMimeType(self, mimeType):

		self.CheckCefResponse()
		assert type(mimeType) in (str, unicode, bytes), "Response.SetMimeType() failed: mimeType param is not a string"
		cdef CefString cefMimeType
		PyStringToCefString(mimeType, cefMimeType)
		(<CefResponse*>(self.cefResponse.get())).SetMimeType(cefMimeType)

	def GetHeader(self, name):

		# TODO: what is returned when you try to get a non-existent header?
		self.CheckCefResponse()
		assert type(name) in (str, unicode, bytes), "Response.GetHeader() failed: name param is not a string"
		cdef CefString cefName
		PyStringToCefString(name, cefName)
		return CefStringToPyString((<CefResponse*>(self.cefResponse.get())).GetHeader(cefName))

	"""
	def GetHeaderMap(self):

		pass # TODO.

	def SetHeaderMap(self, headerMap):

		pass # TODO.
	"""