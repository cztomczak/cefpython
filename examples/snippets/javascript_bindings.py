"""
Communicate between Python and Javascript asynchronously using
inter-process messaging with the use of Javascript Bindings.
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
    function js_function(value) {
        print("Value sent from Python: <b>"+value+"</b>");
        py_function("I am a Javascript string #1", js_callback);
    }
    function js_callback(value, py_callback) {
        print("Value sent from Python: <b>"+value+"</b>");
        py_callback("I am a Javascript string #2");
    }
    </script>
</head>
<body>
    <h1>Javascript Bindings</h1>
    <div id=console></div>
</body>
</html>
"""


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(url=cef.GetDataUrl(g_htmlcode),
                                    window_title="Javascript Bindings")
    browser.SetClientHandler(LoadHandler())
    bindings = cef.JavascriptBindings()
    bindings.SetFunction("py_function", py_function)
    bindings.SetFunction("py_callback", py_callback)
    browser.SetJavascriptBindings(bindings)
    cef.MessageLoop()
    del browser
    cef.Shutdown()


def py_function(value, js_callback):
    print("Value sent from Javascript: "+value)
    js_callback.Call("I am a Python string #2", py_callback)


def py_callback(value):
    print("Value sent from Javascript: "+value)


class LoadHandler(object):
    def OnLoadEnd(self, browser, **_):
        browser.ExecuteFunction("js_function", "I am a Python string #1")


if __name__ == '__main__':
    main()
