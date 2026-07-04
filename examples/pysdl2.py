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

Tested configurations:
- Windows 7: SDL 2.0.7 and PySDL2 0.9.6
- Mac 10.9: SDL 2.0.7 and PySDL2 0.9.6
- Fedora 26: SDL2 2.0.7 with PySDL2 0.9.6
- Ubuntu 14.04: SDL2 with PySDL2 0.9.6

Install instructions:
1. Install SDL libraries for your OS, e.g:
   - Windows: Download SDL2.dll from http://www.libsdl.org/download-2.0.php
              and put SDL2.dll in C:\\Python27\\ (where you've installed Python)
   - Mac: Install Homebrew from https://brew.sh/
          and then type "brew install sdl2"
   - Fedora: sudo dnf install SDL2 SDL2_ttf SDL2_image SDL2_gfx SDL2_mixer
   - Ubuntu: sudo apt-get install libsdl2-dev
2. Install PySDL2 using pip package manager:
   pip install PySDL2

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
import subprocess
import sys


def die(msg):
    """
    Helper function to exit application on failed imports etc.
    """
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

try:
    # noinspection PyUnresolvedReferences
    from PIL import Image
except ImportError:
    die("ERROR: PIL package not found\n"
        "       To install type: pip install Pillow")


if sys.platform == 'darwin':
    try:
        import AppKit
    except ImportError:
        die("ERROR: pyobjc package not found\n"
            "       To install type: pip install pyobjc")


# Under CEF's Chrome runtime the browser context initializes asynchronously,
# so the (off-screen) browser can only be created after OnContextInitialized
# has fired. This flag is set by the callback registered before
# cef.Initialize().
g_context_initialized = False


def _on_context_initialized():
    global g_context_initialized
    g_context_initialized = True


def main():
    """
    Parses input, initializes everything and then runs the main loop of the
    program, which handles input and draws the scene.
    """
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
    parser.add_argument(
        '--debug',
        help='debug app',
        action='store_true'
    )
    args = parser.parse_args()
    logLevel = logging.INFO
    if args.verbose:
        logLevel = logging.DEBUG
    logging.basicConfig(
        format='[%(filename)s %(levelname)s]: %(message)s',
        level=logLevel
    )
    logging.info("Using PySDL2 %s", sdl2.__version__)
    version = sdl2.SDL_version()
    sdl2.SDL_GetVersion(version)
    logging.info(
        "Using SDL2 %s.%s.%s" % (version.major, version.minor, version.patch)
    )
    # The following variables control the dimensions of the window
    # and browser display area
    width = 800
    height = 600
    # headerHeight is useful for leaving space for controls
    # at the top of the window (future implementation?)
    headerHeight = 0
    browserHeight = height - headerHeight
    browserWidth = width
    # CSS pixels per wheel unit. Used as a multiplier (not an adder) so that
    # smooth-scroll sub-pixel events scale proportionally and y=0 events send
    # nothing. Multiplied by deviceScaleFactor at event time so the perceived
    # scroll distance matches a native browser at any DPI.
    scrollEnhance = 40
    # desired frame rate
    frameRate = 100
    # On Wayland sessions prefer the native SDL Wayland backend over XWayland.
    # Must be done before cef.Initialize() because CEF clears WAYLAND_DISPLAY
    # from the process environment during its own Wayland/X11 negotiation.
    # With XWayland the compositor composites the SDL surface at 1/scale so
    # an 800x600 SDL window appears as 400x300 logical pixels and text looks
    # half the size of a native Wayland app.  The Wayland SDL backend exposes
    # the true physical pixel count via SDL_GetRendererOutputSize (with
    # SDL_WINDOW_ALLOW_HIGHDPI), so the CEF buffer maps 1:1 and matches Firefox.
    if os.environ.get("WAYLAND_DISPLAY") and not os.environ.get("SDL_VIDEODRIVER"):
        os.environ["SDL_VIDEODRIVER"] = "wayland"
        logging.info("Wayland session detected: using SDL Wayland backend")
    # Initialise CEF for offscreen rendering
    sys.excepthook = cef.ExceptHook
    switches = {
        # Tweaking OSR performance by setting the same Chromium flags
        # as in upstream cefclient (Issue #240).
        "disable-surfaces": "",
        "disable-gpu": "",
        "disable-gpu-compositing": "",
        "enable-begin-frame-scheduling": "",
        # Ensure popup windows (window.open / target=_blank) are always
        # allowed.  Real user clicks satisfy CEF's user-activation check
        # on their own; this flag keeps popups working for any programmatic
        # navigation that lacks a gesture token.
        "disable-popup-blocking": "",
    }
    browser_settings = {
        # Tweaking OSR performance (Issue #240)
        "windowless_frame_rate": frameRate
    }
    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized",
                                _on_context_initialized)
    cef.Initialize(settings={"windowless_rendering_enabled": True},
                   switches=switches)

    if sys.platform == 'darwin':
        # On MacOS, the NSApplication created in the cefpython initialization
        # will be hidden if windowless is specified. In order for SDL to receive
        # propper input events and for the application to show up in the
        # command-tab list, the application must be made "regular".
        AppKit.NSApplication.sharedApplication().setActivationPolicy_(
            AppKit.NSApplicationActivationPolicyRegular)
    logging.debug("cef initialised")
    window_info = cef.WindowInfo()
    window_info.SetAsOffscreen(0)
    # Initialise SDL2 for video (add other init constants if you
    # require other SDL2 functionality e.g. mixer,
    # TTF, joystick etc.
    sdl2.SDL_Init(sdl2.SDL_INIT_VIDEO)
    logging.debug("SDL2 initialised")
    # Create the window
    window = sdl2.video.SDL_CreateWindow(
        b'cefpython3 SDL2 Demo',
        sdl2.video.SDL_WINDOWPOS_UNDEFINED,
        sdl2.video.SDL_WINDOWPOS_UNDEFINED,
        width,
        height,
        sdl2.video.SDL_WINDOW_RESIZABLE | sdl2.video.SDL_WINDOW_ALLOW_HIGHDPI
    )
    # Define default background colour (black in this case)
    backgroundColour = sdl2.SDL_Color(0, 0, 0)
    renderer = None
    if args.renderer == 'hardware':
        # Create the renderer using hardware acceleration
        logging.info("Using hardware rendering")
        renderer = sdl2.SDL_CreateRenderer(
            window,
            -1,
            sdl2.render.SDL_RENDERER_ACCELERATED
        )
    else:
        # Create the renderer using software acceleration
        logging.info("Using software rendering")
        renderer = sdl2.SDL_CreateRenderer(
            window,
            -1,
            sdl2.render.SDL_RENDERER_SOFTWARE
        )
    def _renderer_output_size(renderer):
        """Return the SDL renderer output size in pixels."""
        out_w, out_h = ctypes.c_int(0), ctypes.c_int(0)
        sdl2.SDL_GetRendererOutputSize(renderer,
                                       ctypes.byref(out_w), ctypes.byref(out_h))
        return out_w.value, out_h.value

    def _detect_device_scale_factor(window, renderer):
        """
        Detect the device pixel ratio using a fallback chain:
          1. SDL renderer / window size ratio — works on Mac Retina and Wayland
             when SDL uses the native Wayland backend with SDL_WINDOW_ALLOW_HIGHDPI.
          2. GDK_SCALE env var — GNOME sets this for X11/XWayland sessions.
          3. Xft.dpi from xrdb — GNOME writes 96*scale here for XWayland clients
             even when GDK_SCALE is absent (e.g. Ubuntu with implicit scaling).
          4. Fall back to 1.0.
        """
        win_w, _win_h = ctypes.c_int(0), ctypes.c_int(0)
        sdl2.SDL_GetWindowSize(window, ctypes.byref(win_w), ctypes.byref(_win_h))
        out_w, _out_h = ctypes.c_int(0), ctypes.c_int(0)
        sdl2.SDL_GetRendererOutputSize(renderer,
                                       ctypes.byref(out_w), ctypes.byref(_out_h))
        if win_w.value > 0 and out_w.value != win_w.value:
            return out_w.value / win_w.value

        gdk = os.environ.get("GDK_SCALE", "")
        if gdk:
            try:
                return float(gdk)
            except ValueError:
                pass

        try:
            xrdb_out = subprocess.check_output(
                ["xrdb", "-query"], stderr=subprocess.DEVNULL, timeout=1
            )
            for line in xrdb_out.decode().splitlines():
                if line.lower().startswith("xft.dpi:"):
                    xft_dpi = float(line.split(":", 1)[1].strip())
                    # Round to nearest 0.25 to match GNOME fractional scaling steps.
                    return round(xft_dpi / 96.0 * 4) / 4
        except Exception:
            pass

        return 1.0

    deviceScaleFactor = _detect_device_scale_factor(window, renderer)
    physWidth, physHeight = _renderer_output_size(renderer)
    logging.info("Device scale factor: %.2f  physical: %dx%d",
                 deviceScaleFactor, physWidth, physHeight)
    rendererFlags = (sdl2.render.SDL_RENDERER_ACCELERATED
                     if args.renderer == 'hardware'
                     else sdl2.render.SDL_RENDERER_SOFTWARE)
    # MetaRenderHandler dispatches CEF rendering callbacks to per-browser
    # RenderHandler instances, creating SDL windows for popups lazily.
    renderHandler = MetaRenderHandler(renderer, width, height - headerHeight,
                                      deviceScaleFactor, rendererFlags)
    # Create the browser instance. Unlike the windowed examples (which embed
    # the browser from an event callback), this linear off-screen example
    # creates it inline, so ensure the CEF context has finished initializing
    # first. On most platforms it already has by this point (it initializes
    # during cef.Initialize()); otherwise let the message loop run until
    # OnContextInitialized fires.
    while not g_context_initialized:
        cef.MessageLoopWork()
    # Create the browser instance
    browser = cef.CreateBrowserSync(window_info,
                                    url="https://www.google.com/",
                                    settings=browser_settings)
    lifeSpanHandler = LifeSpanHandler(renderHandler)
    browser.SetClientHandler(LoadHandler())
    browser.SetClientHandler(lifeSpanHandler)
    browser.SetClientHandler(renderHandler)
    # Must call WasResized at least once to let know CEF that
    # viewport size is available and that OnPaint may be called.
    browser.SetFocus(True)
    browser.WasResized()

    main_wid = sdl2.SDL_GetWindowID(window)

    def _browser_for(wid):
        """Return (cef_browser, header_px) for an SDL window ID."""
        p = renderHandler.popups.get(wid)
        if p:
            return p["browser"], 0
        return browser, headerHeight

    # Begin the main rendering loop
    running = True
    # FPS debug variables
    frames = 0
    logging.debug("beginning rendering loop")
    resetFpsTime = True
    fpsTime = 0
    while running:
        # record when we started drawing this frame
        startTime = sdl2.timer.SDL_GetTicks()
        if resetFpsTime:
            fpsTime = sdl2.timer.SDL_GetTicks()
            resetFpsTime = False
        # Convert SDL2 events into CEF events (where appropriate)
        events = sdl2.ext.get_events()
        for event in events:
            if (event.type == sdl2.SDL_QUIT
                or (event.type == sdl2.SDL_KEYDOWN
                    and event.key.keysym.sym == sdl2.SDLK_ESCAPE)):
                logging.debug("SDL2 QUIT event")
                # Close all popup browsers so cef.Shutdown() is not blocked
                # by live popup instances — mirrors real-browser behaviour
                # where closing the main window closes all popups.
                for _bid, (_ph, _wid) in list(
                        renderHandler._popup_handlers.items()):
                    _pb = renderHandler.popups.get(_wid, {}).get("browser")
                    if _pb:
                        _pb.CloseBrowser(True)
                while renderHandler._popup_handlers:
                    cef.MessageLoopWork()
                    sdl2.SDL_Delay(10)
                running = False
                break
            if event.type == sdl2.SDL_MOUSEBUTTONDOWN:
                if event.button.button == sdl2.SDL_BUTTON_LEFT:
                    b, hh = _browser_for(event.button.windowID)
                    if event.button.y > hh:
                        logging.debug(
                            "SDL2 MOUSEBUTTONDOWN event (left button)"
                        )
                        b.SendMouseClickEvent(
                            event.button.x,
                            event.button.y - hh,
                            cef.MOUSEBUTTON_LEFT,
                            False,
                            1
                        )
            elif event.type == sdl2.SDL_MOUSEBUTTONUP:
                if event.button.button == sdl2.SDL_BUTTON_LEFT:
                    b, hh = _browser_for(event.button.windowID)
                    if event.button.y > hh:
                        logging.debug("SDL2 MOUSEBUTTONUP event (left button)")
                        b.SendMouseClickEvent(
                            event.button.x,
                            event.button.y - hh,
                            cef.MOUSEBUTTON_LEFT,
                            True,
                            1
                        )
            elif event.type == sdl2.SDL_MOUSEMOTION:
                b, hh = _browser_for(event.motion.windowID)
                if event.motion.y > hh:
                    modifiers = cef.EVENTFLAG_NONE
                    state = event.motion.state
                    if state & sdl2.SDL_BUTTON_LMASK:
                        modifiers |= cef.EVENTFLAG_LEFT_MOUSE_BUTTON
                    if state & sdl2.SDL_BUTTON_MMASK:
                        modifiers |= cef.EVENTFLAG_MIDDLE_MOUSE_BUTTON
                    if state & sdl2.SDL_BUTTON_RMASK:
                        modifiers |= cef.EVENTFLAG_RIGHT_MOUSE_BUTTON
                    b.SendMouseMoveEvent(event.motion.x,
                                         event.motion.y - hh,
                                         False,
                                         modifiers)
            elif event.type == sdl2.SDL_WINDOWEVENT:
                wid = event.window.windowID
                if wid == main_wid:
                    if event.window.event == sdl2.SDL_WINDOWEVENT_SIZE_CHANGED:
                        width = event.window.data1
                        height = event.window.data2
                        browserWidth = width
                        browserHeight = height - headerHeight
                        physWidth, physHeight = _renderer_output_size(renderer)
                        renderHandler._set_size(browserWidth, browserHeight)
                        browser.WasResized()
                        logging.debug(
                            "Main window resized to %dx%d (scale %.2f)",
                            width, height, deviceScaleFactor)
                    elif event.window.event == sdl2.SDL_WINDOWEVENT_CLOSE:
                        # With multiple windows open SDL sends WINDOWEVENT_CLOSE
                        # for the clicked window instead of SDL_QUIT.  Treat
                        # closing the main window as a full quit request.
                        logging.debug("Main window close button clicked")
                        for _bid, (_ph, _wid) in list(
                                renderHandler._popup_handlers.items()):
                            _pb = renderHandler.popups.get(_wid, {}).get(
                                "browser")
                            if _pb:
                                _pb.CloseBrowser(True)
                        while renderHandler._popup_handlers:
                            cef.MessageLoopWork()
                            sdl2.SDL_Delay(10)
                        running = False
                        break
                elif wid in renderHandler.popups:
                    p = renderHandler.popups[wid]
                    if event.window.event == sdl2.SDL_WINDOWEVENT_SIZE_CHANGED:
                        p["render_handler"]._set_size(
                            event.window.data1, event.window.data2)
                        p["browser"].WasResized()
                        logging.debug(
                            "Popup window %d resized to %dx%d",
                            wid, event.window.data1, event.window.data2)
                    elif event.window.event == sdl2.SDL_WINDOWEVENT_CLOSE:
                        p["browser"].CloseBrowser(True)
            elif event.type == sdl2.SDL_MOUSEWHEEL:
                logging.debug("SDL2 MOUSEWHEEL event")
                # Use sub-pixel precision when available (SDL >= 2.0.18).
                # Multiply by deviceScaleFactor: SendMouseWheelEvent takes
                # physical pixels, so at 2x a logical-unit delta must be
                # doubled to move the same apparent distance as in a native
                # browser.
                try:
                    dx = event.wheel.preciseX
                    dy = event.wheel.preciseY
                except AttributeError:
                    dx = float(event.wheel.x)
                    dy = float(event.wheel.y)
                scale = scrollEnhance * deviceScaleFactor
                b, _ = _browser_for(event.wheel.windowID)
                b.SendMouseWheelEvent(0, 0, int(dx * scale), int(dy * scale))
            elif event.type == sdl2.SDL_TEXTINPUT:
                # Handle text events to get actual characters typed rather
                # than the key pressed.
                logging.debug("SDL2 TEXTINPUT event: %s" % event.text.text)
                b, _ = _browser_for(event.text.windowID)
                keycode = ord(event.text.text)
                key_event = {
                    "type": cef.KEYEVENT_CHAR,
                    "windows_key_code": keycode,
                    "character": keycode,
                    "unmodified_character": keycode,
                    "modifiers": cef.EVENTFLAG_NONE
                }
                b.SendKeyEvent(key_event)
                key_event = {
                    "type": cef.KEYEVENT_KEYUP,
                    "windows_key_code": keycode,
                    "character": keycode,
                    "unmodified_character": keycode,
                    "modifiers": cef.EVENTFLAG_NONE
                }
                b.SendKeyEvent(key_event)
            elif event.type == sdl2.SDL_KEYDOWN:
                # Handle key down events for non-text keys
                logging.debug("SDL2 KEYDOWN event")
                b, _ = _browser_for(event.key.windowID)
                if event.key.keysym.sym == sdl2.SDLK_RETURN:
                    keycode = event.key.keysym.sym
                    key_event = {
                        "type": cef.KEYEVENT_CHAR,
                        "windows_key_code": keycode,
                        "character": keycode,
                        "unmodified_character": keycode,
                        "modifiers": cef.EVENTFLAG_NONE
                    }
                    b.SendKeyEvent(key_event)
                elif event.key.keysym.sym in [
                        sdl2.SDLK_BACKSPACE,
                        sdl2.SDLK_DELETE,
                        sdl2.SDLK_LEFT,
                        sdl2.SDLK_RIGHT,
                        sdl2.SDLK_UP,
                        sdl2.SDLK_DOWN,
                        sdl2.SDLK_HOME,
                        sdl2.SDLK_END
                ]:
                    keycode = get_key_code(event.key.keysym.sym)
                    if keycode is not None:
                        key_event = {
                            "type": cef.KEYEVENT_RAWKEYDOWN,
                            "windows_key_code": keycode,
                            "native_key_code": get_native_key(keycode),
                            # For raw key events, the character and unmodified
                            # character codes should be 0.
                            "character": 0,
                            "unmodified_character": 0,
                            "modifiers": cef.EVENTFLAG_NONE
                        }
                        b.SendKeyEvent(key_event)
            elif event.type == sdl2.SDL_KEYUP:
                # Handle key up events for non-text keys
                logging.debug("SDL2 KEYUP event")
                b, _ = _browser_for(event.key.windowID)
                if event.key.keysym.sym in [
                        sdl2.SDLK_RETURN,
                        sdl2.SDLK_BACKSPACE,
                        sdl2.SDLK_DELETE,
                        sdl2.SDLK_LEFT,
                        sdl2.SDLK_RIGHT,
                        sdl2.SDLK_UP,
                        sdl2.SDLK_DOWN,
                        sdl2.SDLK_HOME,
                        sdl2.SDLK_END
                ]:
                    keycode = get_key_code(event.key.keysym.sym)
                    if keycode is not None:
                        key_event = {
                            "type": cef.KEYEVENT_KEYUP,
                            "windows_key_code": keycode,
                            "native_key_code": get_native_key(keycode),
                            # On raw key up events, the character and unmodified
                            # character need to be defined, otherwise pressing
                            # one of the above-listed keys will eat the next
                            # normal keypress.
                            "character": keycode,
                            "unmodified_character": keycode,
                            "modifiers": cef.EVENTFLAG_NONE
                        }
                        b.SendKeyEvent(key_event)
        # Clear the renderer
        sdl2.SDL_SetRenderDrawColor(
            renderer,
            backgroundColour.r,
            backgroundColour.g,
            backgroundColour.b,
            255
        )
        sdl2.SDL_RenderClear(renderer)
        # Tell CEF to update which will trigger the OnPaint
        # method of the RenderHandler instance
        cef.MessageLoopWork()
        # Update display using physical pixel dimensions for the destination rect
        # so the texture fills the renderer output correctly on HiDPI displays.
        if renderHandler.texture:
            physHeaderHeight = int(headerHeight * deviceScaleFactor)
            sdl2.SDL_RenderCopy(
                renderer,
                renderHandler.texture,
                None,
                sdl2.SDL_Rect(0, physHeaderHeight,
                              physWidth, physHeight - physHeaderHeight)
            )
        # Composite in-page popup widgets (e.g. <select> dropdowns) on top.
        if (renderHandler._popup_visible
                and renderHandler._popup_texture
                and renderHandler._popup_rect):
            sdl2.SDL_RenderCopy(
                renderer,
                renderHandler._popup_texture,
                None,
                renderHandler._popup_rect,
            )
        sdl2.SDL_RenderPresent(renderer)
        # Render each popup window independently.
        for p in renderHandler.popups.values():
            out_w, out_h = ctypes.c_int(0), ctypes.c_int(0)
            sdl2.SDL_GetRendererOutputSize(
                p["renderer"], ctypes.byref(out_w), ctypes.byref(out_h))
            sdl2.SDL_SetRenderDrawColor(p["renderer"], 0, 0, 0, 255)
            sdl2.SDL_RenderClear(p["renderer"])
            rh = p["render_handler"]
            if rh.texture:
                sdl2.SDL_RenderCopy(
                    p["renderer"], rh.texture, None,
                    sdl2.SDL_Rect(0, 0, out_w.value, out_h.value))
            if rh._popup_visible and rh._popup_texture and rh._popup_rect:
                sdl2.SDL_RenderCopy(
                    p["renderer"], rh._popup_texture, None, rh._popup_rect)
            sdl2.SDL_RenderPresent(p["renderer"])
        # FPS debug code
        frames += 1
        if sdl2.timer.SDL_GetTicks() - fpsTime > 1000:
            logging.debug("FPS: %d" % frames)
            frames = 0
            resetFpsTime = True
        # regulate frame rate
        if sdl2.timer.SDL_GetTicks() - startTime < 1000.0 / frameRate:
            sdl2.timer.SDL_Delay(
                (1000 // frameRate) - (sdl2.timer.SDL_GetTicks() - startTime)
            )
    # User exited
    exit_app()


def get_key_code(key):
    """Helper function to convert SDL2 key codes to cef ones"""
    key_map = {
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
    if key in key_map:
        return key_map[key]
    # Key not mapped, raise exception
    logging.error(
        """
        Keyboard mapping incomplete: unsupported SDL key %d.
        See https://wiki.libsdl.org/SDLKeycodeLookup for mapping.
        """ % key
    )
    return None


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


def get_native_key(key):
    """
    Helper function for returning the correct native key map for the operating
    system.
    """
    if sys.platform == 'darwin':
        return MACOS_TRANSLATION_TABLE.get(key, key)

    return key


class LoadHandler(object):
    """Simple handler for loading URLs."""

    def OnLoadingStateChange(self, is_loading, **_):
        if not is_loading:
            logging.info("Page loading complete")

    def OnLoadError(self, frame, failed_url, **_):
        if not frame.IsMain():
            return
        logging.error("Failed to load %s" % failed_url)


class LifeSpanHandler(object):
    """Allow JS window.open() popup browsers and clean up on close.

    SDL window creation happens lazily inside MetaRenderHandler._handler_for
    on the first GetViewRect call, so no OnAfterCreated hook is needed
    (cefpython does not expose that callback).
    """

    def __init__(self, meta_render_handler):
        self._rh = meta_render_handler

    def OnBeforePopup(self, browser, frame, target_url, window_info_out, **_):
        # window_info_out is a list; append a WindowInfo to configure the popup.
        wi = cef.WindowInfo()
        wi.SetAsOffscreen(0)
        window_info_out.append(wi)
        logging.info("Popup requested: %s", target_url)
        return False  # allow; MetaRenderHandler creates the SDL window lazily

    def OnBeforeClose(self, browser, **_):
        if browser.IsPopup():
            self._rh._close_popup(browser)


class MetaRenderHandler(object):
    """Dispatches CEF rendering callbacks across the main and any popup browsers.

    cefpython routes all rendering callbacks (GetViewRect, OnPaint, …) through
    the single handler instance registered on the parent browser.  When a popup
    browser first contacts _handler_for(), its SDL window, renderer, and
    per-browser RenderHandler are created right there — no OnAfterCreated needed.

    self.popups is a dict of {SDL_window_id: popup_entry} where each entry is
    {"window", "renderer", "browser", "render_handler"}.  The event loop uses
    this dict to route input events and to render each popup window.
    """

    def __init__(self, main_renderer, width, height, device_scale_factor,
                 renderer_flags):
        self.__dsf = device_scale_factor
        self.__renderer_flags = renderer_flags
        self._main = RenderHandler(main_renderer, width, height, device_scale_factor)
        self._popup_handlers = {}   # browser_id -> (RenderHandler, wid)
        self.popups = {}            # SDL_window_id -> popup entry dict

    # -- Proxy the main browser's render state for the main event loop --------

    @property
    def texture(self):
        return self._main.texture

    @property
    def _popup_visible(self):
        return self._main._popup_visible

    @property
    def _popup_texture(self):
        return self._main._popup_texture

    @property
    def _popup_rect(self):
        return self._main._popup_rect

    def _set_size(self, width, height):
        self._main._set_size(width, height)

    # -- Per-browser dispatch --------------------------------------------------

    def _handler_for(self, browser):
        if not browser.IsPopup():
            return self._main
        bid = browser.GetIdentifier()
        if bid not in self._popup_handlers:
            popup_window = sdl2.video.SDL_CreateWindow(
                b'Popup',
                sdl2.video.SDL_WINDOWPOS_UNDEFINED,
                sdl2.video.SDL_WINDOWPOS_UNDEFINED,
                800, 600,
                sdl2.video.SDL_WINDOW_RESIZABLE | sdl2.video.SDL_WINDOW_ALLOW_HIGHDPI,
            )
            popup_renderer = sdl2.SDL_CreateRenderer(
                popup_window, -1, self.__renderer_flags)
            win_w, win_h = ctypes.c_int(0), ctypes.c_int(0)
            sdl2.SDL_GetWindowSize(
                popup_window, ctypes.byref(win_w), ctypes.byref(win_h))
            handler = RenderHandler(
                popup_renderer, win_w.value, win_h.value, self.__dsf)
            wid = sdl2.SDL_GetWindowID(popup_window)
            self._popup_handlers[bid] = (handler, wid)
            self.popups[wid] = {
                "window": popup_window,
                "renderer": popup_renderer,
                "browser": browser,
                "render_handler": handler,
            }
            logging.info("Popup SDL window %d created for browser %d", wid, bid)
        return self._popup_handlers[bid][0]

    def _close_popup(self, browser):
        bid = browser.GetIdentifier()
        entry = self._popup_handlers.pop(bid, None)
        if entry is None:
            return
        handler, wid = entry
        p = self.popups.pop(wid, {})
        if handler.texture:
            sdl2.SDL_DestroyTexture(handler.texture)
        if handler._popup_texture:
            sdl2.SDL_DestroyTexture(handler._popup_texture)
        sdl2.SDL_DestroyRenderer(p.get("renderer"))
        sdl2.SDL_DestroyWindow(p.get("window"))
        logging.info("Popup SDL window %d destroyed", wid)

    # -- CEF callbacks (dispatched to the right per-browser handler) ----------

    def GetScreenInfo(self, browser, screen_info_out, **_):
        return self._handler_for(browser).GetScreenInfo(browser, screen_info_out)

    def GetViewRect(self, browser, rect_out, **_):
        return self._handler_for(browser).GetViewRect(rect_out)

    def OnPopupShow(self, browser, show, **_):
        self._handler_for(browser).OnPopupShow(browser, show)

    def OnPopupSize(self, browser, rect, **_):
        self._handler_for(browser).OnPopupSize(browser, rect)

    def OnPaint(self, browser, element_type, paint_buffer, width, height, **_):
        self._handler_for(browser).OnPaint(element_type, paint_buffer, width, height)


class RenderHandler(object):
    """
    Handler for rendering web pages to the
    screen via SDL2.

    The object's texture property is exposed
    to allow the main rendering loop to access
    the SDL2 texture.
    """

    def __init__(self, renderer, width, height, device_scale_factor=1.0):
        self.__width = width
        self.__height = height
        self.__renderer = renderer
        self.__device_scale_factor = device_scale_factor
        self.texture = None
        self._popup_texture = None
        self._popup_rect = None
        self._popup_visible = False

    def _set_size(self, width, height):
        self.__width = width
        self.__height = height

    def _set_device_scale_factor(self, scale):
        self.__device_scale_factor = scale

    def OnPopupShow(self, browser, show, **_):
        self._popup_visible = show
        if not show and self._popup_texture:
            sdl2.SDL_DestroyTexture(self._popup_texture)
            self._popup_texture = None

    def OnPopupSize(self, browser, rect, **_):
        s = self.__device_scale_factor
        self._popup_rect = sdl2.SDL_Rect(
            int(rect.x * s), int(rect.y * s),
            int(rect.width * s), int(rect.height * s),
        )

    def GetScreenInfo(self, browser, screen_info_out, **_):
        screen_info_out["device_scale_factor"] = self.__device_scale_factor
        return True

    def GetViewRect(self, rect_out, **_):
        rect_out.extend([0, 0, self.__width, self.__height])
        return True

    def _paint_buffer_to_texture(self, paint_buffer, width, height):
        """Convert a CEF paint buffer to an SDL texture."""
        image = Image.frombuffer(
            'RGBA',
            (width, height),
            paint_buffer.GetString(mode="rgba", origin="top-left"),
            'raw',
            'BGRA'
        )
        mode = image.mode
        rmask = gmask = bmask = amask = 0
        if mode == "RGB":
            if sdl2.endian.SDL_BYTEORDER == sdl2.endian.SDL_LIL_ENDIAN:
                rmask = 0x0000FF
                gmask = 0x00FF00
                bmask = 0xFF0000
            else:
                rmask = 0xFF0000
                gmask = 0x00FF00
                bmask = 0x0000FF
            depth = 24
            pitch = width * 3
        elif mode in ("RGBA", "RGBX"):
            if sdl2.endian.SDL_BYTEORDER == sdl2.endian.SDL_LIL_ENDIAN:
                rmask = 0x00000000
                gmask = 0x0000FF00
                bmask = 0x00FF0000
                if mode == "RGBA":
                    amask = 0xFF000000
            else:
                rmask = 0xFF000000
                gmask = 0x00FF0000
                bmask = 0x0000FF00
                if mode == "RGBA":
                    amask = 0x000000FF
            depth = 32
            pitch = width * 4
        else:
            logging.error("ERROR: Unsupported mode: %s" % mode)
            exit_app()
        pxbuf = image.tobytes()
        surface = sdl2.SDL_CreateRGBSurfaceFrom(
            pxbuf, width, height, depth, pitch, rmask, gmask, bmask, amask
        )
        texture = sdl2.SDL_CreateTextureFromSurface(self.__renderer, surface)
        sdl2.SDL_FreeSurface(surface)
        return texture

    def OnPaint(self, element_type, paint_buffer, width, height, **_):
        """
        Using the pixel data from CEF's offscreen rendering
        the data is converted by PIL into a SDL2 surface
        which can then be rendered as a SDL2 texture.
        """
        if element_type == cef.PET_VIEW:
            if self.texture:
                sdl2.SDL_DestroyTexture(self.texture)
            self.texture = self._paint_buffer_to_texture(
                paint_buffer, width, height)
        elif element_type == cef.PET_POPUP:
            if self._popup_texture:
                sdl2.SDL_DestroyTexture(self._popup_texture)
            self._popup_texture = self._paint_buffer_to_texture(
                paint_buffer, width, height)
        else:
            logging.warning("Unsupported element_type in OnPaint")


def exit_app():
    """Tidy up SDL2 and CEF before exiting."""
    sdl2.SDL_Quit()
    cef.Shutdown()
    logging.info("Exited gracefully")


if __name__ == "__main__":
    main()
