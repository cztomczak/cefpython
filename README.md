# CEF Python

Table of contents:
 * [Introduction](#introduction)
 * [Supported Python versions and platforms](#supported-python-versions-and-platforms)
 * [Downloads](#downloads)
 * [Help](#help)
 * [Watch the project](#watch-the-project)
 * [Support development](#support-development)
 * [Thanks](#thanks)

## Introduction

CEF Python is an open source project founded by <a href="http://www.linkedin.com/in/czarektomczak">Czarek Tomczak</a> in 2012 to provide python bindings for the <a href="https://bitbucket.org/chromiumembedded/cef">Chromium Embedded Framework</a>. See the growing list of <a href="http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF">applications using CEF</a> on wikipedia. Examples of embedding CEF browser are available for many popular GUI toolkits including: <a href="../wiki/wxPython.md">wxPython</a>, <a href="../wiki/PyGTK.md">PyGTK</a>, <a href="../wiki/PyQt.md">PyQt</a>, <a href="../wiki/PySide.md">PySide</a>, <a href="../wiki/Kivy.md">Kivy</a>, <a href="../wiki/Panda3D.md">Panda3D</a> and <a href="../master/cefpython/cef3/windows/binaries_32bit/pywin32.py">PyWin32</a>.

Some use cases for CEF: 

* Embed a web browser control with great HTML5 support (based on Chromium)
* Use it to create a HTML5 based GUI in an application. This can act as a replacement for GUI toolkits like wxWidgets/Qt/Gtk. For native communication between javascript and python use <a href="../wiki/JavascriptBindings.md">javascript bindings</a>. Another option is to run an internal python web server and use websockets/XMLHttpRequest for js&lt;&gt;python communication. This way you can write a desktop app in the same way you write web apps. 
* Render web content off-screen in applications that use custom drawing frameworks. See the <a href="../wiki/Kivy.md">Kivy</a> and <a href="../wiki/Panda3D.md">Panda3D</a> examples.
* Use it for automated testing of existing web applications. Use it for web scraping, or as a web crawler or other kind of internet bots.

## Supported Python versions and platforms

* Supported Python versions: 2.7 (Python 3.4 will be supported soon, see [Issue #121](../../issues/121))
* Supported platforms: Windows, Linux, Mac (both 32bit and 64bit binaries are available for all platforms)

## Downloads

* For Windows: see the <a href="../wiki/Download_CEF3_Windows.md">Download_CEF3_Windows</a> wiki page.
* For Linux: see the <a href="../wiki/Download_CEF3_Linux.md">Download_CEF3_Linux</a> wiki page.
* For Mac: see the <a href="../wiki/Download_CEF3_Mac.md">Download_CEF3_Mac</a> wiki page.

## Help

* Documentation is on the <a href="../../tree/wiki">wiki pages</a>. Start with the <a href="../wiki/API.md">API</a> page.
* Ask questions and report problems on the <a href="https://groups.google.com/group/cefpython">CEF Python Forum</a>.
* Please do not use the [Issue Tracker](../../issues) for asking questions.
* Instructions on how to enable Flash Player are on the <a href="../wiki/Plugins.md">Plugins</a> wiki page.
* Having problems with playing audio or video? See the <a href="../wiki/AudioVideo.md">AudioVideo</a> wiki page. 

## Watch the project

To be notified of updates watch the project on GitHub and additionally join the <a href="http://groups.google.com/group/cefpython">Forum</a> and set membership settings to send Daily summaries via email.

## Support development

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=95W9VHNSFWRUN"><img align="right" src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif"></img></a> If you are interested in donating time to help with the CEF Python development please see the <a href="../wiki/InternalDevelopment.md">InternalDevelopment</a> wiki page. If you would like to support general CEF Python development efforts by making a donation please click the Paypal "Donate" button to the right. At this time CEF Python is unable to accept donations that sponsor the development of specific features. If you are interested in sponsorship opportunities please contact Czarek directly.

### Thanks

* Thanks to the numerous individuals that made a Paypal donation: Walter Purvis, Rokas Stupuras, Alex Rattray, Greg Kacy, Paul Korzhyk.
* Thanks to those that have donated their time through code contributions: see the  [AUTHORS.txt](../master/cefpython/AUTHORS.txt) file. Patches can be attached in the issue tracker.
* <a href="http://www.cyaninc.com/"><img align="right" width="200" height="42" src="https://cefpython.googlecode.com/git/cefpython/var/cyan_new_logo.png"></img></a>Many thanks to <a href="http://www.cyaninc.com/">Cyan Inc.</a> for sponsoring this project, making CEF Python 3 more mature. Lots of new features were added, including javascript bindings and Linux support.
* Thanks to <a href="http://www.rentouch.ch/">Rentouch GmbH</a> for sponsoring the development of the off-screen rendering support in CEF Python 3.
* Thanks to Thomas Wusatiuk for sponsoring the development of the web response reading features in CEF Python 3.
* Thanks to Adam Duston for donating a Macbook to aid the development of the Mac port.

## Built a cool app?

Built a cool app using CEF Python and would like to share info with the community? Talk about it on the <a href="https://groups.google.com/group/cefpython?hl=en">CEF Python Forum</a>.

## Familiar with PHP or Go?

The author of CEF Python is also working on CEF bindings for other languages such as PHP and Go. For PHP take a look at the [PHP Desktop](https://github.com/cztomczak/phpdesktop) project. For Go see the [CEF2go](https://github.com/cztomczak/cef2go) project on GitHub.
