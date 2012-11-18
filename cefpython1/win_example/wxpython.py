# An example of embedding CEF in wxPython application.

import platform
if platform.architecture()[0] != "32bit":
	raise Exception("Architecture not supported: %s" % platform.architecture()[0])

import sys
if not sys.hexversion >= 0x020700F0:
	raise Exception("Python version not supported: %s" % sys.version)

import wx
import time
import cefpython

# Notes:
# - currently using wx.Timer to imitate message loop, but it would probably be better
# to use wx.CallLater() and wx.lib.pubsub.
# - would using OnIdle() (wx.EVT_IDLE) be better than OnTimer()?

class MainFrame(wx.Frame):

	browser = None

	def __init__(self):
		
		wx.Frame.__init__(self, parent=None, id=wx.ID_ANY, title='wxPython example', size=(600,400))
		self.CreateMenu()
		self.browser = cefpython.CreateBrowser(self.GetHandle(), browserSettings={}, navigateURL="cefsimple.html")		
		
		self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
		self.Bind(wx.EVT_SIZE, self.OnSize)
		self.Bind(wx.EVT_CLOSE, self.OnClose)
		
	def CreateMenu(self):

		filemenu = wx.Menu()
		filemenu.Append(1, "Open")
		filemenu.Append(2, "Exit")

		aboutmenu = wx.Menu()
		aboutmenu.Append(1, "CEF Python")

		menubar = wx.MenuBar()
		menubar.Append(filemenu,"&File")
		menubar.Append(aboutmenu, "&About")

		self.SetMenuBar(menubar)

	def OnSetFocus(self, event):

		cefpython.wm_SetFocus(self.GetHandle(), 0, 0, 0)

	def OnSize(self, event):

		cefpython.wm_Size(self.GetHandle(), 0, 0, 0)
      
	def OnClose(self, event):

		self.browser.CloseBrowser()
		self.Destroy()

class MyApp(wx.App):

	timer = None
	timerID = 1

	def OnInit(self):

		cefpython.Initialize()
		sys.excepthook = cefpython.ExceptHook

		self.timer = wx.Timer(self, self.timerID)
		self.timer.Start(10) # 10ms
		wx.EVT_TIMER(self, self.timerID, self.OnTimer)
		
		frame = MainFrame()
		self.SetTopWindow(frame)
		frame.Show()
		
		return True

	def OnExit(self):

		self.timer.Stop()
		cefpython.Shutdown()

	def OnTimer(self, event):

		cefpython.SingleMessageLoop()

if __name__ == '__main__':
	
	print('wx.version=%s' % wx.version())
	app = MyApp(False)
	app.MainLoop()
