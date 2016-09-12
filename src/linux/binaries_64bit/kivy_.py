# An example of embedding CEF browser in the Kivy framework.
# The browser is embedded using off-screen rendering mode.

# Tested using Kivy 1.7.2 stable on Ubuntu 12.04 64-bit.

# In this example kivy-lang is used to declare the layout which
# contains two buttons (back, forward) and the browser view.

# The official CEF Python binaries come with tcmalloc hook
# disabled. But if you've built custom binaries and kept tcmalloc
# hook enabled, then be aware that in such case it is required
# for the cefpython module to be the very first import in
# python scripts. See Issue 73 in the CEF Python Issue Tracker
# for more details.

import ctypes, os, sys
cur_dir = os.path.dirname(os.path.abspath(__file__))
libcef_so = os.path.join(cur_dir, 'libcef.so')
if os.path.exists(libcef_so):
    # Import local module
    LD_LIBRARY_PATH = os.environ.get('LD_LIBRARY_PATH', None)
    if not LD_LIBRARY_PATH:
        LD_LIBRARY_PATH = cur_dir
    else:
        LD_LIBRARY_PATH += os.path.sep + cur_dir
    os.putenv('LD_LIBRARY_PATH', LD_LIBRARY_PATH)
    ctypes.CDLL(libcef_so, ctypes.RTLD_GLOBAL)
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import from package
    from cefpython3 import cefpython

import pygtk
pygtk.require('2.0')
import gtk

import kivy
from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.popup import Popup
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.graphics import Color, Rectangle, GraphicException
from kivy.clock import Clock
from kivy.graphics.texture import Texture
from kivy.core.window import Window
from kivy.lang import Builder
from kivy.uix.boxlayout import BoxLayout
from kivy.base import EventLoop

# Global variables
g_switches = None


class BrowserLayout(BoxLayout):
    browser = None

    def __init__(self, **kwargs):
        super(BrowserLayout, self).__init__(**kwargs)
        self.orientation = "vertical"

        browser = CefBrowser(id="browser")

        layout = BoxLayout()
        layout.size_hint_y = None
        layout.height = 40
        layout.add_widget(Button(text="Back", on_press=browser.go_back))
        layout.add_widget(Button(text="Forward", on_press=browser.go_forward))
        layout.add_widget(Button(text="Reload", on_press=browser.reload))
        layout.add_widget(Button(text="Print", on_press=browser.print_page))
        layout.add_widget(Button(text="DevTools", on_press=browser.devtools))

        self.add_widget(layout)
        self.add_widget(browser)


class CefBrowser(Widget):

    # Keyboard mode: "global" or "local".
    # 1. Global mode forwards keys to CEF all the time.
    # 2. Local mode forwards keys to CEF only when an editable
    #    control is focused (input type=text|password or textarea).
    keyboard_mode = "global"

    '''Represent a browser widget for kivy, which can be used like a normal widget.
    '''
    def __init__(self, start_url='https://www.google.com/', **kwargs):
        super(CefBrowser, self).__init__(**kwargs)

        for arg in sys.argv:
            if arg.startswith("http://") or arg.startswith("https://"):
                start_url = arg
        self.start_url = start_url

        #Workaround for flexible size:
        #start browser when the height has changed (done by layout)
        #This has to be done like this because I wasn't able to change
        #the texture size
        #until runtime without core-dump.
        self.bind(size = self.size_changed)


    starting = True
    def size_changed(self, *kwargs):
        '''When the height of the cefbrowser widget got changed, create the browser
        '''
        if self.starting:
            if self.height != 100:
                self.start_cef()
                self.starting = False
        else:
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
    def _message_loop_work(self, *kwargs):
        '''Get called every frame.
        '''
        self.count += 1
        # print(self.count)
        cefpython.MessageLoopWork()
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


    def _update_rect(self, *kwargs):
        '''Get called whenever the texture got updated.
        => we need to reset the texture for the rectangle
        '''
        self.rect.texture = self.texture


    def start_cef(self):
        '''Starts CEF.
        '''
        # create texture & add it to canvas
        self.texture = Texture.create(
                size=self.size, colorfmt='rgba', bufferfmt='ubyte')
        self.texture.flip_vertical()
        with self.canvas:
            Color(1, 1, 1)
            self.rect = Rectangle(size=self.size, texture=self.texture)

        # Configure CEF
        settings = {
            "debug": True, # cefpython debug messages in console and in log_file
            "log_severity": cefpython.LOGSEVERITY_INFO,
            "log_file": "debug.log",
            # This directories must be set on Linux
            "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
            "resources_dir_path": cefpython.GetModuleDirectory(),
            "browser_subprocess_path": "%s/%s" % (
                cefpython.GetModuleDirectory(), "subprocess"),
            "windowless_rendering_enabled": True,
            "context_menu": {
                # Disable context menu, popup widgets not supported
                "enabled": False,
            },
        }
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
        cefpython.WindowUtils.InstallX11ErrorHandlers()

        global g_switches
        g_switches = switches
        cefpython.Initialize(settings, switches)

        # Start idle - CEF message loop work.
        Clock.schedule_once(self._message_loop_work, 0)

        # CEF needs a valid window handle passed to SetAsOffscreen()
        # for Printing to work. There is no API to get Kivy's window
        # handle so creating a dummy hidden Window using GTK.
        gtkwin = gtk.Window()
        gtkwin.realize()

        # WindowInfo offscreen flag
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsOffscreen(gtkwin.window.xid)

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
        self.browser = cefpython.CreateBrowserSync(windowInfo, browserSettings,
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
            self._js_bindings = cefpython.JavascriptBindings(
                bindToFrames=True, bindToPopups=True)
            self._js_bindings.SetFunction("__kivy__request_keyboard",
                    self.request_keyboard)
            self._js_bindings.SetFunction("__kivy__release_keyboard",
                    self.release_keyboard)
        self.browser.SetJavascriptBindings(self._js_bindings)


    def change_url(self, *kwargs):
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
        print("request_keyboard()")
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
        print("release_keyboard()")
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

    def on_key_down(self, keyboard, key, text, modifiers):
        # NOTE: Right alt modifier is not sent by Kivy through modifiers param.
        print("---- on_key_down")
        print("-- key="+str(key))
        # print(text) - utf-8 char
        print("-- modifiers="+str(modifiers))
        if text:
            print("-- ord(text)="+str(ord(text)))

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
        cef_modifiers = cefpython.EVENTFLAG_NONE
        if "shift" in modifiers:
            cef_modifiers |= cefpython.EVENTFLAG_SHIFT_DOWN
        if "ctrl" in modifiers:
            cef_modifiers |= cefpython.EVENTFLAG_CONTROL_DOWN
        if "alt" in modifiers:
            cef_modifiers |= cefpython.EVENTFLAG_ALT_DOWN
        if "capslock" in modifiers:
            cef_modifiers |= cefpython.EVENTFLAG_CAPS_LOCK_ON

        keycode = self.get_windows_key_code(key[0])
        charcode = key[0]
        if text:
            charcode = ord(text)

        # Send key event to cef: RAWKEYDOWN
        keyEvent = {
                "type": cefpython.KEYEVENT_RAWKEYDOWN,
                "windows_key_code": keycode,
                "character": charcode,
                "unmodified_character": charcode,
                "modifiers": cef_modifiers,
        }
        print("- SendKeyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)

        # Send key event to cef: CHAR
        if text:
            keyEvent = {
                    "type": cefpython.KEYEVENT_CHAR,
                    "windows_key_code": keycode,
                    "character": charcode,
                    "unmodified_character": charcode,
                    "modifiers": cef_modifiers
            }
            print("- SendKeyEvent: %s" % keyEvent)
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


    def on_key_up(self, keyboard, key):
        print("---- on_key_up")
        print("-- key="+str(key))

        # Kivy code -1 is a special key eg. Change keyboard layout.
        # Sending it to CEF would crash it.
        if key[0] == -1:
            return

        # CEF modifiers
        cef_modifiers = cefpython.EVENTFLAG_NONE
        if self.is_shift1 or self.is_shift2:
            cef_modifiers |= cefpython.EVENTFLAG_SHIFT_DOWN
        if self.is_ctrl1 or self.is_ctrl2:
            cef_modifiers |= cefpython.EVENTFLAG_CONTROL_DOWN
        if self.is_alt1:
            cef_modifiers |= cefpython.EVENTFLAG_ALT_DOWN

        keycode = self.get_windows_key_code(key[0])
        charcode = key[0]

        # Send key event to cef: KEYUP
        keyEvent = {
                "type": cefpython.KEYEVENT_KEYUP,
                "windows_key_code": keycode,
                "character": charcode,
                "unmodified_character": charcode,
                "modifiers": cef_modifiers
        }
        print("- SendKeyEvent: %s" % keyEvent)
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
            "27":27,
            # F1-F12
            "282":112, "283":113, "284":114, "285":115,
            "286":116, "287":117, "288":118, "289":119,
            "290":120, "291":121, "292":122, "293":123,
            # Tab
            "9":9,
            # Left Shift, Right Shift
            "304":16, "303":16,
            # Left Ctrl, Right Ctrl
            "306":17, "305": 17,
            # Left Alt, Right Alt
            # TODO: left alt is_system_key=True in CEF but only when RAWKEYDOWN
            "308":18, "313":225,
            # Backspace
            "8":8,
            # Enter
            "13":13,
            # PrScr, ScrLck, Pause
            "316":42, "302":145, "19":19,
            # Insert, Delete,
            # Home, End,
            # Pgup, Pgdn
            "277":45, "127":46,
            "278":36, "279":35,
            "280":33, "281":34,
            # Arrows (left, up, right, down)
            "276":37, "273":38, "275":39, "274":40,
            # tilde
            "96":192,
            # minus, plus
            "45":189, "61":187,
            # square brackets / curly brackets, backslash
            "91":219, "93":221, "92":220,
            # windows key
            "311":91,
            # colon / semicolon
            "59": 186,
            # single quote / double quote
            "39":222,
            # comma, dot, slash
            "44":188, "46":190, "47":91,
            # context menu key is 93, but disable as it crashes app after
            # context menu is shown.
            "319":0,
        }
        if str(kivycode) in other_keys_map:
            cefcode = other_keys_map[str(kivycode)]

        return cefcode


    def go_forward(self, *kwargs):
        '''Going to forward in browser history
        '''
        print "go forward"
        self.browser.GoForward()


    def go_back(self, *kwargs):
        '''Going back in browser history
        '''
        print "go back"
        self.browser.GoBack()


    def reload(self, *kwargs):
        self.browser.Reload()


    def print_page(self, *kwargs):
        self.browser.Print()


    def devtools(self, *kwargs):
        # ShowDevTools doesn't work with the 'enable-begin-frame-scheduling'
        # switch. This might be fixed by implementing native popup widgets,
        # see Issue #69. The solution for now is to remove that switch,
        # but this will impact performance.
        if "enable-begin-frame-scheduling" in g_switches:
            text = ("To enable DevTools you need to remove the\n"
                    "'enable-begin-frame-scheduling' switch that\n"
                    "is passed to cefpython.Initialize(). See also\n"
                    "comment in CefBrowser.devtools().")
            popup = Popup(title='DevTools INFO', content=Label(text=text),
                          size_hint=(None, None), size=(400, 400))
            popup.open()

        else:
            self.browser.ShowDevTools()


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
                touch.x, y, cefpython.MOUSEBUTTON_RIGHT,
                mouseUp=False, clickCount=1
            )
            self.browser.SendMouseClickEvent(
                touch.x, y, cefpython.MOUSEBUTTON_RIGHT,
                mouseUp=True, clickCount=1
            )
        else:
            print("~~ DragTargetDragEnter")
            self.browser.SendMouseClickEvent(touch.x, y,
                                             cefpython.MOUSEBUTTON_LEFT,
                                             mouseUp=False, clickCount=1)
            self.browser.DragTargetDragEnter(cefpython.DragData(), touch.x,
                                             y, cefpython.DRAG_OPERATION_EVERY)




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
        self.browser.SendMouseClickEvent(touch.x, y, cefpython.MOUSEBUTTON_LEFT,
                                         mouseUp=True, clickCount=1)

        print("~~ DragTargetDrop")
        self.browser.DragTargetDrop(touch.x, y)

        print("~~ DragSourceEndedAt")
        self.browser.DragSourceEndedAt(touch.x, y,
                                       cefpython.DRAG_OPERATION_MOVE)

        print("~~ DragSourceSystemDragEnded")
        self.browser.DragSourceSystemDragEnded()

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
        if x >= 0 and y <= 0:
            y = abs(y)
            self.browser.SendMouseMoveEvent(x, y, mouseLeave=False)


    def on_touch_move(self, touch, *kwargs):
        if touch.grab_current is not self:
            return

        y = self.height-touch.pos[1]

        modifiers = cefpython.EVENTFLAG_LEFT_MOUSE_BUTTON
        self.browser.SendMouseMoveEvent(touch.x, y, mouseLeave=False,
                                        modifiers=modifiers)

        print("~~ DragTargetDragOver")
        self.browser.DragTargetDragOver(touch.x, y,
                                        cefpython.DRAG_OPERATION_MOVE)




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
        print("_fix_select_boxes()")
        resources_dir = os.path.join(
                os.path.dirname(os.path.abspath(__file__)),
                "kivy-select-boxes")
        if not os.path.exists(resources_dir):
            print("The kivy-select-boxes directory does not exist, " \
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
        frame.ExecuteJavascript(jsCode,
                "kivy_.py > ClientHandler > OnLoadStart > _fix_select_boxes()")


    def OnLoadStart(self, browser, frame):
        self._fix_select_boxes(frame);
        browserWidget = browser.GetUserData("browserWidget")
        if browserWidget and browserWidget.keyboard_mode == "local":
            print("OnLoadStart(): injecting focus listeners for text controls")
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
            frame.ExecuteJavascript(jsCode,
                    "kivy_.py > ClientHandler > OnLoadStart")


    def OnLoadEnd(self, browser, frame, httpStatusCode):
        # Browser lost its focus after the LoadURL() and the
        # OnBrowserDestroyed() callback bug. When keyboard mode
        # is local the fix is in the request_keyboard() method.
        # Call it from OnLoadEnd only when keyboard mode is global.
        browserWidget = browser.GetUserData("browserWidget")
        if browserWidget and browserWidget.keyboard_mode == "global":
            browser.SendFocusEvent(True)


    def OnLoadingStateChange(self, browser, isLoading, canGoBack,
            canGoForward):
        print("OnLoadingStateChange(): isLoading = %s" % isLoading)
        browserWidget = browser.GetUserData("browserWidget")


    def OnPaint(self, browser, paintElementType, dirtyRects, buffer, width,
            height):
        # print "OnPaint()"
        if paintElementType != cefpython.PET_VIEW:
            print "Popups aren't implemented yet"
            return

        #update buffer
        buffer = buffer.GetString(mode="bgra", origin="top-left")

        #update texture of canvas rectangle
        self.browserWidget.texture.blit_buffer(buffer, colorfmt='bgra',
                bufferfmt='ubyte')
        self.browserWidget._update_rect()

        return True


    def GetViewRect(self, browser, rect):
        width, height = self.browserWidget.texture.size
        rect.append(0)
        rect.append(0)
        rect.append(width)
        rect.append(height)
        # print("GetViewRect(): %s x %s" % (width, height))
        return True


    """

    def GetRootScreenRect(self, browser, rect):
        width, height = self.browserWidget.texture.size
        rect.append(0)
        rect.append(0)
        rect.append(width)
        rect.append(height)
        return True


    def GetScreenRect(self, browser, rect):
        width, height = self.browserWidget.texture.size
        rect.append(0)
        rect.append(0)
        rect.append(width)
        rect.append(height)
        return True


    def GetScreenPoint(self, browser, view_x, view_y, screen_coords):
        screen_coords.append(view_x)
        screen_coords.append(view_y)
        return True

    """


    def OnJavascriptDialog(self, browser, originUrl, dialogType,
                   messageText, defaultPromptText, callback,
                   suppressMessage):
        suppressMessage[0] = True
        return False


    def OnBeforeUnloadJavascriptDialog(self, browser, messageText, isReload,
            callback):
        callback.Continue(allow=True, userInput="")
        return True


    def StartDragging(self, browser, drag_data, allowed_ops, x, y):
        print("!!!! StartDragging()")
        # TODO: succession of calls:
        #   DragTargetDragEnter
        #   DragTargetDragOver
        #   DragTargetDragLeave - optional
        #   DragSourceSystemDragEnded - optional, to cancel dragging
        #   DragTargetDrop
        #   DragSourceEndedAt
        #   DragSourceSystemDragEnded
        return False


    def UpdateDragCursor(self, browser, operation):
        # print("~~ UpdateDragCursor(): operation=%s" % operation)
        pass


if __name__ == '__main__':

    class CefBrowserApp(App):
        def build(self):
            return BrowserLayout()
    CefBrowserApp().run()
    cefpython.Shutdown()
