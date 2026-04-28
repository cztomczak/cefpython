# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

from task cimport *

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

#cdef Cookie cookie = Cookie()
#cookie.SetName("asd1")
#print("cookie.cefCookie: %s" % cookie.cefCookie)
#print("cookie.GetName(): %s" % cookie.GetName())
#print("cookie.GetCreation(): %s" % cookie.GetCreation())
#cookie.SetCreation(datetime.datetime(2013,5,23))
#print("cookie.GetCreation(): %s" % cookie.GetCreation())
#print("cookie: %s" % cookie.Get())

# ------------------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------------------

# noinspection PyUnresolvedReferences
cdef PyCookieManager g_globalCookieManager = None
# See StoreUserCookieVisitor().
import weakref
cdef object g_userCookieVisitors = weakref.WeakValueDictionary()
cdef int g_userCookieVisitorMaxId = 0

# ------------------------------------------------------------------------------
# Cookie
# ------------------------------------------------------------------------------

# noinspection PyUnresolvedReferences
ctypedef Cookie PyCookie

cdef PyCookie CreatePyCookie(CefCookie cefCookie):
    cdef PyCookie pyCookie = Cookie()
    pyCookie.cefCookie = cefCookie
    return pyCookie

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
            elif key == "sameSite":
                self.SetSameSite(cookie[key])
            elif key == "priority":
                self.SetPriority(cookie[key])
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
            "sameSite": self.GetSameSite(),
            "priority": self.GetPriority(),
        }

    cpdef py_void SetName(self, object name):
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
        # Solution: use Attach() method to pass reference to cef_string_t.
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.name, False)
        PyToCefString(name, cefString)

    cpdef str GetName(self):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.name, False)
        return CefToPyString(cefString)

    cpdef py_void SetValue(self, object value):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.value, False)
        PyToCefString(value, cefString)

    cpdef str GetValue(self):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.value, False)
        return CefToPyString(cefString)

    cpdef py_void SetDomain(self, object domain):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.domain, False)
        PyToCefString(domain, cefString)

    cpdef str GetDomain(self):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.domain, False)
        return CefToPyString(cefString)

    cpdef py_void SetPath(self, object path):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.path, False)
        PyToCefString(path, cefString)

    cpdef str GetPath(self):
        cdef CefString cefString
        cefString.Attach(&self.cefCookie.path, False)
        return CefToPyString(cefString)

    cpdef py_void SetSecure(self, py_bool secure):
        self.cefCookie.secure = int(bool(secure))

    cpdef py_bool GetSecure(self):
        return bool(self.cefCookie.secure)

    cpdef py_void SetHttpOnly(self, py_bool httpOnly):
        self.cefCookie.httponly = int(bool(httpOnly))

    cpdef py_bool GetHttpOnly(self):
        return bool(self.cefCookie.httponly)

    cpdef py_void SetCreation(self, object creation):
        DatetimeToCefBasetimeT(creation, self.cefCookie.creation)

    cpdef object GetCreation(self):
        return CefBasetimeTToDatetime(self.cefCookie.creation)

    cpdef py_void SetLastAccess(self, object lastAccess):
        DatetimeToCefBasetimeT(lastAccess, self.cefCookie.last_access)

    cpdef object GetLastAccess(self):
        return CefBasetimeTToDatetime(self.cefCookie.last_access)

    cpdef py_void SetHasExpires(self, py_bool hasExpires):
        self.cefCookie.has_expires = int(bool(hasExpires))

    cpdef py_bool GetHasExpires(self):
        return bool(self.cefCookie.has_expires)

    cpdef py_void SetExpires(self, object expires):
        DatetimeToCefBasetimeT(expires, self.cefCookie.expires)

    cpdef object GetExpires(self):
        return CefBasetimeTToDatetime(self.cefCookie.expires)

    cpdef int GetSameSite(self) except *:
        return self.cefCookie.same_site

    cpdef py_void SetSameSite(self, int sameSite):
        self.cefCookie.same_site = <cef_cookie_same_site_t>sameSite

    cpdef int GetPriority(self) except *:
        return self.cefCookie.priority

    cpdef py_void SetPriority(self, int priority):
        self.cefCookie.priority = <cef_cookie_priority_t>priority

# ------------------------------------------------------------------------------
# CookieManager
# ------------------------------------------------------------------------------

class CookieManager(object):
    """Class used for managing cookies. To instantiate this class
    call CreateManager() static method."""

    @classmethod
    def GetGlobalManager(cls):
        global g_globalCookieManager
        cdef CefRefPtr[CefCookieManager] cefCookieManager
        if not g_globalCookieManager:
            cefCookieManager = CefCookieManager_GetGlobalManager(
                    <CefRefPtr[CefCompletionCallback]?>nullptr)
            g_globalCookieManager = CreatePyCookieManager(cefCookieManager)
        return g_globalCookieManager

# ------------------------------------------------------------------------------
# PyCookieManager
# ------------------------------------------------------------------------------

cdef PyCookieManager CreatePyCookieManager(
        CefRefPtr[CefCookieManager] cefCookieManager):
    cdef PyCookieManager pyCookieManager = PyCookieManager()
    pyCookieManager.cefCookieManager = cefCookieManager
    return pyCookieManager

cdef class PyCookieManager:
    cdef CefRefPtr[CefCookieManager] cefCookieManager

    cdef py_void ValidateUserCookieVisitor(self, object userCookieVisitor):
        if userCookieVisitor and hasattr(userCookieVisitor, "Visit") and (
                callable(getattr(userCookieVisitor, "Visit"))):
            # OK.
            return
        raise Exception("CookieVisitor object is missing Visit() method")

    cpdef py_bool VisitAllCookies(self, object userCookieVisitor):
        self.ValidateUserCookieVisitor(userCookieVisitor)
        cdef int cookieVisitorId = StoreUserCookieVisitor(userCookieVisitor)
        cdef CefRefPtr[CefCookieVisitor] cefCookieVisitor = (
                <CefRefPtr[CefCookieVisitor]?>new CookieVisitor(
                        cookieVisitorId))
        return self.cefCookieManager.get().VisitAllCookies(
                cefCookieVisitor)

    cpdef py_bool VisitUrlCookies(self, object url, 
            py_bool includeHttpOnly, object userCookieVisitor):
        self.ValidateUserCookieVisitor(userCookieVisitor)
        cdef int cookieVisitorId = StoreUserCookieVisitor(userCookieVisitor)
        cdef CefRefPtr[CefCookieVisitor] cefCookieVisitor = (
                <CefRefPtr[CefCookieVisitor]?>new CookieVisitor(
                        cookieVisitorId))
        return self.cefCookieManager.get().VisitUrlCookies(
                PyToCefStringValue(url), bool(includeHttpOnly), 
                cefCookieVisitor)

    cpdef py_void SetCookie(self, object url, PyCookie cookie):
        assert isinstance(cookie, Cookie), "cookie object is invalid"
        CefPostTask(TID_IO, CreateTask_SetCookie(
                self.cefCookieManager.get(),
                PyToCefStringValue(url), cookie.cefCookie,
                <CefRefPtr[CefSetCookieCallback]?>nullptr))

    cpdef py_void DeleteCookies(self, object url, object cookie_name):
        CefPostTask(TID_IO, CreateTask_DeleteCookies(
                self.cefCookieManager.get(),
                PyToCefStringValue(url), PyToCefStringValue(cookie_name),
                <CefRefPtr[CefDeleteCookiesCallback]?>nullptr))

    cpdef py_bool FlushStore(self, callback=None):
        return self.cefCookieManager.get().FlushStore(
                <CefRefPtr[CefCompletionCallback]?>nullptr)


# ------------------------------------------------------------------------------
# PyCookieVisitor
# ------------------------------------------------------------------------------

cdef int StoreUserCookieVisitor(object userCookieVisitor) except *:
    global g_userCookieVisitorMaxId
    global g_userCookieVisitors
    g_userCookieVisitorMaxId += 1
    g_userCookieVisitors[g_userCookieVisitorMaxId] = userCookieVisitor
    return g_userCookieVisitorMaxId

cdef PyCookieVisitor GetPyCookieVisitor(int cookieVisitorId):
    global g_userCookieVisitors
    cdef object userCookieVisitor
    cdef PyCookieVisitor pyCookieVisitor
    if cookieVisitorId in g_userCookieVisitors:
        userCookieVisitor = g_userCookieVisitors[cookieVisitorId]
        pyCookieVisitor = PyCookieVisitor(userCookieVisitor)
        return pyCookieVisitor

cdef class PyCookieVisitor:
    cdef object userCookieVisitor

    def __init__(self, object userCookieVisitor):
        self.userCookieVisitor = userCookieVisitor

    cdef object GetCallback(self, str funcName):
        if self.userCookieVisitor and (
                hasattr(self.userCookieVisitor, funcName) and (
                callable(getattr(self.userCookieVisitor, funcName)))):
            return getattr(self.userCookieVisitor, funcName)

# ------------------------------------------------------------------------------
# C++ CookieVisitor
# ------------------------------------------------------------------------------

cdef public cpp_bool CookieVisitor_Visit(
        int cookieVisitorId,
        const CefCookie& cookie,
        int count,
        int total,
        cpp_bool& deleteCookie
        ) except * with gil:
    cdef PyCookieVisitor pyCookieVisitor
    cdef object callback
    cdef py_bool ret
    cdef PyCookie pyCookie
    cdef list pyDeleteCookie = [False]
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        pyCookieVisitor = GetPyCookieVisitor(cookieVisitorId)
        pyCookie = CreatePyCookie(cookie)
        if pyCookieVisitor:
            callback = pyCookieVisitor.GetCallback("Visit")
            if callback:
                ret = callback(
                        cookie=pyCookie,
                        count=count,
                        total=total,
                        delete_cookie_out=pyDeleteCookie)
                (&deleteCookie)[0] = bool(pyDeleteCookie[0])
                return bool(ret)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
