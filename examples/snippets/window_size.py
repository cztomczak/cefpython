"""
Set initial window size without use of any third party
GUI framework, by passing the window rect to
WindowInfo.SetAsChild.
"""

from cefpython3 import cefpython as cef


def main():
    if not cef.Initialize():
        return
    window_info = cef.WindowInfo()
    parent_handle = 0
    # [left, top, right, bottom]. The size is that of the content
    # area. CEF or the window manager can still adjust the position.
    window_info.SetAsChild(parent_handle, [0, 0, 900, 640])
    browser = cef.CreateBrowserSync(url="https://www.google.com/",
                                    window_info=window_info,
                                    window_title="Window size")
    cef.MessageLoop()
    del browser
    cef.Shutdown()


if __name__ == '__main__':
    main()
