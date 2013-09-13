# An example of embedding CEF browser in the Kivy framework.
# The browser is embedded using off-screen rendering mode.

# Tested using Kivy 1.7.2 stable on Ubuntu 12.04 64-bit.

# In this example kivy-lang is used to declare the layout which
# contains two buttons (back, forward) and the browser view.

from kivy.app import App
from kivy.uix.widget import Widget
from kivy.graphics import Color, Rectangle, GraphicException
from kivy.clock import Clock
from kivy.graphics.texture import Texture
from kivy.core.window import Window
from kivy.lang import Builder
from kivy.uix.boxlayout import BoxLayout
from kivy.base import EventLoop

####CEF IMPORT ####
import ctypes, os, sys
libcef_so = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'libcef.so')
if os.path.exists(libcef_so):
    # Import local module
    ctypes.CDLL(libcef_so, ctypes.RTLD_GLOBAL)
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import from package
    from cefpython3 import cefpython


####Kivy APP ####
Builder.load_string("""

<BrowserLayout>:
    orientation: 'vertical'
    BoxLayout:
        size_hint_y: None
        width: 80
        Button:
            text: "Back"
            on_press: browser.go_back()
        Button:
            text: "Forward"
            on_press: browser.go_forward()
    CefBrowser:
        id: browser

""")



class BrowserLayout(BoxLayout):

    def __init__(self, **kwargs):
        super(BrowserLayout, self).__init__(**kwargs)
    


class CefBrowser(Widget):
    
    '''Represent a browser widget for kivy, which can be used like a normal widget.
    '''
    def __init__(self, start_url='http://www.google.com', **kwargs):
        super(CefBrowser, self).__init__(**kwargs)
        
        self.start_url = start_url
        
        #Workaround for flexible size:
        #start browser when the height has changed (done by layout)
        #This has to be done like this because I wasn't able to change the texture size
        #until runtime without core-dump.
        self.bind(size = self.size_changed)
            
    
    def size_changed(self, *kwargs):
        '''When the height of the cefbrowser widget got changed, create the browser
        '''
        if self.height != 100:
            self.start_cef(self.start_url)

   
    def _cef_mes(self, *kwargs):
        '''Get called every frame.
        '''
        cefpython.MessageLoopWork()
        
        
    def _update_rect(self, *kwargs):
        '''Get called whenever the texture got updated. 
        => we need to reset the texture for the rectangle
        '''
        self.rect.texture = self.texture
   
            
    def start_cef(self, start_url='http://google.com'):
        '''Starts CEF. 
        '''
        # create texture & add it to canvas
        self.texture = Texture.create(size=self.size, colorfmt='rgba', bufferfmt='ubyte')
        self.texture.flip_vertical()
        with self.canvas:
            Color(1, 1, 1)
            self.rect = Rectangle(size=self.size, texture=self.texture)
            
        #configure cef
        cefpython.g_debug = True
        cefpython.g_debugFile = "debug.log"
        settings = {"log_severity": cefpython.LOGSEVERITY_INFO,
                "log_file": "debug.log",
                "release_dcheck_enabled": True, # Enable only when debugging.
                # This directories must be set on Linux
                "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
                "resources_dir_path": cefpython.GetModuleDirectory(),
                "browser_subprocess_path": "%s/%s" % (cefpython.GetModuleDirectory(), "subprocess")}
        
        #start idle
        Clock.schedule_interval(self._cef_mes, 0)
        
        #init CEF
        cefpython.Initialize(settings)
       
        #WindowInfo offscreen flag
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsOffscreen(0)
        
        #Create Broswer and naviagte to empty page <= OnPaint won't get called yet
        browserSettings = {}
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
        self.browser = cefpython.CreateBrowserSync(windowInfo, browserSettings, 
                navigateUrl=start_url)
        
        #set focus
        self.browser.SendFocusEvent(True)
        
        #Create RenderHandler (in ClientHandler)
        CH = ClientHandler(self.texture, self)
        self.browser.SetClientHandler(CH)

        jsBindings = cefpython.JavascriptBindings(
            bindToFrames=True, bindToPopups=True)
        jsBindings.SetFunction("__kivy__request_keyboard", 
                self.request_keyboard)
        jsBindings.SetFunction("__kivy__release_keyboard",
                self.release_keyboard)
        self.browser.SetJavascriptBindings(jsBindings)
        
        #Call WasResized() => force cef to call GetViewRect() and OnPaint afterwards
        self.browser.WasResized() 

        # The browserWidget instance is required in OnLoadingStateChange().
        self.browser.SetUserData("browserWidget", self)


    def request_keyboard(self):
        print("request_keyboard()")
        self._keyboard = EventLoop.window.request_keyboard(
                self.release_keyboard, self)
        self._keyboard.bind(on_key_down=self.on_key_down)
        self._keyboard.bind(on_key_up=self.on_key_up)


    def release_keyboard(self):
        if not self._keyboard:
            return
        print("release_keyboard()")
        self._keyboard.unbind(on_key_down=self.on_key_down)
        self._keyboard.unbind(on_key_up=self.on_key_up)
        self._keyboard.release()

    
    def on_key_down(self, keyboard, keycode, text, modifiers):
        # Notes:
        # - right alt modifier is not sent by Kivy 
        #   (Polish characters don't work)
        print("on_key_down(): keycode = %s modifiers = %s" % (
                keycode, modifiers))
        if keycode[0] == 27:
            # On escape release the keyboard, see the injected
            # javascript in OnLoadStart().
            self.browser.GetFocusedFrame().ExecuteJavascript(
                    "__kivy__on_escape()")
            return
        cefModifiers = cefpython.EVENTFLAG_NONE
        if "shift" in modifiers:
            cefModifiers |= cefpython.EVENTFLAG_SHIFT_DOWN
        if "ctrl" in modifiers:
            cefModifiers |= cefpython.EVENTFLAG_CONTROL_DOWN
        if "alt" in modifiers:
            cefModifiers |= cefpython.EVENTFLAG_ALT_DOWN
        if "capslock" in modifiers:
            cefModifiers |= cefpython.EVENTFLAG_CAPS_LOCK_ON
        # print("on_key_down(): cefModifiers = %s" % cefModifiers)
        keyEvent = {
                "type": cefpython.KEYEVENT_RAWKEYDOWN,
                "native_key_code": keycode[0],
                "modifiers": cefModifiers
                }
        # print("keydown keyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)


    def on_key_up(self, keyboard, keycode):
        # print("on_key_up(): keycode = %s" % (keycode,))
        cefModifiers = cefpython.EVENTFLAG_NONE
        keyEvent = {
                "type": cefpython.KEYEVENT_KEYUP,
                "native_key_code": keycode[0],
                "modifiers": cefModifiers
                }
        # print("keyup keyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)
        keyEvent = {
                "type": cefpython.KEYEVENT_CHAR,
                "native_key_code": keycode[0],
                "modifiers": cefModifiers
                }
        # print("char keyEvent: %s" % keyEvent)
        self.browser.SendKeyEvent(keyEvent)


    def go_forward(self):
        '''Going to forward in browser history
        '''
        print "go forward"
        self.browser.GoForward()
    
    
    def go_back(self):
        '''Going back in browser history
        '''
        print "go back"
        self.browser.GoBack()
    
    
    def on_touch_down(self, touch, *kwargs):
        if not self.collide_point(*touch.pos):
            return
        touch.grab(self)
        
        y = self.height-touch.pos[1]
        self.browser.SendMouseClickEvent(touch.x, y, cefpython.MOUSEBUTTON_LEFT,
                                         mouseUp=False, clickCount=1)
    
    
    def on_touch_move(self, touch, *kwargs):
        if touch.grab_current is not self:
            return
        
        y = self.height-touch.pos[1]
        self.browser.SendMouseMoveEvent(touch.x, y, mouseLeave=False)
        
        
    def on_touch_up(self, touch, *kwargs):
        if touch.grab_current is not self:
            return
        
        y = self.height-touch.pos[1]
        self.browser.SendMouseClickEvent(touch.x, y, cefpython.MOUSEBUTTON_LEFT,
                                         mouseUp=True, clickCount=1)
        touch.ungrab(self)


class ClientHandler:

    def __init__(self, texture, parent):
        self.texture = texture
        self.parent = parent


    def OnLoadStart(self, browser, frame):
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
                // <input> with an empty type is a text type by default!
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
            setInterval(__kivy__keyboard_interval, 13);
        """
        frame.ExecuteJavascript(jsCode, 
                "kivy_.py > ClientHandler > OnLoadStart")

    
    def OnLoadingStateChange(self, browser, isLoading, canGoBack,
            canGoForward):
        print("OnLoadingStateChange(): isLoading = %s" % isLoading)
        if isLoading and browser.GetUserData("browserWidget"):
            # Release keyboard when navigating to a new page.
            browser.GetUserData("browserWidget").release_keyboard()
            pass

    
    def OnPaint(self, browser, paintElementType, dirtyRects, buffer, width, height):        
        # print "OnPaint()"
        if paintElementType != cefpython.PET_VIEW:
            print "Popups aren't implemented yet"
            return
        
        #update buffer
        buffer = buffer.GetString(mode="bgra", origin="top-left")
        
        #update texture of canvas rectangle
        self.texture.blit_buffer(buffer, colorfmt='bgra', bufferfmt='ubyte')
        self.parent._update_rect()
                
        return True
    

    def GetViewRect(self, browser, rect):
        width, height = self.texture.size
        rect.append(0)
        rect.append(0)
        rect.append(width)
        rect.append(height)
        return True


if __name__ == '__main__':
    class CefBrowserApp(App):
        def build(self):
            return BrowserLayout()
    CefBrowserApp().run()
    
    cefpython.Shutdown()
