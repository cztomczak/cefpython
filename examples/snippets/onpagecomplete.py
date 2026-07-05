"""
Execute custom Python code on a web page when all visible content is loaded.
Implements a custom "_OnPageComplete" event that fires after window.load and
a browser paint frame, ensuring content is fully rendered before notifying.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="_OnPageComplete event")
    handler = PageCompleteHandler(browser)
    browser.SetClientHandler(handler)
    bindings = cef.JavascriptBindings()
    bindings.SetFunction("LoadHandler_OnPageComplete",
                         handler["_OnPageComplete"])
    browser.SetJavascriptBindings(bindings)
    cef.MessageLoop()
    del handler
    del browser
    cef.Shutdown()


class PageCompleteHandler(object):
    def __init__(self, browser):
        self.browser = browser

    def __getitem__(self, key):
        return getattr(self, key)

    def OnContextCreated(self, browser, frame, **_):
        if not frame.IsMain():
            return
        browser.ExecuteJavascript("""
            window.addEventListener("load", function() {
                requestAnimationFrame(function() {
                    LoadHandler_OnPageComplete();
                });
            });
        """)

    def _OnPageComplete(self):
        print("Page loading is complete!")
        self.browser.ExecuteJavascript(
            'setTimeout(function(){'
            ' alert("Message from Python: Page loading is complete!");'
            ' }, 0);'
        )


if __name__ == '__main__':
    main()
