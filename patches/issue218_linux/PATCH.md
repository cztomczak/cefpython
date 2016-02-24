Fixes to the CEF GTK implementation on Linux:
https://github.com/cztomczak/cefpython/issues/218

Apply the patch in the `~/chromium/src/cef/` directory.

Modifications are made to the CefBrowserHostImpl::
PlatformCreateWindow function.
