__Notes__:
* Repository rewritten on 2016-02-15 to reduce its size.
  Please clone it again.


# CEF Python

Table of contents:
* [Introduction](#introduction)
* [Compatibility](#compatibility)
* [Downloads](#downloads)
* [Documentation and help](#documentation-and-help)
* [Support development](#support-development)


## Introduction

CEF Python is an open source project founded by [Czarek Tomczak](http://www.linkedin.com/in/czarektomczak) in 2012 to provide python bindings for the [Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef). See the growing list of [applications using CEF](http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF) on wikipedia. Examples of embedding CEF browser are available for many popular GUI toolkits including: [wxPython](../../wiki/wxPython), [PyGTK](../../wiki/PyGTK), [PyQt](../../wiki/PyQt), [PySide](../../wiki/PySide), [Kivy](../../wiki/Kivy), [Panda3D](../../wiki/Panda3D) and [PyWin32](../master/cefpython/cef3/windows/binaries_32bit/pywin32.py).

Some use cases for CEF: 

* Embed a web browser control with great HTML5 support (based on Chromium)
* Use it to create a HTML5 based GUI in an application. This can act as a replacement for GUI toolkits like wxWidgets/Qt/Gtk. For native communication between javascript and python use [javascript bindings](../../wiki/JavascriptBindings). Another option is to run an internal python web server and use websockets/XMLHttpRequest for js&lt;&gt;python communication. This way you can write a desktop app in the same way you write web apps. 
* Render web content off-screen in applications that use custom drawing frameworks. See the [Kivy](../../wiki/Kivy) and [Panda3D](../../wiki/Panda3D) examples.
* Use it for automated testing of existing web applications. Use it for web scraping, or as a web crawler or other kind of internet bots.


## Compatibility

* Supported Python versions: 2.7 (Python 3.4 will be supported soon, see [Issue #121](../../issues/121))
* Supported platforms: Windows, Linux, Mac (both 32bit and 64bit binaries are available for all platforms)


## Downloads

* For Windows: see the [Download_CEF3_Windows](../../wiki/Download_CEF3_Windows) wiki page.
* For Linux: see the [Download_CEF3_Linux](../../wiki/Download_CEF3_Linux) wiki page.
* For Mac: see the [Download_CEF3_Mac](../../wiki/Download_CEF3_Mac) wiki page.


## Documentation and help

* See the [Help and search](../../wiki/Help-and-search) wiki page
* Documentation and API is available on [Wiki Pages](../../wiki)
* New up-to-date API docs are in the [api/](api/) directory.
* Please do not use the Issue Tracker for asking questions. Use the
  [Forum](https://groups.google.com/group/cefpython).


## Support development

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=95W9VHNSFWRUN"><img align="right" src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif"></img></a> If you are interested in donating time to help with the CEF Python development please see the [Internal development](../../wiki/InternalDevelopment) wiki page. If you would like to support general CEF Python development efforts by making a donation see the [Donations](docs/Donations.md) page. At this time CEF Python is unable to accept donations that sponsor the development of specific features. If you are interested in sponsorship opportunities please contact Czarek directly.
