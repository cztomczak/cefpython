# CEF Python

[![](https://img.shields.io/badge/python-2.7-yellow.png "Python versions supported")](https://github.com/cztomczak/cefpython#cef-python)
[![](https://img.shields.io/badge/release-v31.2-orange.png "GitHub latest release")](https://github.com/cztomczak/cefpython/releases/latest)
[![](https://img.shields.io/badge/pypi-v31.2-blue.png "PyPI latest release")](https://pypi.python.org/pypi/cefpython3/)
[![](https://img.shields.io/badge/commits%20since-v31.2-lightgray.png "Commits since v31.2 release")](https://github.com/cztomczak/cefpython/compare/05366f2...master)

__IMPORTANT NOTES__:
* Master branch is a work in progress. The last stable release
  is in the cefpython31 branch. Up-to-date API docs for the cefpython31
  branch can be viewed in commit [169a1b2](https://github.com/cztomczak/cefpython/tree/169a1b20d3cd09879070d41aab28cfa195d2a7d5/docs/api).
* Repository rewritten on 2016-02-15 to reduce its size.
  Please clone it again.

Table of contents:
* [Introduction](#introduction)
* [Compatibility](#compatibility)
* [Downloads](#downloads)
* [Support](#support)
* [Changes in API during updates](#changes-in-api-during-updates)
* [Donate](#donate)


## Introduction

CEF Python is an open source project founded by [Czarek Tomczak](http://www.linkedin.com/in/czarektomczak) in 2012 to provide python bindings for the [Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef). See the growing list of [applications using CEF](http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF) on wikipedia. Examples of embedding CEF browser are available for many popular GUI toolkits including: [wxPython](../../wiki/wxPython), [PyGTK](../../wiki/PyGTK), [PyQt](../../wiki/PyQt), [PySide](../../wiki/PySide), [Kivy](../../wiki/Kivy), [Panda3D](../../wiki/Panda3D) and [PyWin32](src/windows/binaries_32bit/pywin32.py).

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

__New releases RSS/Atom feed__
To be notified of new releases subscribe to this [Atom feed](https://github.com/cztomczak/cefpython/releases.atom).


## Support

* API docs are in the [docs/api/](docs/api/) directory
* See also [Wiki Pages](../../wiki)
* Ask questions and report problems on the
  [Forum](https://groups.google.com/group/cefpython)
* Please do not ask questions in the Issue Tracker


## Changes in API during updates

CEF Python depends on CEF and API breaks are inevitable when updating
to a newer CEF. When updating cefpython to a new version go to the
[GitHub Releases](https://github.com/cztomczak/cefpython/releases) page
and check release notes for all the releases that appeared between
your old version and the new version. Look for lists named
"Changes in API that break backward compatibility".


## Donate

If you would like to support general CEF Python development efforts by making a donation see the [Donations](../../wiki/Donations) wiki page.
