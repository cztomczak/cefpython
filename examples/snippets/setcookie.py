"""
Shows how to set a cookie.
"""

from cefpython3 import cefpython as cef
import datetime


def main():
    cef.Initialize()
    cef.CreateBrowserSync(
        url="http://www.html-kit.com/tools/cookietester/",
        window_title="Set a cookie")
    manager = cef.CookieManager.GetGlobalManager()
    cookie = cef.Cookie()
    cookie.Set({
        "name": "my_cookie",
        "value": "my_value",
        # Make sure domain is a valid value otherwise it crashes
        # app (Issue #459)
        "domain": "www.html-kit.com",
        "path": "/",
        "secure": False,
        "httpOnly": False,
        "creation": datetime.datetime(2018, 8, 22),
        "lastAccess": datetime.datetime(2018, 8, 22),
        "hasExpires": True,
        "expires": datetime.datetime(2028, 12, 31, 23, 59, 59),
    })
    manager.SetCookie("http://www.html-kit.com/", cookie)
    cef.MessageLoop()
    cef.Shutdown()


if __name__ == '__main__':
    main()
