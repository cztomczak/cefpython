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

CEF Python is an open source project founded by [Czarek Tomczak]
(http://www.linkedin.com/in/czarektomczak)
in 2012 to provide python bindings for the [Chromium Embedded Framework]
(https://bitbucket.org/chromiumembedded/cef).
See the growing list of [applications using CEF]
(http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF)
on wikipedia. Examples of embedding CEF browser are available for many
popular GUI toolkits including: wxPython, PyGTK, PyQt, PySide, Kivy,
Panda3D, PyWin32 and PyGame/PyOpenGL.

There are many use cases for CEF. You can embed a web browser control
based on Chromium with great HTML 5 support. You can use it to create
a HTML 5 based GUI in an application, this can act as a replacement for
standard GUI toolkits like wxWidgets, Qt or GTK. You can render web
content off-screen in application that use custom drawing frameworks.
You can use it for automated testing of existing applications. You can
use it for web scraping or as a web crawler, or other kind of internet
bots.


## Versions

### v50+ releases

1. Can be installed on all platforms using `pip install` command
2. Downloads are available on [GitHub Releases](../../releases) pages
2. Windows support: 32-bit, Python 2.7
3. Linux support: 64-bit, Python 2.7 / 3.4 / 3.5 / 3.6
4. Mac support: 64-bit, Python 2.7 / 3.4 / 3.5 / 3.6
5. Documentation is in the [docs/](docs) directory
6. API reference is in the [api/](api) directory
7. Additional documentation is in issues labelled [Knowledge Base]
   (../../issues?q=is%3Aissue+is%3Aopen+label%3A%22Knowledge+Base%22)

### v31 release

1. Downloads are available on [wiki pages](../../wiki#downloads)
   and on GH Releases tagged [v31.2](../../releases/tag/v31.2)
2. Supports only Python 2.7
3. Windows support: 32-bit and 64-bit
4. Linux support: 32-bit and 64-bit
5. Mac support: 32-bit and 64-bit
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
