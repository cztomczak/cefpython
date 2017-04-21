# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""General testing of CEF Python."""

import unittest
# noinspection PyUnresolvedReferences
import _test_runner
from os.path import basename
from cefpython3 import cefpython as cef
import time
import base64
import sys

# To show the window for an extended period of time increase this number.
MESSAGE_LOOP_RANGE = 200  # each iteration is 0.01 sec

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
    window.onload = function(){
        print("window.onload() ok");

        version = cefpython_version
        print("CEF Python: <b>"+version.version+"</b>");
        print("Chrome: <b>"+version.chrome_version+"</b>");
        print("CEF: <b>"+version.cef_version+"</b>");

        // Test binding property: test_property1
        if (test_property1 == "Test binding property to the 'window' object") {
            print("test_property_1 ok");
        } else {
            throw new Error("test_property1 contains invalid string");
        }

        // Test binding property: test_property2
        if (JSON.stringify(test_property2) == '{"key1":"Test binding property'+
                ' to the \\'window\\' object","key2":["Inside list",1,2]}') {
            print("test_property2 ok");
        } else {
            throw new Error("test_property2 contains invalid value");
        }

        // Test binding function: test_function
        test_function();
        print("test_function() ok");

        // Test binding external object and use of javascript<>python callbacks
        var start_time = new Date().getTime();
        print("[TIMER] Call Python function and then js callback that was"+
              " passed (Issue #277 test)");
        external.test_callbacks(function(msg_from_python, py_callback){
            if (msg_from_python == "String sent from Python") {
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
    };
    </script>
</head>
<body>
    <!-- FrameSourceVisitor hash = 747ef3e6011b6a61e6b3c6e54bdd2dee -->
    <h1>Main test</h1>
    <div id="console"></div>
</body>
</html>
"""
g_datauri = "data:text/html;base64,"+base64.b64encode(g_datauri_data.encode(
        "utf-8", "replace")).decode("utf-8", "replace")

g_subtests_ran = 0


def subtest_message(message):
    global g_subtests_ran
    g_subtests_ran += 1
    print(str(g_subtests_ran) + ". " + message)
    sys.stdout.flush()


class MainTest_IsolatedTest(unittest.TestCase):

    def test_main(self):
        """Main entry point."""
        # All this code must run inside one single test, otherwise strange
        # things happen.
        print("")
        print("CEF Python {ver}".format(ver=cef.__version__))
        print("Python {ver}".format(ver=sys.version[:6]))

        # Test initialization of CEF
        settings = {
            "debug": False,
            "log_severity": cef.LOGSEVERITY_ERROR,
            "log_file": "",
        }
        if "--debug" in sys.argv:
            settings["debug"] = True
            settings["log_severity"] = cef.LOGSEVERITY_INFO
        cef.Initialize(settings)
        subtest_message("cef.Initialize() ok")

        # Test global handler
        global_handler = GlobalHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    global_handler._OnAfterCreated)
        subtest_message("cef.SetGlobalClientCallback() ok")

        # Test creation of browser
        browser = cef.CreateBrowserSync(url=g_datauri)
        self.assertIsNotNone(browser, "Browser object")
        subtest_message("cef.CreateBrowserSync() ok")

        # Test other handlers: LoadHandler, DisplayHandler etc.
        client_handlers = [LoadHandler(self), DisplayHandler(self)]
        for handler in client_handlers:
            browser.SetClientHandler(handler)
        subtest_message("browser.SetClientHandler() ok")

        # Test javascript bindings
        external = External(self)
        bindings = cef.JavascriptBindings(
                bindToFrames=False, bindToPopups=False)
        bindings.SetFunction("test_function", external.test_function)
        bindings.SetProperty("test_property1", external.test_property1)
        bindings.SetProperty("test_property2", external.test_property2)
        bindings.SetProperty("cefpython_version", cef.GetVersion())
        bindings.SetObject("external", external)
        browser.SetJavascriptBindings(bindings)
        subtest_message("browser.SetJavascriptBindings() ok")

        # Run message loop for some time.
        # noinspection PyTypeChecker
        for i in range(MESSAGE_LOOP_RANGE):
            cef.MessageLoopWork()
            time.sleep(0.01)
        subtest_message("cef.MessageLoopWork() ok")

        # Test browser closing. Remember to clean reference.
        browser.CloseBrowser(True)
        del browser
        subtest_message("browser.CloseBrowser() ok")

        # Give it some time to close before calling shutdown.
        # noinspection PyTypeChecker
        for i in range(25):
            cef.MessageLoopWork()
            time.sleep(0.01)

        # Automatic check of asserts in handlers and in external
        for obj in [] + client_handlers + [global_handler, external]:
            test_for_True = False  # Test whether asserts are working correctly
            for key, value in obj.__dict__.items():
                if key == "test_for_True":
                    test_for_True = True
                    continue
                if "_True" in key:
                    self.assertTrue(value, "Check assert: " +
                                    obj.__class__.__name__ + "." + key)
                    subtest_message(obj.__class__.__name__ + "." +
                                    key.replace("_True", "") +
                                    " ok")
                elif "_False" in key:
                    self.assertFalse(value, "Check assert: " +
                                     obj.__class__.__name__ + "." + key)
                    subtest_message(obj.__class__.__name__ + "." +
                                    key.replace("_False", "") +
                                    " ok")
            self.assertTrue(test_for_True)

        # Test shutdown of CEF
        cef.Shutdown()
        subtest_message("cef.Shutdown() ok")

        # Display real number of tests there were run
        print("\nRan " + str(g_subtests_ran) + " sub-tests in test_main")
        sys.stdout.flush()


class GlobalHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case

        # Asserts for True/False will be checked just before shutdown
        self.test_for_True = True  # Test whether asserts are working correctly
        self.OnAfterCreated_True = False

    def _OnAfterCreated(self, browser, **_):
        # For asserts that are checked automatically before shutdown its
        # values should be set first, so that when other asserts fail
        # (the ones called through the test_case member) they are reported
        # correctly.
        self.test_case.assertFalse(self.OnAfterCreated_True)
        self.OnAfterCreated_True = True
        self.test_case.assertEqual(browser.GetIdentifier(), 1)


class LoadHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case
        self.frame_source_visitor = None

        # Asserts for True/False will be checked just before shutdown
        self.test_for_True = True  # Test whether asserts are working correctly
        self.OnLoadStart_True = False
        self.OnLoadEnd_True = False
        self.FrameSourceVisitor_True = False
        # self.OnLoadingStateChange_Start_True = False # FAILS
        self.OnLoadingStateChange_End_True = False

    def OnLoadStart(self, browser, frame, **_):
        self.test_case.assertFalse(self.OnLoadStart_True)
        self.OnLoadStart_True = True
        self.test_case.assertEqual(browser.GetUrl(), frame.GetUrl())
        self.test_case.assertEqual(browser.GetUrl(), g_datauri)

    def OnLoadEnd(self, browser, frame, http_code, **_):
        # OnLoadEnd should be called only once
        self.test_case.assertFalse(self.OnLoadEnd_True)
        self.OnLoadEnd_True = True
        self.test_case.assertEqual(http_code, 200)
        self.frame_source_visitor = FrameSourceVisitor(self, self.test_case)
        frame.GetSource(self.frame_source_visitor)
        browser.ExecuteJavascript("print('LoadHandler.OnLoadEnd() ok')")

    def OnLoadingStateChange(self, browser, is_loading, can_go_back,
                             can_go_forward, **_):
        if is_loading:
            # TODO: this test fails, looks like OnLoadingStaetChange with
            #       is_loading=False is being called very fast, before
            #       OnLoadStart and before client handler is set by calling
            #       browser.SetClientHandler().
            #       SOLUTION: allow to set OnLoadingStateChange through
            #       SetGlobalClientCallback similarly to _OnAfterCreated().
            # self.test_case.assertFalse(self.OnLoadingStateChange_Start_True)
            # self.OnLoadingStateChange_Start_True = True
            pass
        else:
            self.test_case.assertFalse(self.OnLoadingStateChange_End_True)
            self.OnLoadingStateChange_End_True = True
            self.test_case.assertEqual(browser.CanGoBack(), can_go_back)
            self.test_case.assertEqual(browser.CanGoForward(), can_go_forward)


class DisplayHandler(object):
    def __init__(self, test_case):
        self.test_case = test_case

        # Asserts for True/False will be checked just before shutdown
        self.test_for_True = True  # Test whether asserts are working correctly
        self.javascript_errors_False = False
        self.OnConsoleMessage_True = False

    def OnConsoleMessage(self, message, **_):
        if "error" in message.lower() or "uncaught" in message.lower():
            self.javascript_errors_False = True
            raise Exception(message)
        else:
            # Check whether messages from javascript are coming
            self.OnConsoleMessage_True = True
            subtest_message(message)


class FrameSourceVisitor(object):
    """Visitor for Frame.GetSource()."""

    def __init__(self, load_handler, test_case):
        self.load_handler = load_handler
        self.test_case = test_case

    def Visit(self, **_):
        self.test_case.assertFalse(self.load_handler.FrameSourceVisitor_True)
        self.load_handler.FrameSourceVisitor_True = True
        self.test_case.assertIn("747ef3e6011b6a61e6b3c6e54bdd2dee",
                                g_datauri_data)


class External(object):
    """Javascript 'window.external' object."""

    def __init__(self, test_case):
        self.test_case = test_case

        # Test binding properties to the 'window' object.
        self.test_property1 = "Test binding property to the 'window' object"
        self.test_property2 = {"key1": self.test_property1,
                               "key2": ["Inside list", 1, 2]}

        # Asserts for True/False will be checked just before shutdown
        self.test_for_True = True  # Test whether asserts are working correctly
        self.test_function_True = False
        self.test_callbacks_True = False
        self.py_callback_True = False

    def test_function(self):
        """Test binding function to the 'window' object."""
        self.test_function_True = True

    def test_callbacks(self, js_callback):
        """Test both javascript and python callbacks."""
        def py_callback(msg_from_js):
            self.py_callback_True = True
            self.test_case.assertEqual(msg_from_js,
                                       "String sent from Javascript")
        self.test_callbacks_True = True
        js_callback.Call("String sent from Python", py_callback)


if __name__ == "__main__":
    _test_runner.main(basename(__file__))
