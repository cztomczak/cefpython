# Download CEF Python 3 for Mac #

Table of contents:


## Introduction ##

The binaries were built by following the instructions on the [BuildOnMac](BuildOnMac) wiki page.<br>

<b>Version information</b><br>
The latest version is 31.2 for OSX 10.7+, released on January 13, 2015.<br>
Chrome version is 31.0.1650.69. Based on CEF 3 branch 1650 rev. 1639.<br>
For an explanation of these numbers see the <a href='VersionNumbering'>VersionNumbering</a> wiki page.<br>
<br>
<b>Release notes</b><br>
For a list of changes in current and past binary distributions see<br>
the ReleaseNotes wiki page.<br>
<br>
<b>Stability note</b><br>
Chrome switched to only 64-bit builds on Mac starting with Chrome 39. Earlier versions of Chrome 64bit are not considered stable. CEF Python currently ships Chrome 31 and during testing everything worked fine. But if you want the best stability it is recommended that you use 32bit binaries.<br>
<br>
<h2>Install from PyPI</h2>

To install the <a href='https://pypi.python.org/pypi/cefpython3'>PyPI/cefpython3</a> package using the pip package manager type:<br>
<pre><code>pip install cefpython3<br>
</code></pre>

If there are problems installing the cefpython3 package, then it might be caused by an old version of pip which may not support Python Wheels. To upgrade pip type: "<code>pip install --upgrade pip</code>".<br>
<br>
When using preinstalled Python that ships with OS X, to install pip type "<code>sudo easy_install pip</code>" and to install the cefpython3 package type "<code>sudo pip install cefpython3</code>".<br>
<br>
<h2>Downloads</h2>

Packages are available only for Python 2.7. All packages contain fat binaries and can run on both 32bit and 64bit. Python 3.4 is not yet supported, see <a href='../issues/121'>Issue 121</a>.<br>
<br>
<a href='https://drive.google.com/folderview?id=0B1di2XiBBfacOFpJb1dERGZSRnc&usp=drive_web#list'>Download from Google Drive</a>.<br>
<br>
<a href='https://www.dropbox.com/sh/zar95p27yznuiv1/AACjDpU4NGtPFC5I5sS1TI22a?dl=0'>Download from Dropbox</a>.<br>
<br>
<h2>Examples</h2>

To run some examples go to the examples/ directory that is inside the cefpython3 package. Type "<code>pip show cefpython3</code>" to see where the cefpython3 package was installed. It is recommended to run the wxpython.py example which presents the most features.<br>
<br>
<ul><li><a href='../blob/master/cefpython/cef3/mac/binaries_64bit/wxpython.py'>wxpython.py</a> - example of embedding using the <a href='http://www.wxpython.org/'>wxPython</a> GUI toolkit. Includes many tests of advanced features.<br>
</li><li>The cefpython3.wx subpackage comes with more wxPython examples, see: <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample1.py'>sample1.py</a>, <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample2.py'>sample2.py</a>, <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample3.py'>sample3.py</a>.</li></ul>

Note that when using preinstalled Python that ships with OS X and running examples from the "<code>/Library/Python/2.7/site-packages/cefpython3/examples</code>" directory, you might encounter an error "Segmentation fault: 11". This will occur if app doesn't have permission to write to the "debug.log" file. To fix it run the "<code>sudo chmod 666 debug.log wx/debug.log</code>" command in the examples/ directory. This is to be fixed in <a href='../issues/164</a>.