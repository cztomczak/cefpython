import cefpython # cefpython.pyd
import cefwindow
import win32con # pywin32 extension
import win32gui


def QuitApplication(hwnd, msg, wparam, lparam):
	
	browser = cefpython.GetBrowserByHwnd(hwnd)
	cefpython.CloseBrowser(browser)
	win32gui.PostQuitMessage(0)


def CefExample():
	
	# Whether to print debug output to console.
	cefwindow.__debug = True
	cefpython.__debug = True

	appSettings = {} # See: http://code.google.com/p/cefpython/wiki/AppSettings
	appSettings["multi_threaded_message_loop"] = False # The UI thread will be the same as the main application thread.

	cefpython.Initialize(appSettings)

	# 5th and 6th arguments to CreateWindow() are x/y position, 
	# if you do not provide them the window will be centered on the screen.
	wndproc = {win32con.WM_CLOSE: QuitApplication}
	windowID = cefwindow.CreateWindow("CefExample", "cefexample", 800, 600, None, None, wndproc)

	browserSettings = {} # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
	browser = cefpython.CreateBrowser(windowID, browserSettings)

	cefpython.MessageLoop()
	cefpython.Shutdown()


def JavascriptBindings():
	# http://code.google.com/p/chromiumembedded/wiki/JavaScriptIntegration
	pass


def JavascriptCallbacks():
	pass


def PopupWindow():
	pass


def ModalWindow():
	pass


def ResizeWindow():
	# main window, popup and modal
	pass


def MoveWindow():
	# main window, popup and modal
	pass


def ApplicationIcon():
	# This is just a reminder, a way to change application's icon should be possible.
	pass


def DeveloperTools():
	pass


def LoadContentFromZip():
	# Allow to pack html/css/images to a zip and run content from this file.
	# Optionally allow to password protect this zip file.
	pass


def LoadContentFromEncryptedZip():
	# This will be useful only if you protect your python sources by compiling them
	# to exe by using for example "pyinstaller", or even better you could compile sources
	# to a dll-like file called "pyd" by using cython extension, or you could combine them both.
	# See WBEA for implementation.
	pass


if __name__ == "__main__":
	CefExample()
