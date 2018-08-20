"""
Execute custom Python code on a web page as soon as DOM is ready.
Implements a custom "_OnDomReady" event in the LifespanHandler object.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="_OnDomReady event")
    lifespan_handler = LifespanHandler(browser)
    browser.SetClientHandler(lifespan_handler)
    bindings = cef.JavascriptBindings()
    bindings.SetFunction("LifespanHandler_OnDomReady",
                         lifespan_handler["_OnDomReady"])
    browser.SetJavascriptBindings(bindings)
    cef.MessageLoop()
    del lifespan_handler
    del browser
    cef.Shutdown()


class LifespanHandler(object):
    def __init__(self, browser):
        self.browser = browser

    def __getitem__(self, key):
        return getattr(self, key)

    def OnLoadStart(self, browser, **_):
        browser.ExecuteJavascript("""
            if (document.readyState === "complete") {
                LifespanHandler_OnDomReady();
            } else {
                document.addEventListener("DOMContentLoaded", function() {
                    LifespanHandler_OnDomReady();
                });
            }
        """)

    def _OnDomReady(self):
        print("DOM is ready!")
        self.browser.ExecuteFunction("alert",
                                     "Message from Python: DOM is ready!")


if __name__ == '__main__':
    main()
