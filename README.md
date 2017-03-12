# CEF Python

Table of contents:
* [Introduction](#introduction)
* [Versions](#versions)
  * [v50+ releases](#v50-releases)
  * [v31 release](#v31-release)
* [Support](#support)
* [Support development](#support-development)
  * [Thanks](#thanks)


## Introduction

CEF Python is a BSD-licensed open source project founded by [Czarek Tomczak]
(http://www.linkedin.com/in/czarektomczak) in 2012 and is based on
Google Chromium and the [CEF Framework]
(https://bitbucket.org/chromiumembedded/cef) projects. The Chromium
project focuses mainly on Google Chrome application development, while
CEF focuses on facilitating embedded browser use cases in third-party
applications. Lots of applications use CEF control, there are more than
[100 million CEF instances]
(http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF)
installed around the world. [Examples of embedding](examples/Examples-README.md)
Chrome browser are available for many popular GUI toolkits including:
wxPython, PyGTK, PyQt, PySide, Kivy, Panda3D and PyGame/PyOpenGL.

There are many use cases for CEF. You can embed a web browser control
based on Chromium with great HTML 5 support. You can use it to create
a HTML 5 based GUI in an application, this can act as a replacement for
standard GUI toolkits such as wxWidgets, Qt or GTK. In such case to
communicate between Python<>Javascript use javascript bindings or
embed an internal web server and talk using http requests. You can render
web content off-screen in application that use custom drawing frameworks.
You can use it for automated testing of existing applications. You can
use it for web scraping or as a web crawler, or other kind of internet
bots.


## Versions

### v50+ releases

1. Can be installed on all platforms using `pip install cefpython3` command
2. Downloads are available on [GitHub Releases](../../releases) pages
2. Windows support: 32-bit and 64-bit, Python 2.7 / 3.4 / 3.5 / 3.6
   (requirements: Windows 7+)
3. Linux support: 64-bit, Python 2.7 / 3.4 / 3.5 / 3.6
   (requirements: Debian 7+ / Ubuntu 12.04+)
4. Mac support: 64-bit, Python 2.7 / 3.4 / 3.5 / 3.6
   (requirements: MacOS 10.9+)
5. Documentation is in the [docs/](docs) directory
6. API reference is in the [api/](api) directory
7. Additional documentation is in issues labelled [Knowledge Base]
   (../../issues?q=is%3Aissue+is%3Aopen+label%3A%22Knowledge+Base%22)

### v31 release

1. Downloads are available on [wiki pages](../../wiki#downloads)
   and on GH Releases tagged [v31.2](../../releases/tag/v31.2)
2. Supports only Python 2.7
3. Windows support: 32-bit and 64-bit (requirements: Windows XP+)
4. Linux support: 32-bit and 64-bit (requirements: Debian 7+ / Ubuntu 12.04+)
5. Mac support: 32-bit and 64-bit (requirements: MacOS 10.7+)
6. Documentation is on [wiki pages](../../wiki)
7. API reference is available in revision [169a1b2]
   (../../tree/169a1b20d3cd09879070d41aab28cfa195d2a7d5/docs/api)


## Support

- Ask questions and report problems on the [Forum]
  (https://groups.google.com/group/cefpython)
- Documentation is in the [docs/](docs) directory
- API reference is in the [api/](api) directory
- Additional documentation is in issues labelled [Knowledge Base]
  (../../issues?q=is%3Aissue+is%3Aopen+label%3A%22Knowledge+Base%22)
- Wiki pages are deprecated and for v31 only


## Support development

If you would like to support general CEF Python development efforts
by making a donation please click the Paypal Donate button:

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=V7LU7PD4N4GGG'>
<img src='https://raw.githubusercontent.com/wiki/cztomczak/cefpython/images/donate.gif' />
</a>

At this time CEF Python is unable to accept donations that sponsor the
development of specific features. However you can make a donation with
a comment that you would like to see some feature implemented and it will
give it a higher priority.

If you are interested in sponsorship opportunities please contact Czarek
directly.

### Thanks

* Many thanks to [ClearChat Inc.](https://clearchat.com) for sponsoring
  the v55/v56 releases for all platforms
* Thanks to JetBrains for providing an Open Source license for
  [PyCharm](https://www.jetbrains.com/pycharm/)
* Thanks to those who have made a Paypal donation: [Rentouch GmbH]
  (http://www.rentouch.ch/), Walter Purvis, Rokas Stupuras, Alex Rattray,
  Greg Kacy, Paul Korzhyk
* Lots of thanks goes to [Cyan Inc.](http://www.blueplanet.com/) for
  sponsoring this project for a long time, making CEF Python 3 mature
* Thanks to those who have donated their time through code contributions,
  they are listed in the [Authors](Authors) file
* Thanks to Adam Duston for donating a Macbook to aid the development
  of Mac port
* Thanks to [Rentouch GmbH](http://www.rentouch.ch/) for sponsoring the
  development of the off-screen rendering support
* Thanks to Thomas Wusatiuk for sponsoring the development of the web
  response reading features
