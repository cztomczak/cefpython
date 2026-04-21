# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Off-screen rendering tests."""

import unittest
# noinspection PyUnresolvedReferences
import _test_runner
from _common import *

from cefpython3 import cefpython as cef

import sys

g_datauri_data = """
<!DOCTYPE html>
<html>
<head>
    <style type="text/css">
    body,html {
        font-family: Arial;
        font-size: 11pt;
    }
    </style>

    <script>
    function print(msg) {
        console.log(msg+" [JS]");
        msg = msg.replace("ok", "<b style='color:green'>ok</b>");
        msg = msg.replace("error", "<b style='color:red'>error</b>");
        document.getElementById("console").innerHTML += msg+"<br>";
    }
    function onload_helper() {
        if (!window.hasOwnProperty("cefpython_version")) {
            // Sometimes page could finish loading before javascript
            // bindings are available. Javascript bindings are sent
            // from the browser process to the renderer process via
            // IPC messaging and it can take some time (5-10ms). If
            // the page loads very fast window.onload could execute
            // before bindings are available.
            setTimeout(onload_helper, 10);
            return;
        }
        version = cefpython_version
        print("CEF Python: <b>"+version.version+"</b>");
        print("Chrome: <b>"+version.chrome_version+"</b>");
        print("CEF: <b>"+version.cef_version+"</b>");
        js_code_completed();
    }
    function selectText(ev) {
        // Selection API must run inside a real user-gesture handler so that
        // CEF fires OnTextSelectionChanged (Chrome 130+ requirement).
        var el = ev.target;
        var range = document.createRange();
        range.selectNodeContents(el);
        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    }
    window.onload = function() {
        print("window.onload() ok");
        onload_helper();
    }
    </script>
</head>
<body>
    <!-- FrameSourceVisitor hash = 747ef3e6011b6a61e6b3c6e54bdd2dee -->
    <h1 onclick="selectText(event)">Off-screen rendering test</h1>
    <div id="console"></div>
    <div id="OnTextSelectionChanged">Test selection.</div>
</body>
</html>
"""
g_datauri = cef.GetDataUrl(g_datauri_data)


class OsrTest_IsolatedTest(unittest.TestCase):
    def test_osr(self):
        """Main entry point. All the code must run inside one
        single test, otherwise strange things happen."""

        print("")
        print("CEF Python {ver}".format(ver=cef.__version__))
        print("Python {ver}".format(ver=sys.version[:6]))

        # Application settings
        settings = {
            "debug": False,
            "log_severity": cef.LOGSEVERITY_ERROR,
            "log_file": "",
            "windowless_rendering_enabled": True
        }
        if not LINUX:
            # On Linux you get a lot of "X error received" messages
            # from Chromium's "x11_util.cc", so do not show them.
            settings["log_severity"] = cef.LOGSEVERITY_WARNING
        if "--debug" in sys.argv:
            settings["debug"] = True
            settings["log_severity"] = cef.LOGSEVERITY_INFO
        if "--debug-warning" in sys.argv:
            settings["debug"] = True
            settings["log_severity"] = cef.LOGSEVERITY_WARNING

        switches = {
            # GPU acceleration is not supported in OSR mode, so must disable
            # it using these Chromium switches (Issue #240 and #463)
            "disable-gpu": "",
            "disable-gpu-compositing": "",
            # Tweaking OSR performance by setting the same Chromium flags
            # as in upstream cefclient (Issue #240).
            "enable-begin-frame-scheduling": "",
            "disable-surfaces": "",  # This is required for PDF ext to work
        }
        if LINUX:
            # Sandbox setup fails on CI runners; subprocess won't launch
            # without this under xvfb even with --disable-gpu.
            switches["no-sandbox"] = ""
            # /dev/shm is too small in CI containers; renderer subprocess
            # fails shared-memory descriptor lookup (global descriptor 7).
            switches["disable-dev-shm-usage"] = ""
            # Zygote FD-passing fails in CI containers; launch renderers
            # directly from the browser process instead.
            switches["no-zygote"] = ""
        browser_settings = {
            # Tweaking OSR performance (Issue #240)
            "windowless_frame_rate": 30,  # Default frame rate in CEF is 30
        }

        # Initialize
        cef.Initialize(settings=settings, switches=switches)
        subtest_message("cef.Initialize() ok")

        # Accessibility handler
        accessibility_handler = AccessibilityHandler(self)
        cef.SetGlobalClientHandler(accessibility_handler)
        subtest_message("cef.SetGlobalClientHandler() ok")

        # Global handler
        global_handler = GlobalHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    global_handler._OnAfterCreated)
        subtest_message("cef.SetGlobalClientCallback() ok")

        # Create browser
        window_info = cef.WindowInfo()
        window_info.SetAsOffscreen(0)
        browser = cef.CreateBrowserSync(window_info=window_info,
                                        settings=browser_settings,
                                        url=g_datauri)

        # Javascript bindings
        bindings = cef.JavascriptBindings(
                bindToFrames=False, bindToPopups=False)
        bindings.SetFunction("js_code_completed", js_code_completed)
        bindings.SetProperty("cefpython_version", cef.GetVersion())
        browser.SetJavascriptBindings(bindings)
        subtest_message("browser.SetJavascriptBindings() ok")

        # Enable accessibility
        browser.SetAccessibilityState(cef.STATE_ENABLED)
        subtest_message("cef.SetAccessibilityState(STATE_ENABLED) ok")

        # Client handlers
        client_handlers = [LoadHandler(self, g_datauri),
                           DisplayHandler(self),
                           RenderHandler(self)]
        for handler in client_handlers:
            browser.SetClientHandler(handler)

        # Initiate OSR rendering
        browser.SetFocus(True)
        browser.WasResized()

        # Message loop
        run_message_loop()

        # Close browser and clean reference
        browser.CloseBrowser(True)
        del browser
        subtest_message("browser.CloseBrowser() ok")

        # Give it some time to close before checking asserts
        # and calling shutdown.
        do_message_loop_work(25)

        # Asserts before shutdown
        # noinspection PyTypeChecker
        check_auto_asserts(self, [] + client_handlers
                                    + [global_handler,
                                       accessibility_handler])

        # Test shutdown of CEF
        cef.Shutdown()
        subtest_message("cef.Shutdown() ok")

        # Display summary
        show_test_summary(__file__)
        sys.stdout.flush()


class AccessibilityHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case

        # Asserts for True/False will be checked just before shutdown.
        # Test whether asserts are working correctly.
        self.test_for_True = True

        self.javascript_errors_False = False
        self._OnAccessibilityTreeChange_True = False
        self._OnAccessibilityLocationChange_True = False
        self.loadComplete_True = False



    def _OnAccessibilityTreeChange(self, value):

        self._OnAccessibilityTreeChange_True = True
        for event in value.get('events', []):
            if "event_type" in event:
                if event["event_type"] == "loadComplete":
                    # LoadHandler.OnLoadEnd is called after this event
                    self.test_case.assertFalse(self.loadComplete_True)
                    self.loadComplete_True = True

    def _OnAccessibilityLocationChange(self, **_):
        self._OnAccessibilityLocationChange_True = True


def _click_h1_to_select(browser):
    """Send a real click to the h1 element after layout is complete.

    Chrome 130+ requires the Selection API to run inside a real user-gesture
    event handler for OnTextSelectionChanged to fire. The h1 has an onclick
    handler (selectText) that selects the element's text via the Selection API.
    h1 position: body margin 8px + h1 margin-block-start ~20px ≈ y=28 top,
    h1 font-size ~29px ≈ y=57px bottom; click center at y=43.
    """
    browser.SendMouseClickEvent(200, 43, cef.MOUSEBUTTON_LEFT,
                                mouseUp=False, clickCount=1)
    browser.SendMouseClickEvent(200, 43, cef.MOUSEBUTTON_LEFT,
                                mouseUp=True, clickCount=1)
    browser.Invalidate(cef.PET_VIEW)
    subtest_message("_click_h1_to_select() ok")


class RenderHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case

        # Asserts for True/False will be checked just before shutdown.
        # Test whether asserts are working correctly.
        self.test_for_True = True

        self.GetViewRect_True = False
        self.OnPaint_True = False
        self.OnTextSelectionChanged_True = False

    def GetViewRect(self, rect_out, **_):
        """Called to retrieve the view rectangle which is relative
        to screen coordinates. Return True if the rectangle was
        provided."""
        # rect_out --> [x, y, width, height]
        self.GetViewRect_True = True
        rect_out.extend([0, 0, 800, 600])
        return True

    def OnPaint(self, browser, element_type, paint_buffer, **_):
        """Called when an element should be painted."""
        if element_type == cef.PET_VIEW:
            self.test_case.assertEqual(paint_buffer.width, 800)
            self.test_case.assertEqual(paint_buffer.height, 600)
            if not self.OnPaint_True:
                self.OnPaint_True = True
                subtest_message("RenderHandler.OnPaint: viewport ok")
                # Layout is now complete. Post the click so it isn't
                # re-entrant with OnPaint and hit-testing is reliable.
                cef.PostDelayedTask(cef.TID_UI, 100, _click_h1_to_select,
                                    browser)
        else:
            raise Exception("Unsupported element_type in OnPaint")

    def OnTextSelectionChanged(self, selected_text, selected_range, **_):
        self.OnTextSelectionChanged_True = True
        if selected_text:
            # Verify the h1 text is selected when a non-empty selection fires.
            self.test_case.assertEqual(selected_text,
                                       "Off-screen rendering test")


if __name__ == "__main__":
    _test_runner.main(os.path.basename(__file__))
