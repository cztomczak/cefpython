# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef cpp_bool HttpAuthenticationDialog(
        browser, isProxy, host, port, realm, scheme, username, password
        ) except *:
    cdef AuthCredentialsData* credentialsData
    cdef int innerWindowHandle = browser.GetWindowHandle()
    cdef HWND hwnd = <HWND>innerWindowHandle
    with nogil:
        credentialsData = AuthDialog(hwnd)
    if credentialsData == NULL:
        return False
    else:
        username[0] = CharToPyString(credentialsData.username.c_str())
        password[0] = CharToPyString(credentialsData.password.c_str())
        return True
