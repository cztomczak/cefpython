# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython
"""OSR testing of CEF Python."""

import unittest
import _test_runner
from cefpython3 import cefpython as cef
import platform
import sys,time,os
import base64

g_datauri_data = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script>
        function print(msg) {
            console.log(msg + " [JS]");
        }
        window.onload = function(){
            document.addEventListener("mousedown", function( e ) {
              print('mousedown:'+e.pageX+","+e.pageY)
            }, false);
            document.addEventListener("mouseup", function( e ) {
              print('mouseup:'+e.pageX+","+e.pageY)
            }, false);

            document.addEventListener("mousemove", function( e ) {
              print('mousemove:'+e.pageX+","+e.pageY)
            }, false);

            document.addEventListener("dragenter", function( e ) {
              print('dragenter:'+e.pageX+","+e.pageY)
            }, false);

            document.addEventListener("dragover", function( e ) {
              print('dragover:'+e.pageX+","+e.pageY)
            }, false);
            document.addEventListener("drop", function( e ) {
              print('drop:'+e.pageX+","+e.pageY)
            }, false);


        }
        print('window.onload init')
    </script>
    <style>
        .box{
            background-color: #F00;
            height: 200px;
        }
    </style>
</head>
<body>

<input id="selectFile" type="file">
<div class="box"></div>
</body>
</html>

"""

g_datauri = "data:text/html;base64," + base64.b64encode(g_datauri_data.encode(
    "utf-8", "replace")).decode("utf-8", "replace")
VIEWPORT_SIZE = (1024, 768)

g_subtests_ran = 0

def subtest_message(message):
    global g_subtests_ran
    g_subtests_ran += 1
    print(str(g_subtests_ran) + ". " + message)
    sys.stdout.flush()

class Handler(object):
    def __init__(self):
        self.OnPaint_called = False

    def OnConsoleMessage(self, message, **_):
        if "error" in message.lower() or "uncaught" in message.lower():
            self.javascript_errors_False = True
            raise Exception(message)
        else:
            # Check whether messages from javascript are coming
            self.OnConsoleMessage_True = True
            subtest_message(message)

    def OnDragEnter(self, browser, dragData, mask):
        subtest_message('cef.OnDragEnter() OK')
        return False

    def StartDragging(self,browser, drag_data, allowed_ops, x, y):
        subtest_message('cef.StartDragging() OK')
        return False

    def OnLoadEnd(self,browser,frame,http_code):
        subtest_message('cef.OnLoadEnd() OK')
        #testing mouse event
        browser.SendMouseClickEvent(300, 20, cef.MOUSEBUTTON_LEFT, False, 1, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
        browser.SendMouseMoveEvent(305, 25, False, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
        browser.SendMouseClickEvent(305, 25, cef.MOUSEBUTTON_LEFT, True, 1, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)

        # testing drag event
        # It can trigging cef.OnDragEnter, but still not trigger dragenter event in JS.
        dragData = cef.DragData()
        dragData.SetFragmentText('Test')
        dragData.ResetFileContents()
        browser.DragTargetDragEnter(dragData, 301, 21, cef.DRAG_OPERATION_COPY )
        browser.DragTargetDragOver(302, 22, cef.DRAG_OPERATION_COPY )
        browser.DragTargetDrop(303, 23)
        browser.DragSourceEndedAt(303, 23, cef.DRAG_OPERATION_COPY )
        browser.DragSourceSystemDragEnded()




class OSRTest_IsolatedTest(unittest.TestCase):
    def test_dragdrop(self):
        sys.excepthook = cef.ExceptHook
        cef.Initialize(settings={"windowless_rendering_enabled": True})
        parent_window_handle = 0
        window_info = cef.WindowInfo()
        window_info.SetAsOffscreen(parent_window_handle)
        browser = cef.CreateBrowserSync(window_info=window_info,
                                        url=g_datauri)
        browser.SetClientHandler(Handler())
        browser.SendFocusEvent(True)
        browser.WasResized()
        for i in range(200):
            cef.MessageLoopWork()
            time.sleep(0.01)
        cef.Shutdown()

    def test_dragdata(self):
        dragData = cef.DragData()
        testString = 'Testing DragData'
        fileUri = r"C:\temp\ninja\README"
        dragData.SetFragmentText(testString)
        self.assertEqual(testString,dragData.GetFragmentText(),'SetFragmentText')
        subtest_message('DragData.SetFragmentText() OK')
        dragData.SetFragmentHtml(testString)
        self.assertEqual(testString, dragData.GetFragmentHtml(), 'SetFragmentHtml')
        subtest_message('DragData.SetFragmentHtml() OK')
        dragData.AddFile(fileUri,'README')
        subtest_message('DragData.AddFile() OK')
        self.assertIn(fileUri, dragData.GetFileNames(), 'GetFileNames')
        subtest_message('DragData.GetFileNames() OK')

if __name__ == "__main__":
    unittests._test_runner.main(basename(__file__))