# Panda3D off-screen rendering example
# http://www.panda3d.org/

# You need panda3D runtime compatible with python 2.7, the stable version (1.7.2)
# comes with python 2.6, so you will have to compile it yourself
# or download 1.8.0 sdk (unstable) which comes with python 2.7.

# In panda3D version 1.8.0 api has changed, this code works with version 1.8.0,
# to make it work with 1.7.2 slight changes will be required.

# To use custom python (not the one provided with the SDK) create a "panda.pth"
# file inside your copy of python, containing the path of the panda directory
# and the bin directory within it on separate lines, for example:
# c:\Panda3D-1.8.0
# c:\Panda3D-1.8.0\bin
# This will enable your copy of python to find the panda libraries.

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

import direct.directbase.DirectStart
from panda3d.core import *
from direct.showbase.DirectObject import DirectObject
from direct.task import Task
from math import pi, sin, cos
from direct.gui.OnscreenImage import OnscreenImage

class World(DirectObject):

    browser = None

    def __init__(self):

        environ = loader.loadModel("models/environment")
        environ.reparentTo(render)
        environ.setScale(0.25,0.25,0.25)
        environ.setPos(-8,42,0)
        taskMgr.add(self.spinCameraTask, "SpinCameraTask")

        windowHandle = base.win.getWindowHandle().getIntHandle()

        # image = OnscreenImage("wxpython.png", pos = Vec3(0,0,0))
        # image.setImage("panda3d_.jpg")

        # from panda3d.core import PTAUchar

        # tex = Texture()
        # tex.setup2dTexture(512, 512, Texture.CMOff, Texture.FRgba)
        # tex.setRamImage(tex2.getRamImage())

        # or:

        # tex = Texture()
        # tex.setup2dTexture()
        # tex.load()...?
        # tex.read("wxpython.png")

        self.tex = Texture()
        self.tex.setup2dTexture(400, 300, Texture.CMOff,
                Texture.FLuminanceAlpha)

        cm = CardMaker("browser2d")
        cm.setFrame(-0.75,.75,-0.75,0.75)
        card = render2d.attachNewNode(cm.generate())
        card.setTexture(self.tex)
        card.setHpr(0, 0, 5)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsOffscreen(windowHandle)
        self.browser = cefpython.CreateBrowserSync(
                windowInfo, browserSettings={}, navigateURL="cefsimple.html")
        self.browser.SetClientHandler(ClientHandler(self.browser, self.tex))
        self.browser.SetSize(cefpython.PET_VIEW, 400, 300);

        taskMgr.add(self.messageLoop, "CefMessageLoop")

        # python: bytearray(), memoryview() (buffer in python < 3)
        # mode = "L", "RGBX", "RGBA", and "CMYK"
        # image = Image.frombuffer(mode="RGBA", size=(w,h), buffer, "raw", "RGBA", 0, 1)
        # image.save("panda3D_buffer.png", "PNG")

    def messageLoop(self, task):
        # print("messageLoop()")
        cefpython.SingleMessageLoop()
        # Force more calls to OnPaint():
        # self.browser.GetMainFrame().ExecuteJavascript("document.body.innerHTML += '<b>asd</b>'")
        return Task.cont

    def spinCameraTask(self, task):

        angleDegrees = task.time * 6.0
        angleRadians = angleDegrees * (pi / 180.0)
        camera.setPos(20 *  sin(angleRadians), -20.0 * cos(angleRadians), 3)
        camera.setHpr(angleDegrees, 0,  0)
        return Task.cont

class ClientHandler:

    browser = None
    tex = None

    def __init__(self, browser, tex):
        self.browser = browser
        self.tex = tex

    def OnPaint(self, browser, paintElementType, dirtyRects, buffer):
        print("OnPaint()")
        print("paintElementType: %s" % paintElementType)
        print("dirtyRects: %s" % dirtyRects)

        (width, height) = self.browser.GetSize(paintElementType)

        print("buffer.GetIntPointer(): %s" % buffer.GetIntPointer())
        print("width, height = %d, %d" % (width, height))

        print("len(buffer.GetString()): %s" % len(buffer.GetString()))
        print("type: %s" % type(buffer.GetString()))

        img = self.tex.modifyRamImage()
        img.setData(buffer.GetString(origin="bottom-left", mode="bgra"))

        #arrayBuffer = PTAUchar.emptyArray(0)
        #arrayBuffer.setData(buffer.GetString())
        #self.tex.setRamImage(CPTAUchar(arrayBuffer), Texture.CMOff)

        #image = Image.fromstring("BGRA", (width, height),
        #                         buffer.GetString(), "raw", "BGRA")

        #self.tex.setRamMipmapPointerFromInt(
        #    buffer.GetIntPointer(), 0, width*height*4)

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
