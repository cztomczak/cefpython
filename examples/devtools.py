"""
This script is a workaround for CEF Python Issue #381 which is causing
keyboard issues in DevTools window in the wxpython.py example.
A solution is to open devtools window in a seprate process by executing
this script. An example usage is in the wxpython.py example. See
also the "api/DevToolsHandler.md" document.
"""

from cefpython3 import cefpython as cef
import sys

DEVTOOLS_URL = sys.argv[1]


def main():
    print("[devtools.py] url={0}".format(DEVTOOLS_URL))
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    cef.CreateBrowserSync(url=DEVTOOLS_URL,
                          window_title="DevTools")
    cef.MessageLoop()
    cef.Shutdown()


if __name__ == '__main__':
    main()