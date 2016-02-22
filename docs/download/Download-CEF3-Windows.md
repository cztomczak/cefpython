# Download CEF Python 3 for Windows #

## Introduction ##

The binaries were built by following the instructions on the [BuildOnWindows](BuildOnWindows) wiki page.<br>

<b>Version information</b><br>
The latest version is 31.2, released on January 10, 2015.<br>
Chrome version is 31.0.1650.69. Based on CEF 3 branch 1650 rev. 1639.<br>
For an explanation of these numbers see the <a href='VersionNumbering'>VersionNumbering</a> wiki page.<br>
<br>
<b>Release notes</b><br>
For a list of changes in current and past binary distributions see<br>
the ReleaseNotes wiki page.<br>
<br>
<b>Stability note</b><br>
For best stability please use 32bit binaries. 64bit binaries do work fine, but are not yet considered stable in upstream CEF/Chromium.<br>
<br>
<h2>Install from PyPI</h2>

To install the <a href='https://pypi.python.org/pypi/cefpython3'>PyPI/cefpython3</a> package using the pip package manager (see <a href='http://stackoverflow.com/a/12476379/623622'>how to install pip</a>), type:<br>
<pre><code>pip install cefpython3<br>
</code></pre>

If there are problems installing the cefpython3 package, then it might be caused by an old version of pip which may not support Python Wheels. To upgrade pip type: "<code>pip install --upgrade pip</code>".<br>
<br>
<h2>Downloads</h2>

Python 2.7 32-bit and 64-bit downloads are available. Python 3.4 is not yet supported, see <a href='../issues/121'>Issue 121</a>.<br>
<br>
<a href='https://drive.google.com/folderview?id=0B1di2XiBBfacOFpJb1dERGZSRnc&usp=drive_web#list'>Download from Google Drive</a>.<br>
<br>
<a href='https://www.dropbox.com/sh/zar95p27yznuiv1/AACjDpU4NGtPFC5I5sS1TI22a?dl=0'>Download from Dropbox</a>.<br>
<br>
<h2>Examples</h2>

To run some examples go to the examples/ directory that is inside the cefpython3 package. Type "<code>pip show cefpython3</code>" to see where the cefpython3 package was installed. It is recommended to run the wxpython.py example which presents the most features.<br>
<ul><li><a href='../blob/master/cefpython/cef3/windows/binaries_64bit/wxpython.py'>wxpython.py</a> - example of embedding using the <a href='http://www.wxpython.org/'>wxPython</a> GUI toolkit. Includes many tests of advanced features.<br>
</li><li><a href='../blob/master/cefpython/cef3/windows/binaries_32bit/pywin32.py'>pywin32.py</a> - example of embeddig using the pywin32 extension.<br>
</li><li><a href='../blob/master/cefpython/cef3/windows/binaries_32bit/pygtk_.py'>pygtk_.py</a> - example of embedding using the <a href='http://www.pygtk.org/'>PyGTK</a> GUI toolkit<br>
</li><li><a href='../blob/master/cefpython/cef3/windows/binaries_32bit/pyqt.py'>pyqt.py</a> - example of embedding using the <a href='http://www.riverbankcomputing.co.uk/software/pyqt/intro'>PyQt</a> UI framework<br>
</li><li><a href='../blob/master/cefpython/cef3/windows/binaries_32bit/pyside.py'>pyside.py</a> - example of embedding using the <a href='http://qt-project.org/wiki/PySide'>PySide</a> UI framework<br>
</li><li>The Inno setup and Distutils distributions come with the cefpython3.wx module with more wxPython examples. See <a href='https://code.google.com/p/cefpython/source/browse/cefpython/cef3/wx-subpackage/examples/sample1.py'>sample1.py</a>, <a href='https://code.google.com/p/cefpython/source/browse/cefpython/cef3/wx-subpackage/examples/sample2.py'>sample2.py</a>, <a href='https://code.google.com/p/cefpython/source/browse/cefpython/cef3/wx-subpackage/examples/sample3.py'>sample3.py</a>.</li></ul>

<h2>Notes</h2>

<ul><li>64bit binaries do not have applied the patch that fixes HTTPS caching on sites with SSL certificate errors (<a href='https://code.google.com/p/cefpython/issues/detail?id=125'>Issue 125</a>).