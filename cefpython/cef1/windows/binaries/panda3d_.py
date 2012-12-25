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
from math import pi, sin, cos

class World(DirectObject):

    browser = None
    texture = None

    def __init__(self):

        environ = loader.loadModel("models/environment")
        environ.reparentTo(render)
        environ.setScale(0.25,0.25,0.25)
        environ.setPos(-8,42,0)
        taskMgr.add(self.spinCameraTask, "SpinCameraTask")

        windowHandle = base.win.getWindowHandle().getIntHandle()

        self.texture = Texture()
        self.texture.setup2dTexture(400, 300, Texture.CMOff,
                Texture.FLuminanceAlpha)

        cardMaker = CardMaker("browser2d")
        cardMaker.setFrame(-0.75,.75,-0.75,0.75)
        card = render2d.attachNewNode(cardMaker.generate())
        card.setTexture(self.texture)
        card.setHpr(0, 0, 5)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsOffscreen(windowHandle)
        self.browser = cefpython.CreateBrowserSync(
                windowInfo, browserSettings={}, navigateURL="cefsimple.html")
        self.browser.SetClientHandler(
                ClientHandler(self.browser, self.texture))
        self.browser.SetSize(cefpython.PET_VIEW, 400, 300);

        taskMgr.add(self.messageLoop, "CefMessageLoop")

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
        "log_severity": cefpython.LOGSEVERITY_VERBOSE,
        "release_dcheck_enabled": True
    }
    cefpython.Initialize(settings)

    print("Panda3D version: %s" % PandaSystem.getVersionString())
    w = World()
    run()
    del w

    cefpython.Shutdown()
