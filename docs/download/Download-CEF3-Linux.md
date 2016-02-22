# Download CEF Python 3 for Linux #


## Introduction ##

The binaries were built by following the instructions on the [BuildOnLinux](BuildOnLinux) wiki page.<br>
Linux release is sponsored by <a href='http://www.cyaninc.com/'>Cyan Inc.</a>

<b>Version information</b><br>
The latest version is 31.2 (stable), released on January 10, 2015.<br>
The Chrome version is 31.0.1650.69. Based on CEF 3 branch 1650 rev. 1639.<br>
For an explanation of these numbers see the <a href='VersionNumbering'>VersionNumbering</a> wiki page.<br>
<br>
<b>Release notes</b><br>
For a list of changes in current and past binary distributions see<br>
the ReleaseNotes wiki page.<br>
<br>
<h2>Downloads</h2>

There are two distributions available for linux: a Debian package and a Distutils Setup. Both 32-bit and 64-bit platforms are supported. Only Python 2.7 downloads are available. Python 3.4 is not yet supported, see <a href='../issues/121'>Issue 121</a>.<br>
<br>
<a href='https://drive.google.com/folderview?id=0B1di2XiBBfacOFpJb1dERGZSRnc&usp=drive_web#list'>Download from Google Drive</a>.<br>
<br>
<a href='https://www.dropbox.com/sh/zar95p27yznuiv1/AACjDpU4NGtPFC5I5sS1TI22a?dl=0'>Download from Dropbox</a>.<br>
<br>
<h2>Install location on Ubuntu</h2>

Debian package installs to:<br>
<pre><code>/usr/share/pyshared/cefpython3/<br>
/usr/lib/pymodules/python2.7/cefpython3/ (symbolic links to /usr/share/pyshared/cefpthon3/)<br>
</code></pre>

Distutils package installs to:<br>
<pre><code>/usr/local/lib/python2.7/dist-packages/cefpython3/<br>
</code></pre>

Note that if you've installed both the Debian package and the Distutils package, then the Distutils package will take precedence when importing the cefpython3 module.<br>
<br>
<h2>Examples</h2>

Go to examples/ directory that is inside cefpython3/ package. For location of this directory see the previous section "Install location on Ubuntu".<br>
<br>
It is recommended to run the wxpython.py example which presents the most features. To install wx toolkit type:<br>
<pre><code>sudo apt-get install python-wxtools<br>
</code></pre>

<ul><li><a href='../blob/master/cefpython/cef3/linux/binaries_64bit/wxpython.py'>wxpython.py</a> - example of embedding using the <a href='http://www.wxpython.org/'>wxPython</a> GUI toolkit. Includes many tests of advanced features.<br>
</li><li><a href='../blob/master/cefpython/cef3/linux/binaries_64bit/wxpython-response.py'>wxpython-response.py</a> - example of reading/modifying all resource requests<br>
</li><li><a href='../blob/master/cefpython/cef3/linux/binaries_64bit/kivy_.py'>kivy_.py</a> - example of embedding an off-screen rendered browser using the <a href='http://kivy.org/'>Kivy</a> framework, see <a href='Kivy'>the screenshot</a>
</li><li><a href='../blob/master/cefpython/cef3/linux/binaries_64bit/pygtk_.py'>pygtk_.py</a> - example of embedding using the <a href='http://www.pygtk.org/'>PyGTK</a> GUI toolkit<br>
</li><li><a href='../blob/master/cefpython/cef3/linux/binaries_64bit/pyqt.py'>pyqt.py</a> - example of embedding using the <a href='http://www.riverbankcomputing.co.uk/software/pyqt/intro'>PyQt</a> UI framework<br>
</li><li>The distutils setup distribution and the debian package come with the cefpython3.wx module with more wxPython examples. See <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample1.py'>sample1.py</a>, <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample2.py'>sample2.py</a>, <a href='../blob/master/cefpython/cef3/wx-subpackage/examples/sample3.py'>sample3.py</a>.<br>
</li><li><a href='https://gist.github.com/croxis/9789973'>basic.py</a> - example of off-screen rendering using the <a href='http://www.panda3d.org/'>Panda3D</a> game engine. See <a href='http://www.panda3d.org/forums/viewtopic.php?f=8&t=16861'>this topic</a> on Panda3D Forums for more details.</li></ul>

<h2>Uninstall</h2>

To uninstall the Debian package type:<br>
<pre><code>sudo apt-get remove python-cefpython3<br>
</code></pre>

To uninstall the Distutils package type:<br>
<pre><code>sudo rm -rf /usr/local/lib/python2.7/dist-packages/cefpython3*<br>
</code></pre>