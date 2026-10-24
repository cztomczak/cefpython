"""
Example of embedding CEF browser using PySDL2 library.

Requires PySDL2 and SDL2 libraries, see install instructions further
down.

This example is incomplete and has some issues, see the "Known issues"
section further down. Pull requests with fixes are welcome.

Usage:

    python pysdl2.py [-v] [-h] [-r {software|hardware}]

    -v  turn on debug messages
    -r  specify hardware (default) or software rendering
    -h  display help info

    Press Escape to quit.

Tested configurations:
- Ubuntu 26.04 (KDE Plasma 6.6, Wayland): SDL2 2.32.10 with PySDL2 0.9.17
- Windows 11: SDL2 2.32.10 with PySDL2 0.9.17

Install instructions:
1. Install PySDL2 using pip package manager:
   pip install PySDL2
2. Install SDL2 (not SDL3) libraries. The easiest way on Windows, Mac
   and Linux is the pysdl2-dll package:
   pip install pysdl2-dll
   Or install SDL2 for your OS, e.g:
   - Windows: Download SDL2.dll from
              https://github.com/libsdl-org/SDL/releases
              and put it next to python.exe
   - Mac: Install Homebrew from https://brew.sh/
          and then type "brew install sdl2"
   - Fedora: sudo dnf install SDL2 SDL2_ttf SDL2_image SDL2_gfx SDL2_mixer
   - Ubuntu: sudo apt-get install libsdl2-dev

Known issues (pull requests are welcome):
- There are issues when running on slow machine - key events are being
  lost (noticed on Mac only), see Issue #324 for more details
- Performance is still not perfect, see Issue #324 for further details
- Keyboard modifiers that are not yet handled in this example:
  ctrl, marking text inputs with the shift key.

GUI controls:
  Due to SDL2's lack of GUI widgets there are no GUI controls
  for the user. However, as an exercise this example could
  be extended by create some simple SDL2 widgets. An example of
  widgets made using PySDL2 can be found as part of the Pi
  Entertainment System at:
  https://github.com/neilmunday/pes/blob/master/lib/pes/ui.py
"""

import argparse
import ctypes
import logging
import os
import platform
import sys


def die(msg):
    """Print an error message and exit, e.g. on failed imports."""
    sys.stderr.write("%s\n" % msg)
    sys.exit(1)


try:
    # noinspection PyUnresolvedReferences
    from cefpython3 import cefpython as cef
except ImportError:
    die("ERROR: cefpython3 package not found\n"
        "       To install type: pip install cefpython3")

try:
    # noinspection PyUnresolvedReferences
    import sdl2
    # noinspection PyUnresolvedReferences
    import sdl2.ext
except ImportError as exc:
    excstr = repr(exc)
    if "No module named sdl2" in excstr:
        die("ERROR: PySDL2 package not found\n"
            "       To install type: pip install PySDL2")
    elif ("could not find any library for SDL2"
          " (PYSDL2_DLL_PATH: unset)" in excstr):
        die("ERROR: SDL2 package not found.\n"
            "       See install instructions in top comment in sources.")
    else:
        die(excstr)

if sys.platform == 'darwin':
    try:
        import AppKit
    except ImportError:
        die("ERROR: pyobjc package not found\n"
            "       To install type: pip install pyobjc")


# Config
URL = "https://www.google.com/"
WINDOW_SIZE = (800, 600)
FRAME_RATE = 100
# Mouse wheel scroll amount per step
SCROLL_STEP = 100


def main():
    """Initialize CEF and SDL2 and run the event loop until exit."""
    args = parse_args()
    logging.basicConfig(
        format='[%(filename)s %(levelname)s]: %(message)s',
        level=logging.DEBUG if args.verbose else logging.INFO
    )
    log_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    init_cef()
    init_sdl()
    logging.info("Using %s rendering", args.renderer)
    if args.renderer == 'hardware':
        renderer_flags = sdl2.SDL_RENDERER_ACCELERATED
    else:
        renderer_flags = sdl2.SDL_RENDERER_SOFTWARE
    windows = create_browser(renderer_flags)
    run_event_loop(windows)
    # User exited. Shutdown CEF before SDL2, because it closes any
    # remaining popup browsers, which destroys their SDL windows.
    cef.Shutdown()
    sdl2.SDL_Quit()
    logging.info("Exited gracefully")


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='PySDL2 / cefpython example',
        add_help=True
    )
    parser.add_argument(
        '-v',
        '--verbose',
        help='Turn on debug info',
        dest='verbose',
        action='store_true'
    )
    parser.add_argument(
        '-r',
        '--renderer',
        help='Specify hardware or software rendering',
        default='hardware',
        dest='renderer',
        choices=['software', 'hardware']
    )
    # The --debug flag is handled by cef.Initialize(), it only needs
    # to be accepted here. See docs/Knowledge-Base.md.
    parser.add_argument(
        '--debug',
        help='debug app',
        action='store_true'
    )
    return parser.parse_args()


def log_versions():
    """Log versions of CEF Python, Chromium, CEF, Python and SDL2."""
    ver = cef.GetVersion()
    logging.info("CEF Python %s", ver["version"])
    logging.info("Chromium %s", ver["chrome_version"])
    logging.info("CEF %s", ver["cef_version"])
    logging.info("Python %s %s", platform.python_version(),
                 platform.architecture()[0])
    logging.info("PySDL2 %s", sdl2.__version__)
    sdl_version = sdl2.SDL_version()
    sdl2.SDL_GetVersion(sdl_version)
    logging.info("SDL2 %s.%s.%s", sdl_version.major, sdl_version.minor,
                 sdl_version.patch)


def init_cef():
    """Initialize CEF for off-screen rendering."""
    switches = {
        # Tweaking OSR performance by setting the same Chromium flags
        # as in upstream cefclient (Issue #240).
        "disable-surfaces": "",
        "disable-gpu": "",
        "disable-gpu-compositing": "",
        "enable-begin-frame-scheduling": "",
    }
    cef.Initialize(settings={"windowless_rendering_enabled": True},
                   switches=switches)
    if sys.platform == 'darwin':
        # On MacOS, the NSApplication created in the cefpython initialization
        # will be hidden if windowless is specified. In order for SDL to receive
        # propper input events and for the application to show up in the
        # command-tab list, the application must be made "regular".
        AppKit.NSApplication.sharedApplication().setActivationPolicy_(
            AppKit.NSApplicationActivationPolicyRegular)


def init_sdl():
    """Initialize SDL2 for video."""
    # In Wayland sessions SDL2 uses XWayland by default, which doesn't
    # report the real pixel density of HiDPI displays. Use SDL's native
    # Wayland backend instead.
    if (os.environ.get("WAYLAND_DISPLAY")
            and not os.environ.get("SDL_VIDEODRIVER")):
        os.environ["SDL_VIDEODRIVER"] = "wayland"
    # On Windows SDL2 window sizes are in pixels by default, so the
    # device scale factor would always be 1.0. Make SDL2 use scaled
    # sizes, like on Mac and Wayland (requires SDL2 >= 2.24).
    sdl2.SDL_SetHint(sdl2.SDL_HINT_WINDOWS_DPI_SCALING, b"1")
    # Add other init constants if you require other SDL2
    # functionality e.g. mixer, TTF, joystick etc.
    check_sdl(sdl2.SDL_Init(sdl2.SDL_INIT_VIDEO) == 0, "SDL_Init")


def check_sdl(ok, function_name):
    """Raise an error with SDL's error message if a call failed."""
    if not ok:
        raise RuntimeError("%s failed: %s" % (
            function_name, sdl2.SDL_GetError().decode()))


def create_browser(renderer_flags):
    """Create the browser in an SDL window, return WindowManager."""
    window_info = cef.WindowInfo()
    window_info.SetAsOffscreen(0)
    browser = cef.CreateBrowserSync(window_info, url=URL, settings={
        # Tweaking OSR performance (Issue #240)
        "windowless_frame_rate": FRAME_RATE,
    })
    main_window = BrowserWindow(browser, b'cefpython3 SDL2 Demo',
                                renderer_flags)
    logging.info("Device scale factor: %.2f",
                 main_window.get_device_scale_factor())
    windows = WindowManager(main_window, renderer_flags)
    browser.SetClientHandler(LoadHandler())
    browser.SetClientHandler(LifespanHandler(windows))
    browser.SetClientHandler(RenderHandler(windows))
    # Must call WasResized at least once to let know CEF that
    # viewport size is available and that OnPaint may be called.
    browser.SetFocus(True)
    browser.WasResized()
    return windows


def run_event_loop(windows):
    """
    Run the event loop until the user quits.

    Each frame: send SDL2 input events to CEF, let CEF do its work
    (this is when RenderHandler.OnPaint gets called) and draw all
    windows.
    """
    frames = 0
    fps_time = sdl2.SDL_GetTicks()
    while True:
        # record when we started drawing this frame
        start_time = sdl2.SDL_GetTicks()
        for event in sdl2.ext.get_events():
            if is_quit_event(event, windows.main_window):
                return
            handle_event(event, windows)
        cef.MessageLoopWork()
        for window in windows.all_windows():
            window.update_available_rect()
            window.render()
        # FPS debug code
        frames += 1
        if sdl2.SDL_GetTicks() - fps_time > 1000:
            logging.debug("FPS: %d", frames)
            frames = 0
            fps_time = sdl2.SDL_GetTicks()
        # regulate frame rate
        frame_time = sdl2.SDL_GetTicks() - start_time
        if frame_time < 1000 // FRAME_RATE:
            sdl2.SDL_Delay(1000 // FRAME_RATE - frame_time)


def is_quit_event(event, main_window):
    """Return True for Escape key or closing of the main window."""
    if event.type == sdl2.SDL_QUIT:
        return True
    if event.type == sdl2.SDL_KEYDOWN:
        return event.key.keysym.sym == sdl2.SDLK_ESCAPE
    # While popup windows are open SDL sends WINDOWEVENT_CLOSE
    # for the closed window instead of SDL_QUIT.
    return (event.type == sdl2.SDL_WINDOWEVENT
            and event.window.event == sdl2.SDL_WINDOWEVENT_CLOSE
            and event.window.windowID == main_window.window_id)


def get_window_id(event):
    """Return the SDL window ID of an event, or None if it has none."""
    if event.type == sdl2.SDL_WINDOWEVENT:
        return event.window.windowID
    if event.type in (sdl2.SDL_MOUSEBUTTONDOWN, sdl2.SDL_MOUSEBUTTONUP):
        return event.button.windowID
    if event.type == sdl2.SDL_MOUSEMOTION:
        return event.motion.windowID
    if event.type == sdl2.SDL_MOUSEWHEEL:
        return event.wheel.windowID
    if event.type == sdl2.SDL_TEXTINPUT:
        return event.text.windowID
    if event.type in (sdl2.SDL_KEYDOWN, sdl2.SDL_KEYUP):
        return event.key.windowID
    return None


def handle_event(event, windows):
    """Convert an SDL2 event into a CEF event for the window's browser."""
    window = windows.find_window(get_window_id(event))
    if window is None:
        # Not handled, or the window was already closed. SDL keeps
        # queued events of a window after it was destroyed.
        return
    browser = window.browser
    if event.type == sdl2.SDL_WINDOWEVENT:
        if event.window.event == sdl2.SDL_WINDOWEVENT_SIZE_CHANGED:
            window.resized()
        elif event.window.event == sdl2.SDL_WINDOWEVENT_CLOSE:
            # A popup window was closed
            browser.CloseBrowser(True)
    elif event.type in (sdl2.SDL_MOUSEBUTTONDOWN, sdl2.SDL_MOUSEBUTTONUP):
        if event.button.button == sdl2.SDL_BUTTON_LEFT:
            browser.SendMouseClickEvent(
                event.button.x,
                event.button.y,
                cef.MOUSEBUTTON_LEFT,
                event.type == sdl2.SDL_MOUSEBUTTONUP,
                1
            )
    elif event.type == sdl2.SDL_MOUSEMOTION:
        browser.SendMouseMoveEvent(event.motion.x,
                                   event.motion.y,
                                   False,
                                   get_mouse_modifiers(event.motion.state))
    elif event.type == sdl2.SDL_MOUSEWHEEL:
        # preciseX/Y (SDL >= 2.0.18) are fractional for smooth scrolling
        dx = getattr(event.wheel, "preciseX", event.wheel.x)
        dy = getattr(event.wheel, "preciseY", event.wheel.y)
        browser.SendMouseWheelEvent(0, 0, int(dx * SCROLL_STEP),
                                    int(dy * SCROLL_STEP))
    elif event.type == sdl2.SDL_TEXTINPUT:
        # Handle text events to get actual characters typed rather
        # than the key pressed.
        text = event.text.text.decode("utf-8")
        for keycode in get_utf16_code_units(text):
            send_key_event(browser, cef.KEYEVENT_CHAR, keycode, keycode)
            send_key_event(browser, cef.KEYEVENT_KEYUP, keycode, keycode)
    elif event.type in (sdl2.SDL_KEYDOWN, sdl2.SDL_KEYUP):
        handle_key_event(event.key, browser)


def get_mouse_modifiers(button_state):
    """Return CEF flags for the held mouse buttons, for dragging."""
    modifiers = cef.EVENTFLAG_NONE
    if button_state & sdl2.SDL_BUTTON_LMASK:
        modifiers |= cef.EVENTFLAG_LEFT_MOUSE_BUTTON
    if button_state & sdl2.SDL_BUTTON_MMASK:
        modifiers |= cef.EVENTFLAG_MIDDLE_MOUSE_BUTTON
    if button_state & sdl2.SDL_BUTTON_RMASK:
        modifiers |= cef.EVENTFLAG_RIGHT_MOUSE_BUTTON
    return modifiers


def get_utf16_code_units(text):
    """
    Split text into UTF-16 code units.

    CEF key events take a single UTF-16 code unit as character, so
    e.g. an emoji is sent as two events.
    """
    data = text.encode("utf-16-le")
    return [int.from_bytes(data[i:i + 2], "little")
            for i in range(0, len(data), 2)]


# Windows key codes for the non-text keys handled in handle_key_event.
# See https://wiki.libsdl.org/SDLKeycodeLookup to map more keys.
KEY_CODES = {
    sdl2.SDLK_RETURN: 13,
    sdl2.SDLK_DELETE: 46,
    sdl2.SDLK_BACKSPACE: 8,
    sdl2.SDLK_LEFT: 37,
    sdl2.SDLK_RIGHT: 39,
    sdl2.SDLK_UP: 38,
    sdl2.SDLK_DOWN: 40,
    sdl2.SDLK_HOME: 36,
    sdl2.SDLK_END: 35,
}

# The key events on MacOS have different native keycode than on other operating
# systems. This table is a translation from Windows-keycodes to MacOS ones.
MACOS_TRANSLATION_TABLE = {
    # Backspace
    0x08: 0x33,

    # Left arrow
    0x25: 0x7B,
    # Up arrow
    0x26: 0x7E,
    # Right arrow
    0x27: 0x7C,
    # Down arrow
    0x28: 0x7D,
}


def handle_key_event(key_event, browser):
    """
    Handle key down and key up events for non-text keys.

    Text keys are handled with SDL_TEXTINPUT events in handle_event.
    """
    keycode = KEY_CODES.get(key_event.keysym.sym)
    if keycode is None:
        return
    if key_event.type == sdl2.SDL_KEYUP:
        # On raw key up events, the character and unmodified
        # character need to be defined, otherwise pressing
        # one of the above-listed keys will eat the next
        # normal keypress.
        send_key_event(browser, cef.KEYEVENT_KEYUP, keycode, keycode,
                       get_native_key(keycode))
    else:
        # For raw key events, the character and unmodified
        # character codes should be 0.
        send_key_event(browser, cef.KEYEVENT_RAWKEYDOWN, keycode, 0,
                       get_native_key(keycode))
        if key_event.keysym.sym == sdl2.SDLK_RETURN:
            # SDL sends no SDL_TEXTINPUT event for Enter. The char
            # event submits the form of a single-line input and
            # inserts a newline in a text area, unless the page
            # called preventDefault() on the key down event.
            send_key_event(browser, cef.KEYEVENT_CHAR, keycode, keycode)


def send_key_event(browser, event_type, keycode, character,
                   native_keycode=0):
    """Send a key event with no modifier keys to the browser."""
    browser.SendKeyEvent({
        "type": event_type,
        "windows_key_code": keycode,
        "native_key_code": native_keycode,
        "character": character,
        "unmodified_character": character,
        "modifiers": cef.EVENTFLAG_NONE
    })


def get_native_key(key):
    """
    Helper function for returning the correct native key map for the operating
    system.
    """
    if sys.platform == 'darwin':
        return MACOS_TRANSLATION_TABLE.get(key, key)

    return key


def destroy_texture(texture):
    """Destroy an SDL texture, if there is one."""
    if texture:
        sdl2.SDL_DestroyTexture(texture)


class BrowserWindow(object):
    """
    An SDL window showing one browser.

    Its textures are painted by CEF in RenderHandler.OnPaint.
    """

    def __init__(self, browser, title, renderer_flags):
        self.browser = browser
        self.window = sdl2.SDL_CreateWindow(
            title,
            sdl2.SDL_WINDOWPOS_UNDEFINED,
            sdl2.SDL_WINDOWPOS_UNDEFINED,
            WINDOW_SIZE[0],
            WINDOW_SIZE[1],
            sdl2.SDL_WINDOW_RESIZABLE | sdl2.SDL_WINDOW_ALLOW_HIGHDPI
        )
        check_sdl(self.window, "SDL_CreateWindow")
        self.renderer = sdl2.SDL_CreateRenderer(self.window, -1,
                                                renderer_flags)
        check_sdl(self.renderer, "SDL_CreateRenderer")
        self.window_id = sdl2.SDL_GetWindowID(self.window)
        # The web page
        self.texture = None
        # Popup widget drawn on top of the web page, e.g. a <select>
        # dropdown. Not to be confused with popup browser windows.
        self.popup_texture = None
        self.popup_rect = None
        # Screen area for popup widgets, see update_available_rect
        width, height = self.get_size()
        self.available_rect = [0, 0, width, height]
        self.resize_time = None

    def get_size(self):
        """Return the window size in screen coordinates (CEF view size)."""
        width, height = ctypes.c_int(), ctypes.c_int()
        sdl2.SDL_GetWindowSize(self.window,
                               ctypes.byref(width), ctypes.byref(height))
        return width.value, height.value

    def get_display_size(self):
        """Return the size of the display that the window is on."""
        bounds = sdl2.SDL_Rect()
        sdl2.SDL_GetDisplayBounds(sdl2.SDL_GetWindowDisplayIndex(self.window),
                                  ctypes.byref(bounds))
        return bounds.w, bounds.h

    def resized(self):
        """Tell CEF that the window size changed."""
        # RenderHandler.GetViewRect returns the new window size
        self.browser.WasResized()
        self.resize_time = sdl2.SDL_GetTicks()

    def update_available_rect(self):
        """
        Update the screen area available to popup widgets.

        Once resizing stopped for a moment, make the area match the window
        again, so that e.g. a <select> dropdown at the bottom of the window
        opens upwards. This is not done on every resize, because changing
        the screen info on every resize makes resizing complex pages slow.
        """
        if (self.resize_time is None
                or sdl2.SDL_GetTicks() - self.resize_time < 300):
            return
        self.resize_time = None
        width, height = self.get_size()
        self.available_rect = [0, 0, width, height]
        self.browser.NotifyScreenInfoChanged()

    def get_device_scale_factor(self):
        """Return pixels per screen coordinate, e.g. 2.0 on Retina."""
        pixel_width, pixel_height = ctypes.c_int(), ctypes.c_int()
        sdl2.SDL_GetRendererOutputSize(self.renderer,
                                       ctypes.byref(pixel_width),
                                       ctypes.byref(pixel_height))
        width, _ = self.get_size()
        if not width:
            return 1.0
        # With fractional scaling, e.g. 125%, the pixel size is rounded,
        # so the ratio varies a little with the window size. Round it to
        # a multiple of 1/120 (the unit of Wayland fractional scales),
        # because a scale factor that changes on every resize makes
        # resizing complex pages slow. The rounding doesn't change common
        # scales like 1.25, 1.5 or 2.0.
        return round(pixel_width.value / width * 120) / 120

    def paint(self, element_type, paint_buffer, width, height):
        """Copy pixels painted by CEF to the page or the popup texture."""
        # CEF paints in BGRA format, so pixels can be copied as they are
        texture = sdl2.SDL_CreateTexture(
            self.renderer,
            sdl2.SDL_PIXELFORMAT_BGRA32,
            sdl2.SDL_TEXTUREACCESS_STATIC,
            width,
            height
        )
        sdl2.SDL_UpdateTexture(texture, None, paint_buffer.GetPointer(),
                               width * 4)
        if element_type == cef.PET_VIEW:
            destroy_texture(self.texture)
            self.texture = texture
        else:
            destroy_texture(self.popup_texture)
            self.popup_texture = texture

    def hide_popup(self):
        """Stop drawing the popup widget."""
        destroy_texture(self.popup_texture)
        self.popup_texture = None
        self.popup_rect = None

    def render(self):
        """Draw the page and the popup widget to the window."""
        sdl2.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255)
        sdl2.SDL_RenderClear(self.renderer)
        if self.texture:
            # Stretch to the whole window
            sdl2.SDL_RenderCopy(self.renderer, self.texture, None, None)
        if self.popup_texture and self.popup_rect:
            sdl2.SDL_RenderCopy(self.renderer, self.popup_texture, None,
                                self.popup_rect)
        sdl2.SDL_RenderPresent(self.renderer)

    def close(self):
        """Destroy the window and its textures."""
        destroy_texture(self.texture)
        destroy_texture(self.popup_texture)
        sdl2.SDL_DestroyRenderer(self.renderer)
        sdl2.SDL_DestroyWindow(self.window)


class WindowManager(object):
    """
    Keep track of the main window and of popup windows.

    Popup windows are opened with window.open() or target=_blank links.
    """

    def __init__(self, main_window, renderer_flags):
        self.main_window = main_window
        self.popup_windows = {}  # browser identifier -> BrowserWindow
        self.renderer_flags = renderer_flags

    def all_windows(self):
        """Return the main window and all popup windows."""
        return [self.main_window] + list(self.popup_windows.values())

    def get_or_create_window(self, browser):
        """
        Return the window of a browser.

        The window of a popup browser is created the first time this is
        called for it, which happens when CEF first asks RenderHandler
        about the popup's view size.
        """
        if not browser.IsPopup():
            return self.main_window
        browser_id = browser.GetIdentifier()
        if browser_id not in self.popup_windows:
            self.popup_windows[browser_id] = BrowserWindow(
                browser, b'Popup', self.renderer_flags)
        return self.popup_windows[browser_id]

    def find_window(self, window_id):
        """
        Return the window with the given SDL window ID.

        If there is none, e.g. for events of a window that was just
        closed, return None.
        """
        for window in self.all_windows():
            if window.window_id == window_id:
                return window
        return None

    def close_popup(self, browser):
        """Close the window of a popup browser."""
        window = self.popup_windows.pop(browser.GetIdentifier(), None)
        if window:
            window.close()


class LoadHandler(object):
    """Simple handler for loading URLs."""

    def OnLoadingStateChange(self, is_loading, **_):
        if not is_loading:
            logging.info("Page loading complete")

    def OnLoadError(self, frame, failed_url, **_):
        if not frame.IsMain():
            return
        logging.error("Failed to load %s", failed_url)


class LifespanHandler(object):
    """Opens popup browsers in their own SDL windows."""

    def __init__(self, windows):
        self.windows = windows

    def OnBeforePopup(self, target_url, window_info_out, **_):
        # Popups use off-screen rendering too. Their SDL window
        # is created by WindowManager.get_or_create_window.
        window_info = cef.WindowInfo()
        window_info.SetAsOffscreen(0)
        window_info_out.append(window_info)
        logging.info("Opening popup: %s", target_url)
        return False  # Allow the popup

    def OnBeforeClose(self, browser, **_):
        if browser.IsPopup():
            self.windows.close_popup(browser)


class RenderHandler(object):
    """
    Handler for rendering web pages to the screen via SDL2.

    Popup browsers inherit client handlers from the browser that opened
    them, so this handler is called for all browsers. Each callback
    looks up the SDL window of the browser it was called for.
    """

    def __init__(self, windows):
        self.windows = windows

    def GetScreenInfo(self, browser, screen_info_out, **_):
        window = self.windows.get_or_create_window(browser)
        screen_info_out["device_scale_factor"] = \
            window.get_device_scale_factor()
        # Without a screen rect CEF would use the view rect, so the
        # screen info would change on every resize. This example doesn't
        # tell CEF where the window is, so the view is placed at the
        # top-left corner of the screen.
        width, height = window.get_display_size()
        screen_info_out["rect"] = [0, 0, width, height]
        screen_info_out["available_rect"] = window.available_rect
        return True

    def GetViewRect(self, browser, rect_out, **_):
        width, height = self.windows.get_or_create_window(browser).get_size()
        rect_out.extend([0, 0, width, height])
        return True

    def OnPopupShow(self, browser, show, **_):
        if not show:
            self.windows.get_or_create_window(browser).hide_popup()

    def OnPopupSize(self, browser, rect_out, **_):
        # The rect is in screen coordinates, the renderer uses pixels
        window = self.windows.get_or_create_window(browser)
        scale = window.get_device_scale_factor()
        x, y, width, height = [int(value * scale) for value in rect_out]
        window.popup_rect = sdl2.SDL_Rect(x, y, width, height)

    def OnPaint(self, browser, element_type, paint_buffer, width, height,
                **_):
        window = self.windows.get_or_create_window(browser)
        window.paint(element_type, paint_buffer, width, height)


if __name__ == "__main__":
    main()
