# CEF off-screen rendering using the Panda3D game engine:
# http://www.panda3d.org/

# You need panda3D runtime that is compatible with python 2.7,
# version 1.8.0 comes by default with python 2.7.

# To use custom python (not the one provided with the SDK)
# create a "panda.pth" file inside your copy of python, in
# this file put paths to panda & bin directory on separate,
# for example:
#
# c:\Panda3D-1.8.0
# c:\Panda3D-1.8.0\bin
#
# This will enable your copy of python to find the panda libraries.

# TODO: fix the blurriness of the browser when window is resized.

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Unsupported architecture: %s" % (
            platform.architecture()[0]))

import sys
if sys.hexversion >= 0x02070000 and sys.hexversion < 0x03000000:
    import cefpython_py27 as cefpython
elif sys.hexversion >= 0x03000000 and sys.hexversion < 0x04000000:
    import cefpython_py32 as cefpython
else:
    raise Exception("Unsupported python version: %s" % sys.version)

import direct.directbase.DirectStart
from panda3d.core import *
from direct.showbase.DirectObject import DirectObject
from direct.task import Task
from math import pi, sin, cos, floor, ceil
import platform
import ctypes

class World(DirectObject):
    browser = None
    texture = None

    def __init__(self):
        wp = WindowProperties()
        wp.setTitle('Panda3D example')
        base.win.requestProperties(wp)

        environ = loader.loadModel("models/environment")
        environ.reparentTo(render)
        environ.setScale(0.25,0.25,0.25)
        environ.setPos(-8,42,0)
        taskMgr.add(self.spinCameraTask, "SpinCameraTask")

        self.texture = Texture()
        self.texture.setCompression(Texture.CMOff)
        self.texture.setComponentType(Texture.TUnsignedByte)
        self.texture.setFormat(Texture.FRgba4)
        self.texture.setTexturesPower2(0)
        self.texture.setAutoTextureScale(0)

        self.cardMaker = CardMaker("browser2d")
        self.cardMaker.setFrame(-0.75, 0.75, -0.75, 0.75)
        node = self.cardMaker.generate()
        self.nodePath = render2d.attachNewNode(node)
        self.nodePath.setTexture(self.texture)
        self.nodePath.setHpr(0, 0, 5)

        windowHandle = base.win.getWindowHandle().getIntHandle()
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsOffscreen(windowHandle)

        browserSettings = {"animation_frame_rate": 60}

        self.browser = cefpython.CreateBrowserSync(
                windowInfo, browserSettings, navigateURL="cefsimple.html")
        self.browser.SetClientHandler(
                ClientHandler(self.browser, self.texture))

        # SetFocus needs to be called after browser creation.
        if platform.system() == "Windows":
            ctypes.windll.user32.SetFocus(windowHandle)

        self.setBrowserSize()
        self.accept("window-event", self.setBrowserSize)

        # Browser methods for sending mouse/keyboard/focus events:
        # SendKeyEvent(), SendMouseClickEvent(), SendMouseMoveEvent(),
        # SendMouseWheelEvent(), SendFocusEvent(), SendCaptureLostEvent().

        self.initMouseHandlers()
        self.initKeyboardHandlers()

        taskMgr.add(self.messageLoop, "CefMessageLoop")

    def setBrowserSize(self, window=None):
        width = int(round(base.win.getXSize() * 0.75))
        height = int(round(base.win.getYSize() * 0.75))
        self.texture.setXSize(width)
        self.texture.setYSize(height)
        self.browser.SetSize(cefpython.PET_VIEW, width, height)

    def initMouseHandlers(self):
        taskMgr.add(self.onMouseMove, "onMouseMove")
        self.accept("mouse1", self.onMouseDown)
        self.accept("mouse1-up", self.onMouseUp)
        self.accept("wheel_up", self.onMouseWheelUp)
        self.accept("wheel_down", self.onMouseWheelDown)

    def initKeyboardHandlers(self):
        pass

    def isMouseInsideBrowser(self, mouse):
        if mouse.getX() >= -0.75 and mouse.getX() <= 0.75 and (
                mouse.getY() >= -0.75 and mouse.getY() <= 0.75):
            return True
        else:
            return False

    def getMousePixelCoordinates(self, mouse):
        # This calculation works only for the browser area.
        relX = mouse.getX()
        relY = mouse.getY()
        relX += 0.75 # 0 .. 1.5
        relY += 0.75 # 0 .. 1.5
        width = self.texture.getXSize()
        height = self.texture.getYSize()
        width /= 1.5
        height /= 1.5
        pixelX = relX * width
        pixelY = relY * height
        pixelY = abs(pixelY - self.texture.getYSize())
        pixelX = int(round(pixelX))
        pixelY = int(round(pixelY))
        return (pixelX, pixelY)

    def onMouseMove(self, task):
        if base.mouseWatcherNode.hasMouse():
            mouse = base.mouseWatcherNode.getMouse()
            if self.isMouseInsideBrowser(mouse):
                self.nodePath.setHpr(0, 0, 0)
                (x,y) = self.getMousePixelCoordinates(mouse)
                self.browser.SendMouseMoveEvent(x, y, mouseLeave=False)
            else:
                self.browser.SendMouseMoveEvent(-1, -1, mouseLeave=True)
                self.nodePath.setHpr(0, 0, 5)
        else:
            self.nodePath.setHpr(0, 0, 5)
        return Task.cont

    def onMouseDown(self):
        mouse = base.mouseWatcherNode.getMouse()
        (x,y) = self.getMousePixelCoordinates(mouse)
        self.browser.SendMouseClickEvent(x, y, cefpython.MOUSEBUTTON_LEFT,
                mouseUp=False, clickCount=1)

    def onMouseUp(self):
        mouse = base.mouseWatcherNode.getMouse()
        (x,y) = self.getMousePixelCoordinates(mouse)
        self.browser.SendMouseClickEvent(x, y, cefpython.MOUSEBUTTON_LEFT,
                mouseUp=True, clickCount=1)

    def onMouseWheelUp(self):
        if base.mouseWatcherNode.hasMouse():
            mouse = base.mouseWatcherNode.getMouse()
            if self.isMouseInsideBrowser(mouse):
                (x,y) = self.getMousePixelCoordinates(mouse)
                self.browser.SendMouseWheelEvent(x, y, deltaX=0, deltaY=120)

    def onMouseWheelDown(self):
        if base.mouseWatcherNode.hasMouse():
            mouse = base.mouseWatcherNode.getMouse()
            if self.isMouseInsideBrowser(mouse):
                (x,y) = self.getMousePixelCoordinates(mouse)
                self.browser.SendMouseWheelEvent(x, y, deltaX=0, deltaY=-120)

    def messageLoop(self, task):
        cefpython.SingleMessageLoop()
        return Task.cont

    def spinCameraTask(self, task):
        angleDegrees = task.time * 6.0
        angleRadians = angleDegrees * (pi / 180.0)
        camera.setPos(20 *  sin(angleRadians), -20.0 * cos(angleRadians), 3)
        camera.setHpr(angleDegrees, 0,  0)
        return Task.cont

class ClientHandler:
    browser = None
    texture = None

    def __init__(self, browser, texture):
        self.browser = browser
        self.texture = texture

    def OnPaint(self, browser, paintElementType, dirtyRects, buffer):
        (width, height) = self.browser.GetSize(paintElementType)
        img = self.texture.modifyRamImage()
        img.setData(buffer.GetString(mode="bgra", origin="bottom-left"))

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        return
        self._saveImage()

    def _saveImage(self):
        try:
            from PIL import Image
        except:
            print("PIL library not available, can't save image")
            return
        (width, height) = self.browser.GetSize(cefpython.PET_VIEW)
        buffer = self.browser.GetImage(cefpython.PET_VIEW, width, height)
        image = Image.fromstring(
            "RGBA", (width,height),
            buffer.GetString(mode="rgba", origin="top-left"),
            "raw", "RGBA", 0, 1)
        image.save("panda3d_image.png", "PNG")

if __name__ == "__main__":
    sys.excepthook = cefpython.ExceptHook
    settings = {
        "log_file": cefpython.GetRealPath("debug.log"),
        # Change to LOGSEVERITY_INFO if you want less debug output.
        "log_severity": cefpython.LOGSEVERITY_VERBOSE,
        "release_dcheck_enabled": True
    }
    cefpython.Initialize(settings)

    print("Panda3D version: %s" % PandaSystem.getVersionString())
    w = World()
    run()
    del w

    cefpython.Shutdown()
