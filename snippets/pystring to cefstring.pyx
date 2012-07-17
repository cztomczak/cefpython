cdef CefString cefURL
bytesURL = URL.enode("utf-8")
cefURL.FromASCII(<char*>bytesURL)