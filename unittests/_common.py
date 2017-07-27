# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython
"""Common function for unittests."""
import base64
import sys,time
from cefpython3 import cefpython as cef

g_subtests_ran = 0
def subtest_message(message):
    global g_subtests_ran
    g_subtests_ran += 1
    print(str(g_subtests_ran) + ". " + message)
    sys.stdout.flush()

def display_number_of_unittest(message):
    print("\nRan " + str(g_subtests_ran) + " " + message)

def html_to_data_uri(html):
    html = html.encode("utf-8", "replace")
    b64 = base64.b64encode(html).decode("utf-8", "replace")
    ret = "data:text/html;base64,{data}".format(data=b64)
    return ret

def cef_waiting(loop_range):
    for i in range(loop_range):
        cef.MessageLoopWork()
        time.sleep(0.01)

def automatic_check_handlers(test_case,handlers=[]):
    # Automatic check of asserts in handlers.
    for obj in handlers:
        test_for_True = False  # Test whether asserts are working correctly
        for key, value in obj.__dict__.items():
            if key == "test_for_True":
                test_for_True = True
                continue
            if "_True" in key:
                test_case.assertTrue(value, "Check assert: " +
                                obj.__class__.__name__ + "." + key)
                subtest_message(obj.__class__.__name__ + "." +
                                key.replace("_True", "") +
                                " ok")
            elif "_False" in key:
                test_case.assertFalse(value, "Check assert: " +
                                 obj.__class__.__name__ + "." + key)
                subtest_message(obj.__class__.__name__ + "." +
                                key.replace("_False", "") +
                                " ok")
        test_case.assertTrue(test_for_True)