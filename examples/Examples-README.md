# Examples README

Table of contents:
* [Hello World!](#hello-world)
* [Supported examples](#supported-examples)
* [More examples](#more-examples)

## Hello World!

Instructions to install the cefpython3 package, clone the repository
and run the hello_world.py example:

```
pip install cefpython3==56.2
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/
python hello_world.py
```


## Supported examples

Examples provided in the examples/ root directory are actively
maintained:

- [hello_world.py](hello_world.py): basic example, doesn't require any
  third party GUI framework to run
- [tutorial.py](tutorial.py): example from [Tutorial](../docs/Tutorial.md)
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

If there are any issues in examples read top comments in sources
to see whether this is a known issue with available workarounds.

**Unit tests**

There are also available unit tests and its usage of the API can
be of some use. See [main_test.py](../unittests/main_test.py).


## More examples

There are even more examples available, some of them are externally
maintained. 

- Kivy framework:
  see [Kivy](https://github.com/cztomczak/cefpython/wiki/Kivy) wiki page.
- Panda3D game engine:
  see [Panda3D](https://github.com/cztomczak/cefpython/wiki/Panda3D) wiki page.
- PyGame/PyOpenGL:
  see [gist by AnishN](https://gist.github.com/AnishN/aa3bb27fc9d69319955ed9a8973cd40f)
- Screenshot example:
  see [gist by stefanbacon](https://gist.github.com/stefanbacon/7b1571d57aee54aa9f8e9021b4848d06)
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
