# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython
"""OSR testing of CEF Python."""

import unittest
import _test_runner
from _common import subtest_message, display_number_of_unittest, html_to_data_uri, cef_waiting
from _common import automatic_check_handlers
from cefpython3 import cefpython as cef
import platform
import sys,time,os

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
            // Test mouse event
            document.addEventListener("mousedown", function( e ) {
              print('mousedown: '+e.pageX+", "+e.pageY)
            }, false);
            document.addEventListener("mouseup", function( e ) {
              print('mouseup: '+e.pageX+", "+e.pageY)
            }, false);
            document.addEventListener("mousemove", function( e ) {
              print('mousemove: '+e.pageX+", "+e.pageY)
            }, false);

            // Test drag & drop event.
            document.addEventListener("dragenter", function( e ) {
              print('dragenter: '+e.pageX+", "+e.pageY)
            }, false);
            document.addEventListener("dragover", function( e ) {
              print('dragover: '+e.pageX+", "+e.pageY)
            }, false);
            document.addEventListener("drop", function( e ) {
              print('drop: '+e.pageX+", "+e.pageY)
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

g_datauri = html_to_data_uri(g_datauri_data)


class OSRTest_IsolatedTest(unittest.TestCase):
    def test_osr(self):
        sys.excepthook = cef.ExceptHook
        cef.Initialize(settings={"windowless_rendering_enabled": True})
        parent_window_handle = 0
        window_info = cef.WindowInfo()
        window_info.SetAsOffscreen(parent_window_handle)
        browser = cef.CreateBrowserSync(window_info=window_info,
                                        url=g_datauri)

        client_handlers = [LoadHandler(self),
                           DisplayHandler(self),
                           RenderHandler(self),
                           DragHandler(self)]

        for handler in client_handlers:
            browser.SetClientHandler(handler)

        browser.SendFocusEvent(True)
        browser.WasResized()

        # Test setting DragData.
        self.subtest_dragdata()
        cef_waiting(200)

        # Automatic check of asserts in handlers
        automatic_check_handlers(self, [] + client_handlers)

        browser.CloseBrowser(True)
        del browser
        cef.Shutdown()

    def subtest_dragdata(self):
        # Test setting DragData.
        dragData = cef.DragData()
        testString = "Testing DragData"
        fileUri = __file__
        dragData.SetFragmentText(testString)
        self.assertEqual(testString,dragData.GetFragmentText(),"SetFragmentText")
        subtest_message("DragData.SetFragmentText() OK")
        dragData.SetFragmentHtml(testString)
        self.assertEqual(testString, dragData.GetFragmentHtml(), "SetFragmentHtml")
        subtest_message("DragData.SetFragmentHtml() OK")
        dragData.AddFile(fileUri,'testfile')
        subtest_message("DragData.AddFile() OK")
        self.assertIn(fileUri, dragData.GetFileNames(), "GetFileNames")
        subtest_message("DragData.GetFileNames() OK")

class DisplayHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.test_for_True = True

    def OnConsoleMessage(self, message, **_):
        if "error" in message.lower() or "uncaught" in message.lower():
            raise Exception(message)
        else:
            subtest_message(message)

class LoadHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.test_for_True = True
        self.OnLoadEnd_True = False

    def OnLoadEnd(self,browser,frame,http_code):
        self.test_case.assertFalse(self.OnLoadEnd_True)
        self.OnLoadEnd_True = True

        # testing trigger StartDragging handler.
        # TODO: this test fails, following the steps of SendMouse*Event,
        #       it's not successfuly triggered.
        # browser.SendMouseMoveEvent(305, 20, False, 0)
        # browser.SendMouseClickEvent(300, 20, cef.MOUSEBUTTON_LEFT, False, 1, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
        # browser.SendMouseMoveEvent(305, 25, False, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
        # browser.SendMouseClickEvent(305, 25, cef.MOUSEBUTTON_LEFT, True, 1, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)

        # testing drag event
        # TODO: It can trigging cef.OnDragEnter,
        #       but still not trigger dragenter event in JS.
        dragData = cef.DragData()
        browser.DragTargetDragEnter(dragData, 301, 21, cef.DRAG_OPERATION_COPY)
        browser.DragTargetDragOver(302, 22, cef.DRAG_OPERATION_COPY)
        browser.DragTargetDrop(303, 23)
        browser.DragSourceEndedAt(303, 23, cef.DRAG_OPERATION_COPY)
        browser.DragSourceSystemDragEnded()

class RenderHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.test_for_True = True
        # self.StartDragging_True = False

    def StartDragging(self,browser, drag_data, allowed_ops, x, y):
        # self.test_case.assertFalse(self.StartDragging_True)
        # self.StartDragging_True = True
        return False

class DragHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.test_for_True = True
        self.OnDragEnter_True = False

    def OnDragEnter(self, browser, dragData, mask):
        self.test_case.assertFalse(self.OnDragEnter_True)
        self.OnDragEnter_True = True
        return False

if __name__ == "__main__":
    unittests._test_runner.main(basename(__file__))
