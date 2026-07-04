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
        // Always target the h1 directly so any click on the page works.
        var el = document.querySelector('h1');
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
<body onclick="selectText(event)">
    <!-- FrameSourceVisitor hash = 747ef3e6011b6a61e6b3c6e54bdd2dee -->
    <h1>Off-screen rendering test</h1>
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
        }
        if not MAC:
            # Tweaking OSR performance (Issue #240). On macOS ARM the viz
            # Surfaces API is required for OSR browser creation, so these
            # switches (which disable it) must not be passed there.
            switches["enable-begin-frame-scheduling"] = ""
            switches["disable-surfaces"] = ""  # Required for PDF ext to work
        if LINUX:
            # Open a GDK/X11 display connection before CEF initialises.
            init_gtk()
            # cefpython does not ship a chrome-sandbox (setuid) binary.
            # Disable SUID/namespace sandboxes; Chrome falls back to seccomp-BPF
            # which keeps GlobalDescriptors key 7 registered for subprocesses.
            # Do NOT pass --no-sandbox: it skips key 7 registration but encodes
            # it in --pseudonymization-salt-handle, causing a CHECK-crash.
            switches["disable-setuid-sandbox"] = ""
                    # /dev/shm is too small in CI containers.
            switches["disable-dev-shm-usage"] = ""
            # Run GPU process inside the browser process so it is not
            # spawned during CefInitialize() where it would fail.
            switches["in-process-gpu"] = ""
            switches["no-zygote"] = ""
            # Force X11 rendering via XWayland (see main_test.py for details).
            switches["ozone-platform"] = "x11"
            # Run the network service in-process so no utility subprocess
            # needs to be spawned (reduces spawn overhead on CI).
            # The feature string in Chrome 130+ is "NetworkServiceInProcess2".
            switches["enable-features"] = "NetworkServiceInProcess2"
        if MAC:
            # Prevent macOS keychain authorization prompts during init.
            # CEF's own test infrastructure (client_app_browser.cc) does
            # the same on macOS.
            switches["use-mock-keychain"] = ""
            # Chrome 130+ MachPortRendezvousServer registers its bootstrap
            # service as BaseBundleID()+".MachPortRendezvousServer."+pid.
            # Python processes with only ad-hoc code signing receive a
            # restricted bootstrap namespace from macOS, so renderer
            # subprocesses cannot bootstrap_look_up the service.
            # --single-process runs the renderer inside the browser process,
            # eliminating the subprocess bootstrap_look_up entirely.
            # (--in-process-renderer was removed in Chrome 130+.)
            switches["single-process"] = ""
            # --single-process puts the renderer's V8 in the browser process,
            # which requires a large contiguous CodeRange for JIT code.
            # --jitless disables V8 JIT, removing that requirement.
            switches["js-flags"] = "--jitless"
            # Run the network service in-process to avoid Mach port rendezvous
            # failures for the network utility subprocess on macOS.
            # (Feature name in Chrome 130+: "NetworkServiceInProcess2".)
            switches["enable-features"] = "NetworkServiceInProcess2"
        browser_settings = {
            # Tweaking OSR performance (Issue #240)
            "windowless_frame_rate": 30,  # Default frame rate in CEF is 30
        }

        # Register global callbacks and the OnContextInitialized browser-
        # creation callback BEFORE cef.Initialize(). Under CEF's Chrome runtime
        # OnContextInitialized can fire during cef.Initialize() itself, and the
        # browser is created from that callback, so the callbacks must already
        # be registered. Matches CEF's cefsimple sample.

        # Accessibility handler
        accessibility_handler = AccessibilityHandler(self)
        cef.SetGlobalClientHandler(accessibility_handler)
        subtest_message("cef.SetGlobalClientHandler() ok")

        # Global handler
        global_handler = GlobalHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    global_handler._OnAfterCreated)
        subtest_message("cef.SetGlobalClientCallback() ok")

        # Client handlers (constructed up front; browser is created below in
        # the OnContextInitialized callback).
        client_handlers = [LoadHandler(self, g_datauri),
                           DisplayHandler(self),
                           RenderHandler(self)]

        # Holder so the browser created inside the callback is reachable after
        # the message loop returns.
        browser_holder = {}

        def _on_context_initialized():
            # The CEF context is ready — create and configure the browser here
            # (see cefpython.pyx > CreateBrowserSync).
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
            for handler in client_handlers:
                browser.SetClientHandler(handler)

            # Initiate OSR rendering
            browser.SetFocus(True)
            browser.WasResized()

            browser_holder["browser"] = browser

        cef.SetGlobalClientCallback("OnContextInitialized",
                                    _on_context_initialized)
        subtest_message("cef.SetGlobalClientCallback(OnContextInitialized) ok")

        # Initialize. OnContextInitialized fires during / shortly after this,
        # creating the browser and starting OSR rendering.
        cef.Initialize(settings=settings, switches=switches)
        subtest_message("cef.Initialize() ok")

        # Message loop lets the page finish loading and rendering.
        run_message_loop()

        browser = browser_holder.get("browser")
        self.assertIsNotNone(browser,
                             "Browser created from OnContextInitialized")

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
        # Not fired since Chrome M117 (CEF issue #3545); kept so the binding
        # doesn't raise if somehow called.
        pass


def _click_h1_to_select(browser):
    """Send a real click anywhere in the viewport after layout is complete.

    Chrome 130+ requires the Selection API to run inside a real user-gesture
    event handler for OnTextSelectionChanged to fire. The body has an onclick
    handler (selectText) that selects the h1 text via the Selection API.
    Click at the center of the 800x600 viewport — guaranteed to land on the
    body regardless of font metrics or CI rendering differences.
    """
    browser.SendMouseClickEvent(400, 300, cef.MOUSEBUTTON_LEFT,
                                mouseUp=False, clickCount=1)
    browser.SendMouseClickEvent(400, 300, cef.MOUSEBUTTON_LEFT,
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
