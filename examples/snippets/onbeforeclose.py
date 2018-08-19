"""
Implement LifespanHandler.OnBeforeClose to execute custom
code before browser window closes.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="OnBeforeClose")
    browser.SetClientHandler(LifespanHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class LifespanHandler(object):
    def OnBeforeClose(self, browser):
        print("Browser ID: {}".format(browser.GetIdentifier()))
        print("Browser will close and app will exit")


if __name__ == '__main__':
    main()
