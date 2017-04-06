# Tutorial example.
# Tested with CEF Python v56.1+

from cefpython3 import cefpython as cef
import base64
import platform
import sys

# HTML code. Browser will navigate to a Data uri created
# from this html code.
HTML_code = """
test
"""


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    settings = {"cache_path": "webcache"}
    cef.Initialize(settings=settings)
    set_global_handler()
    browser = cef.CreateBrowserSync(url=html_to_data_uri(HTML_code),
                                    window_title="Hello World!")
    set_client_handlers(browser)
    set_javascript_bindings(browser)
    cef.MessageLoop()
    cef.Shutdown()


def check_versions():
    print("[tutorial.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[tutorial.py] Python {ver} {arch}".format(
          ver=platform.python_version(), arch=platform.architecture()[0]))
    assert cef.__version__ >= "56.1", "CEF Python v56.1+ required to run this"


def html_to_data_uri(html):
    html = html.encode("utf-8", "replace")
    b64 = base64.b64encode(html).decode("utf-8", "replace")
    return "data:text/html;base64,{data}".format(data=b64)


def set_global_handler():
    # A global handler is a special handler for callbacks that
    # must be set before Browser is created using
    # SetGlobalClientCallback() method.
    global_handler = GlobalHandler()
    cef.SetGlobalClientCallback("OnAfterCreated",
                                global_handler.OnAfterCreated)


def set_client_handlers(browser):
    client_handlers = [LoadHandler(), DisplayHandler()]
    for handler in client_handlers:
        browser.SetClientHandler(handler)


def set_javascript_bindings(browser):
    external = External(browser)
    bindings = cef.JavascriptBindings(
            bindToFrames=False, bindToPopups=False)
    bindings.SetFunction("html_to_data_uri", html_to_data_uri)
    bindings.SetProperty("test_property", "This property was set in Python")
    bindings.SetObject("external", external)
    browser.SetJavascriptBindings(bindings)


def js_print(browser, msg):
    browser.ExecuteFunction("js_print", msg)


class GlobalHandler(object):
    def OnAfterCreated(self, browser, **_):
        js_print(browser,
                 "Python: GlobalHandler._OnAfterCreated: browser id={id}"
                 .format(id=browser.GetIdentifier()))


class LoadHandler(object):
    def OnLoadingStateChange(self, browser, is_loading, **_):
        if not is_loading:
            # Loading is complete
            js_print(browser, "Python: LoadHandler.OnLoadingStateChange:"
                              "loading is complete")


class DisplayHandler(object):
    def OnConsoleMessage(self, browser, message, **_):
        if "error" in message.lower() or "uncaught" in message.lower():
            js_print(browser, "Python: LoadHandler.OnConsoleMessage: "
                              "intercepted Javascript error: {error}"
                              .format(error=message))


class External(object):
    def __init__(self, browser):
        self.browser = browser

    def test_function(self):
        pass


if __name__ == '__main__':
    main()
