# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef c_bool HttpAuthenticationDialog(
		browser, isProxy, host, port, realm, scheme, username, password
		) except *:

	# Using "with nogil" in this function, so it needs to be a "cdef function".
	cdef AuthCredentialsData* credentialsData
	innerWindowID = browser.GetInnerWindowID() # innerWindowID is a top window for a popup
	cdef HWND handle = <HWND><int>innerWindowID
	with nogil:
		credentialsData = AuthDialog(handle)
	if credentialsData == NULL:
		return False
	else:
		# In Python 2.7 c_str returns a string.
		username[0] = credentialsData.username.c_str()
		password[0] = credentialsData.password.c_str()
		# Python 3
		if str != bytes:
			# c_str() returned bytes.
			if type(username[0]) == bytes:
				username[0] = username[0].decode(g_applicationSettings["unicode_to_bytes_encoding"])
			if type(password[0]) == bytes:
				password[0] = password[0].decode(g_applicationSettings["unicode_to_bytes_encoding"])
		return True
