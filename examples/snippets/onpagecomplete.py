"""
Execute custom Python code on a web page when all visible content is loaded.
Implements a custom "_OnPageComplete" event that fires after window.load and
a browser paint frame, ensuring content is fully rendered before notifying.
"""

from cefpython3 import cefpython as cef


def main():
    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so create the browser here rather than right after
        # cef.Initialize().
        browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                        window_title="_OnPageComplete event")
        handler = PageCompleteHandler(browser)
        browser.SetClientHandler(handler)
        bindings = cef.JavascriptBindings()
        bindings.SetFunction("LoadHandler_OnPageComplete",
                             handler["_OnPageComplete"])
        browser.SetJavascriptBindings(bindings)

    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized", on_context_initialized)
    cef.Initialize()
    cef.MessageLoop()
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
