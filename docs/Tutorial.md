# Tutorial (STILL A WORK IN PROGRESS.. #256)

This tutorial is for v50+ versions of CEF Python, which are currently
available only for Linux.


Table of contents:
* [Install and download examples](#install-and-download-examples)
* [Hello world](#hello-world)
* [CEF's multiprocess architecture](#cefs-multiprocess-architecture)
* [Handling Python exceptions](#handling-python-exceptions)


## Install and download examples

The easy way to install CEF Python is through PyPI, using the pip tool,
which is bundled with all recent versions of Python. On Linux pip 8.1+
is required. To check version and install CEF Python type:

```
pip --version
pip install cefpython3
```

Alternatively you can download the setup package from
[GitHub Releases](../../../releases) and install it by following
the instructions in README.txt.

Now let's download examples by cloning the GitHub repository. After
that, enter the "cefpython/examples/" directory. In that directory
you will find all the examples from this Tutorial, their names
start with a "tutorial_" prefix, except for the hello world example
which is just named "hello_world.py".

```
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/
```


## Hello world

The [hello_world.py](../examples/hello_world.py) example is the
most basic example. It doesn't depend on any third party GUI frameworks.
It creates a browser widget without providing any window information
(parent window not specified), thus CEF automatically takes care of creating
a top-level window for us, and in that window a Chromium widget is embedded.
When creating the browser, an "url" parameter is specified, which causes the
browser to initially navigate to the Google website. Let's explain the code
from this example:

1. `from cefpython3 import cefpython as cef` - Import the cefpython
   module and bind it to a shorter name "cef".
2. `sys.excepthook = cef.ExceptHook` - Overwrite Python's default
   exception handler so that all CEF processes are terminated when
   Python exception occurs. To understand this better read the
   "CEF's multiprocess architecture" and "Handling Python exceptions"
   sections further down in this Tutorial.
3. `cef.Initialize()` - Initialize CEF. This function must be called
   somewhere in the beginning of your code. It must be called before
   any app window is created. It must be called only once during app's
   lifetime and must have a corresponding Shutdown() call.
4. `cef.CreateBrowserSync(url="https://www.google.com/")` - Create
   a browser synchronously, this function returns the Browser object.
5. `cef.MessageLoop()` - Run CEF message loop. All desktop GUI programs
   run some message loop that waits and dispatches events or messages.
6. `cef.Shutdown()` - Shut down CEF. This function must be called for
   CEF to shut down cleanly. It will free CEF system resources, it
   will terminate all subprocesses, and it will flush to disk any
   yet unsaved data like for example cookies and/or local storage. Call
   this function at the very end of your program execution. When using
   third party GUI frameworks such as Qt/wxWidgets, CEF should be shut down
   after these frameworks' shutdown procedures were called. For example
   in Qt, shut down CEF only after QApplication object was destroyed.

Documentation for the functions from this example can be found in
API docs (the api/ directory in GitHub's repository):

* [ExceptHook](../api/cefpython.md#excepthook)
* [Initialize()](../api/cefpython.md#initialize)
* [CreateBrowserSync()](../api/cefpython.md#createbrowsersync)
* [Browser](../api/Browser.md) object
* [MessageLoop()](../api/cefpython.md#messageloop)
* [Shutdown()](../api/cefpython.md#shutdown)


## CEF's multiprocess architecture

...


## Handling Python exceptions
...
