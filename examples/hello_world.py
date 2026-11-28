# Hello world example. Doesn't depend on any third party GUI framework.
# Tested with CEF Python v57.0+.

import sys

from cefpython3 import cefpython as cef
import platform


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # shut down all CEF processes on error
    settings = {}
    if not cef.Initialize(settings=settings):
        return 1
    cef.CreateBrowserSync(url="https://www.google.com/",
                          window_title="Hello World!")
    cef.MessageLoop()
    cef.Shutdown()


def check_versions():
    ver = cef.GetVersion()
    print("[hello_world.py] CEF Python {ver}".format(ver=ver["version"]))
    print("[hello_world.py] Chromium {ver}".format(ver=ver["chrome_version"]))
    print("[hello_world.py] CEF {ver}".format(ver=ver["cef_version"]))
    print("[hello_world.py] Python {ver} {arch}".format(
           ver=platform.python_version(),
           arch=platform.architecture()[0]))
    assert int(cef.__version__.split(".")[0]) >= 57, \
        "CEF Python v57.0+ required to run this"


if __name__ == '__main__':
    sys.exit(main())
