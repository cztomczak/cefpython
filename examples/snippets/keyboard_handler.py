from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="Keyboard Handler")
    browser.SetClientHandler(KeyboardHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class KeyboardHandler(object):
    def OnKeyEvent(self, browser, event, event_handle,  **_):
        print("OnKeyEvent: "+str(event))

if __name__ == '__main__':
    main()
