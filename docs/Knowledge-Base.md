# Knowledge Base

Table of contents:
* [Notifications about new releases / commits](#notifications-about-new-releases--commits)
* [Changes in API after CEF updates](#changes-in-api-after-cef-updates)
* [Differences between Python 2 and Python 3](#differences-between-python-2-and-python-3)
* [How to enable debug information in examples?](#how-to-enable-debug-information-in-examples)
* [Remote debugging with Google Chrome instance](#remote-debugging-with-google-chrome-instance)
* [Debugging using various chrome:// protocol uris](#debugging-using-various-chrome-protocol-uris)
* [A blank window on Mac/Linux](#a-blank-window-on-maclinux)
* [Location of CEF framework in Mac apps](#location-of-cef-framework-in-mac-apps)
* [Flash support](#flash-support)
* [Feature X works in Google Chrome, but doesn't work in CEF Python](#feature-x-works-in-google-chrome-but-doesnt-work-in-cef-python)
* [How to capture Audio and Video in HTML5?](#how-to-capture-audio-and-video-in-html5)
* [Touch and multi-touch support](#touch-and-multi-touch-support)
* [Black or white browser screen](#black-or-white-browser-screen)
* [Python crashes with "Segmentation fault" - how to debug?](#python-crashes-with-segmentation-fault---how-to-debug)
* [Windows XP support](#windows-xp-support)
* [Mac 32-bit support](#mac-32-bit-support)
* [Security](#security)


## Notifications about new releases / commits

To be notified of new releases subscribe to this [RSS/Atom feed](../../../releases.atom).

Announcements are also made on the [Forum](https://groups.google.com/d/forum/cefpython).
To be notified of these via email set your Membership and Email settings
and change delivery preference to Daily summaries.

To be notified on new commits subscribe to this [RSS/Atom feed](../../../commits/master.atom).


## Changes in API after CEF updates

CEF Python depends on CEF and API breaks are inevitable when updating
to latest CEF. The [Migration Guide](Migration-guide.md) document
lists most notable breaking changes for each release. Full chanelogs
can be found on [GitHub Releases](../../../releases) pages.

Due to unavoidable changes in upstream API it is recommended for your setup
scripts, that for example use PIP to install the cefpython3 package,
to hardcode the cefpython version string. If for example using PIP's
`requirements.txt` file then include the cefpython3 package in the
following format if using e.g. cefpython v57.0: `cefpython3 == 57.0`.


## Differences between Python 2 and Python 3

In Python 2 all cefpython strings are byte strings, but in Python 3
they are all unicode strings. Be aware of this when porting cefpython
based apps to Python 3, as it may cause issues.


## How to enable debug information in examples?

You can pass "--debug" command line flag to any of CEF Python
examples and unit tests. It will also work with your app, as
this feature is enabled in CEF Python's core. When this flag is
passed the following settings will be set:
```python
settings = {
    "debug": True,
    "log_severity": cef.LOGSEVERITY_INFO,
    "log_file": "debug.log",
}
cef.Initialize(settings=settings)
```

Now you should see debug information displayed in console like this:
```
[CEF Python] Initialize() called
[CEF Python] CefExecuteProcess(): exitCode = -1
[CEF Python] CefInitialize()
[CEF Python] App_OnBeforeCommandLineProcessing_BrowserProcess()
[CEF Python] Command line string for the browser process:  ...
```


## Remote debugging with Google Chrome instance

Remote debugging is enabled by default and is configurable using
the ApplicationSettings.[remote_debugging_port](../api/ApplicationSettings.md#remote_debugging_port) option.
When launching app you can see in console log the random port that
was generated:

```
DevTools listening on ws://127.0.0.1:63967/devtools/browser/c52ad9ad-bf40-47d1-b2d1-be392d536a2b
```

You can debug remotely in two ways:

1. Debug with CEF devtools. Open the `http://127.0.0.1:port` url
   (replace port with e.g. 63967 in our case) in a Google Chrome
   browser. You will see a list of CEF browser instances running
   which you can debug with DevTools.
   This way of debugging has the same sets of features as opening DevTools
   popup via `Browser.ShowDevTools` method or using the "Show DevTools"
   option from mouse context menu in a CEF app. CEF DevTools has some
   limits, not all features of Google Chrome DevTools do work. There
   is another way to remotely debug that can workaround these limits,
   see the point 2 below.

2. If some features don't work when debugging with CEF devtools you can
   use dedicated DevTools for Node in Google Chrome browser. For example
   as of CEF v70 the devtools feature "Save as HAR file" doesn't work,
   however it works with dedicated DevTools for Node. Follow these steps
   to use dedicated DevTools for Node with CEF:

   1. In Google Chrome browser open `chrome://inspect` url and click
      "Open dedicated DevTools for Node"
   2. Add `localhost:1234` connection and close the popup window
   3. Set `ApplicationSettings.remote_debugging_port` to `1234` and
      run your app
   4. Refresh the `chrome://inspect` page in Google Chrome browser
   5. You should see a new target on the Remote Target list. Click
      "inspect" link for this target.


## Debugging using various chrome:// protocol uris

The `chrome://` protocol uris give you access to various debugging
tools. For example if you encounter GPU issues then after the issue
occured load the `chrome://gpu` to see a list of errors.

Here is a list of supported `chrome://` protocol uris as of v55.2:
- chrome://accessibility
- chrome://appcache-internals
- chrome://blob-internals
- chrome://credits
- chrome://gpu
- chrome://histograms
- chrome://indexeddb-internals
- chrome://license
- chrome://media-internals
- chrome://net-export
- chrome://net-internals
- chrome://network-error
- chrome://network-errors
- chrome://resources
- chrome://serviceworker-internals
- chrome://system
- chrome://tracing
- chrome://version
- chrome://view-http-cache
- chrome://webrtc-internals
- chrome://webui-hosts
  

## A blank window on Mac/Linux

A blank window might appear when your Python does not support
GUI applications and this seems to be the case when you're using
a custom Python installation. On system Python everything should
work just fine.

- On Mac it is required for Python to be build as a framework. See here:
  https://github.com/pyenv/pyenv/wiki#how-to-build-cpython-with-framework-support-on-os-x
- On Linux it is required for Python to be build as a shared library. See here:
  https://github.com/pyenv/pyenv/wiki#how-to-build-cpython-with---enable-shared

For a more detailed explanation see this comment by Robin Dunn from the
wxPython project:
https://github.com/wxWidgets/Phoenix/issues/288#issuecomment-294896145


## Location of CEF framework in Mac apps

This information here is for when creating apps for distribution
on Mac.

By default CEF expects that CEF framework is located at
`Contents/Frameworks/Chromium Embedded Framework.framework`
in the top-level app bundle. If that is not the case then you have
to set ApplicationSettings.[framework_dir_path](../api/ApplicationSettings.md#framework_dir_path)
before calling cef.Initialize().

You may also need to change the structure and embedded paths in
CEF framework and in the cefpython module. Here are the default
settings:
```
cefpython_package/
    cefpython_py27.so
        rpath=@loader_path/
        load:@rpath/Chromium Embedded Framework.framework/Chromium Embedded Framework
    Chromium Embedded Framework.framework/
        Chromium Embedded Framework
            id:@rpath/Chromium Embedded Framework.framework/Chromium Embedded Framework
```

When creating Mac app for distribution you may want to change
directory structure, so you might have to change these settings
embedded in these libraries. You can do so with these commands:

```
install_name_tool -rpath old new
install_name_tool -change old new
install_name_tool -id name
```

To check whether it succeeded run these commands:
```
otool -l file
otool -L file
```


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

1. Go to [Spotify Automated Builds](http://opensource.spotify.com/cefbuilds/index.html)
   to download latest CEF for your platform. Choose "Sample
   Application" binaries.
2. Extract the archive and run sample application from the
   Release/ directory.


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


## Python crashes with "Segmentation fault" - how to debug?

Install gdb:
- On Linux type: `sudo apt-get install gdb`
- On Mac type: `brew install gdb` and then [sign gdb](https://sourceware.org/gdb/wiki/BuildingOnDarwin#Giving_gdb_permission_to_control_other_processes)
- Additionally on Mac to get a meaningful stack trace with gdb do these steps:
    - Install [macports](https://www.macports.org/install.php)
      and restart terminal
    - Type `sudo port install gdb-apple`
    - Type `sudo codesign -s "gdb-cert" /opt/local/bin/gdb-apple`
    - Type `/opt/local/bin/gdb-apple python`

Run python script using gdb:
```
gdb python
run tkinter_.py
```

On segmentation fault to display stack trace type:
```
bt
```

On Mac to use lldb:
```
lldb python
run tkinter_.py
bt
```


## Windows XP support

CEF Python v31.2 was the last version to support Windows XP. This is
due to Chromium/CEF dropping XP support, last CEF version that
supported XP was v49.

On XP you should disable GPU acceleration by using the --disable-gpu
and --disable-gpu-compositing switches. These switches must be passed
programmatically to cef.Initialize(), see [api/Command Line Switches](../api/CommandLineSwitches.md).


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

Reference: [Question on browser security](http://magpcss.org/ceforum/viewtopic.php?f=10&t=10222)
on the CEF Forum.

