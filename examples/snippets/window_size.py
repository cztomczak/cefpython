"""
Set initial window size to 900/600 pixels without using
any third party GUI framework. On Linux/Mac you can set
window size by calling WindowInfo.SetAsChild. On Windows
you can accomplish this by calling Windows native functions
using the ctypes module.
"""

from cefpython3 import cefpython as cef
import ctypes
import platform


def main():
    cef.Initialize()
    window_info = cef.WindowInfo()
    parent_handle = 0
    # All rect coordinates are applied including X and Y parameters
    window_info.SetAsChild(parent_handle, [0, 0, 900, 640])
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_info=window_info,
                                    window_title="Window size")
    if platform.system() == "Windows":
        window_handle = browser.GetOuterWindowHandle()
        # X and Y parameters are ignored by setting the SWP_NOMOVE flag
        SWP_NOMOVE = 0x0002
        insert_after_handle = 0
        # noinspection PyUnresolvedReferences
        ctypes.windll.user32.SetWindowPos(window_handle, insert_after_handle,
                                          0, 0, 900, 640, SWP_NOMOVE)
    cef.MessageLoop()
    del browser
    cef.Shutdown()


class LifespanHandler(object):
    def OnBeforeClose(self, browser):
        print("Browser ID: {}".format(browser.GetIdentifier()))
        print("Browser will close and app will exit")


if __name__ == '__main__':
    main()
