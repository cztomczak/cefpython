# Hello world example. Doesn't depend on any third party GUI framework.
# Tested with CEF Python v53.1+, only on Linux.

from cefpython3 import cefpython as cef
import sys


def main():
    print("[hello_world.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[hello_world.py] Python {ver}".format(ver=sys.version[:6]))
    assert cef.__version__ >= "53.1", "CEF Python v53.1+ required to run this"
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/")
    browser.SetClientHandler(ClientHandler())
    cef.MessageLoop()
    cef.Shutdown()


class ClientHandler(object):

    def OnBeforeClose(self, browser):
        """Called just before a browser is destroyed."""
        if not browser.IsPopup():
            # Exit app when main window is closed.
            cef.QuitMessageLoop()


if __name__ == '__main__':
    main()
