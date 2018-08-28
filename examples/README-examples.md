# Examples README

Table of contents:
* [Hello World!](#hello-world)
* [Supported examples](#supported-examples)
  * [Featured](#featured)
  * [Snippets](#snippets)
  * [GUI frameworks](#gui-frameworks)
  * [Build executable with PyInstaller](#build-executable-with-pyinstaller)
  * [Unit tests](#unit-tests)
* [Other examples](#other-examples)
* [More examples to come](#more-examples-to-come)

## Hello World!

Instructions to install the cefpython3 package, clone the repository
and run the hello_world.py example:

```
pip install cefpython3==66.0
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/
python hello_world.py
```


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

For small code snippets that show various CEF features and are easy to
understand see the [README-snippets.md](snippets/README-snippets.md)
document.


### GUI frameworks

Examples of embedding CEF browser using various GUI frameworks:

- [gtk2.py](gtk2.py): example for [PyGTK](http://www.pygtk.org/)
  library (GTK 2)
- [gtk3.py](gtk3.py): example for [PyGObject / PyGI](https://wiki.gnome.org/Projects/PyGObject)
  library (GTK 3). Currently broken on Mac ([#310](../../../issues/310)).
- [pysdl2.py](pysdl2.py): off-screen rendering example for
  [PySDL2](https://github.com/marcusva/py-sdl2) library. Example has some
  issues that are reported in Issue [#324](../../../issues/324).
- [pywin32.py](pywin32.py): example for [pywin32](https://github.com/mhammond/pywin32)
  library
- [qt.py](qt.py): example for [PyQt4](https://wiki.python.org/moin/PyQt4),
  [PyQt5](https://pypi.python.org/pypi/PyQt5)
  and [PySide](https://wiki.qt.io/PySide) libraries.
  PyQt4 and PySide examples are currently broken on Linux, see
  [Issue #452](../../../issues/452).
- [tkinter_.py](tkinter_.py): example for [Tkinter](https://wiki.python.org/moin/TkInter).
  Currently broken on Mac ([#309](../../../issues/309)).
- [wxpython.py](wxpython.py): example for [wxPython](https://wxpython.org/)
  toolkit. This example implements High DPI support on Windows.


### Build executable with PyInstaller

- [PyInstaller example](pyinstaller/README-pyinstaller.md):
  example of packaging app using [PyInstaller](http://www.pyinstaller.org/)
  packager. Currently this example supports only Windows platform.


### Unit tests

There are also available unit tests and its usage of the API can
be of some use. See:
- [main_test.py](../unittests/main_test.py) - windowed rendering general tests
- [osr_test.py](../unittests/osr_test.py) - off-screen rendering tests


## Other examples

There are even more examples available, they do not reside in the examples/
directory. Some of them were created for old verions of CEF and were not
yet ported to latest CEF. Some of them are externally maintained.

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
- Example of using Python network library (urllib3/openssl) instead of Chromium's
  network library - see [gist by Massimiliano Dal Cero](https://gist.github.com/yattamax/0252a3c5dc54a2f81650d5c0eafabf99)
- Example of passing exceptions from Python to Javascript and using await syntax to receive values from python return values - see [Managed python calls example by Elliot Woods](https://github.com/elliotwoods/cefpython-tests/tree/0180b22eac10a1bde08820ca192fdc30eb93f00d/6.%20Managed%20python%20calls)

## More examples to come

Here is a list of issues in the tracker to create or upgrade examples:

- [Issue #323](../../../issues/323) - "Create cocos2d example"
- [Issue #322](../../../issues/322) - "Create pyglet example"
- [Issue #312](../../../issues/312) - "Easy to use CefBrowser widgets
                                       for many popular GUI toolkits"
- [Issue #301](../../../issues/301) - "Fix cefpython3.wx package to work
                                       with latest v55+"
- [Issue #289](../../../issues/289) - "Pygame / PyOpenGL example"
- [Issue #288](../../../issues/288) - "Create panda3d_.py example"
- [Issue #285](../../../issues/285) - "[kivy_.py] Refactor example, make
                                       it work cross-platform and move it
                                       to examples/"
- [Issue #252](../../../issues/252) - "Use CEF views in Hello World, Tutorial
                                       and Offscreen examples, and in Unit
                                       tests"
- [Issue #224](../../../issues/224) - "Port CEF 1 examples to CEF 3"
- [Issue #109](../../../issues/109) - "The ResourceHandler example"

Packaging examples:

- [Issue #407](../../../issues/407) - "Example of packaging app using
                                       Cython compiler"
- [Issue #396](../../../issues/396) - "Example of packaging app using
                                       Nuitka compiler"
- [Issue #338](../../../issues/338) - "Example of packaging app using
                                       cx_Freeze"
- [Issue #337](../../../issues/337) - "Example of packaging app using
                                       py2app"
- [Issue #135](../../../issues/135) - "Example of packaging app using
                                       pyinstaller"
