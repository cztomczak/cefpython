# Copyright (c) 2017 CEF Python, see the Authors file.
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

MESSAGE_LOOP_RANGE = 200

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
            document.getElementById('selectFile').addEventListener('change', function(e){
                print('Received file change "'+this.files[0].name + '" OK')
            }, true);

        }

    </script>
</head>
<body>

<input id="selectFile" type="file">

</body>
</html>
"""

g_datauri = "data:text/html;base64," + base64.b64encode(g_datauri_data.encode(
    "utf-8", "replace")).decode("utf-8", "replace")

g_subtests_ran = 0

def subtest_message(message):
    global g_subtests_ran
    g_subtests_ran += 1
    print(str(g_subtests_ran) + ". " + message)
    sys.stdout.flush()


class DropTest_IsolatedTest(unittest.TestCase):
    def test_filedialog(self):
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

        browser = cef.CreateBrowserSync(url=g_datauri)
        browser.SetClientHandler(DisplayHandler(self))


        # Test handlers: DialogHandler etc.
        browser.SetClientHandler(DialogHandler())

        # Run message loop for some time.
        for i in range(MESSAGE_LOOP_RANGE):
            cef.MessageLoopWork()
            time.sleep(0.01)

        #Simulating file dialog click event for testing OnFileDialog handler
        browser.SendMouseClickEvent(67, 20, cef.MOUSEBUTTON_LEFT, False, 1)
        browser.SendMouseClickEvent(67, 20, cef.MOUSEBUTTON_LEFT, True, 1)

        cef.Shutdown()


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


class DialogHandler(object):
    def OnFileDialog(self, browser, mode,title, default_file_path,accept_filters,selected_accept_filter,file_dialog_callback):
        subtest_message("cef.OnFileDialog() ok")
        file_dialog_callback.Continue(selected_accept_filter, [r"filedialog_test.py"])
        return False


if __name__ == "__main__":
    unittests._test_runner.main(basename(__file__))
