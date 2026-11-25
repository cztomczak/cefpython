# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Automated regression test script for Issue #765 and PR #768.

Validates 8 checks across the 7 subsystems where 32-bit ID counters are used:
  1a. PostTask (TID_UI)
  1b. PostDelayedTask (TID_UI)
  2.  JavaScript callback (JS passing function to Python, Python executing it)
  3.  Python callback (Python passing function to JS, JS executing it)
  4.  ResourceHandler (custom URL intercept with payload verification)
  5.  WebRequest (cef.WebRequest.Create to local server with status and payload verification)
  6.  StringVisitor (frame.GetSource)
  7.  CookieVisitor (specific cookie name/value verification via VisitAllCookies)

Runs automatically on startup. Returns exit code 0 on success, exit code 1 on failure.
"""

import http.server
import socketserver
import sys
import threading
import time
from cefpython3 import cefpython as cef

# -----------------------------------------------------------------------------
# Test Status Tracking
# -----------------------------------------------------------------------------

TEST_CHECKLIST = {
    "1a_post_task": {
        "title": "1a. PostTask",
        "passed": False,
        "detail": ""
    },
    "1b_post_delayed_task": {
        "title": "1b. PostDelayedTask",
        "passed": False,
        "detail": ""
    },
    "2_js_callback": {
        "title": "2.  JavaScript callback (JS -> Python -> JS)",
        "passed": False,
        "detail": ""
    },
    "3_py_callback": {
        "title": "3.  Python callback (Python -> JS -> Python)",
        "passed": False,
        "detail": ""
    },
    "4_resource_handler": {
        "title": "4.  ResourceHandler (ProcessRequest & ReadResponse verified)",
        "passed": False,
        "detail": ""
    },
    "5_web_request": {
        "title": "5.  WebRequest (status=Success & payload verified)",
        "passed": False,
        "detail": ""
    },
    "6_string_visitor": {
        "title": "6.  StringVisitor (frame.GetSource)",
        "passed": False,
        "detail": ""
    },
    "7_cookie_visitor": {
        "title": "7.  CookieVisitor ('test_issue765' cookie verified)",
        "passed": False,
        "detail": ""
    },
}

g_browser = None
g_done = False
g_all_tests_passed = False
g_http_server = None
g_http_port = 0

# Strong references for CEF WeakValueDictionary registries
g_references = {
    "handlers": [],
    "web_requests": [],
    "string_visitor": None,
    "cookie_visitor": None,
}


def mark_test_passed(test_key, detail=""):
    def _inner():
        if test_key in TEST_CHECKLIST and not TEST_CHECKLIST[test_key]["passed"]:
            TEST_CHECKLIST[test_key]["passed"] = True
            TEST_CHECKLIST[test_key]["detail"] = detail
            print("[CHECKLIST PASS] %s %s" % (
                TEST_CHECKLIST[test_key]["title"],
                ("(%s)" % detail) if detail else ""
            ))
            check_all_completed()
    cef.PostTask(cef.TID_UI, _inner)


def print_final_report():
    print("\n" + "=" * 70)
    print("CEF Python - Issue #765 / PR #768 Regression Test Report")
    print("=" * 70)
    all_ok = True
    for key in sorted(TEST_CHECKLIST.keys()):
        item = TEST_CHECKLIST[key]
        status = "[PASS]" if item["passed"] else "[FAIL / TIMEOUT]"
        if not item["passed"]:
            all_ok = False
        print(" %-16s %-48s %s" % (status, item["title"], item["detail"]))
    print("=" * 70)
    if all_ok:
        print("SUCCESS: All 8 checks across 7 subsystems verified successfully!")
    else:
        print("FAILURE: Some tests did not complete or failed verification.")
    print("=" * 70 + "\n")
    return all_ok


def finish_testing(all_passed=True):
    global g_done, g_browser, g_all_tests_passed
    if g_done:
        return
    g_done = True
    g_all_tests_passed = print_final_report()
    if g_http_server:
        threading.Thread(target=g_http_server.shutdown).start()
    if g_browser:
        g_browser.CloseBrowser(True)
    cef.QuitMessageLoop()


def check_all_completed():
    if all(item["passed"] for item in TEST_CHECKLIST.values()):
        cef.PostTask(cef.TID_UI, finish_testing, True)


def on_timeout():
    if not g_done:
        print("[WARNING] Test suite timeout (10s) reached.")
        finish_testing(False)


# -----------------------------------------------------------------------------
# Local HTTP Server (For genuine CefURLRequest / WebRequest verification)
# -----------------------------------------------------------------------------

WEBREQUEST_PAYLOAD = b"WebRequest Verified Payload for Issue #765"


class LocalHttpHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/webrequest.txt":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(WEBREQUEST_PAYLOAD)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(WEBREQUEST_PAYLOAD)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress HTTP server logging


def start_local_http_server():
    global g_http_server, g_http_port
    g_http_server = socketserver.TCPServer(("127.0.0.1", 0), LocalHttpHandler)
    g_http_port = g_http_server.server_address[1]
    t = threading.Thread(target=g_http_server.serve_forever)
    t.daemon = True
    t.start()


# -----------------------------------------------------------------------------
# 1a. PostTask & 1b. PostDelayedTask
# -----------------------------------------------------------------------------

def task_callback(msg):
    mark_test_passed("1a_post_task", "executed on TID_UI: %s" % msg)


def delayed_task_callback(msg):
    mark_test_passed("1b_post_delayed_task", "executed with 50ms delay: %s" % msg)


# -----------------------------------------------------------------------------
# 2. JavaScript Callback & 3. Python Callback
# -----------------------------------------------------------------------------

def my_python_callback(response_from_js):
    """
    Executed when JavaScript invokes the Python callback function passed to it.
    Tests 3: Python callback executed (PutPythonCallback / ExecutePythonCallback).
    """
    if response_from_js == "Response sent from V8 JavaScript engine":
        mark_test_passed("3_py_callback", "V8 called Python callback with valid payload")
    else:
        print("[FAIL] Python callback received unexpected: %s" % response_from_js)


def py_setup_callbacks(js_callback):
    """
    Called from JavaScript. Receives js_callback (cef.JavascriptCallback).
    Tests 2: JS callback received (PutJavascriptCallback).
    Calls js_callback passing my_python_callback as argument, which tests
    passing Python callbacks to JavaScript via IPC.
    """
    mark_test_passed("2_js_callback", "Python received and calling js_callback")
    js_callback.Call(my_python_callback)


# -----------------------------------------------------------------------------
# 4. ResourceHandler
# -----------------------------------------------------------------------------

HTML_PAGE_CONTENT = b"""<!doctype html>
<html>
<head><title>Test Issue #765</title></head>
<body>
    <h2>Test Runner: Issue #765 ID Check</h2>
    <div id="status">Running tests...</div>

    <script>
    function start_js_tests() {
        if (typeof window.py_setup_callbacks !== "function") {
            setTimeout(start_js_tests, 50);
            return;
        }

        // 2 & 3. JavaScript Callback & Python Callback
        window.py_setup_callbacks(function(py_callback) {
            if (typeof py_callback === "function") {
                py_callback("Response sent from V8 JavaScript engine");
            }
        });

        // 4. ResourceHandler: fetch intercepted subresource & verify content
        fetch("/message.txt")
            .then(function(r) { return r.text(); })
            .then(function(text) {
                document.getElementById("status").textContent = "Fetched: " + text;
                window.py_notify_resource_handler_content(text);
            })
            .catch(function(err) {
                console.error("Fetch error:", err);
            });
    }
    </script>
</body>
</html>
"""

MESSAGE_CONTENT = b"Custom ResourceHandler Content for Issue #765"


class CustomResourceHandler(object):
    def __init__(self, data, mime_type="text/plain"):
        self.offset = 0
        self.data = data
        self.mime_type = mime_type

    def ProcessRequest(self, request, callback):
        callback.Continue()
        return True

    def GetResponseHeaders(self, response, response_length_out, redirect_url_out):
        response.SetStatus(200)
        response.SetMimeType(self.mime_type)
        response_length_out[0] = len(self.data)

    def ReadResponse(self, data_out, bytes_to_read, bytes_read_out, callback):
        if self.offset < len(self.data):
            chunk = self.data[self.offset:self.offset + bytes_to_read]
            self.offset += len(chunk)
            data_out[0] = chunk
            bytes_read_out[0] = len(chunk)
            return True
        else:
            bytes_read_out[0] = 0
            return False

    def Cancel(self):
        pass


def py_notify_resource_handler_content(content):
    if content.encode("utf-8") == MESSAGE_CONTENT:
        mark_test_passed("4_resource_handler", "Content verified end-to-end (%d bytes)" % len(content))
    else:
        print("[FAIL] ResourceHandler content mismatch: %r" % content)


class RequestHandler(object):
    def GetResourceHandler(self, browser, frame, request):
        url = request.GetUrl()
        handler = None
        if "test-resource-handler.local/index.html" in url:
            handler = CustomResourceHandler(HTML_PAGE_CONTENT, "text/html")
        elif "test-resource-handler.local/message.txt" in url:
            handler = CustomResourceHandler(MESSAGE_CONTENT, "text/plain")
        if handler:
            g_references["handlers"].append(handler)
        return handler


# -----------------------------------------------------------------------------
# 5. WebRequest
# -----------------------------------------------------------------------------

class CustomWebRequestClient(object):
    def __init__(self):
        self.received_data = b""

    def OnUploadProgress(self, web_request, current, total):
        pass

    def OnDownloadProgress(self, web_request, current, total):
        pass

    def OnDownloadData(self, web_request, data):
        if data:
            self.received_data += data

    def OnRequestComplete(self, web_request):
        status = web_request.GetRequestStatus()
        success_status = cef.WebRequest.Status["Success"]
        if status == success_status and self.received_data == WEBREQUEST_PAYLOAD:
            mark_test_passed("5_web_request", "status=Success, payload verified (%d bytes)" % len(self.received_data))
        else:
            print("[FAIL] WebRequest failed: status=%s (expected %s), data=%r" % (
                status, success_status, self.received_data
            ))


def run_web_request_test():
    request = cef.Request.CreateRequest()
    request.SetUrl("http://127.0.0.1:%d/webrequest.txt" % g_http_port)
    client = CustomWebRequestClient()
    web_request = cef.WebRequest.Create(request, client)
    g_references["web_requests"].append((web_request, client))


# -----------------------------------------------------------------------------
# 6. StringVisitor (GetSource)
# -----------------------------------------------------------------------------

class CustomStringVisitor(object):
    def Visit(self, value):
        if "<title>Test Issue #765</title>" in value:
            mark_test_passed("6_string_visitor", "Visited & validated HTML source (%d chars)" % len(value))
        else:
            print("[FAIL] StringVisitor received unexpected HTML source")


# -----------------------------------------------------------------------------
# 7. CookieVisitor (VisitAllCookies)
# -----------------------------------------------------------------------------

class CustomCookieVisitor(object):
    def __init__(self):
        self.found = False

    def Visit(self, cookie, count, total, delete_cookie_out):
        if cookie.GetName() == "test_issue765" and cookie.GetValue() == "int64_val":
            self.found = True
            mark_test_passed("7_cookie_visitor", "Verified cookie 'test_issue765'='int64_val'")
            return False  # Target cookie found, stop iteration
        return True


def run_cookie_test():
    manager = cef.CookieManager.GetGlobalManager()
    cookie = cef.Cookie()
    cookie.Set({
        "name": "test_issue765",
        "value": "int64_val",
        "domain": "test-resource-handler.local",
        "path": "/",
        "secure": False,
        "httpOnly": False,
        "hasExpires": False
    })
    manager.SetCookie("http://test-resource-handler.local/", cookie)

    def do_visit():
        g_references["cookie_visitor"] = CustomCookieVisitor()
        manager.VisitAllCookies(g_references["cookie_visitor"])

    cef.PostDelayedTask(cef.TID_UI, 250, do_visit)


# -----------------------------------------------------------------------------
# CEF Client Handlers
# -----------------------------------------------------------------------------

class LoadHandler(object):
    def __init__(self):
        self.tests_started = False

    def OnLoadingStateChange(self, browser, is_loading, **_):
        if not is_loading and not self.tests_started:
            self.tests_started = True
            frame = browser.GetMainFrame()

            # 6. StringVisitor: request HTML source
            g_references["string_visitor"] = CustomStringVisitor()
            frame.GetSource(g_references["string_visitor"])

            # Trigger JS-side tests (initiates py_setup_callbacks and fetch)
            frame.ExecuteJavascript("start_js_tests();")

            # 5. WebRequest: initiate web request
            cef.PostDelayedTask(cef.TID_UI, 150, run_web_request_test)


# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

def main():
    global g_browser

    print("=" * 70)
    print("Starting automated tests for Issue #765 / PR #768...")
    print("=" * 70)

    start_local_http_server()

    sys.excepthook = cef.ExceptHook
    settings = {}
    cef.Initialize(settings)

    # Setup JS Bindings
    bindings = cef.JavascriptBindings(bindToFrames=True, bindToPopups=True)
    bindings.SetFunction("py_setup_callbacks", py_setup_callbacks)
    bindings.SetFunction("py_notify_resource_handler_content", py_notify_resource_handler_content)

    # Create Browser loading our intercepted local domain
    g_browser = cef.CreateBrowserSync(
        url="http://test-resource-handler.local/index.html",
        window_title="Test Issue #765 IDs"
    )
    g_browser.SetJavascriptBindings(bindings)
    g_browser.SetClientHandler(LoadHandler())
    g_browser.SetClientHandler(RequestHandler())

    # 1a. PostTask test
    cef.PostTask(cef.TID_UI, task_callback, "Immediate Task")

    # 1b. PostDelayedTask test
    cef.PostDelayedTask(cef.TID_UI, 50, delayed_task_callback, "Delayed Task")

    # 7. CookieVisitor test
    cef.PostDelayedTask(cef.TID_UI, 100, run_cookie_test)

    # 10s safety timeout to avoid hanging
    cef.PostDelayedTask(cef.TID_UI, 10000, on_timeout)

    cef.MessageLoop()
    cef.Shutdown()

    if not g_all_tests_passed:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
