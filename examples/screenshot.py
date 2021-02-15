"""
Example of using CEF browser in off-screen rendering mode
(windowless) to create a screenshot of a web page. This
example doesn't depend on any third party GUI framework.
This example is discussed in Tutorial in the Off-screen
rendering section.

Before running this script you have to install Pillow image
library (PIL module):

    pip install Pillow

With optionl arguments to this script you can resize viewport
so that screenshot includes whole page with height like 5000px
which would be an equivalent of scrolling down multiple pages.
By default when no arguments are provided will load cefpython
project page on Github with 5000px height.

Usage:
    python screenshot.py
    python screenshot.py https://github.com/cztomczak/cefpython 1024 5000
    python screenshot.py https://www.google.com/ncr 1024 768

Tested configurations:
- CEF Python v57.0+
- Pillow 2.3.0 / 4.1.0

NOTE: There are limits in Chromium on viewport size. For some
      websites with huge viewport size it won't work. In such
      case it is required to reduce viewport size to an usual
      size of a window and perform scrolling programmatically
      using javascript while making a screenshot for each of
      the scrolled region. Then at the end combine all the
      screenshots into one. To force a paint event in OSR
      mode call cef.Invalidate().
"""

from cefpython3 import cefpython as cef
import os
import platform
import subprocess
import sys

try:
    from PIL import Image, __version__ as PILLOW_VERSION
except ImportError:
    print("[screenshot.py] Error: PIL module not available. To install"
          " type: pip install Pillow")
    sys.exit(1)


# Config
URL = "https://github.com/cztomczak/cefpython"
VIEWPORT_SIZE = (1024, 5000)
SCREENSHOT_PATH = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                               "screenshot.png")


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    if os.path.exists(SCREENSHOT_PATH):
        print("[screenshot.py] Remove old screenshot")
        os.remove(SCREENSHOT_PATH)
    command_line_arguments()
    # Off-screen-rendering requires setting "windowless_rendering_enabled"
    # option.
    settings = {
        "windowless_rendering_enabled": True,
    }
    switches = {
        # GPU acceleration is not supported in OSR mode, so must disable
        # it using these Chromium switches (Issue #240 and #463)
        "disable-gpu": "",
        "disable-gpu-compositing": "",
        # Tweaking OSR performance by setting the same Chromium flags
        # as in upstream cefclient (Issue #240).
        "enable-begin-frame-scheduling": "",
        "disable-surfaces": "",  # This is required for PDF ext to work
    }
    browser_settings = {
        # Tweaking OSR performance (Issue #240)
        "windowless_frame_rate": 30,  # Default frame rate in CEF is 30
    }
    cef.Initialize(settings=settings, switches=switches)
    create_browser(browser_settings)
    cef.MessageLoop()
    cef.Shutdown()
    print("[screenshot.py] Opening screenshot with default application")
    open_with_default_application(SCREENSHOT_PATH)


def check_versions():
    ver = cef.GetVersion()
    print("[screenshot.py] CEF Python {ver}".format(ver=ver["version"]))
    print("[screenshot.py] Chromium {ver}".format(ver=ver["chrome_version"]))
    print("[screenshot.py] CEF {ver}".format(ver=ver["cef_version"]))
    print("[screenshot.py] Python {ver} {arch}".format(
           ver=platform.python_version(),
           arch=platform.architecture()[0]))
    print("[screenshot.py] Pillow {ver}".format(ver=PILLOW_VERSION))
    assert cef.__version__ >= "57.0", "CEF Python v57.0+ required to run this"


def command_line_arguments():
    if len(sys.argv) == 4:
        url = sys.argv[1]
        width = int(sys.argv[2])
        height = int(sys.argv[3])
        if url.startswith("http://") or url.startswith("https://"):
            global URL
            URL = url
        else:
            print("[screenshot.py] Error: Invalid url argument")
            sys.exit(1)
        if width > 0 and height > 0:
            global VIEWPORT_SIZE
            VIEWPORT_SIZE = (width, height)
        else:
            print("[screenshot.py] Error: Invalid width and height")
            sys.exit(1)

    elif len(sys.argv) > 1:
        print("[screenshot.py] Error: Expected arguments: url width height")
        sys.exit(1)


def create_browser(settings):
    # Create browser in off-screen-rendering mode (windowless mode)
    # by calling SetAsOffscreen method. In such mode parent window
    # handle can be NULL (0).
    parent_window_handle = 0
    window_info = cef.WindowInfo()
    window_info.SetAsOffscreen(parent_window_handle)
    print("[screenshot.py] Viewport size: {size}"
          .format(size=str(VIEWPORT_SIZE)))
    print("[screenshot.py] Loading url: {url}"
          .format(url=URL))
    browser = cef.CreateBrowserSync(window_info=window_info,
                                    settings=settings,
                                    url=URL)
    browser.SetClientHandler(LoadHandler())
    browser.SetClientHandler(RenderHandler())
    browser.SendFocusEvent(True)
    # You must call WasResized at least once to let know CEF that
    # viewport size is available and that OnPaint may be called.
    browser.WasResized()


def save_screenshot(browser):
    # Browser object provides GetUserData/SetUserData methods
    # for storing custom data associated with browser. The
    # "OnPaint.buffer_string" data is set in RenderHandler.OnPaint.
    buffer_string = browser.GetUserData("OnPaint.buffer_string")
    if not buffer_string:
        raise Exception("buffer_string is empty, OnPaint never called?")
    image = Image.frombytes("RGBA", VIEWPORT_SIZE, buffer_string,
                            "raw", "RGBA", 0, 1)
    image.save(SCREENSHOT_PATH, "PNG")
    print("[screenshot.py] Saved image: {path}".format(path=SCREENSHOT_PATH))
    # See comments in exit_app() why PostTask must be used
    cef.PostTask(cef.TID_UI, exit_app, browser)


def open_with_default_application(path):
    if sys.platform.startswith("darwin"):
        subprocess.call(("open", path))
    elif os.name == "nt":
        # noinspection PyUnresolvedReferences
        os.startfile(path)
    elif os.name == "posix":
        subprocess.call(("xdg-open", path))


def exit_app(browser):
    # Important note:
    #   Do not close browser nor exit app from OnLoadingStateChange
    #   OnLoadError or OnPaint events. Closing browser during these
    #   events may result in unexpected behavior. Use cef.PostTask
    #   function to call exit_app from these events.
    print("[screenshot.py] Close browser and exit app")
    browser.CloseBrowser()
    cef.QuitMessageLoop()


class LoadHandler(object):
    def OnLoadingStateChange(self, browser, is_loading, **_):
        """Called when the loading state has changed."""
        if not is_loading:
            # Loading is complete
            sys.stdout.write(os.linesep)
            print("[screenshot.py] Web page loading is complete")
            print("[screenshot.py] Will save screenshot in 2 seconds")
            # Give up to 2 seconds for the OnPaint call. Most of the time
            # it is already called, but sometimes it may be called later.
            cef.PostDelayedTask(cef.TID_UI, 2000, save_screenshot, browser)

    def OnLoadError(self, browser, frame, error_code, failed_url, **_):
        """Called when the resource load for a navigation fails
        or is canceled."""
        if not frame.IsMain():
            # We are interested only in loading main url.
            # Ignore any errors during loading of other frames.
            return
        print("[screenshot.py] ERROR: Failed to load url: {url}"
              .format(url=failed_url))
        print("[screenshot.py] Error code: {code}"
              .format(code=error_code))
        # See comments in exit_app() why PostTask must be used
        cef.PostTask(cef.TID_UI, exit_app, browser)


class RenderHandler(object):
    def __init__(self):
        self.OnPaint_called = False

    def GetViewRect(self, rect_out, **_):
        """Called to retrieve the view rectangle which is relative
        to screen coordinates. Return True if the rectangle was
        provided."""
        # rect_out --> [x, y, width, height]
        rect_out.extend([0, 0, VIEWPORT_SIZE[0], VIEWPORT_SIZE[1]])
        return True

    def OnPaint(self, browser, element_type, paint_buffer, **_):
        """Called when an element should be painted."""
        if self.OnPaint_called:
            sys.stdout.write(".")
            sys.stdout.flush()
        else:
            sys.stdout.write("[screenshot.py] OnPaint")
            self.OnPaint_called = True
        if element_type == cef.PET_VIEW:
            # Buffer string is a huge string, so for performance
            # reasons it would be better not to copy this string.
            # I think that Python makes a copy of that string when
            # passing it to SetUserData.
            buffer_string = paint_buffer.GetBytes(mode="rgba",
                                                  origin="top-left")
            # Browser object provides GetUserData/SetUserData methods
            # for storing custom data associated with browser.
            browser.SetUserData("OnPaint.buffer_string", buffer_string)
        else:
            raise Exception("Unsupported element_type in OnPaint")


if __name__ == '__main__':
    main()
