"""
Shows how to set a cookie.
"""

from cefpython3 import cefpython as cef
import datetime


class LoadHandler(object):
    def OnLoadEnd(self, browser, frame, http_code, **_):
        if not frame.IsMain():
            return
        manager = cef.CookieManager.GetGlobalManager()
        cookie = cef.Cookie()
        cookie.Set({
            "name": "my_cookie",
            "value": "my_value",
            # Make sure domain is a valid value otherwise it crashes
            # app (Issue #459)
            "domain": ".google.com",
            "path": "/",
            "secure": True,
            "httpOnly": False,
            "creation": datetime.datetime(2018, 8, 22),
            "lastAccess": datetime.datetime(2018, 8, 22),
            "hasExpires": True,
            "expires": datetime.datetime(2028, 12, 31, 23, 59, 59),
        })
        manager.SetCookie("https://www.google.com/", cookie)
        print("Cookie set: my_cookie=my_value")

        # Delay so SetCookie (async on IO thread) completes before visiting
        cef.PostDelayedTask(cef.TID_UI, 200, visit_cookies)


def visit_cookies():
    manager = cef.CookieManager.GetGlobalManager()
    manager.VisitUrlCookies(
        "https://www.google.com/",
        False,
        CookieVisitor())


class CookieVisitor(object):
    def Visit(self, cookie, count, total, delete_cookie_out):
        print("Cookie[%d/%d]: %s=%s (domain=%s)" % (
            count + 1, total,
            cookie.Get("name"), cookie.Get("value"),
            cookie.Get("domain")))
        return True  # continue visiting


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(
        url="https://www.google.com/",
        window_title="Set a cookie")
    browser.SetClientHandler(LoadHandler())
    cef.MessageLoop()
    cef.Shutdown()


if __name__ == '__main__':
    main()
