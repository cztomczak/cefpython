# An example of embedding CEF browser with the Kivy framework
# by using off-screen rendering mode.

# In this example kivy-lang is used to declare the layout which
# contains two buttons (back, forward) and the browser view.

from cefpython3 import cefpython as cef

import sys
import os
import time
if sys.platform == 'linux':
    import pygtk
    import gtk
    pygtk.require('2.0')
elif sys.platform == 'darwin':
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk
elif sys.platform == 'win32':
    # no gtk needed on Windows
    pass

from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.popup import Popup
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.graphics import Color, Rectangle
from kivy.clock import Clock
from kivy.graphics.texture import Texture
from kivy.uix.boxlayout import BoxLayout
from kivy.base import EventLoop

# Global variables
g_switches = None


class BrowserLayout(BoxLayout):

    def __init__(self, **kwargs):
        super(BrowserLayout, self).__init__(**kwargs)
        self.orientation = "vertical"

        self.browser_widget = CefBrowser()

        layout = BoxLayout()
        layout.size_hint_y = None
        layout.height = 40
        layout.add_widget(Button(text="Back",
                                 on_press=self.browser_widget.go_back))
        layout.add_widget(Button(text="Forward",
                                 on_press=self.browser_widget.go_forward))
        layout.add_widget(Button(text="Reload",
                                 on_press=self.browser_widget.reload))
        layout.add_widget(Button(text="Print",
                                 on_press=self.browser_widget.print_page))
        layout.add_widget(Button(text="DevTools",
                                 on_press=self.browser_widget.devtools))

        self.add_widget(layout)
        self.add_widget(self.browser_widget)


class CefBrowser(Widget):
    """Represent a browser widget for kivy, which can be used
    like a normal widget."""

    # Keyboard mode: "global" or "local".
    # 1. Global mode forwards keys to CEF all the time.
    # 2. Local mode forwards keys to CEF only when an editable
    #    control is focused (input type=text|password or textarea).
    keyboard_mode = "global"

    def __init__(self, start_url='https://www.google.com/', **kwargs):
        super(CefBrowser, self).__init__(**kwargs)

        for arg in sys.argv:
            if arg.startswith("http://") or arg.startswith("https://"):
                start_url = arg
        self.start_url = start_url

        # Workaround for flexible size:
        # start browser when the height has changed (done by layout)
        # This has to be done like this because I wasn't able to change
        # the texture size
        # until runtime without core-dump.
        # noinspection PyArgumentList
        self.bind(size=self.size_changed)

        self.browser = None

    starting = True

    def size_changed(self, *_):
        """When the height of the cefbrowser widget got changed,
        create the browser."""
        if self.starting:
            if self.height != 100:
                self.start_cef()
                self.starting = False
        else:
            # noinspection PyArgumentList
            self.texture = Texture.create(
                size=self.size, colorfmt='rgba', bufferfmt='ubyte')
            self.texture.flip_vertical()
            with self.canvas:
                Color(1, 1, 1)
                # This will cause segmentation fault:
                # | self.rect = Rectangle(size=self.size, texture=self.texture)
                # Update only the size:
                self.rect.size = self.size
            self.browser.WasResized()

    count = 0

    def _message_loop_work(self, *_):
        """Get called every frame."""
        self.count += 1
        # print(self.count)
        cef.MessageLoopWork()
        self.on_mouse_move_emulate()

        # From Kivy docs:
        # Clock.schedule_once(my_callback, 0) # call after the next frame
        # Clock.schedule_once(my_callback, -1) # call before the next frame

        # When scheduling "after the next frame" Kivy calls _message_loop_work
        # in about 13ms intervals. We use a small trick to make this 6ms
        # interval by scheduling it alternately before and after the next
        # frame. This gives better User Experience when scrolling.
        # See Issue #240 for more details on OSR performance.
        if self.count % 2 == 0:
            Clock.schedule_once(self._message_loop_work, 0)
        else:
            Clock.schedule_once(self._message_loop_work, -1)

    def update_rect(self, *_):
        """Get called whenever the texture got updated.
        => we need to reset the texture for the rectangle
        """
        self.rect.texture = self.texture

    def start_cef(self):
        """Starts CEF."""
        # create texture & add it to canvas
        # noinspection PyArgumentList
        self.texture = Texture.create(
                size=self.size, colorfmt='rgba', bufferfmt='ubyte')
        self.texture.flip_vertical()
        with self.canvas:
            Color(1, 1, 1)
            self.rect = Rectangle(size=self.size, texture=self.texture)

        # Configure CEF
        settings = {
            "browser_subprocess_path": "%s/%s" % (
                cef.GetModuleDirectory(), "subprocess"),
            "windowless_rendering_enabled": True,
            "context_menu": {
                # Disable context menu, popup widgets not supported
                "enabled": False,
            },
            "external_message_pump": False,  # See Issue #246
            "multi_threaded_message_loop": False,
        }
        if sys.platform == 'linux':
            # This directories must be set on Linux
            settings["locales_dir_path"] = cef.GetModuleDirectory() + "/locales"
            settings["resources_dir_path"] = cef.GetModuleDirectory()
        if sys.platform == 'darwin':
            settings["external_message_pump"] = True  # Temporary fix for Issue #246

        switches = {
            # Tweaking OSR performance by setting the same Chromium flags
            # as in upstream cefclient (# Issue #240).
            "disable-surfaces": "",
            "disable-gpu": "",
            "disable-gpu-compositing": "",
            "enable-begin-frame-scheduling": "",
        }
        browserSettings = {
            # Tweaking OSR performance (Issue #240)
            "windowless_frame_rate": 60
        }

        # Initialize CEF

        # To shutdown all CEF processes on error
        sys.excepthook = cef.ExceptHook

        # noinspection PyArgumentList
        cef.WindowUtils.InstallX11ErrorHandlers()

        global g_switches
        g_switches = switches
        cef.Initialize(settings, switches)

        # Start idle - CEF message loop work.
        Clock.schedule_once(self._message_loop_work, 0)

        windowInfo = cef.WindowInfo()

        # TODO: For printing to work in off-screen-rendering mode
        #       it is enough to call gtk_init(). It is not required
        #       to provide window handle when calling SetAsOffscreen().
        #       However it still needs to be tested whether providing
        #       window handle is required for mouse context menu and
        #       popup widgets to work.
        # WindowInfo offscreen flag
        if sys.platform == 'linux':
            gtkwin = gtk.Window()
            gtkwin.realize()
            windowInfo.SetAsOffscreen(gtkwin.window.xid)
        elif sys.platform == 'darwin' or sys.platform == 'win32':
            windowInfo.SetAsOffscreen(0)

        # Create Broswer and naviagte to empty page <= OnPaint won't get
        # called yet
        # The render handler callbacks are not yet set, thus an
        # error report will be thrown in the console (when release
        # DCHECKS are enabled), however don't worry, it is harmless.
        # This is happening because calling GetViewRect will return
        # false. That's why it is initially navigating to "about:blank".
        # Later, a real url will be loaded using the LoadUrl() method
        # and the GetViewRect will be called again. This time the render
        # handler callbacks will be available, it will work fine from
        # this point.
        # --
        # Do not use "about:blank" as navigateUrl - this will cause
        # the GoBack() and GoForward() methods to not work.
        #
        self.browser = cef.CreateBrowserSync(
                windowInfo,
                browserSettings,
                navigateUrl=self.start_url)

        # Set focus
        self.browser.SendFocusEvent(True)

        self._client_handler = ClientHandler(self)
        self.browser.SetClientHandler(self._client_handler)
        self.set_js_bindings()

        # Call WasResized() => force cef to call GetViewRect() and OnPaint
        # afterwards
        self.browser.WasResized()

        # The browserWidget instance is required in OnLoadingStateChange().
        self.browser.SetUserData("browserWidget", self)

        if self.keyboard_mode == "global":
            self.request_keyboard()

        # Clock.schedule_once(self.change_url, 5)

    _client_handler = None
    _js_bindings = None

    def set_js_bindings(self):
        if not self._js_bindings:
            self._js_bindings = cef.JavascriptBindings(
                bindToFrames=True, bindToPopups=True)
            self._js_bindings.SetFunction("__kivy__request_keyboard",
                                          self.request_keyboard)
            self._js_bindings.SetFunction("__kivy__release_keyboard",
                                          self.release_keyboard)
        self.browser.SetJavascriptBindings(self._js_bindings)

    def change_url(self, *_):
        # Doing a javascript redirect instead of Navigate()
        # solves the js bindings error. The url here need to
        # be preceded with "http://". Calling StopLoad()
        # might be a good idea before making the js navigation.

        self.browser.StopLoad()
        self.browser.GetMainFrame().ExecuteJavascript(
               "window.location='http://www.youtube.com/'")

        # Do not use Navigate() or GetMainFrame()->LoadURL(),
        # as it causes the js bindings to be removed. There is
        # a bug in CEF, that happens after a call to Navigate().
        # The OnBrowserDestroyed() callback is fired and causes
        # the js bindings to be removed. See this topic for more
        # details:
        # http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=11009

        # OFF:
        # | self.browser.Navigate("http://www.youtube.com/")

    _keyboard = None

    def request_keyboard(self):
        print("[kivy_.py] request_keyboard()")
        self._keyboard = EventLoop.window.request_keyboard(
                self.release_keyboard, self)
        self._keyboard.bind(on_key_down=self.on_key_down)
        self._keyboard.bind(on_key_up=self.on_key_up)
        self.is_shift1 = False
        self.is_shift2 = False
        self.is_ctrl1 = False
        self.is_ctrl2 = False
        self.is_alt1 = False
        self.is_alt2 = False
        # Not sure if it is still required to send the focus
        # (some earlier bug), but it shouldn't hurt to call it.
        self.browser.SendFocusEvent(True)

    def release_keyboard(self):
        # When using local keyboard mode, do all the request
        # and releases of the keyboard through js bindings,
        # otherwise some focus problems arise.
        self.is_shift1 = False
        self.is_shift2 = False
        self.is_ctrl1 = False
        self.is_ctrl2 = False
        self.is_alt1 = False
        self.is_alt2 = False
        if not self._keyboard:
            return
        print("[kivy_.py] release_keyboard()")
        self._keyboard.unbind(on_key_down=self.on_key_down)
        self._keyboard.unbind(on_key_up=self.on_key_up)
        self._keyboard.release()

    # Kivy does not provide modifiers in on_key_up, but these
    # must be sent to CEF as well.
    is_shift1 = False
    is_shift2 = False
    is_ctrl1 = False
    is_ctrl2 = False
    is_alt1 = False
    is_alt2 = False

    def on_key_down(self, _, key, text, modifiers):
        # NOTE: Right alt modifier is not sent by Kivy through modifiers param.
        # print("---- on_key_down")
        # print("-- key="+str(key))
        # print(text) - utf-8 char
        # print("-- modifiers="+str(modifiers))
        if text:
            # print("-- ord(text)="+str(ord(text)))
            pass

        # CEF key event type:
        #   KEYEVENT_RAWKEYDOWN = 0
        #   KEYEVENT_KEYDOWN = 1
        #   KEYEVENT_KEYUP = 2
        #   KEYEVENT_CHAR = 3

        # Kivy code -1 is a special key eg. Change keyboard layout.
        # Sending it to CEF would crash it.
        if key[0] == -1:
            return

        # On escape release the keyboard, see the injected in OnLoadStart()
        if key[0] == 27:
            self.browser.GetFocusedFrame().ExecuteJavascript(
                    "__kivy__on_escape()")
            return

        # CEF modifiers
        # When pressing ctrl also set modifiers for ctrl
        if key[0] in (306, 305):
            modifiers.append('ctrl')
        cef_modifiers = cef.EVENTFLAG_NONE
        if "shift" in modifiers:
            cef_modifiers |= cef.EVENTFLAG_SHIFT_DOWN
        if "ctrl" in modifiers:
            cef_modifiers |= cef.EVENTFLAG_CONTROL_DOWN
        if "alt" in modifiers:
            cef_modifiers |= cef.EVENTFLAG_ALT_DOWN
        if "capslock" in modifiers:
            cef_modifiers |= cef.EVENTFLAG_CAPS_LOCK_ON

        keycode = self.get_windows_key_code(key[0])
        charcode = key[0]
        if text:
            charcode = ord(text)

        # Send key event to cef: RAWKEYDOWN
        keyEvent = {
                "type": cef.KEYEVENT_RAWKEYDOWN,
                "windows_key_code": keycode,
                "character": charcode,
                "unmodified_character": charcode,
                "modifiers": cef_modifiers,
        }
        # print("- SendKeyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)

        # Send key event to cef: CHAR
        if text:
            keyEvent = {
                    "type": cef.KEYEVENT_CHAR,
                    "windows_key_code": keycode,
                    "character": charcode,
                    "unmodified_character": charcode,
                    "modifiers": cef_modifiers
            }
            # print("- SendKeyEvent: %s" % keyEvent)
            self.browser.SendKeyEvent(keyEvent)

        if key[0] == 304:
            self.is_shift1 = True
        elif key[0] == 303:
            self.is_shift2 = True
        elif key[0] == 306:
            self.is_ctrl1 = True
        elif key[0] == 305:
            self.is_ctrl2 = True
        elif key[0] == 308:
            self.is_alt1 = True
        elif key[0] == 313:
            self.is_alt2 = True

    def on_key_up(self, _, key):
        # print("---- on_key_up")
        # print("-- key="+str(key))

        # Kivy code -1 is a special key eg. Change keyboard layout.
        # Sending it to CEF would crash it.
        if key[0] == -1:
            return

        # CEF modifiers
        cef_modifiers = cef.EVENTFLAG_NONE
        if self.is_shift1 or self.is_shift2:
            cef_modifiers |= cef.EVENTFLAG_SHIFT_DOWN
        if self.is_ctrl1 or self.is_ctrl2:
            cef_modifiers |= cef.EVENTFLAG_CONTROL_DOWN
        if self.is_alt1:
            cef_modifiers |= cef.EVENTFLAG_ALT_DOWN

        keycode = self.get_windows_key_code(key[0])
        charcode = key[0]

        # Send key event to cef: KEYUP
        keyEvent = {
                "type": cef.KEYEVENT_KEYUP,
                "windows_key_code": keycode,
                "character": charcode,
                "unmodified_character": charcode,
                "modifiers": cef_modifiers
        }
        # print("- SendKeyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)

        if key[0] == 304:
            self.is_shift1 = False
        elif key[0] == 303:
            self.is_shift2 = False
        elif key[0] == 306:
            self.is_ctrl1 = False
        elif key[0] == 305:
            self.is_ctrl2 = False
        elif key[0] == 308:
            self.is_alt1 = False
        elif key[0] == 313:
            self.is_alt2 = False

    def get_windows_key_code(self, kivycode):
        cefcode = kivycode

        # NOTES:
        # - Map on all platforms to OnPreKeyEvent.event["windows_key_code"]
        # - Mapping all keys was not necessary on Linux, for example
        #   'comma' worked fine, while 'dot' did not, but mapping all keys
        #   to make sure it will work correctly on all platforms.
        # - If some key mapping is missing launch wxpython.py and see
        #   OnPreKeyEvent info for key events and replacate it here.
        #   (key codes can also be found on MSDN Virtual-key codes page)

        # Must map basic letters, otherwise eg. ctrl+a to select all
        # text won't work. (97-122 kivy <> 65-90 cef)
        if 97 <= kivycode <= 122:
            cefcode = kivycode - 32

        other_keys_map = {
            # Escape
            "27": 27,
            # F1-F12
            "282": 112, "283": 113, "284": 114, "285": 115,
            "286": 116, "287": 117, "288": 118, "289": 119,
            "290": 120, "291": 121, "292": 122, "293": 123,
            # Tab
            "9": 9,
            # Left Shift, Right Shift
            "304": 16, "303": 16,
            # Left Ctrl, Right Ctrl
            "306": 17, "305": 17,
            # Left Alt, Right Alt
            # TODO: left alt is_system_key=True in CEF but only when RAWKEYDOWN
            "308": 18, "313": 225,
            # Backspace
            "8": 8,
            # Enter
            "13": 13,
            # PrScr, ScrLck, Pause
            "316": 42, "302": 145, "19": 19,
            # Insert, Delete,
            # Home, End,
            # Pgup, Pgdn
            "277": 45, "127": 46,
            "278": 36, "279": 35,
            "280": 33, "281": 34,
            # Arrows (left, up, right, down)
            "276": 37, "273": 38, "275": 39, "274": 40,
            # tilde
            "96": 192,
            # minus, plus
            "45": 189, "61": 187,
            # square brackets / curly brackets, backslash
            "91": 219, "93": 221, "92": 220,
            # windows key
            "311": 91,
            # colon / semicolon
            "59": 186,
            # single quote / double quote
            "39": 222,
            # comma, dot, slash
            "44": 188, "46": 190, "47": 91,
            # context menu key is 93, but disable as it crashes app after
            # context menu is shown.
            "319": 0,
        }
        if str(kivycode) in other_keys_map:
            cefcode = other_keys_map[str(kivycode)]

        return cefcode

    def go_forward(self, *_):
        """Going to forward in browser history."""
        print("go forward")
        self.browser.GoForward()

    def go_back(self, *_):
        """Going back in browser history."""
        print("go back")
        self.browser.GoBack()

    def reload(self, *_):
        self.browser.Reload()

    def print_page(self, *_):
        self.browser.Print()

    def devtools(self, *_):
        # ShowDevTools doesn't work with the 'enable-begin-frame-scheduling'
        # switch. This might be fixed by implementing native popup widgets,
        # see Issue #69. The solution for now is to remove that switch,
        # but this will impact performance.
        if "enable-begin-frame-scheduling" in g_switches:
            text = ("To enable DevTools you need to remove the\n"
                    "'enable-begin-frame-scheduling' switch that\n"
                    "is passed to cef.Initialize(). See also\n"
                    "comment in CefBrowser.devtools().")
            popup = Popup(title='DevTools INFO', content=Label(text=text),
                          size_hint=(None, None), size=(400, 400))
            popup.open()

        else:
            self.browser.ShowDevTools()

    is_mouse_down = False
    is_drag = False
    is_drag_leave = False  # Mouse leaves web view
    drag_data = None
    current_drag_operation = cef.DRAG_OPERATION_NONE

    def on_touch_down(self, touch, *kwargs):
        # Mouse scrolling
        if "button" in touch.profile:
            if touch.button in ["scrollup", "scrolldown"]:
                # Handled in on_touch_up()
                return

        if not self.collide_point(*touch.pos):
            return
        touch.grab(self)

        y = self.height-touch.pos[1]
        if touch.is_double_tap:
            # is_double_tap seems not to work in Kivy 1.7.
            # Context menu is currently disabled see
            # settings["context_menu"] in cef_start().
            self.browser.SendMouseClickEvent(
                touch.x, y, cef.MOUSEBUTTON_RIGHT,
                mouseUp=False, clickCount=1
            )
            self.browser.SendMouseClickEvent(
                touch.x, y, cef.MOUSEBUTTON_RIGHT,
                mouseUp=True, clickCount=1
            )
        else:
            self.browser.SendMouseClickEvent(touch.x, y,
                                             cef.MOUSEBUTTON_LEFT,
                                             mouseUp=False, clickCount=1)
            self.is_mouse_down = True

    def on_touch_up(self, touch, *kwargs):
        # Mouse scrolling
        if "button" in touch.profile:
            if touch.button in ["scrollup", "scrolldown"]:
                x = touch.x
                y = self.height-touch.pos[1]
                deltaY = -40 if "scrollup" == touch.button else 40
                self.browser.SendMouseWheelEvent(x, y, deltaX=0, deltaY=deltaY)
                return

        if touch.grab_current is not self:
            return

        y = self.height-touch.pos[1]
        self.browser.SendMouseClickEvent(touch.x, y, cef.MOUSEBUTTON_LEFT,
                                         mouseUp=True, clickCount=1)
        self.is_mouse_down = False

        if self.is_drag:
            # print("on_touch_up=%s/%s" % (touch.x,y))
            if self.is_drag_leave or not self.is_inside_web_view(touch.x, y):
                # See comment in is_inside_web_view() - x/y at borders
                # should be treated as outside of web view.
                x = touch.x
                if x == 0:
                    x = -1
                if x == self.width-1:
                    x = self.width
                if y == 0:
                    y = -1
                if y == self.height-1:
                    y = self.height
                print("[kivy_.py] ~~ DragSourceEndedAt")
                print("[kivy_.py] ~~ current_drag_operation=%s"
                      % self.current_drag_operation)
                self.browser.DragSourceEndedAt(x, y,
                                               self.current_drag_operation)
                self.drag_ended()
            else:
                print("[kivy_.py] ~~ DragTargetDrop")
                print("[kivy_.py] ~~ DragSourceEndedAt")
                print("[kivy_.py] ~~ current_drag_operation=%s"
                      % self.current_drag_operation)
                self.browser.DragTargetDrop(touch.x, y)
                self.browser.DragSourceEndedAt(touch.x, y,
                                               self.current_drag_operation)
                self.drag_ended()

        touch.ungrab(self)

    last_mouse_pos = None

    def on_mouse_move_emulate(self):
        if not hasattr(self.get_root_window(), "mouse_pos"):
            # Not all Kivy window providers have the "mouse_pos" attribute.
            # WindowPygame does have (kivy/kivy#325).
            return
        mouse_pos = self.get_root_window().mouse_pos
        if self.last_mouse_pos == mouse_pos:
            return
        self.last_mouse_pos = mouse_pos
        # Fix mouse pos: realy = 0, kivy y = 600 / realy = 600, kivy y = 0
        x = mouse_pos[0]
        y = int(mouse_pos[1]-self.height)
        if x >= 0 >= y:
            y = abs(y)
            if not self.is_mouse_down and not self.is_drag:
                # When mouse is down on_touch_move will be called. Calling
                # mouse move event here caused issues with drag&drop.
                self.browser.SendMouseMoveEvent(x, y, mouseLeave=False)

    def on_touch_move(self, touch, *kwargs):
        if touch.grab_current is not self:
            return

        y = self.height-touch.pos[1]

        modifiers = cef.EVENTFLAG_LEFT_MOUSE_BUTTON
        self.browser.SendMouseMoveEvent(touch.x, y, mouseLeave=False,
                                        modifiers=modifiers)
        if self.is_drag:
            # print("on_touch_move=%s/%s" % (touch.x, y))
            if self.is_inside_web_view(touch.x, y):
                if self.is_drag_leave:
                    print("[kivy_.py] ~~ DragTargetDragEnter")
                    self.browser.DragTargetDragEnter(
                            self.drag_data, touch.x, y,
                            cef.DRAG_OPERATION_EVERY)
                    self.is_drag_leave = False
                print("[kivy_.py] ~~ DragTargetDragOver")
                self.browser.DragTargetDragOver(
                        touch.x, y, cef.DRAG_OPERATION_EVERY)
                self.update_drag_icon(touch.x, y)
            else:
                if not self.is_drag_leave:
                    self.is_drag_leave = True
                    print("[kivy_.py] ~~ DragTargetDragLeave")
                    self.browser.DragTargetDragLeave()

    def is_inside_web_view(self, x, y):
        # When mouse is out of app window Kivy still generates move events
        # at the borders with x=0, x=width-1, y=0, y=height-1.
        if (0 < x < self.width-1) and (0 < y < self.height-1):
            return True
        return False

    def drag_ended(self):
        # Either success or cancelled.
        self.is_drag = False
        self.is_drag_leave = False
        del self.drag_data
        self.current_drag_operation = cef.DRAG_OPERATION_NONE
        self.update_drag_icon(None, None)
        print("[kivy_.py] ~~ DragSourceSystemDragEnded")
        self.browser.DragSourceSystemDragEnded()

    drag_icon = None

    def update_drag_icon(self, x, y):
        if self.is_drag:
            if self.drag_icon:
                self.drag_icon.pos = self.flip_pos_vertical(x, y)
            else:
                image = self.drag_data.GetImage()
                width = image.GetWidth()
                height = image.GetHeight()
                abuffer = image.GetAsBitmap(
                        1.0,
                        cef.CEF_COLOR_TYPE_BGRA_8888,
                        cef.CEF_ALPHA_TYPE_PREMULTIPLIED)
                # noinspection PyArgumentList
                texture = Texture.create(size=(width, height))
                texture.blit_buffer(abuffer, colorfmt='bgra', bufferfmt='ubyte')
                texture.flip_vertical()
                self.drag_icon = Rectangle(texture=texture,
                                           pos=self.flip_pos_vertical(x, y),
                                           size=(width, height))
                self.canvas.add(self.drag_icon)
        elif self.drag_icon:
            self.canvas.remove(self.drag_icon)
            del self.drag_icon

    def flip_pos_vertical(self, x, y):
        half = self.height / 2
        if y > half:
            y = half - (y-half)
        elif y < half:
            y = half + (half-y)
        # Additionally position drag icon to the center of mouse cursor
        y -= 20
        x -= 20
        return x, y


class ClientHandler:

    def __init__(self, browserWidget):
        self.browserWidget = browserWidget

    def _fix_select_boxes(self, frame):
        # This is just a temporary fix, until proper Popup widgets
        # painting is implemented (PET_POPUP in OnPaint). Currently
        # there is no way to obtain a native window handle (GtkWindow
        # pointer) in Kivy, and this may cause things like context menus,
        # select boxes and plugins not to display correctly. Although,
        # this needs to be tested. The popup widget buffers are
        # available in a separate paint buffer, so they could positioned
        # freely so that it doesn't go out of the window. So the native
        # window handle might not necessarily be required to make it work
        # in most cases (99.9%). Though, this still needs testing to confirm.
        # --
        # See this topic on the CEF Forum regarding the NULL window handle:
        # http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10851
        # --
        # See also a related topic on the Kivy-users group:
        # https://groups.google.com/d/topic/kivy-users/WdEQyHI5vTs/discussion
        # --
        # The javascript select boxes library used:
        # http://marcj.github.io/jquery-selectBox/
        # --
        # Cannot use "file://" urls to load local resources, error:
        # | Not allowed to load local resource
        print("[kivy_.py] _fix_select_boxes()")
        resources_dir = os.path.join(
                os.path.dirname(os.path.abspath(__file__)),
                "kivy-select-boxes")
        if not os.path.exists(resources_dir):
            print("[kivy_.py] The kivy-select-boxes directory does not exist, "
                  "select boxes fix won't be applied.")
            return
        js_file = os.path.join(resources_dir, "kivy-selectBox.js")
        js_content = ""
        with open(js_file, "r") as myfile:
            js_content = myfile.read()
        css_file = os.path.join(resources_dir, "kivy-selectBox.css")
        css_content = ""
        with open(css_file, "r") as myfile:
            css_content = myfile.read()
        css_content = css_content.replace("\r", "")
        css_content = css_content.replace("\n", "")
        jsCode = """
            %(js_content)s
            var __kivy_temp_head = document.getElementsByTagName('head')[0];
            var __kivy_temp_style = document.createElement('style');
            __kivy_temp_style.type = 'text/css';
            __kivy_temp_style.appendChild(document.createTextNode("%(css_content)s"));
            __kivy_temp_head.appendChild(__kivy_temp_style);
        """ % locals()
        frame.ExecuteJavascript(
            jsCode,
            "kivy_.py > ClientHandler > OnLoadStart > _fix_select_boxes()")

    def OnLoadStart(self, browser, frame, **_):
        self.load_start_time = time.time()
        self._fix_select_boxes(frame)
        browserWidget = browser.GetUserData("browserWidget")
        if browserWidget and browserWidget.keyboard_mode == "local":
            print("[kivy_.py] OnLoadStart(): injecting focus listeners for"
                  " text controls")
            # The logic is similar to the one found in kivy-berkelium:
            # https://github.com/kivy/kivy-berkelium/blob/master/berkelium/__init__.py
            jsCode = """
                var __kivy__keyboard_requested = false;
                function __kivy__keyboard_interval() {
                    var element = document.activeElement;
                    if (!element) {
                        return;
                    }
                    var tag = element.tagName;
                    var type = element.type;
                    if (tag == "INPUT" && (type == "" || type == "text"
                            || type == "password") || tag == "TEXTAREA") {
                        if (!__kivy__keyboard_requested) {
                            __kivy__request_keyboard();
                            __kivy__keyboard_requested = true;
                        }
                        return;
                    }
                    if (__kivy__keyboard_requested) {
                        __kivy__release_keyboard();
                        __kivy__keyboard_requested = false;
                    }
                }
                function __kivy__on_escape() {
                    if (document.activeElement) {
                        document.activeElement.blur();
                    }
                    if (__kivy__keyboard_requested) {
                        __kivy__release_keyboard();
                        __kivy__keyboard_requested = false;
                    }
                }
                setInterval(__kivy__keyboard_interval, 100);
            """
            frame.ExecuteJavascript(
                    jsCode,
                    "kivy_.py > ClientHandler > OnLoadStart")

    def OnLoadEnd(self, browser, **_):
        # Browser lost its focus after the LoadURL() and the
        # OnBrowserDestroyed() callback bug. When keyboard mode
        # is local the fix is in the request_keyboard() method.
        # Call it from OnLoadEnd only when keyboard mode is global.
        browserWidget = browser.GetUserData("browserWidget")
        if browserWidget and browserWidget.keyboard_mode == "global":
            browser.SendFocusEvent(True)

    def OnLoadingStateChange(self, is_loading, **_):
        print("[kivy_.py] OnLoadingStateChange: isLoading = %s" % is_loading)
        # browserWidget = browser.GetUserData("browserWidget")
        if self.load_start_time:
            print("[kivy_.py] OnLoadingStateChange: load time = {time}"
                  .format(time=time.time()-self.load_start_time))
            self.load_start_time = None

    def OnPaint(self, element_type, paint_buffer, **_):
        # print "OnPaint()"
        if element_type != cef.PET_VIEW:
            print("Popups aren't implemented yet")
            return

        # FPS meter ("fps" arg)
        if "fps" in sys.argv:
            if not hasattr(self, "last_paints"):
                self.last_paints = []
            self.last_paints.append(time.time())
            while len(self.last_paints) > 30:
                self.last_paints.pop(0)
            if len(self.last_paints) > 1:
                fps = len(self.last_paints) /\
                        (self.last_paints[-1] - self.last_paints[0])
                print("[kivy_.py] FPS={fps}".format(fps=fps))

        # update buffer
        paint_buffer = paint_buffer.GetString(mode="bgra", origin="top-left")

        # update texture of canvas rectangle
        self.browserWidget.texture.blit_buffer(
                paint_buffer,
                colorfmt='bgra',
                bufferfmt='ubyte')

        self.browserWidget.update_rect()

        return True

    def GetViewRect(self, rect_out, **_):
        width, height = self.browserWidget.texture.size
        rect_out.append(0)
        rect_out.append(0)
        rect_out.append(width)
        rect_out.append(height)
        return True

    """

    def GetRootScreenRect(self, rect_out, **_):
        width, height = self.browserWidget.texture.size
        rect_out.append(0)
        rect_out.append(0)
        rect_out.append(width)
        rect_out.append(height)
        return True


    def GetScreenRect(self, rect_out, **_):
        width, height = self.browserWidget.texture.size
        rect_out.append(0)
        rect_out.append(0)
        rect_out.append(width)
        rect_out.append(height)
        return True


    def GetScreenPoint(self, screen_coordinates_out, **kwargs):
        screen_coordinates_out.append(view_x)
        screen_coordinates_out.append(view_y)
        return True

    """

    def OnJavascriptDialog(self, suppress_message_out, **_):
        suppress_message_out[0] = True
        return False

    def OnBeforeUnloadJavascriptDialog(self, callback, **_):
        callback.Continue(allow=True, userInput="")
        return True

    def StartDragging(self, drag_data, x, y, **_):
        print("[kivy_.py] ~~ StartDragging")
        # Succession of d&d calls:
        #   DragTargetDragEnter
        #   DragTargetDragOver - in touch move event
        #   DragTargetDragLeave - optional
        #   DragSourceSystemDragEnded - optional, to cancel dragging
        #   DragTargetDrop - on mouse up
        #   DragSourceEndedAt - on mouse up
        #   DragSourceSystemDragEnded - on mouse up
        print("[kivy_.py] ~~ DragTargetDragEnter")
        self.browserWidget.browser.DragTargetDragEnter(
                drag_data, x, y, cef.DRAG_OPERATION_EVERY)
        self.browserWidget.is_drag = True
        self.browserWidget.is_drag_leave = False
        self.browserWidget.drag_data = drag_data
        self.browserWidget.current_drag_operation = \
            cef.DRAG_OPERATION_NONE
        self.browserWidget.update_drag_icon(x, y)
        return True

    def UpdateDragCursor(self, **kwargs):
        # print("~~ UpdateDragCursor(): operation=%s" % operation)
        self.browserWidget.current_drag_operation = kwargs["operation"]


class CefBrowserApp(App):

    def build(self):
        self.layout = BrowserLayout()
        return self.layout

    def on_stop(self):
        # This is required for a clean shutdown of CEF.
        self.layout.browser_widget.browser.CloseBrowser(True)
        del self.layout.browser_widget.browser


if __name__ == '__main__':
    CefBrowserApp().run()
    cef.Shutdown()
