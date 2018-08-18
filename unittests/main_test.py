# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""General testing of CEF Python."""

import unittest
# noinspection PyUnresolvedReferences
import _test_runner
from _common import *

from cefpython3 import cefpython as cef

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
        width: 800px;
        heiht: 600px;
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

        // Test binding function: test_property3_function
        test_property3_function();
        print("test_property3_function() ok");

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
g_datauri = html_to_data_uri(g_datauri_data)


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
        if "--debug" in sys.argv:
            settings["debug"] = True
            settings["log_severity"] = cef.LOGSEVERITY_INFO
        cef.Initialize(settings)
        subtest_message("cef.Initialize() ok")

        # Global handler
        global_handler = GlobalHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    global_handler._OnAfterCreated)
        subtest_message("cef.SetGlobalClientCallback() ok")

        # Create browser
        browser = cef.CreateBrowserSync(url=g_datauri)
        self.assertIsNotNone(browser, "Browser object")
        browser.SetFocus(True)
        subtest_message("cef.CreateBrowserSync() ok")

        # Client handlers
        client_handlers = [LoadHandler(self, g_datauri),
                           DisplayHandler(self),
                           DisplayHandler2(self)]
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
            req_file = req_file.encode()
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

        # Run message loop
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

    def OnAutoResize(self, new_size, **_):
        self.OnAutoResize_True = True
        self.test_case.assertGreaterEqual(new_size[0], 800)
        self.test_case.assertLessEqual(new_size[0], 1024)
        self.test_case.assertGreaterEqual(new_size[1], 600)
        self.test_case.assertLessEqual(new_size[1], 768)


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
