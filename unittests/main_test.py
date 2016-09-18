"""General testing of CEF Python."""

# To show the window for an extended period of time increase this number.
MESSAGE_LOOP_RANGE = 25  # each iteration is 0.01 sec

import unittest
# noinspection PyUnresolvedReferences
import _runner
from os.path import basename
from cefpython3 import cefpython as cef
import time
import base64

g_browser = None
g_client_handler = None
g_external = None

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
        msg = msg.replace("ok", "<b style='color:green'>ok</b>");
        msg = msg.replace("error", "<b style='color:red'>error</b>");
        document.getElementById("console").innerHTML += msg+"<br>";
    }
    window.onload = function(){
        print("window.onload() ok");

        print("test_property1 = <i>"+test_property1+"</i>")
        if (test_property1 == "Test binding property to the 'window' object") {
            print("ok");
        } else {
            print("error");
            throw "test_property1 contains invalid string";
        }

        print("test_property2 = <i>"+JSON.stringify(test_property2)+"</i>");
        if (JSON.stringify(test_property2) == '{"key1":"Test binding property'+
                ' to the \\'window\\' object","key2":["Inside list",1,2]}') {
            print("ok");
        } else {
            print("error");
            throw "test_property2 contains invalid value";
        }

        test_function();
        print("test_function() ok");

        external.test_callbacks(function(msg_from_python, py_callback){
            print("test_callbacks(): "+msg_from_python+" ok")
            print("py_callback.toString()="+py_callback.toString());
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


class MainTest_IsolatedTest(unittest.TestCase):

    def test_main(self):
        """Main entry point."""
        # All this code must run inside one single test, otherwise strange
        # things happen.

        # Test initialization of CEF
        cef.Initialize({
            "debug": False,
            "log_severity": cef.LOGSEVERITY_ERROR,
            "log_file": "",
        })

        # Test global client callback
        global g_client_handler
        g_client_handler = ClientHandler(self)
        cef.SetGlobalClientCallback("OnAfterCreated",
                                    g_client_handler._OnAfterCreated)

        # Test creation of browser
        global g_browser
        g_browser = cef.CreateBrowserSync(url=g_datauri)
        self.assertIsNotNone(g_browser, "Browser object")

        # Test client handler
        g_browser.SetClientHandler(g_client_handler)

        # Test javascript bindings
        global g_external
        g_external = External(self)
        bindings = cef.JavascriptBindings(
                bindToFrames=False, bindToPopups=False)
        bindings.SetFunction("test_function", g_external.test_function)
        bindings.SetProperty("test_property1", g_external.test_property1)
        bindings.SetProperty("test_property2", g_external.test_property2)
        bindings.SetObject("external", g_external)
        g_browser.SetJavascriptBindings(bindings)

        # Run message loop for 0.5 sec.
        # noinspection PyTypeChecker
        for i in range(MESSAGE_LOOP_RANGE):
            cef.MessageLoopWork()
            time.sleep(0.01)

        # Test browser closing. Remember to clean reference.
        g_browser.CloseBrowser(True)
        g_browser = None

        # Give it some time to close before calling shutdown.
        # noinspection PyTypeChecker
        for i in range(25):
            cef.MessageLoopWork()
            time.sleep(0.01)

        # Client handler asserts
        self.assertTrue(g_client_handler.OnAfterCreated_called,
                        "OnAfterCreated() call")
        self.assertTrue(g_client_handler.OnLoadStart_called,
                        "OnLoadStart() call")
        self.assertTrue(g_client_handler.OnLoadEnd_called,
                        "OnLoadEnd() call")
        self.assertTrue(g_client_handler.FrameSourceVisitor_called,
                        "FrameSourceVisitor.Visit() call")
        self.assertEqual(g_client_handler.javascript_errors, 0,
                         "Javascript errors caught in OnConsoleMessage")

        # Javascript asserts
        self.assertTrue(g_external.test_function_called,
                        "js test_function() call")
        self.assertTrue(g_external.test_callbacks_called,
                        "js external.test_callbacks() call")
        self.assertTrue(g_external.py_callback_called,
                        "py_callback() call from js external.test_callbacks()")

        # Test shutdown of CEF
        cef.Shutdown()


class ClientHandler:
    test_case = None

    OnAfterCreated_called = False
    OnLoadStart_called = False
    OnLoadEnd_called = False

    FrameSourceVisitor_called = False
    frame_source_visitor = None

    javascript_errors = 0

    def __init__(self, test_case):
        self.test_case = test_case

    # noinspection PyUnusedLocal
    def _OnAfterCreated(self, browser):
        self.OnAfterCreated_called = True

    # noinspection PyUnusedLocal
    def OnLoadStart(self, browser, frame):
        self.test_case.assertEqual(browser.GetUrl(), g_datauri)
        self.OnLoadStart_called = True

    # noinspection PyUnusedLocal
    def OnLoadEnd(self, browser, frame, http_code):
        self.test_case.assertEqual(http_code, 200)
        self.frame_source_visitor = FrameSourceVisitor(self, self.test_case)
        frame.GetSource(self.frame_source_visitor)
        browser.ExecuteJavascript(
                "print('ClientHandler.OnLoadEnd() ok')")
        self.OnLoadEnd_called = True

    # noinspection PyUnusedLocal
    def OnConsoleMessage(self, browser, message, source, line):
        if "error" in message.lower() or "uncaught" in message.lower():
            self.javascript_errors += 1
            raise Exception(message)


class FrameSourceVisitor:
    client_handler = None
    test_case = None

    def __init__(self, client_handler, test_case):
        self.client_handler = client_handler
        self.test_case = test_case

    # noinspection PyUnusedLocal
    def Visit(self, value):
        self.test_case.assertIn("747ef3e6011b6a61e6b3c6e54bdd2dee",
                                g_datauri_data)
        self.client_handler.FrameSourceVisitor_called = True


class External:
    """Javascript 'window.external' object."""
    test_case = None

    # Test binding properties to the 'window' object.
    test_property1 = "Test binding property to the 'window' object"
    test_property2 = {"key1": test_property1,
                      "key2": ["Inside list", 1, 2]}

    test_function_called = False
    test_callbacks_called = False
    py_callback_called = False

    def __init__(self, test_case):
        self.test_case = test_case

    def test_function(self):
        """Test binding function to the 'window' object."""
        self.test_function_called = True

    def test_callbacks(self, js_callback):
        """Test both javascript and python callbacks."""
        def py_callback(msg_from_js):
            self.test_case.assertEqual(msg_from_js,
                                       "String sent from Javascript")
            self.py_callback_called = True
        js_callback.Call("String sent from Python", py_callback)
        self.test_callbacks_called = True


if __name__ == "__main__":
    _runner.main(basename(__file__))
