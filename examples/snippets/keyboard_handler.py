from cefpython3 import cefpython as cef


def main():
    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so create the browser here rather than right after
        # cef.Initialize().
        browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                        window_title="Keyboard Handler")
        browser.SetClientHandler(KeyboardHandler())

    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized", on_context_initialized)
    cef.Initialize()
    cef.MessageLoop()
    cef.Shutdown()


class KeyboardHandler(object):
    def OnKeyEvent(self, browser, event, event_handle,  **_):
        print("OnKeyEvent: "+str(event))

if __name__ == '__main__':
    main()
