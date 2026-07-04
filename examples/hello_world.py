# Hello world example. Doesn't depend on any third party GUI framework.
# Tested with CEF Python v57.0+.
#
# ==== High DPI support on Windows ====
# To enable DPI awareness on Windows you have to either embed DPI aware manifest
# in your executable created with pyinstaller or change python.exe properties manually:
# Compatibility > High DPI scaling override > Application.
# Setting DPI awareness programmatically via a call to cef.DpiAware.EnableHighDpiSupport
# is problematic in Python, may not work and can cause display glitches.

import sys

from cefpython3 import cefpython as cef
import platform


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # shut down all CEF processes on error
    settings = {}

    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so the browser must be created from the
        # OnContextInitialized callback rather than immediately after
        # cef.Initialize(). This matches CEF's cefsimple sample.
        cef.CreateBrowserSync(url="https://www.google.com/",
                              window_title="Hello World!")

    # Register the callback before cef.Initialize(): OnContextInitialized can
    # fire during cef.Initialize() itself.
    cef.SetGlobalClientCallback("OnContextInitialized",
                                on_context_initialized)
    cef.Initialize(settings=settings)
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
    assert tuple(int(x) for x in cef.__version__.split(".")) >= (57, 0), \
        "CEF Python v57.0+ required to run this"


if __name__ == '__main__':
    main()
