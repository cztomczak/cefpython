include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
from cef_string cimport CefString

IF CEF_VERSION == 1:
    from cef_cookie_cef1 cimport CefCookie
ELIF CEF_VERSION == 3:
    from cef_cookie_cef3 cimport CefCookie

# We need to pass C++ class methods by reference to a function,
# it is not possible with such syntax:
# | &CefCookieManager.SetCookie
# We had to create this addional pxd file so we can pass it like this:
# | &cef_cookie_manager_namespace.SetCookie
# In cookie.pyx > PyCookieManager.SetCookie().
# See this topic:
# https://groups.google.com/d/topic/cython-users/G-vEdIkmNNY/discussion

cdef extern from "include/cef_cookie.h" namespace "CefCookieManager":
    cpp_bool SetCookie(const CefString& url, const CefCookie& cookie)
    cpp_bool DeleteCookies(const CefString& url,
                           const CefString& cookie_name)
