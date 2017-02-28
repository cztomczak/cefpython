# Knowledge Base

Table of contents:
* [Notifications on new releases](#notifications-on-new-releases)
* [Changes in API after CEF updates](#changes-in-api-after-cef-updates)
* [Differences between Python 2 and Python 3](#differences-between-python-2-and-python-3)
* [Flash support](#flash-support)
* [Feature X works in Google Chrome, but doesn't work in CEF Python](#feature-x-works-in-google-chrome-but-doesnt-work-in-cef-python)
* [How to capture Audio and Video in HTML5?](#how-to-capture-audio-and-video-in-html5)
* [Touch and multi-touch support](#touch-and-multi-touch-support)
* [Black or white browser screen](#black-or-white-browser-screen)
* [Windows XP support](#windows-xp-support)
* [Mac 32-bit support](#mac-32-bit-support)
* [Security](#security)


## Notifications on new releases

To be notified of new releases subscribe to this [RSS/Atom feed]
(../../../releases.atom).

Announcements are also made on the [Forum]
(https://groups.google.com/d/forum/cefpython).
To be notified of these via email set your Membership and Email settings
and change delivery preference to Daily summaries.


## Changes in API after CEF updates

CEF Python depends on CEF and API breaks are inevitable when updating
to latest CEF. The [Migration Guide](Migration-guide.md) document which
is still under works, will list most notable breaking changes since
v31 release. Until it's done go to go to the [GitHub Releases]
(../../../releases) page and check release notes for all the releases
that appeared between your old version and the new version. Look for
lists named "Changes in API that break backward compatibility" or
similar.

Due to unavoidable changes in API it is recommended for your setup
scripts that use for example PIP to install the cefpython3 package,
to hardcode the cefpython version string. If for example using PIP's
requirements.txt file then list the cefpython3 package in the
following format: `cefpython3 == 31.2`.


## Differences between Python 2 and Python 3

In Python 2 all cefpython strings are byte strings, but in Python 3
they are all unicode strings. Be aware of this when porting cefpython
based apps to Python 3, as it may cause issues.


## Flash support

See [Issue #235](../../../issues/235) ("Flash support in CEF 51+").


## Feature X works in Google Chrome, but doesn't work in CEF Python

CEF Python embeds Chromium Embedded Framework (CEF) which is based
on Chromium browser. Functionality may differ a bit from Google Chrome.
The browser from Google is a proprietary software that for example
includes MPEG-4/H.264 codecs that aren't included in the open source
Chromium. CEF currently doesn't support Chrome Extensions, but basic
support for Chrome Extensions is being implemented in upstream CEF
as of now.

To see if some feature is working or a bug is fixed in newer CEF
release perform the following steps:

1. Download and install [CMake](https://cmake.org/download/) and
   [Ninja](https://github.com/ninja-build/ninja/releases)
2. Go to [Spotify Automated Builds]
   (http://opensource.spotify.com/cefbuilds/index.html)
   and download latest CEF for your platform. Choose "Standard
   Distribution" binaries.
3. Follow the instructions in `CMakeLists.txt` file
4. Run either cefclient or cefsimple to test features


## How to capture Audio and Video in HTML5?

To be able to use the getUserMedia() function you need to set the
"enable-media-stream" switch.
See [api/Command line switches](../api/CommandLineSwitches.md) document.


## Touch and multi-touch support

In CEF v47 or later touch device is auto-detected and everything should
work out of the box. If that's not the case try setting the following
switches:

* --touch-events=enabled
* --enable-pinch

See [api/Command line switches](../api/CommandLineSwitches.md) document.


## Black or white browser screen

If you get a black or white screen in the browser view then this may
be caused by incompatible GPU (video card) drivers. There are following
solutions to this:

1. When CEF Python is updated to a newer CEF/Chromium version then the
problem may be disappear. Check with latest Google Chrome if that is
the case.

2. Try updating your video card drivers to the latest version available

3. You can disable GPU hardware acceleration by adding the "disable-gpu"
and "disable-gpu-compositing" command line switches. See the
[api/Command Line Switches](../api/CommandLineSwitches.md). Note that
this will degrade performance if you're using any advanced 3D features.
It will affect 2D accelerated content as well.

Note that when web page uses WebGL then the black screen may still
appear even after disabling GPU hardware acceleration. This is normal
because GPU was disabled so WebGL cannot work.


## Windows XP support

CEF Python v31.2 was the last version to support Windows XP. This is
due to Chromium/CEF dropping XP support, last CEF version that
supported XP was v49.

On XP you should disable GPU acceleration by using the --disable-gpu
and --disable-gpu-compositing switches. These switches must be passed
programmatically to cef.Initialize(), see [api/Command Line Switches]
(../api/CommandLineSwitches.md).


## Mac 32-bit support

CEF Python v31.2 was the last version to support Mac 32-bit.
This is due to CEF/Chromium dropping 32-bit support, last CEF version
that supported 32-bit was v38.


## Security

A quote by Marshall Greenblatt:

> CEF offers significant integration capabilities beyond what
> is offered by a standard Google Chrome browser installation.
> The trade off for these additional capabilities is that
> organizations using CEF must take responsibility for their own
> application security. CEF and the underlying open source projects
> (Chromium, WebKit, etc) involve a significant amount of code and
> offer no warranties. Organizations should document and follow best
> practices to minimize potential security risks. Here are some
> recommended best practices that organizations can consider:
> - Only load known/trusted content. This is by far the best way
>   to avoid potential security issues.
> - Disable plugins. This will avoid a large category of security
>   issues caused by buggy versions of Flash, Java, etc.
> - Do not explicitly disable or bypass security features in your
>   application. For example, do not enable CefBrowserSettings that
>   bypass security features or add fake headers to bypass HTTP
>   access control.
> - Keep your application up to date with the newest CEF release
>   branch. You may want to update the underlying Chromium release
>   version and perform your own builds to take immediate advantage
>   of any bug fixes.
> - Enforce good programming practices. Every organization should
>   have best practices for design, testing and verification.
> - Audit your application for potential security issues. Every
>   decision that may have security consequences should be evaluated
>   by people who are knowledgeable about security considerations.

Reference: [Question on browser security]
(http://magpcss.org/ceforum/viewtopic.php?f=10&t=10222)
on the CEF Forum.

