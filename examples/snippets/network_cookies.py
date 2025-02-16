"""
Implement RequestHandler.CanSendCookie and CanSaveCookie
to block or allow cookies over network requests.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(
        url="http://www.html-kit.com/tools/cookietester/",
        window_title="Network cookies")
    browser.SetClientHandler(RequestHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class RequestHandler(object):
    def __init__(self):
        self.getcount = 0
        self.setcount = 0

    def CanSendCookie(self, browser, frame, request, cookie):
        # There are multiple iframes on that website, let's log
        # cookies only for the main frame.
        if frame.IsMain():
            self.getcount += 1
            print("-- CanSendCookie #"+str(self.getcount))
            print("url="+request.GetUrl()[0:80])
            print("")
        # Return True to allow reading cookies or False to block
        return True

    def CanSaveCookie(self, browser, frame, request, response, cookie):
        # There are multiple iframes on that website, let's log
        # cookies only for the main frame.
        if frame.IsMain():
            self.setcount += 1
            print("-- CanSaveCookie @"+str(self.setcount))
            print("url="+request.GetUrl()[0:80])
            print("Name="+cookie.GetName())
            print("Value="+cookie.GetValue())
            print("")
        # Return True to allow setting cookie or False to block
        return True


if __name__ == '__main__':
    main()