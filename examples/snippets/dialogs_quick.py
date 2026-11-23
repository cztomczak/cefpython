"""
The dialogs that CEF Python shows on Linux when no handler takes them:
alert(), confirm(), prompt(), beforeunload, file choosers and print.
Run it with the current build and with the branch, then click everything.

Two clocks show what keeps running while a dialog is open:
- Page clock: the page's own JavaScript.
- Python clock: Python code that updates the page every 100 ms with
  cef.PostDelayedTask(), so it needs the CEF message loop.
Open a file chooser and watch the Python clock. alert(), confirm(), prompt()
and print() pause the page's JavaScript in every browser, so both clocks
stop during those.

python dialogs_quick.py --html  writes the page to dialogs.html, to open it
in cefsimple --use-alloy-style --use-native --url=file://... (there is no
Python there, so the Python clock stays empty).
"""

import datetime
import os
import sys

from cefpython3 import cefpython as cef

g_htmlcode = """
<!doctype html>
<html>
<body style="font-family: Arial; font-size: 14pt">
    <h1>Dialogs</h1>
    <p>Page clock: <b id="clock"></b><br>
       Python clock: <b id="pyclock"></b></p>
    <p>
        <button onclick="alert('alert')">alert()</button>
        <button onclick="show('confirm: ' + confirm('confirm'))">confirm()</button>
        <button onclick="show('prompt: ' + prompt('prompt', 'default'))">prompt()</button>
    </p>
    <p>
        <button onclick="window.onbeforeunload = function(e) {
                e.preventDefault(); e.returnValue = ''; };
                show('beforeunload set, now close the window')">beforeunload</button>
    </p>
    <p>File: <input type="file" accept=".txt" onchange="files(this)"></p>
    <p>Multiple: <input type="file" multiple onchange="files(this)"></p>
    <p>Folder: <input type="file" webkitdirectory onchange="files(this)"></p>
    <p><button onclick="window.print()">print()</button></p>
    <p id="result"></p>
    <script>
    function show(text) {
        document.getElementById("result").textContent = text;
    }
    function files(input) {
        show(input.files.length + " file(s) chosen");
    }
    function now_text() {
        var now = new Date();
        return now.toTimeString().slice(0, 8) + "." + Math.floor(now.getMilliseconds() / 100);
    }
    function set_pyclock(text) {
        document.getElementById("pyclock").textContent = text;
    }
    setInterval(function() {
        document.getElementById("clock").textContent = now_text();
    }, 100);
    </script>
</body>
</html>
"""


g_browser_closed = False


class LifespanHandler(object):
    def OnBeforeClose(self, **_):
        global g_browser_closed
        g_browser_closed = True


def python_clock(browser):
    if g_browser_closed:
        return
    now = datetime.datetime.now()
    text = now.strftime("%H:%M:%S.") + str(now.microsecond // 100000)
    browser.ExecuteJavascript("set_pyclock('%s')" % text)
    cef.PostDelayedTask(cef.TID_UI, 100, python_clock, browser)


def main():
    if "--html" in sys.argv:
        with open("dialogs.html", "w") as f:
            f.write(g_htmlcode)
        print("file://" + os.path.abspath("dialogs.html"))
        return
    sys.excepthook = cef.ExceptHook
    cef.Initialize()
    browser = cef.CreateBrowserSync(url=cef.GetDataUrl(g_htmlcode),
                                    window_title="Dialogs")
    browser.SetClientHandler(LifespanHandler())
    python_clock(browser)
    cef.MessageLoop()
    cef.Shutdown()


if __name__ == "__main__":
    main()
