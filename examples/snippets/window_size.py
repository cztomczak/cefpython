"""
Set initial size of window to 900px / 640px without using
any third party GUI framework. On Linux/Mac you can set
window size by calling WindowInfo.SetAsChild. On Windows
you can accomplish this by calling Windows native functions
using the ctypes module.
"""

from cefpython3 import cefpython as cef
import platform


def main():
    cef.Initialize()
    window_info = cef.WindowInfo()
    window_info.SetAsChild(0, [0, 0, 900, 640])
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_info=window_info,
                                    window_title="Window size")
    if platform.system() == "Windows":
        pass
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class LifespanHandler(object):
    def OnBeforeClose(self, browser):
        print("Browser ID: {}".format(browser.GetIdentifier()))
        print("Browser will close and app will exit")


if __name__ == '__main__':
    main()
