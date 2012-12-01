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

	"""
	weak reference
	http://docs.cython.org/src/userguide/extension_types.html#making-extension-types-weak-referenceable
	cdef object __weakref__
	"""

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

	def GetHeaderMap(self):

		headerMultimap = self.GetHeaderMultimap()
		headerMap = {}
		for headerTuple in headerMultimap:
			key = headerTuple[0]
			value = headerTuple[1]
			headerMap[key] = value
		return headerMap

	def GetHeaderMultimap(self):
		
		self.CheckCefResponse()
		cdef c_multimap[CefString, CefString] cefHeaderMap
		(<CefResponse*>(self.cefResponse.get())).GetHeaderMap(cefHeaderMap)
		pyHeaderMultimap = []
		cdef c_multimap[CefString, CefString].iterator iterator = cefHeaderMap.begin()
		cdef CefString cefKey
		cdef CefString cefValue
		while iterator != cefHeaderMap.end():
			cefKey = deref(iterator).first
			cefValue = deref(iterator).second
			pyKey = CefStringToPyString(cefKey)
			pyValue = CefStringToPyString(cefValue)
			pyHeaderMultimap.append((pyKey, pyValue))
			preinc(iterator)
		return pyHeaderMultimap

	def SetHeaderMap(self, headerMap):

		assert type(headerMap) == dict, "headerMap param is not a dictionary"
		assert len(headerMap) > 0, "headerMap param is an empty dictionary"
		headerMultimap = []
		for key in headerMap:
			headerMultimap.append((str(key), str(headerMap[key])))
		self.SetHeaderMultimap(headerMultimap)

	def SetHeaderMultimap(self, headerMultimap):

		assert type(headerMultimap) == list, "headerMultimap param is not a list"
		assert len(headerMultimap) > 0, "headerMultimap param is an empty list"
		self.CheckCefResponse()
		cdef c_multimap[CefString, CefString] cefHeaderMap
		cdef CefString cefKey
		cdef CefString cefValue
		cdef c_pair[CefString, CefString] pair
		for headerTuple in headerMultimap:
			PyStringToCefString(str(headerTuple[0]), cefKey)
			PyStringToCefString(str(headerTuple[1]), cefValue)
			pair.first, pair.second = cefKey, cefValue
			cefHeaderMap.insert(pair)
		(<CefResponse*>(self.cefResponse.get())).SetHeaderMap(cefHeaderMap)
