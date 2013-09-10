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
        settings = {"log_severity": cefpython.LOGSEVERITY_INFO,
                #"log_file": GetApplicationPath("debug.log"),
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
        self.browser = cefpython.CreateBrowserSync(windowInfo, browserSettings, navigateUrl="about:blank")
        
        #set focus
        self.browser.SendFocusEvent(True)
        
        #Create RenderHandler (in ClientHandler)
        CH = ClientHandler(self.texture, self)
        self.browser.SetClientHandler(CH)
        
        #Call WasResized() => force cef to call GetViewRect() and OnPaint afterwards
        self.browser.WasResized() 
        
        #Load desired start URL
        self.browser.GetMainFrame().LoadUrl(start_url)
                
        #Clock.schedule_interval(self.press_key, 5)
        self._keyboard = Window.request_keyboard(self._keyboard_closed, self)
        self._keyboard.bind(on_key_down=self.press_key)
    
    
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
    
    
    def _keyboard_closed(self, *kwargs):
        pass
    
    
    def press_key(self, wid, key, *kwargs):
        #print "key pressed",  key[0]
        self.browser.SendKeyEvent(cefpython.KEYTYPE_CHAR, key[0])
    
    
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
        

    def OnPaint(self, browser, paintElementType, dirtyRects, buffer, width, height):        
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
