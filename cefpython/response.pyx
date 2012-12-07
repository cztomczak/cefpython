# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef object CreatePyResponse(CefRefPtr[CefResponse] cefResponse):

	pyResponse = PyResponse()
	pyResponse.cefResponse = cefResponse
	return pyResponse

cdef class PyResponse:

	cdef CefRefPtr[CefResponse] cefResponse

	cdef CefRefPtr[CefResponse] GetCefResponse(self) except *:
		
		if <void*>self.cefResponse != NULL and self.cefResponse.get():
			return self.cefResponse
		raise Exception("CefResponse was destroyed, you cannot use this object anymore")

	def GetStatus(self):

		return self.GetCefResponse().get().GetStatus()

	def SetStatus(self, status):

		assert type(status) == int, "Response.SetStatus() failed: status param is not an int"		
		self.GetCefResponse().get().SetStatus(int(status))

	def GetStatusText(self):

		return ToPyString(self.GetCefResponse().get().GetStatusText())

	def SetStatusText(self, statusText):

		assert type(statusText) in (str, unicode, bytes), "Response.SetStatusText() failed: statusText param is not a string"
		cdef CefString cefStatusText
		ToCefString(statusText, cefStatusText)
		self.GetCefResponse().get().SetStatusText(cefStatusText)

	def GetMimeType(self):

		return ToPyString(self.GetCefResponse().get().GetMimeType())

	def SetMimeType(self, mimeType):

		assert type(mimeType) in (str, unicode, bytes), "Response.SetMimeType() failed: mimeType param is not a string"
		cdef CefString cefMimeType
		ToCefString(mimeType, cefMimeType)
		self.GetCefResponse().get().SetMimeType(cefMimeType)

	def GetHeader(self, name):

		# TODO: what is returned when you try to get a non-existent header?
		assert type(name) in (str, unicode, bytes), "Response.GetHeader() failed: name param is not a string"
		cdef CefString cefName
		ToCefString(name, cefName)
		return ToPyString(self.GetCefResponse().get().GetHeader(cefName))

	def GetHeaderMap(self):

		headerMultimap = self.GetHeaderMultimap()
		headerMap = {}
		for headerTuple in headerMultimap:
			key = headerTuple[0]
			value = headerTuple[1]
			headerMap[key] = value
		return headerMap

	def GetHeaderMultimap(self):
		
		cdef c_multimap[CefString, CefString] cefHeaderMap
		self.GetCefResponse().get().GetHeaderMap(cefHeaderMap)
		pyHeaderMultimap = []
		cdef c_multimap[CefString, CefString].iterator iterator = cefHeaderMap.begin()
		cdef CefString cefKey
		cdef CefString cefValue
		while iterator != cefHeaderMap.end():
			cefKey = deref(iterator).first
			cefValue = deref(iterator).second
			pyKey = ToPyString(cefKey)
			pyValue = ToPyString(cefValue)
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
		cdef c_multimap[CefString, CefString] cefHeaderMap
		cdef CefString cefKey
		cdef CefString cefValue
		cdef c_pair[CefString, CefString] pair
		for headerTuple in headerMultimap:
			ToCefString(str(headerTuple[0]), cefKey)
			ToCefString(str(headerTuple[1]), cefValue)
			pair.first, pair.second = cefKey, cefValue
			cefHeaderMap.insert(pair)
		self.GetCefResponse().get().SetHeaderMap(cefHeaderMap)
