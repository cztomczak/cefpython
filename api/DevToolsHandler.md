[API categories](API-categories.md) | [API index](API-index.md)


# DevToolsHandler (interface)

Implement this interface to handle events related to Developer Tools window.


Table of contents:
* [Callbacks](#callbacks)
  * [ShowDevTools](#showdevtools)


## Callbacks


### ShowDevTools

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Implement this callback to overwrite the [Browser](Browser.md).`ShowDevTools`
method. This will also overwrite the behavior of mouse context menu option
"Developer Tools". This callback is useful to implement custom behavior
and also to fix keyboard issues in DevTools popup in the `wxpython.py`
example reported in [Issue #381](../../../issues/381).

Example usage case is in the `wxpython.py` and `devtools.py`
examples. See parts of the code from the `wxpython.py` example:

```py
# DevTools port and url. This is needed to workaround keyboard issues
# in DevTools popup on Windows (Issue #381).
DEVTOOLS_PORT = 0  # By default a random port is generated.
if WINDOWS:
    DEVTOOLS_PORT = 54008
    DEVTOOLS_URL = "http://127.0.0.1:{0}/".format(DEVTOOLS_PORT)

...
if DEVTOOLS_PORT:
    settings["remote_debugging_port"] = DEVTOOLS_PORT
...

def ShowDevTools(self, browser, **_):
    # Check if app was frozen with e.g. pyinstaller.
    if getattr(sys, "frozen", None):
        dir = os.path.dirname(os.path.realpath(__file__))
        executable = os.path.join(dir, "devtools.exe");
        if os.path.exists(executable):
            # If making executable with pyinstaller then create
            # executable for the devtools.py script as well.
            subprocess.Popen([executable, DEVTOOLS_URL])
        else:
            # Another way to show DevTools is to open it in Google Chrome
            # system browser.
            webbrowser.open(DEVTOOLS_URL)
    else:
        # Use the devtools.py script to open DevTools popup.
        dir = os.path.dirname(os.path.realpath(__file__))
        script = os.path.join(dir, "devtools.py")
        subprocess.Popen([sys.executable, script, DEVTOOLS_URL])
```
