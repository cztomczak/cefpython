"""
Two ways for intercepting Javascript errors:
1. window.onerror event in Javascript
2. DisplayHandler.OnConsoleMessage in Python
"""

from cefpython3 import cefpython as cef

g_htmlcode = """
<!doctype html>
<html>
<head>
    <style>
    body, html {
        font-family: Arial;
        font-size: 11pt;
    }
    </style>
    <script>
    function print(msg) {
        document.getElementById("console").innerHTML += msg+"<br>";
    }
    window.onerror = function(message, source, lineno, colno, error) {
        print("[JS:window.onerror] "+error+" (line "+lineno+")");
        // Return false so that default event handler is fired and
        // OnConsoleMessage can also intercept this error.
        return false;
    };
    window.onload = function() {
        forceError();
    };
    </script>
</head>
<body>
    <h1>Javascript Errors</h1>
    <div id=console></div>
</body>
</html>
"""


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url=cef.GetDataUrl(g_htmlcode),
                                    window_title="Javascript Errors")
    browser.SetClientHandler(DisplayHandler())
    cef.MessageLoop()
    cef.Shutdown()


class DisplayHandler(object):
    def OnConsoleMessage(self, browser, message, line, **_):
        if "error" in message.lower() or "uncaught" in message.lower():
            logmsg = "[Py:OnConsoleMessage] {message} (line {line})" \
                     .format(message=message, line=line)
            print(logmsg)
            browser.ExecuteFunction("print", logmsg)


if __name__ == '__main__':
    main()
