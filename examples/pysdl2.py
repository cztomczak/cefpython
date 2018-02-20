"""
Example of embedding CEF browser using PySDL2 library.

This example is incomplete, see "Missing functionality" section
further down. Pull requests for the missing functionality are welcome.

Requires PySDL2 and SDL2 libraries.
 
Tested configurations:
- Windows 7: SDL 2.0.7 and PySDL2 0.9.6
- Fedora 25: SDL2 2.0.5 with PySDL2 0.9.3
- Ubuntu 14.04: SDL2 with PySDL2 0.9.6

Install instructions:
1. Install SDL libraries for your OS, e.g:
   - Windows: Download SDL2.dll from http://www.libsdl.org/download-2.0.php
              and put SDL2.dll in C:\Python27\ (where you've installed Python)
   - Fedora: sudo dnf install SDL2 SDL2_ttf SDL2_image SDL2_gfx SDL2_mixer
   - Ubuntu: sudo apt-get install libsdl2-dev
2. Install PySDL2 using pip package manager:
   pip install PySDL2
 
Missing functionality:
- Performance is still not perfect, see Issue #324 for further details
- Keyboard modifiers that are not yet handled in this example:
  ctrl, marking text inputs with the shift key.
- Mouse dragging
- Window size is fixed, cannot be resized

GUI controls:
  Due to SDL2's lack of GUI widgets there are no GUI controls
  for the user. However, as an exercise this example could
  be extended by create some simple SDL2 widgets. An example of
  widgets made using PySDL2 can be found as part of the Pi
  Entertainment System at:
  https://github.com/neilmunday/pes/blob/master/lib/pes/ui.py
"""

import sys
try:
    # noinspection PyUnresolvedReferences
    from cefpython3 import cefpython as cef
except ImportError:
    print("ERROR: cefpython3 package not found")
    print("To install type: `pip install cefpython3`")
    sys.exit(1)
try:
    # noinspection PyUnresolvedReferences
    import sdl2
    # noinspection PyUnresolvedReferences
    import sdl2.ext
except ImportError:
    print("ERROR: SDL2 package not found")
    print("To install type: `pip install PySDL2`")
    sys.exit(1)
try:
    # noinspection PyUnresolvedReferences
    from PIL import Image
except ImportError:
    print("ERROR: PIL package not found")
    print("To install type: pip install Pillow")
    sys.exit(1)


def main():
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
        "windowless_frame_rate": 100
    }
    cef.Initialize(settings={"windowless_rendering_enabled": True},
                   switches=switches)
    window_info = cef.WindowInfo()
    window_info.SetAsOffscreen(0)
    # Initialise SDL2 for video (add other init constants if you
    # require other SDL2 functionality e.g. mixer,
    # TTF, joystick etc.
    sdl2.SDL_Init(sdl2.SDL_INIT_VIDEO)
    # Create the window
    window = sdl2.video.SDL_CreateWindow(
        'cefpython3 SDL2 Demo',
        sdl2.video.SDL_WINDOWPOS_UNDEFINED,
        sdl2.video.SDL_WINDOWPOS_UNDEFINED,
        width,
        height,
        0
    )
    # Define default background colour (black in this case)
    backgroundColour = sdl2.SDL_Color(0, 0, 0)
    # Create the renderer using hardware acceleration
    renderer = sdl2.SDL_CreateRenderer(window, -1,
                                       sdl2.render.SDL_RENDERER_ACCELERATED)
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
    while running:
        # Convert SDL2 events into CEF events (where appropriate)
        events = sdl2.ext.get_events()
        for event in events:
            if (event.type == sdl2.SDL_QUIT
                or (event.type == sdl2.SDL_KEYDOWN
                    and event.key.keysym.sym == sdl2.SDLK_ESCAPE)):
                running = False
                break
            if event.type == sdl2.SDL_MOUSEBUTTONDOWN:
                if event.button.button == sdl2.SDL_BUTTON_LEFT:
                    if event.button.y > headerHeight:
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
                            "character": keycode,
                            "unmodified_character": keycode,
                            "modifiers": cef.EVENTFLAG_NONE
                        }
                        browser.SendKeyEvent(key_event)
            elif event.type == sdl2.SDL_KEYUP:
                # Handle key up events for non-text keys
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
    print("[pysdl2.py] Keyboard mapping incomplete:"
          " unsupported SDL key %d."
          " See https://wiki.libsdl.org/SDLKeycodeLookup for mapping."
          % key)
    return None


class LoadHandler(object):
    """Simple handler for loading URLs."""
    
    def OnLoadingStateChange(self, is_loading, **_):
        if not is_loading:
            print("[pysdl2.py] Page loading complete")
            
    def OnLoadError(self, frame, failed_url, **_):
        if not frame.IsMain():
            return
        print("[pysdl2.py] Failed to load %s" % failed_url)


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
                print("[pysdl2.py] ERROR: Unsupported mode: %s" % mode)
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
            print("[pysdl2.py] WARNING: Unsupport element_type in OnPaint")


def exit_app():
    """Tidy up SDL2 and CEF before exiting."""
    sdl2.SDL_Quit()
    cef.Shutdown()
    print("[pysdl2.py] Exited gracefully")


if __name__ == "__main__":
    main()
