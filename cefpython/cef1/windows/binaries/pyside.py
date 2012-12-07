# An example of embedding CEF Python in PySide application.

import platform
if platform.architecture()[0] != "32bit":
	raise Exception("Architecture not supported: %s" % platform.architecture()[0])

import sys
if sys.hexversion >= 0x02070000 and sys.hexversion < 0x03000000:
	import cefpython_py27 as cefpython
elif sys.hexversion >= 0x03000000 and sys.hexversion < 0x04000000:
	import cefpython_py32 as cefpython
else:
	raise Exception("Unsupported python version: %s" % sys.version)

import PySide
from PySide import QtGui
from PySide import QtCore
import ctypes

class MainWindow(QtGui.QMainWindow):

	mainFrame = None

	def __init__(self):
		
		super(MainWindow, self).__init__(None)
		self.createMenu()
		self.mainFrame = MainFrame(self)
		self.setCentralWidget(self.mainFrame)
		self.resize(600, 480)
		self.setWindowTitle('PySide example')
		self.setFocusPolicy(QtCore.Qt.StrongFocus)

	def createMenu(self):

		menubar = self.menuBar()
		filemenu = menubar.addMenu("&File")
		filemenu.addAction(QtGui.QAction("Open", self))
		filemenu.addAction(QtGui.QAction("Exit", self))
		aboutmenu = menubar.addMenu("&About")

	def focusInEvent(self, event):

		cefpython.WindowUtils.OnSetFocus(int(self.centralWidget().winIdFixed()), 0, 0, 0)

	def closeEvent(self, event):

		self.mainFrame.browser.CloseBrowser()

class MainFrame(QtGui.QWidget):

	browser = None

	def __init__(self, parent=None):

		super(MainFrame, self).__init__(parent)
		windowInfo = cefpython.WindowInfo()
		windowInfo.SetAsChild(int(self.winIdFixed()))
		self.browser = cefpython.CreateBrowserSync(windowInfo, browserSettings={}, 
		                                           navigateURL="cefsimple.html")
		self.show()

	def winIdFixed(self):

		# PySide bug: QWidget.winId() returns <PyCObject object at 0x02FD8788>,
		# there is no easy way to convert it to int.
		try:
			return int(self.winId())
		except:
			if sys.version_info[0] == 2:
				ctypes.pythonapi.PyCObject_AsVoidPtr.restype = ctypes.c_void_p
				ctypes.pythonapi.PyCObject_AsVoidPtr.argtypes = [ctypes.py_object]
				return ctypes.pythonapi.PyCObject_AsVoidPtr(self.winId())
			elif sys.version_info[0] == 3:
				ctypes.pythonapi.PyCapsule_GetPointer.restype = ctypes.c_void_p
				ctypes.pythonapi.PyCapsule_GetPointer.argtypes = [ctypes.py_object]
				return ctypes.pythonapi.PyCapsule_GetPointer(self.winId(), None)

	def moveEvent(self, event):
		
		cefpython.WindowUtils.OnSize(int(self.winIdFixed()), 0, 0, 0)

	def resizeEvent(self, event):
		
		cefpython.WindowUtils.OnSize(int(self.winIdFixed()), 0, 0, 0)

class CefApplication(QtGui.QApplication):

	timer = None

	def __init__(self, args):

		super(CefApplication, self).__init__(args)
		self.createTimer()
	
	def createTimer(self):

		self.timer = QtCore.QTimer()
		self.timer.timeout.connect(self.onTimer)
		self.timer.start(10)

	def onTimer(self):
		
		# The proper way of doing message loop should be:
		# 1. In createTimer() call self.timer.start(0)
		# 2. In onTimer() call SingleMessageLoop() only when
		#    QtGui.QApplication.instance()->hasPendingEvents() returns False.
		# But... there is a bug in Qt, hasPendingEvents() returns always true.
		
		cefpython.SingleMessageLoop()

	def stopTimer(self):
		
		# Stop the timer after Qt message loop ended, calls to SingleMessageLoop()
		# should not happen anymore.
		self.timer.stop()

if __name__ == '__main__':
	
	print("PySide version: %s" % PySide.__version__)
	print("QtCore version: %s" % QtCore.__version__)
	
	sys.excepthook = cefpython.ExceptHook
	settings = {"log_severity": cefpython.LOGSEVERITY_VERBOSE, "release_dcheck_enabled": True}
	cefpython.Initialize(settings)	
	
	app = CefApplication(sys.argv)
	mainWindow = MainWindow()
	mainWindow.show()
	app.exec_()
	app.stopTimer()

	# Need to destroy QApplication(), otherwise Shutdown() fails.
	# Unset main window also just to be safe.
	del mainWindow
	del app
	
	cefpython.Shutdown()
