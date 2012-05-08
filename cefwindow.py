import win32gui
import win32con
import win32api
import time

def onclose(hwnd, msg, wparam, lparam):
	win32gui.DestroyWindow(hwnd)

def ondestroy(hwnd, msg, wparam, lparam):
	win32gui.PostQuitMessage(0)

def lasterror():
	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))

def createwindow(title, classname, wndproc=None):
	if not wndproc:
		wndproc = {
			win32con.WM_CLOSE: onclose,
			win32con.WM_DESTROY: ondestroy
		}
	wc = win32gui.WNDCLASS()
	wc.hInstance = win32api.GetModuleHandle(None)
	wc.lpszClassName = classname
	wc.style = win32con.CS_GLOBALCLASS | win32con.CS_VREDRAW | win32con.CS_HREDRAW
	wc.hbrBackground = win32con.COLOR_WINDOW # + 1
	wc.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
	wc.lpfnWndProc = wndproc

	#wc.cbClsExtra = 0
	#wc.cbWndExtra = 0

	atomclass = win32gui.RegisterClass(wc)
	print "win32gui.RegisterClass(wc)"
	print lasterror()
	if not atomclass:
		print lasterror() # this is probably unneeded, as win32gui.RegisterClass automatically handles errors
		return
	hwnd = win32gui.CreateWindow(classname, title,
			win32con.WS_OVERLAPPEDWINDOW | win32con.WS_CLIPCHILDREN | win32con.WS_VISIBLE,
			200, 200, 600, 400, # x pos, y pos, width, height
			0, 0, wc.hInstance, None)
	print "hwnd=%s" % hwnd
	return hwnd

def messageloop(classname):
	while win32gui.PumpWaitingMessages() == 0:
		time.sleep(0.001)
	win32gui.UnregisterClass(classname, None)

if __name__ == "__main__":
	hwnd = createwindow("Test window", "test_class")
	messageloop("test_class")