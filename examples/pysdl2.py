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
              and put SDL2.dll in C:\Python27\ (where you've installed Python)
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
- Dragging with mouse not implemented
- Window size is fixed, cannot be resized

GUI controls:
  Due to SDL2's lack of GUI widgets there are no GUI controls
  for the user. However, as an exercise this example could
  be extended by create some simple SDL2 widgets. An example of
  widgets made using PySDL2 can be found as part of the Pi
  Entertainment System at:
  https://github.com/neilmunday/pes/blob/master/lib/pes/ui.py
"""

import argparse
import logging
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
    args = parser.parse_args()
    logLevel = logging.INFO
    if args.verbose:
        logLevel = logging.DEBUG
    logging.basicConfig(
        format='[%(filename)s %(levelname)s]: %(message)s',
        level=logLevel
    )
    logging.info("Using PySDL2 %s" % sdl2.__version__)
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
    # Mouse wheel fudge to enhance scrolling
    scrollEnhance = 40
    # desired frame rate
    frameRate = 100
    # Initialise CEF for offscreen rendering
    sys.excepthook = cef.ExceptHook
    switches = {
        # Tweaking OSR performance by setting the same Chromium flags
        # as in upstream cefclient (Issue #240).
        "disable-surfaces": "",
        "disable-gpu": "",
        "disable-gpu-compositing": "",
        "enable-begin-frame-scheduling": "",
    }
    browser_settings = {
        # Tweaking OSR performance (Issue #240)
        "windowless_frame_rate": frameRate
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
        0
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
    # Set-up the RenderHandler, passing in the SDL2 renderer
    renderHandler = RenderHandler(renderer, width, height - headerHeight)
    # Create the browser instance
    browser = cef.CreateBrowserSync(window_info,
                                    url="https://www.google.com/",
                                    settings=browser_settings)
    browser.SetClientHandler(LoadHandler())
    browser.SetClientHandler(renderHandler)
    # Must call WasResized at least once to let know CEF that
    # viewport size is available and that OnPaint may be called.
    browser.SendFocusEvent(True)
    browser.WasResized()

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
                running = False
                logging.debug("SDL2 QUIT event")
                break
            if event.type == sdl2.SDL_MOUSEBUTTONDOWN:
                if event.button.button == sdl2.SDL_BUTTON_LEFT:
                    if event.button.y > headerHeight:
                        logging.debug(
                            "SDL2 MOUSEBUTTONDOWN event (left button)"
                        )
                        # Mouse click triggered in browser region
                        browser.SendMouseClickEvent(
                            event.button.x,
                            event.button.y - headerHeight,
                            cef.MOUSEBUTTON_LEFT,
                            False,
                            1
                        )
            elif event.type == sdl2.SDL_MOUSEBUTTONUP:
                if event.button.button == sdl2.SDL_BUTTON_LEFT:
                    if event.button.y > headerHeight:
                        logging.debug("SDL2 MOUSEBUTTONUP event (left button)")
                        # Mouse click triggered in browser region
                        browser.SendMouseClickEvent(
                            event.button.x,
                            event.button.y - headerHeight,
                            cef.MOUSEBUTTON_LEFT,
                            True,
                            1
                        )
            elif event.type == sdl2.SDL_MOUSEMOTION:
                if event.motion.y > headerHeight:
                    # Mouse move triggered in browser region
                    browser.SendMouseMoveEvent(event.motion.x,
                                               event.motion.y - headerHeight,
                                               False)
            elif event.type == sdl2.SDL_MOUSEWHEEL:
                logging.debug("SDL2 MOUSEWHEEL event")
                # Mouse wheel event
                x = event.wheel.x
                if x < 0:
                    x -= scrollEnhance
                else:
                    x += scrollEnhance
                y = event.wheel.y
                if y < 0:
                    y -= scrollEnhance
                else:
                    y += scrollEnhance
                browser.SendMouseWheelEvent(0, 0, x, y)
            elif event.type == sdl2.SDL_TEXTINPUT:
                # Handle text events to get actual characters typed rather
                # than the key pressed.
                logging.debug("SDL2 TEXTINPUT event: %s" % event.text.text)
                keycode = ord(event.text.text)
                key_event = {
                    "type": cef.KEYEVENT_CHAR,
                    "windows_key_code": keycode,
                    "character": keycode,
                    "unmodified_character": keycode,
                    "modifiers": cef.EVENTFLAG_NONE
                }
                browser.SendKeyEvent(key_event)
                key_event = {
                    "type": cef.KEYEVENT_KEYUP,
                    "windows_key_code": keycode,
                    "character": keycode,
                    "unmodified_character": keycode,
                    "modifiers": cef.EVENTFLAG_NONE
                }
                browser.SendKeyEvent(key_event)
            elif event.type == sdl2.SDL_KEYDOWN:
                # Handle key down events for non-text keys
                logging.debug("SDL2 KEYDOWN event")
                if event.key.keysym.sym == sdl2.SDLK_RETURN:
                    keycode = event.key.keysym.sym
                    key_event = {
                        "type": cef.KEYEVENT_CHAR,
                        "windows_key_code": keycode,
                        "character": keycode,
                        "unmodified_character": keycode,
                        "modifiers": cef.EVENTFLAG_NONE
                    }
                    browser.SendKeyEvent(key_event)
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
                        browser.SendKeyEvent(key_event)
            elif event.type == sdl2.SDL_KEYUP:
                # Handle key up events for non-text keys
                logging.debug("SDL2 KEYUP event")
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
                        browser.SendKeyEvent(key_event)
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
        # Update display
        sdl2.SDL_RenderCopy(
            renderer,
            renderHandler.texture,
            None,
            sdl2.SDL_Rect(0, headerHeight, browserWidth, browserHeight)
        )
        sdl2.SDL_RenderPresent(renderer)
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


class RenderHandler(object):
    """
    Handler for rendering web pages to the
    screen via SDL2.

    The object's texture property is exposed
    to allow the main rendering loop to access
    the SDL2 texture.
    """

    def __init__(self, renderer, width, height):
        self.__width = width
        self.__height = height
        self.__renderer = renderer
        self.texture = None

    def GetViewRect(self, rect_out, **_):
        rect_out.extend([0, 0, self.__width, self.__height])
        return True

    def OnPaint(self, element_type, paint_buffer, **_):
        """
        Using the pixel data from CEF's offscreen rendering
        the data is converted by PIL into a SDL2 surface
        which can then be rendered as a SDL2 texture.
        """
        if element_type == cef.PET_VIEW:
            image = Image.frombuffer(
                'RGBA',
                (self.__width, self.__height),
                paint_buffer.GetString(mode="rgba", origin="top-left"),
                'raw',
                'BGRA'
            )
            # Following PIL to SDL2 surface code from pysdl2 source.
            mode = image.mode
            rmask = gmask = bmask = amask = 0
            depth = None
            pitch = None
            if mode == "RGB":
                # 3x8-bit, 24bpp
                if sdl2.endian.SDL_BYTEORDER == sdl2.endian.SDL_LIL_ENDIAN:
                    rmask = 0x0000FF
                    gmask = 0x00FF00
                    bmask = 0xFF0000
                else:
                    rmask = 0xFF0000
                    gmask = 0x00FF00
                    bmask = 0x0000FF
                depth = 24
                pitch = self.__width * 3
            elif mode in ("RGBA", "RGBX"):
                # RGBX: 4x8-bit, no alpha
                # RGBA: 4x8-bit, alpha
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
                pitch = self.__width * 4
            else:
                logging.error("ERROR: Unsupported mode: %s" % mode)
                exit_app()

            pxbuf = image.tobytes()
            # Create surface
            surface = sdl2.SDL_CreateRGBSurfaceFrom(
                pxbuf,
                self.__width,
                self.__height,
                depth,
                pitch,
                rmask,
                gmask,
                bmask,
                amask
            )
            if self.texture:
                # free memory used by previous texture
                sdl2.SDL_DestroyTexture(self.texture)
            # Create texture
            self.texture = sdl2.SDL_CreateTextureFromSurface(self.__renderer,
                                                             surface)
            # Free the surface
            sdl2.SDL_FreeSurface(surface)
        else:
            logging.warning("Unsupport element_type in OnPaint")


def exit_app():
    """Tidy up SDL2 and CEF before exiting."""
    sdl2.SDL_Quit()
    cef.Shutdown()
    logging.info("Exited gracefully")


if __name__ == "__main__":
    main()
