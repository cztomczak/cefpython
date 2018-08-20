"""
Execute custom Python code on a web page when page loading is complete.
Implements a custom "_OnPageComplete" event in the LoadHandler object.
"""

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_title="_OnPageComplete event")
    browser.SetClientHandler(LoadHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class LoadHandler(object):
    def OnLoadingStateChange(self, browser, is_loading, **_):
        """For detecting if page loading has ended it is recommended
        to use OnLoadingStateChange which is most reliable. The OnLoadEnd
        callback also available in LoadHandler can sometimes fail in
        some cases e.g. when image loading hangs."""
        if not is_loading:
            self._OnPageComplete(browser)

    def _OnPageComplete(self, browser):
        print("Page loading is complete!")
        browser.ExecuteFunction("alert", "Message from Python: Page loading"
                                         " is complete!")


if __name__ == '__main__':
    main()
