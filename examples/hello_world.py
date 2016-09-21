# Hello world example. Doesn't depend on any third party GUI framework.

from cefpython3 import cefpython as cef
import sys


def main():
    """Main entry point."""
    version_info()
    sys.excepthook = cef.ExceptHook
    cef.Initialize()
    browser = cef.CreateBrowserSync(url="https://www.google.com/")
    browser.SetClientHandler(ClientHandler())
    cef.MessageLoop()
    cef.Shutdown()


def version_info():
    print("CEF Python "+cef.__version__)
    print("Python "+sys.version[:6])


class ClientHandler:

    def OnBeforeClose(self, browser):
        """Called just before a browser is destroyed."""
        if not browser.IsPopup():
            # Exit app when main window is closed.
            cef.QuitMessageLoop()


if __name__ == '__main__':
    main()
