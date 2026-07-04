"""
Implement LifespanHandler.OnBeforeClose to execute custom
code before browser window closes.
"""

from cefpython3 import cefpython as cef


def main():
    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so create the browser here rather than right after
        # cef.Initialize().
        browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                        window_title="OnBeforeClose")
        browser.SetClientHandler(LifespanHandler())

    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized", on_context_initialized)
    cef.Initialize()
    cef.MessageLoop()
    cef.Shutdown()


class LifespanHandler(object):
    def OnBeforeClose(self, browser):
        print("Browser ID: {}".format(browser.GetIdentifier()))
        print("Browser will close and app will exit")


if __name__ == '__main__':
    main()
