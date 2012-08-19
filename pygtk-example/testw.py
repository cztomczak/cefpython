#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import glib
import time
import pango
import thread
import threading
import subprocess
import traceback,webbrowser
import logging,urllib2,urllib
import gtk
import gobject

import cefpython
import cefwindow
import win32con
import win32gui
import win32api
import sys

def CloseApplication(windowID, message, wparam, lparam):
    browser = cefpython.GetBrowserByWindowID(windowID)
    if browser is not None:
        browser.CloseBrowser()
    win32api.PostMessage(windowID, win32con.WM_DESTROY, 0, 0)	

def QuitApplication(windowID, message, wparam, lparam):
	win32gui.PostQuitMessage(0)



def main_is_frozen():
    """Return ''True'' if we're running from a frozen program."""
    import imp
    return (
        # new py2exe
        hasattr(sys, "frozen") or
        # tools/freeze
        imp.is_frozen("__main__"))
 
def get_main_dir():
    """Return the script directory - whether we're frozen or not."""
    if main_is_frozen():
        return os.path.abspath(os.path.dirname(sys.executable))
    return os.path.abspath(os.path.dirname(sys.argv[0]))

def get_program_root_path():
    '''获取程序根目录地址

    在win下用py2exe打包后，跟直接运行py文件，程序地址有所不同
    '''
    return get_main_dir()
PROGRAM_ROOT_PATH = get_program_root_path()
def get_glade_file_path(filename):
    """ 获得glade文件路径"""
    glade_folder_path = "%s" % PROGRAM_ROOT_PATH
    return "%s/%s" % (glade_folder_path,  filename)

global __browser

def PyTest1(arg1):
    print "PyTest1(%s) called" % arg1
    return "This string was returned from Python function PyTest1()"

def PyTest2(arg1, arg2):
    print "PyTest2(%s, %s) called" % (arg1, arg2)
    return [1,2, [2.1, {'3': 3, '4': [5,6]}]] # testing nested return values.

def PrintPyConfig():
    print "PrintPyConfig(): %s" % __browser.GetMainFrame().GetProperty("PyConfig")

def ChangePyConfig():
    __browser.GetMainFrame().SetProperty("PyConfig", "Changed in python during runtime in ChangePyConfig()")

def TestJavascriptCallback(jsCallback):
    if isinstance(jsCallback, cefpython.JavascriptCallback):
        print "TestJavascriptCallback(): jsCallback.GetName(): %s" % jsCallback.GetName()
        print "jsCallback.Call(1, [2,3])"
        jsCallback.Call(1, [2,3])
    else:
        raise Exception("TestJavascriptCallback() failed: given argument is not a javascript callback function")

def TestPythonCallbackThroughReturn():
    print "TestPythonCallbackThroughReturn() called, returning PyCallback."
    return PyCallback

def PyCallback(*args):
    print "PyCallback() called, args: %s" % str(args)

def TestPythonCallbackThroughJavascriptCallback(jsCallback):
    print "TestPythonCallbackThroughJavascriptCallback(jsCallback) called"
    print "jsCallback.Call(PyCallback)"
    jsCallback.Call(PyCallback)

def PyAlert(msg):
    print "PyAlert() called instead of window.alert()"
    win32gui.MessageBox(__browser.GetWindowID(), msg, "PyAlert()", win32con.MB_ICONQUESTION)

def ChangeAlertDuringRuntime():
    __browser.GetMainFrame().SetProperty("alert", PyAlert2)

def PyAlert2(msg):
    print "PyAlert2() called instead of window.alert()"
    win32gui.MessageBox(__browser.GetWindowID(), msg, "PyAlert2()", win32con.MB_ICONWARNING)

def OnLoadStart(browser, frame):
    print "OnLoadStart(): frame URL: %s" % frame.GetURL()
    #if frame.IsMain(): return
    #browser.GetMainFrame().ExecuteJavascript("window.open('about:blank', '', 'width=500,height=500')")
    #print "HidePopup(): %s" % browser.HidePopup()

def OnLoadError(browser, frame, errorCode, failedURL, errorText):
    print "OnLoadError() failedURL: %s" % (failedURL)

def OnKeyEvent(browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript):
    # print "keyCode=%s, modifiers=%s, isSystemKey=%s" % (keyCode, modifiers, isSystemKey)
    # Let's bind developer tools to F12 key.
    if keyCode == cefpython.VK_F12 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
        browser.ShowDevTools()
        return True
    # Bind F5 to refresh browser window.
    if keyCode == cefpython.VK_F5 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
        browser.ReloadIgnoreCache()
        return True
    return False

def PyResizeWindow():
    cefwindow.MoveWindow(__browser.GetWindowID(), width=500, height=500)

def PyMoveWindow():
    cefwindow.MoveWindow(__browser.GetWindowID(), xpos=0, ypos=0)

def PopupWindow():
    # TODO: creating popup windows through python.
    pass

def ModalWindow():
    # TODO: creating modal windows throught python.
    pass

def LoadContentFromZip():
    # TODO. Allow to pack html/css/images to a zip and run content from this file.
    # Optionally allow to password protect this zip file.
    pass

def LoadContentFromEncryptedZip():
    # TODO. This will be useful only if you protect your python sources by compiling them
    # to exe by using for example "pyinstaller", or even better you could compile sources
    # to a dll-like file called "pyd" by using cython extension, or you could combine them both.
    # See WBEA for implementation.
    pass


class DealsphereApp():

    def __init__(self):

        # 从glade文件构建widgets
        builder = gtk.Builder()
        builder.add_from_file(get_glade_file_path('cef.glade'))
        builder.connect_signals(self)
        for widget in builder.get_objects():
            if issubclass(type(widget), gtk.Buildable):
                name = gtk.Buildable.get_name(widget)
                setattr(self, name, widget)

      
      
        #其他
        self.__browser=None
        self.CEFXY={'zx':0,'zy':0,'xpos':0,'ypos':0,'width':0,'height':0}


    
    def on_mainwin_delete_event(self, widget, data=None):
        self.window1.connect('event-after', gtk.main_quit) 
        pass

    def on_window1_destroy(slef):
        self.window1.connect('event-after', gtk.main_quit) 
        pass
    def runme(self):

  

      #id = win32api.GetCurrentProcess()

        '''
        error = "\n".join(traceback.format_exception(type, value, traceobject))
        with open(cefpython.GetRealPath("error.log"), "a") as file:
            file.write("\n[%s] %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), error))
        print "\n"+error+"\n"
        '''

        '''
        message_map = {
            win32con.WM_CLOSE: CloseApplication, 
            win32con.WM_DESTROY: QuitApplication,
            win32con.WM_SIZE: cefpython.wm_Size,
            win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
            win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
        }
        '''
        #a=cefpython.CreateBrowser()
        #hWnd =GDK_WINDOW_HWND(self.window1);
        #self.window1.connect("delete-event", lambda widget, evt: gtk.main_quit())
        #self.window1.connect("destroy", lambda widget: gtk.main_quit())

        self.hadjustment =  self.scrolledwindow1.get_hadjustment()
        self.vadjustment =  self.scrolledwindow1.get_vadjustment() 

        #self.window1.maximize() 
        self.window1.show()
        mid= self.scrolledwindow1.window.handle
        '''
        print self.window1.window.handle
        #hWnd = gdk_win32_drawable_get_handle(self.window1);
        print ah
        print self.window1.window.handle


        print gtk.window_list_toplevels()
        cefpython.wm_Size=self.resizem
        '''
        sys.excepthook = cefpython.ExceptHook
        cefwindow.__debug = True # Whether to print debug output to console.
        cefpython.__debug = True

        appSettings = dict() # See: http://code.google.com/p/cefpython/wiki/AppSettings
        appSettings["multi_threaded_message_loop"] = False
        #appSettings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE # LOGSEVERITY_DISABLE - will not create "debug.log" file.
        cefpython.Initialize(appSettings)

        #win32gui.SetWindowLong(ah, win32con.GWL_WNDPROC, message_map)
        handlers = dict()
        handlers["OnLoadStart"] = (OnLoadStart, None, OnLoadStart) # Document is ready. Developer tools window is also a popup, this handler may be called.
        handlers["OnLoadError"] = OnLoadError
        handlers["OnKeyEvent"] = (OnKeyEvent, None, OnKeyEvent)


        bindings = cefpython.JavascriptBindings(bindToFrames=True, bindToPopups=True)
        bindings.SetFunction("PrintPyConfig", PrintPyConfig)

        bindings.SetFunction("PyResizeWindow", PyResizeWindow)
        bindings.SetFunction("PyMoveWindow", PyMoveWindow)


        browserSettings = dict() # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
        browserSettings["history_disabled"] = False # Backspace key will act as "History back" action in browser.
        browserSettings["universal_access_from_file_urls_allowed"] = True
        browserSettings["file_access_from_file_urls_allowed"] = True

        
        wndproc = {
            win32con.WM_CLOSE: CloseApplication, 
            win32con.WM_DESTROY: QuitApplication,
            win32con.WM_SIZE: cefpython.wm_Size,
            win32con.WM_SETFOCUS: cefpython.wm_SetFocus
       }
        windowID=0
        windowID = cefwindow.CreateWindow("Test window", "testwindow", 100,100, 1 , 1,None,wndproc,mid)#mid   
        print windowID
        self.BID  =windowID
        global __browser
        __browser = cefpython.CreateBrowser (windowID,browserSettings, "cefsimple.html", handlers, bindings)
        self.__browser=__browser 


        win32api.PostMessage(windowID, win32con.WM_SIZE, 0, 0)	
        #__browser.ShowDevTools()
        #SingleMessageLoop    MessageLoop

        timeout=100
        self.counter=0
        gobject.timeout_add(timeout, self.callback)
        
        #cefpython.Shutdown()


    def callback(self):
        cefpython.SingleMessageLoop()
        self.counter += 1
        return True

    def resizem(self):
        print 'hi'


    def on_scrolledwindow1_size_request(self, widget, data=None):
        print 'on_scrolledwindow1_size_request'
        pass

    def on_scrolledwindow1_configure_event(self, widget, data=None):
        print 'on_scrolledwindow1_configure_event'
        pass

    def on_scrolledwindow1_motion_notify_event(self, widget, data=None):
        print 'on_scrolledwindow1_motion_notify_event'
        pass


    def on_window1_move_focus(self, widget, data=None):
        print 'on_window1_move_focus'
        pass


    def on_window1_motion_notify_event(self, widget, data=None):
        print 'on_window1_motion_notify_event'
        pass

    def on_window1_configure_event(self, widget, event=None):
        self.CEFXY['xpos'] =   self.CEFXY['hx']+event.x
        self.CEFXY['ypos'] =   self.CEFXY['hy']+  event.y
        self.resizecef()
        pass


   

    def on_scrolledwindow1_drag_end(self, wid, allocation):
        print allocation
        print 'on_scrolledwindow1_size_allocate'

    def on_scrolledwindow1_size_allocate(self, widget, allocation):
        x, y, w, h = allocation
        basex,basey=self.window1.get_position()
        self.CEFXY['hx'],self.CEFXY['hy']=x,y
        print self.scrolledwindow1.get_vadjustment().value
        print allocation

        self.CEFXY['xpos']=basex+x  + 5
        self.CEFXY['ypos']=basey+y + 28
        self.CEFXY['width']=w -5
        self.CEFXY['height']=h -3
        

        self.resizecef()
            

        print 'on_scrolledwindow1_size_allocate'

    
    def resizecef(self):
        if self.__browser is  None: 
            return


        print self.__browser.GetWindowID()
        cefwindow.MoveWindow(self.__browser.GetWindowID(), self.CEFXY['xpos']+self.CEFXY['zx'] ,  self.CEFXY['ypos']+self.CEFXY['zy']  ,self.CEFXY['width'], self.CEFXY['height'] )
        


def main():
  
    DealsphereApp().runme()
    gobject.threads_init()
    try:
        gtk.main()
    except Exception as error:
        print error
        pass


if __name__ == '__main__':
    main()
