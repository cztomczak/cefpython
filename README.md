# CEF Python

[![](https://img.shields.io/badge/python-2.7-yellow.svg "Python versions supported")](https://github.com/cztomczak/cefpython#cef-python)
[![](https://img.shields.io/badge/release-v31.2-orange.svg "GitHub latest release")](https://github.com/cztomczak/cefpython/releases/latest)
[![](https://img.shields.io/badge/pypi-v31.2-blue.svg "PyPI latest release")](https://pypi.python.org/pypi/cefpython3/)
[![](https://img.shields.io/badge/commits%20since-v31.2-lightgray.svg "Commits since v31.2 release")](https://github.com/cztomczak/cefpython/compare/05366f2...master)

__NOTE__: Repository rewritten on 2016-02-15 to reduce its size.
  Please clone it again.

Table of contents:
* [Introduction](#introduction)
* [Compatibility](#compatibility)
* [Downloads](#downloads)
* [Support](#support)
* [Donate](#donate)


## Introduction

CEF Python is an open source project founded by [Czarek Tomczak](http://www.linkedin.com/in/czarektomczak) in 2012 to provide python bindings for the [Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef). See the growing list of [applications using CEF](http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF) on wikipedia. Examples of embedding CEF browser are available for many popular GUI toolkits including: [wxPython](../../wiki/wxPython), [PyGTK](../../wiki/PyGTK), [PyQt](../../wiki/PyQt), [PySide](../../wiki/PySide), [Kivy](../../wiki/Kivy), [Panda3D](../../wiki/Panda3D) and [PyWin32](../master/cefpython/cef3/windows/binaries_32bit/pywin32.py).

Some use cases for CEF: 

* Embed a web browser control with great HTML5 support (based on Chromium)
* Use it to create a HTML5 based GUI in an application. This can act as a replacement for GUI toolkits like wxWidgets/Qt/Gtk. For native communication between javascript and python use [javascript bindings](../../wiki/JavascriptBindings). Another option is to run an internal python web server and use websockets/XMLHttpRequest for js&lt;&gt;python communication. This way you can write a desktop app in the same way you write web apps. 
* Render web content off-screen in applications that use custom drawing frameworks. See the [Kivy](../../wiki/Kivy) and [Panda3D](../../wiki/Panda3D) examples.
* Use it for automated testing of existing web applications. Use it for web scraping, or as a web crawler or other kind of internet bots.


## Compatibility

* Supported Python versions: 2.7. For Python 3.4 / 3.5 support see [Issue #121](../../issues/121).
* Supported platforms: Windows, Linux, Mac. Both 32bit and 64bit binaries are available for all platforms.


## Downloads

On Win/Mac you can install from PyPI using this command:
`pip install cefpython3`.

* For Windows: see the [Download_CEF3_Windows](../../wiki/Download_CEF3_Windows) wiki page.
* For Linux: see the [Download_CEF3_Linux](../../wiki/Download_CEF3_Linux) wiki page.
* For Mac: see the [Download_CEF3_Mac](../../wiki/Download_CEF3_Mac) wiki page.


## Support

* API docs are in the [api/](api/) directory
* See [Wiki Pages](../../wiki)
* Ask questions and report problems on the
  [Forum](https://groups.google.com/group/cefpython)
* Please do not ask questions in the Issue Tracker


## Donate

If you would like to support general CEF Python development efforts by making a donation see the [Donations](../../wiki/Donations) wiki page.
