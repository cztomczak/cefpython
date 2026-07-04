"""
Execute custom Python code on a web page as soon as DOM is ready.
Implements a custom "_OnDomReady" event using the OnContextCreated callback.
"""

from cefpython3 import cefpython as cef


def main():
    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so create the browser here rather than right after
        # cef.Initialize().
        browser = cef.CreateBrowserSync(url="https://example.com/",
                                        window_title="_OnDomReady event")
        handler = DomReadyHandler(browser)
        browser.SetClientHandler(handler)
        bindings = cef.JavascriptBindings()
        bindings.SetFunction("LoadHandler_OnDomReady",
                             handler["_OnDomReady"])
        browser.SetJavascriptBindings(bindings)

    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized", on_context_initialized)
    cef.Initialize()
    cef.MessageLoop()
    cef.Shutdown()


class DomReadyHandler(object):
    def __init__(self, browser):
        self.browser = browser

    def __getitem__(self, key):
        return getattr(self, key)

    def OnContextCreated(self, browser, frame, **_):
        if not frame.IsMain():
            return
        browser.ExecuteJavascript("""
            if (document.readyState === "complete"
                    || document.readyState === "interactive") {
                setTimeout(function(){ LoadHandler_OnDomReady(); }, 0);
            } else {
                document.addEventListener("DOMContentLoaded", function() {
                    setTimeout(function(){ LoadHandler_OnDomReady(); }, 0);
                });
            }
        """)

    def _OnDomReady(self):
        print("DOM is ready!")
        self.browser.ExecuteFunction("alert",
                                     "Message from Python: DOM is ready!")


if __name__ == '__main__':
    main()
