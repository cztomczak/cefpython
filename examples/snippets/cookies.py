"""Shows how to fetch all cookies, all cookies for
a given url and how to delete a specific cookie. For
an example on how to set a cookie see the 'setcookie.py'
snippet."""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(
        url="http://www.html-kit.com/tools/cookietester/",
        window_title="Cookies")
    browser.SetClientHandler(LoadHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class LoadHandler(object):
    def OnLoadingStateChange(self, browser, is_loading, **_):
        if is_loading:
            print("Page loading complete - start visiting cookies")
            manager = cef.CookieManager.GetGlobalManager()
            # Must keep a strong reference to the CookieVisitor object
            # while cookies are being visited.
            self.cookie_visitor = CookieVisitor()
            # Visit all cookies
            result = manager.VisitAllCookies(self.cookie_visitor)
            if not result:
                print("Error: could not access cookies")
            # To visit cookies only for a given url uncomment the
            # code below.
            """
            url = "http://www.html-kit.com/tools/cookietester/"
            http_only_cookies = False
            result = manager.VisitUrlCookies(url, http_only_cookies,
                                             self.cookie_visitor)
            if not result:
                print("Error: could not access cookies")
            """


class CookieVisitor(object):
    def Visit(self, cookie, count, total, delete_cookie_out):
        """This callback is called on the IO thread."""
        print("Cookie {count}/{total}: '{name}', '{value}'"
              .format(count=count+1, total=total, name=cookie.GetName(),
                      value=cookie.GetValue()))
        # Set a cookie named "delete_me" and it will be deleted.
        # You have to refresh page to see whether it succeeded.
        if cookie.GetName() == "delete_me":
            # 'delete_cookie_out' arg is a list passed by reference.
            # Set its '0' index to True to delete the cookie.
            delete_cookie_out[0] = True
            print("Deleted cookie: {name}".format(name=cookie.GetName()))
        # Return True to continue visiting more cookies
        return True


if __name__ == '__main__':
    main()
