# Examples README

Table of contents:
* [Hello World!](#hello-world)
* [Supported examples](#supported-examples)
  * [Featured](#featured)
  * [Snippets](#snippets)
  * [GUI frameworks](#gui-frameworks)
  * [Unit tests](#unit-tests)
* [More examples](#more-examples)

## Hello World!

Instructions to install the cefpython3 package, clone the repository
and run the hello_world.py example:

```
pip --no-cache-dir install cefpython3==49.0
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/
python hello_world.py
```

Please note that if you were previously installing cefpython3 package it
is required to use the `--no-cache-dir` flag, otherwise pip will end up
with error message `No matching distribution found for cefpython3==49.0`.
This happens because 49.0 release occured after 57.0 and 66.0 releases.


## Supported examples

Examples provided in the examples/ root directory are actively
maintained. If there are any issues in examples read top comments
in sources to see whether this is a known issue with available
workarounds.

### Featured

- [hello_world.py](hello_world.py) - Basic example, doesn't require any
  third party GUI framework to run
- [tutorial.py](tutorial.py) - Example from [Tutorial](../docs/Tutorial.md)
- [screenshot.py](screenshot.py) - Example of off-screen rendering mode
  to create a screenshot of a web page. The code from this example is
  discussed in great details in Tutorial in the [Off-screen rendering](../docs/Tutorial.md#off-screen-rendering)
  section.


### Snippets

See small code snippets that show various CEF features in the
[examples/snippets/](snippets/) directory:

- [javascript_bindings.py](snippets/javascript_bindings.py) - Communicate
    between Python and Javascript asynchronously using
    inter-process messaging with the use of Javascript Bindings.
- [javascript_errors.py](snippets/javascript_errors.py) - Two ways for
    intercepting Javascript errors.
- [network_cookies.py](snippets/network_cookies.py) - Implement
    interfaces to block or allow cookies over network requests.
- [onbeforeclose.py](snippets/onbeforeclose.py) - Implement interface
    to execute custom code before browser window closes.
- [ondomready.py](snippets/ondomready.py) - Execute custom Python code
    on a web page as soon as DOM is ready.
- [onpagecomplete.py](snippets/onpagecomplete.py) - Execute custom
    Python code on a web page when page loading is complete.
- [window_size.py](snippets/window_size.py) - Set initial window size
    without use of any third party GUI framework.


### GUI frameworks

Examples of embedding using various GUI frameworks:

- [gtk2.py](gtk2.py): example for [PyGTK](http://www.pygtk.org/)
  library (GTK 2)
- [gtk3.py](gtk3.py): example for [PyGObject/PyGI](https://wiki.gnome.org/Projects/PyGObject)
  library (GTK 3). Currently broken on Linux/Mac, see top comments in sources.
- [qt.py](qt.py): example for [PyQt4](https://wiki.python.org/moin/PyQt4),
  [PyQt5](https://pypi.python.org/pypi/PyQt5)
  and [PySide](https://wiki.qt.io/PySide) libraries
- [tkinter_.py](tkinter_.py): example for [Tkinter](https://wiki.python.org/moin/TkInter).
  Currently broken on Mac.
- [wxpython.py](wxpython.py): example for [wxPython](https://wxpython.org/)
  toolkit


### Unit tests

There are also available unit tests and its usage of the API can
be of some use. See:
- [main_test.py](../unittests/main_test.py) - windowed rendering general tests
- [osr_test.py](../unittests/osr_test.py) - off-screen rendering tests


## More examples

There are even more examples available, some of them are externally
maintained. 

- Kivy framework:
  see [Kivy](https://github.com/cztomczak/cefpython/wiki/Kivy) wiki page.
- Panda3D game engine:
  see [Panda3D](https://github.com/cztomczak/cefpython/wiki/Panda3D) wiki page.
- PyGame/PyOpenGL:
  see [gist by AnishN](https://gist.github.com/AnishN/aa3bb27fc9d69319955ed9a8973cd40f)
- Example of implementing [ResourceHandler](../api/ResourceHandler.md)
  with the use of [WebRequest](../api/WebRequest.md) object and
  [WebRequestClient](../api/WebRequestClient.md) interface to allow
  for reading/modifying web requests: see the [wxpython-response.py](https://github.com/cztomczak/cefpython/blob/cefpython31/cefpython/cef3/linux/binaries_64bit/wxpython-response.py)
  example in the cefpython31 branch.
- Old PyWin32 example:
  see [pywin32.py](https://github.com/cztomczak/cefpython/blob/cefpython31/cefpython/cef3/windows/binaries_32bit/pywin32.py)
  in the cefpython31 branch

There are ongoing efforts to add these examples to the official examples/
directory, see issues in the tracker.
