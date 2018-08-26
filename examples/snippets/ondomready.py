"""
Execute custom Python code on a web page as soon as DOM is ready.
Implements a custom "_OnDomReady" event in the LoadHandler object.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="_OnDomReady event")
    load_handler = LoadHandler(browser)
    browser.SetClientHandler(load_handler)
    bindings = cef.JavascriptBindings()
    bindings.SetFunction("LoadHandler_OnDomReady",
                         load_handler["_OnDomReady"])
    browser.SetJavascriptBindings(bindings)
    cef.MessageLoop()
    del load_handler
    del browser
    cef.Shutdown()


class LoadHandler(object):
    def __init__(self, browser):
        self.browser = browser

    def __getitem__(self, key):
        return getattr(self, key)

    def OnLoadStart(self, browser, **_):
        browser.ExecuteJavascript("""
            if (document.readyState === "complete") {
                LoadHandler_OnDomReady();
            } else {
                document.addEventListener("DOMContentLoaded", function() {
                    LoadHandler_OnDomReady();
                });
            }
        """)

    def _OnDomReady(self):
        print("DOM is ready!")
        self.browser.ExecuteFunction("alert",
                                     "Message from Python: DOM is ready!")


if __name__ == '__main__':
    main()
