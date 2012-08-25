import cefpython
import pygtk
pygtk.require('2.0')
import gtk
import sys
import gobject

class PyGTKExample:

	mainWindow = None
	container = None
	browser = None
	exiting = None

	def __init__(self):

		gobject.timeout_add(10, self.OnTimer)

		self.mainWindow = gtk.Window(gtk.WINDOW_TOPLEVEL)
		self.mainWindow.connect('destroy', self.OnExit)
		self.mainWindow.set_size_request(width=600, height=400)
		self.mainWindow.set_title('PyGTK CEF example')
		self.mainWindow.realize()

		self.container = gtk.DrawingArea()
		self.container.set_property('can-focus', True)
		self.container.connect('focus-in-event', self.OnFocus)
		self.container.connect('size-allocate', self.OnSize)
		self.container.show()

		table = gtk.Table(2, 1, homogeneous=False)
		self.mainWindow.add(table)
		table.attach(self.CreateMenu(), 0, 1, 0, 1, yoptions=gtk.SHRINK)
		table.attach(self.container, 0, 1, 1, 2)
		table.show()

		windowID = self.container.get_window().handle
		self.browser = cefpython.CreateBrowser(windowID, browserSettings={}, navigateURL='cefsimple.html')
		
		self.mainWindow.show()

	def CreateMenu(self):

		file = gtk.MenuItem('File')
		file.show()
		filemenu = gtk.Menu()		
		item = gtk.MenuItem('Open')
		filemenu.append(item)
		item.show()
		item = gtk.MenuItem('Exit')
		filemenu.append(item)
		item.show()
		file.set_submenu(filemenu)

		about = gtk.MenuItem('About')
		about.show()

		menubar = gtk.MenuBar()
		menubar.append(file)
		menubar.append(about)
		menubar.show()

		return menubar

	def OnTimer(self):

		if self.exiting:
			return False
		cefpython.SingleMessageLoop()
		return True

	def OnFocus(self, widget, data):

		cefpython.wm_SetFocus(self.container.get_window().handle, 0, 0, 0)
	
	def OnSize(self, widget, sizeAlloc):

		cefpython.wm_Size(self.container.get_window().handle, 0, 0, 0)	

	def OnExit(self, widget, data=None):

		self.exiting = True
		cefpython.Shutdown()
		gtk.main_quit()

if __name__ == '__main__':

	version = '.'.join(map(str, list(gtk.gtk_version)))
	print('GTK version: %s' % version)

	cefpython.Initialize()
	sys.excepthook = cefpython.ExceptHook	
	
	gobject.threads_init() # timer for messageloop
	PyGTKExample()
	gtk.main()
