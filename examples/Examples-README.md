# Examples README

Table of contents:
* [Supported examples](#supported-examples)
* [More examples](#more-examples)


## Supported examples

Examples provided in the examples/ root directory are actively
maintained:

- [gtk2.py](gtk2.py): example for [PyGTK](http://www.pygtk.org/)
  library (GTK 2)
- [gtk3.py](gtk3.py): example for [PyGObject/PyGI]
  (https://wiki.gnome.org/Projects/PyGObject) library (GTK 3).
  Currently broken on Linux/Mac, see top comments in sources.
- [hello_world.py](hello_world.py): doesn't require any third party
  GUI framework
- [qt4.py](qt4.py): example for [PyQt4](https://wiki.python.org/moin/PyQt4)
  and [PySide](https://wiki.qt.io/PySide) libraries (Qt 4)
- [tkinter_.py](tkinter_.py): example for [Tkinter]
  (https://wiki.python.org/moin/TkInter). Currently broken on Mac.
- [wxpython.py](wxpython.py): example for [wxPython](https://wxpython.org/)

If there are any issues in examples read top comments in sources
to see whether this is a known issue with available workarounds.


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
