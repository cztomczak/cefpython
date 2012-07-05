# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef void LoadHandler_OnLoadEnd(CefRefPtr[CefBrowser] browser, 
						CefRefPtr[CefFrame] frame,
						int httpStatusCode) with gil:

	print "loadhandler.pyx: LoadHandler_OnLoadEnd()"

	#cdef CefRefPtr[CefFrame] frame2 = (<CefBrowser*>(browser.get())).GetMainFrame()
	#cdef cef_types.int64 frameID = (<CefFrame*>(frame2.get())).GetIdentifier()
	#print "frameID = %s" % long(frameID)

	cdef int64 frameID = (<CefFrame*>(frame.get())).GetIdentifier()
	print "frameID = %s" % long(frameID)

	cdef CefString URL = (<CefFrame*>(frame.get())).GetURL()
	print "URL = %s" % CefStringToPyString(URL)
