# PyInstaller example

Table of contents:
* [Package app](#package-app)
* [When it succeeds](#when-it-succeeds)
* [Fatal error](#fatal-error)
* [Debug app](#debug-app)
* [More details](#more-details)


## Package app

This is an example of using [PyInstaller](http://www.pyinstaller.org/)
packager to build executable from one of CEF Python's examples
(wxpython.py). This pyinstaller example supports packaging
on Windows, Linux and Darwin but was mainly tested on Windows platform.

To install required packages type:
```
pip install --upgrade pyinstaller==3.2.1 pycrypto
```

Note that the above command installs an old version of Pyinstaller 3.2.1
and this is intentional as this version has the least issues with Anti-virus
software, see further on this page for more details.

To package the example go to the [examples/pyinstaller/](./) directory
and type:
```
python pyinstaller.py
```

**Note on PyInstaller's bootloader (3.3/3.4) being flagged by Anti-virus software**

PyInstaller's bootloader for Windows (runw.exe as of version 3.3 and 3.4) has [12/67 false-positives](https://www.virustotal.com/#/file/798b3c1cd233c4c025af7445718176bdb46014e3ceb25ef12df41a6a25af2fc5/detection)
reported by Anti-virus software when scanning with virustotal.com and the maintainers of
PyInstaller have no plans to fix that, see [PyInstaller Issue #2501](https://github.com/pyinstaller/pyinstaller/issues/2501)
for details. It is advised that you install PyInstaller version 3.2.1 which has the least amount
of false positives, only [4/67](https://www.virustotal.com/#/file/153dd99a09d0821b99afbda63551e1c679d127fa82d8d3db8fd14cebdce953a3/detection)
by some unpopular AVs. You might also consider using py2exe or cx_Freeze
packagers instead and test whether these have less issues with Anti-virus software, however there
are no official examples for these available.


## When it succeeds

If packaging succeeds you should see "dist/cefapp/" directory open
in explorer on Windows. In there you will find "cefapp.exe" executable
that you can launch.

![cefapp directory](screenshots/cefapp_directory.jpg)


## Fatal error

If there is a "Fatal Error!" message box appearing when running app
then see the next section for how to debug app.

![Fatal Error](screenshots/cefapp_fatal_error.jpg)


## Debug app

In case of a fatal error to debug app pass "--debug" flag when
packaging app:

```
python pyinstaller.py --debug
```

After packaging completes on Windows it will open a new CMD window
and run the cefapp.exe inside it. You should see detailed logs
in console like these:

```
[6708] PyInstaller Bootloader 3.x
[6708] LOADER: executable is \examples\pyinstaller\dist\cefapp\cefapp.exe
[6708] LOADER: homepath is \examples\pyinstaller\dist\cefapp
[6708] LOADER: _MEIPASS2 is NULL
[6708] LOADER: archivename is \examples\pyinstaller\dist\cefapp\cefapp.exe
[6708] LOADER: No need to extract files to run; setting extractionpath to homepath
[6708] LOADER: SetDllDirectory(\examples\pyinstaller\dist\cefapp)
[6708] LOADER: Already in the child - running user's code.
[6708] LOADER: Python library: \examples\pyinstaller\dist\cefapp\python27.dll
[6708] LOADER: Loaded functions from Python library.
[6708] LOADER: Manipulating environment (sys.path, sys.prefix)
[6708] LOADER: sys.prefix is C:\github\CEFPYT~2\examples\PYINST~1\dist\cefapp
[6708] LOADER: Setting runtime options
[6708] LOADER: Initializing python
[6708] LOADER: Overriding Python's sys.path
[6708] LOADER: Post-init sys.path is \examples\pyinstaller\dist\cefapp
[6708] LOADER: Setting sys.argv
[6708] LOADER: setting sys._MEIPASS
[6708] LOADER: importing modules from CArchive
[6708] LOADER: extracted pyimod00_crypto_key
[6708] LOADER: callfunction returned...
[6708] LOADER: extracted struct
[6708] LOADER: callfunction returned...
[6708] LOADER: extracted pyimod01_os_path
[6708] LOADER: callfunction returned...
[6708] LOADER: extracted pyimod02_archive
[6708] LOADER: callfunction returned...
[6708] LOADER: extracted pyimod03_importers
[6708] LOADER: callfunction returned...
[6708] LOADER: Installing PYZ archive with Python modules.
[6708] LOADER: PYZ archive: out00-PYZ.pyz
[6708] LOADER: Running pyiboot01_bootstrap.py
[6708] LOADER: Running wxpython.py
Traceback (most recent call last):
  File "wxpython.py", line 11, in <module>
  File "c:\python27\lib\site-packages\PyInstaller-3.3-py2.7.egg\
       PyInstaller\loader\pyimod03_importers.py", line 396,
       in load_module exec(bytecode, module.__dict__)
  File "site-packages\cefpython3\__init__.py", line 50, in <module>
  File "c:\python27\lib\site-packages\PyInstaller-3.3-py2.7.egg\
       PyInstaller\loader\pyimod03_importers.py", line 687,
       in load_module module = imp.load_module(fullname, fp, filename,
                                               ext_tuple)
  File "cefpython_py27.pyx", line 283, in init cefpython_py27
       (cefpython_py27.cpp:110881)
ImportError: No module named json
[6708] Failed to execute script wxpython
[6708] LOADER: OK.
[6708] LOADER: Cleaning up Python interpreter.
```


## More details

The corresponding issue in the tracker is [Issue #135](https://github.com/cztomczak/cefpython/issues/135).

See also the [Build executable](https://github.com/cztomczak/cefpython/blob/master/docs/Tutorial.md#build-executable)
section in Tutorial.
