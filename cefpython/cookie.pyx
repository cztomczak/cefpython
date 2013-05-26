# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef Cookie cookie = Cookie()
cookie.SetName("asd1")
print("cookie.cefCookie: %s" % cookie.cefCookie)
print("cookie.GetName(): %s" % cookie.GetName())
print("cookie.GetCreation(): %s" % cookie.GetCreation())
cookie.SetCreation(datetime.datetime(2013,5,23))
print("cookie.GetCreation(): %s" % cookie.GetCreation())
print("cookie: %s" % cookie.Get())

# ------------------------------------------------------------------------------
# Cookie
# ------------------------------------------------------------------------------

cdef class Cookie:
    cdef CefCookie cefCookie

    cpdef py_void Set(self, dict cookie):
        for key in cookie:
            if key == "name":
                self.SetName(cookie[key])
            elif key == "value":
                self.SetValue(cookie[key])
            elif key == "domain":
                self.SetDomain(cookie[key])
            elif key == "path":
                self.SetPath(cookie[key])
            elif key == "secure":
                self.SetSecure(cookie[key])
            elif key == "httpOnly":
                self.SetHttpOnly(cookie[key])
            elif key == "creation":
                self.SetCreation(cookie[key])
            elif key == "lastAccess":
                self.SetLastAccess(cookie[key])
            elif key == "hasExpires":
                    self.SetHasExpires(cookie[key])
            elif key == "expires":
                self.SetExpires(cookie[key])
            else:
                raise Exception("Invalid key: %s" % key)

    cpdef dict Get(self):
        return {
            "name": self.GetName(),
            "value": self.GetValue(),
            "domain": self.GetDomain(),
            "path": self.GetPath(),
            "secure": self.GetSecure(),
            "httpOnly": self.GetHttpOnly(),
            "creation": self.GetCreation(),
            "lastAccess": self.GetLastAccess(),
            "hasExpires": self.GetHasExpires(),
            "expires": self.GetExpires(),
        }

    cpdef py_void SetName(self, py_string name):
        # This works:
        # | CefString(&self.cefCookie.name).FromString(name)
        # This does not work:
        # | cdef CefString cefString = CefString(&self.cefCookie.name)
        # | PyToCefString(name, cefString)
        # Because it's a Copy Constructor, it does not reference the
        # same underlying cef_string_t, instead it copies the value.
        # "T a(b)" - direct initialization (not supported by cython)
        # "T a = b" - copy initialization        
        # But this works:
        # | cdef CefString* cefString = new CefString(&self.cefCookie.name)
        # | PyToCefStringPointer(name, cefString)
        # | del cefString
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.name, False)
        PyToCefString(name, cefString)

    cpdef str GetName(self):
        cdef CefString cefString = CefString(&self.cefCookie.name)
        return CefToPyString(cefString)

    cpdef py_void SetValue(self, py_string value):
        CefString(&self.cefCookie.value).FromString(value)

    cpdef str GetValue(self):
        cdef CefString cefString = CefString(&self.cefCookie.value)
        return CefToPyString(cefString)

    cpdef py_void SetDomain(self, py_string domain):
        CefString(&self.cefCookie.domain).FromString(domain)

    cpdef str GetDomain(self):
        cdef CefString cefString = CefString(&self.cefCookie.domain)
        return CefToPyString(cefString)

    cpdef py_void SetPath(self, py_string path):
        CefString(&self.cefCookie.path).FromString(path)

    cpdef str GetPath(self):
        cdef CefString cefString = CefString(&self.cefCookie.path)
        return CefToPyString(cefString)

    cpdef py_void SetSecure(self, py_bool secure):
        self.cefCookie.secure = secure

    cpdef py_bool GetSecure(self):
        return self.cefCookie.secure

    cpdef py_void SetHttpOnly(self, py_bool httpOnly):
        self.cefCookie.httponly = httpOnly

    cpdef py_bool GetHttpOnly(self):
        return self.cefCookie.httponly

    cpdef py_void SetCreation(self, object creation):
        DatetimeToCefTimeT(creation, self.cefCookie.creation)

    cpdef object GetCreation(self):
        return CefTimeTToDatetime(self.cefCookie.creation)

    cpdef py_void SetLastAccess(self, object lastAccess):
        DatetimeToCefTimeT(lastAccess, self.cefCookie.last_access)

    cpdef object GetLastAccess(self):
        return CefTimeTToDatetime(self.cefCookie.last_access)

    cpdef py_void SetHasExpires(self, py_bool hasExpires):
        self.cefCookie.has_expires = hasExpires

    cpdef py_bool GetHasExpires(self):
        return self.cefCookie.has_expires

    cpdef py_void SetExpires(self, object expires):
        DatetimeToCefTimeT(expires, self.cefCookie.expires)

    cpdef object GetExpires(self):
        return CefTimeTToDatetime(self.cefCookie.expires)

# ------------------------------------------------------------------------------
# CookieManager
# ------------------------------------------------------------------------------

class CookieManager:
    pass

# ------------------------------------------------------------------------------
# PyCookieManager
# ------------------------------------------------------------------------------

cdef class PyCookieManager:
    pass

# ------------------------------------------------------------------------------
# PyCookieVisitor
# ------------------------------------------------------------------------------

cdef class PyCookieVisitor:
    pass
