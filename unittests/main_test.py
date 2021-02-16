# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""General testing of CEF Python."""

import unittest
# noinspection PyUnresolvedReferences
import _test_runner
from _common import *

from cefpython3 import cefpython as cef

import glob
import os
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
    body {
        width: 810px;
        heiht: 610px;
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

        // Test binding function: test_function
        test_function();
        print("test_function() ok");

        // Test binding property: test_property1
        if (test_property1 === "Test binding property to the 'window' object") {
            print("test_property_1 ok");
        } else {
            throw new Error("test_property1 contains invalid string");
        }

        // Test binding property: test_property2
        if (JSON.stringify(test_property2) === '{"key1":"Test binding property'+
                ' to the \\'window\\' object","key2":["Inside list",2147483647,"2147483648"]}') {
            print("test_property2 ok");
        } else {
            print("test_property2 invalid value: " + JSON.stringify(test_property2));
            throw new Error("test_property2 contains invalid value");
        }

        // Test binding function: test_property3_function
        test_property3_function();
        print("test_property3_function() ok");

        // Test binding external object and use of javascript<>python callbacks
        var start_time = new Date().getTime();
        print("[TIMER] Call Python function and then js callback that was"+
              " passed (Issue #277 test)");
        external.test_callbacks(function(msg_from_python, py_callback){
            if (msg_from_python === "String sent from Python") {
                print("test_callbacks() ok");
                var execution_time = new Date().getTime() - start_time;
                print("[TIMER]: Elapsed = "+String(execution_time)+" ms");
            } else {
                throw new Error("test_callbacks(): msg_from_python contains"+
                                " invalid value");
            }
            py_callback("String sent from Javascript");
            print("py_callback() ok");
        });

        // Test popup
        window.open("about:blank");

        // Done
        js_code_completed();
    }
    window.onload = function() {
        print("window.onload() ok");
        onload_helper();
    }
    </script>
</head>
<body>
    <!-- FrameSourceVisitor hash = 747ef3e6011b6a61e6b3c6e54bdd2dee -->
    <h1>Main test</h1>
    <div id="console"></div>
</body>
</html>
"""
g_datauri = cef.GetDataUrl(g_datauri_data)


class MainTest_IsolatedTest(unittest.TestCase):
    def test_main(self):
        """Main entry point. All the code must run inside one
        single test, otherwise strange things happen."""

        print("")
        print("CEF Python {ver}".format(ver=cef.__version__))
        print("Python {ver}".format(ver=sys.version[:6]))

        # Test initialization of CEF
        settings = {
            "debug": False,
            "log_severity": cef.LOGSEVERITY_ERROR,
            "log_file": "",
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
        cef.Initialize(settings)
        subtest_message("cef.Initialize() ok")

        # CRL set file
        certrevoc_dir = ""
        if WINDOWS:
            certrevoc_dir = r"C:\localappdata\Google\Chrome\User Data" \
                            r"\CertificateRevocation"
        elif LINUX:
            certrevoc_dir = r"/home/*/.config/google-chrome" \
                            r"/CertificateRevocation"
        elif MAC:
            certrevoc_dir = r"/Users/*/Library/Application Support/Google" \
                            r"/Chrome/CertificateRevocation"
        crlset_files = glob.iglob(os.path.join(certrevoc_dir, "*",
                                               "crl-set"))
        crlset = ""
        for crlset in crlset_files:
            pass
        if os.path.exists(crlset):
            cef.LoadCrlSetsFile(crlset)
            subtest_message("cef.LoadCrlSetsFile ok")

        # High DPI on Windows.
        # Setting DPI awareness from Python is usually too late and should be done
        # via manifest file. Alternatively change python.exe properties > Compatibility
        # > High DPI scaling override > Application.
        # Using cef.DpiAware.EnableHighDpiSupport is problematic, it can cause
        # display glitches.
        if WINDOWS:
            self.assertIsInstance(cef.DpiAware.GetSystemDpi(), tuple)
            window_size = cef.DpiAware.CalculateWindowSize(800, 600)
            self.assertIsInstance(window_size, tuple)
            self.assertGreater(window_size[0], 0)
            self.assertGreater(cef.DpiAware.Scale((800, 600))[0], 0)

            # OFF - see comments above.
            # cef.DpiAware.EnableHighDpiSupport()
            # self.assertTrue(cef.DpiAware.IsProcessDpiAware())

            # Make some calls again after DPI Aware was set
            self.assertIsInstance(cef.DpiAware.GetSystemDpi(), tuple)
            self.assertGreater(cef.DpiAware.Scale([800, 600])[0], 0)
            self.assertIsInstance(cef.DpiAware.Scale(800), int)
            self.assertGreater(cef.DpiAware.Scale(800), 0)
            subtest_message("cef.DpiAware ok")

        # Global handler
        global_handler = GlobalHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    global_handler._OnAfterCreated)
        subtest_message("cef.SetGlobalClientCallback() ok")

        # Create browser
        browser_settings = {
            "inherit_client_handlers_for_popups": False,
        }
        browser = cef.CreateBrowserSync(url=g_datauri,
                                        settings=browser_settings)
        self.assertIsNotNone(browser, "Browser object")
        browser.SetFocus(True)
        subtest_message("cef.CreateBrowserSync() ok")

        # Client handlers
        display_handler2 = DisplayHandler2(self)
        v8context_handler = V8ContextHandler(self)
        client_handlers = [LoadHandler(self, g_datauri),
                           DisplayHandler(self),
                           display_handler2,
                           v8context_handler]
        for handler in client_handlers:
            browser.SetClientHandler(handler)
        subtest_message("browser.SetClientHandler() ok")

        # Javascript bindings
        external = External(self)
        bindings = cef.JavascriptBindings(
                bindToFrames=False, bindToPopups=False)
        bindings.SetFunction("js_code_completed", js_code_completed)
        bindings.SetFunction("test_function", external.test_function)
        bindings.SetProperty("test_property1", external.test_property1)
        bindings.SetProperty("test_property2", external.test_property2)
        # Property with a function value can also be bound. CEF Python
        # supports passing functions as callbacks when called from
        # javascript, and as a side effect any value and in this case
        # a property can also be a function.
        bindings.SetProperty("test_property3_function",
                             external.test_property3_function)
        bindings.SetProperty("cefpython_version", cef.GetVersion())
        bindings.SetObject("external", external)
        browser.SetJavascriptBindings(bindings)
        subtest_message("browser.SetJavascriptBindings() ok")

        # Set auto resize. Call it after js bindings were set.
        browser.SetAutoResizeEnabled(enabled=True,
                                     min_size=[800, 600],
                                     max_size=[1024, 768])
        subtest_message("browser.SetAutoResizeEnabled() ok")

        # Test Request.SetPostData(list)
        # noinspection PyArgumentList
        req = cef.Request.CreateRequest()
        req_file = os.path.dirname(os.path.abspath(__file__))
        req_file = os.path.join(req_file, "main_test.py")
        if sys.version_info.major > 2:
            req_file = req_file.encode("utf-8")
        req_data = [b"--key=value", b"@"+req_file]
        req.SetMethod("POST")
        req.SetPostData(req_data)
        self.assertEqual(req_data, req.GetPostData())
        subtest_message("cef.Request.SetPostData(list) ok")

        # Test Request.SetPostData(dict)
        # noinspection PyArgumentList
        req = cef.Request.CreateRequest()
        req_data = {b"key": b"value"}
        req.SetMethod("POST")
        req.SetPostData(req_data)
        self.assertEqual(req_data, req.GetPostData())
        subtest_message("cef.Request.SetPostData(dict) ok")

        # Cookie manager
        self.assertIsInstance(cef.CookieManager.CreateManager(path=""),
                              cef.PyCookieManager)
        self.assertIsInstance(cef.CookieManager.GetGlobalManager(),
                              cef.PyCookieManager)
        self.assertIsInstance(cef.CookieManager.GetBlockingManager(),
                              cef.PyCookieManager)
        subtest_message("cef.CookieManager ok")

        # Window Utils
        if WINDOWS:
            hwnd = 1  # When using 0 getting issues with OnautoResize
            self.assertFalse(cef.WindowUtils.IsWindowHandle(hwnd))
            cef.WindowUtils.OnSetFocus(hwnd, 0, 0, 0)
            cef.WindowUtils.OnSize(hwnd, 0, 0, 0)
            cef.WindowUtils.OnEraseBackground(hwnd, 0, 0, 0)
            cef.WindowUtils.GetParentHandle(hwnd)
            cef.WindowUtils.SetTitle(browser, "Main test")
            subtest_message("cef.WindowUtils ok")
        elif LINUX:
            cef.WindowUtils.InstallX11ErrorHandlers()
            subtest_message("cef.WindowUtils ok")
        elif MAC:
            hwnd = 0
            cef.WindowUtils.GetParentHandle(hwnd)
            cef.WindowUtils.IsWindowHandle(hwnd)
            subtest_message("cef.WindowUtils ok")

        # Run message loop
        run_message_loop()

        # Make sure popup browser was destroyed
        self.assertIsInstance(cef.GetBrowserByIdentifier(MAIN_BROWSER_ID),
                              cef.PyBrowser)
        self.assertIsNone(cef.GetBrowserByIdentifier(POPUP_BROWSER_ID))
        subtest_message("cef.GetBrowserByIdentifier() ok")

        # Close browser and clean reference
        browser.CloseBrowser(True)
        del browser
        subtest_message("browser.CloseBrowser() ok")

        # Give it some time to close before checking asserts
        # and calling shutdown.
        do_message_loop_work(25)

        # Asserts before shutdown
        self.assertEqual(display_handler2.OnLoadingProgressChange_Progress,
                         1.0)
        # noinspection PyTypeChecker
        check_auto_asserts(self, [] + client_handlers
                                    + [global_handler,
                                       external])

        # Test shutdown of CEF
        cef.Shutdown()
        subtest_message("cef.Shutdown() ok")

        # Display summary
        show_test_summary(__file__)
        sys.stdout.flush()


class DisplayHandler2(object):
    def __init__(self, test_case):
        self.test_case = test_case
        # Asserts for True/False will be checked just before shutdown.
        # Test whether asserts are working correctly.
        self.test_for_True = True
        self.OnAutoResize_True = False
        self.OnLoadingProgressChange_True = False
        self.OnLoadingProgressChange_Progress = 0.0

    def OnAutoResize(self, new_size, **_):
        self.OnAutoResize_True = True
        self.test_case.assertGreaterEqual(new_size[0], 800)
        self.test_case.assertLessEqual(new_size[0], 1024)
        self.test_case.assertGreaterEqual(new_size[1], 600)
        self.test_case.assertLessEqual(new_size[1], 768)

    def OnLoadingProgressChange(self, progress, **_):
        self.OnLoadingProgressChange_True = True
        self.OnLoadingProgressChange_Progress = progress


class V8ContextHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.OnContextCreatedFirstCall_True = False
        self.OnContextCreatedSecondCall_True = False
        self.OnContextReleased_True = False

    def OnContextCreated(self, browser, frame):
        """CEF creates one context when creating browser and this one is
           released immediately. Then when it loads url another context is
           created."""
        if not self.OnContextCreatedFirstCall_True:
            self.OnContextCreatedFirstCall_True = True
        else:
            self.test_case.assertFalse(self.OnContextCreatedSecondCall_True)
            self.OnContextCreatedSecondCall_True = True
        self.test_case.assertEqual(browser.GetIdentifier(), MAIN_BROWSER_ID)
        self.test_case.assertEqual(frame.GetIdentifier(), 2)

    def OnContextReleased(self, browser, frame):
        """This gets called only for the initial empty context, see comment
           in OnContextCreated. This should never get called for the main frame
           of the main browser, because it happens during app exit and there
           isn't enough time for the IPC messages to go through."""
        self.test_case.assertFalse(self.OnContextReleased_True)
        self.OnContextReleased_True = True
        self.test_case.assertEqual(browser.GetIdentifier(), MAIN_BROWSER_ID)
        self.test_case.assertEqual(frame.GetIdentifier(), 2)

class External(object):
    """Javascript 'window.external' object."""

    def __init__(self, test_case):
        self.test_case = test_case

        # Test binding properties to the 'window' object.
        # 2147483648 is out of INT_MAX limit and will be sent to JS as string value.
        self.test_property1 = "Test binding property to the 'window' object"
        self.test_property2 = {"key1": self.test_property1,
                               "key2": ["Inside list", 2147483647, 2147483648]}

        # Asserts for True/False will be checked just before shutdown
        self.test_for_True = True  # Test whether asserts are working correctly
        self.test_function_True = False
        self.test_property3_function_True = False
        self.test_callbacks_True = False
        self.py_callback_True = False

    def test_function(self):
        """Test binding function to the 'window' object."""
        self.test_function_True = True

    def test_property3_function(self):
        """Test binding function to the 'window' object."""
        self.test_property3_function_True = True

    def test_callbacks(self, js_callback):
        """Test both javascript and python callbacks."""
        def py_callback(msg_from_js):
            self.py_callback_True = True
            self.test_case.assertEqual(msg_from_js,
                                       "String sent from Javascript")
        self.test_callbacks_True = True
        js_callback.Call("String sent from Python", py_callback)


if __name__ == "__main__":
    _test_runner.main(os.path.basename(__file__))
