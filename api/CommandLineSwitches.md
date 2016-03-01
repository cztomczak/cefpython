[API categories](API-categories.md) | [API index](API-index.md)


# Command line switches


Table of contents:
* [Preface](#preface)
* [Example switches](#example-switches)
  * [enable-media-stream](#enable-media-stream)
  * [proxy-server](#proxy-server)
  * [no-proxy-server](#no-proxy-server)
  * [disable-gpu](#disable-gpu)
* [Chromium switches by category](#chromium-switches-by-category)


## Preface

There are many settings that can be customized through Chromium command line switches. These switches can only be set programmatically by passing a dictionary of switches as a second argument to [cefpython](cefpython.md).Initialize(applicationSettings, commandLineSwitches). The `commandLineSwitches param` is a dictionary with switch name as a key. The switch name should not contain the "-" or "--" prefix, otherwise it will be ignored. Switch value may be an empty string, if the switch doesn't require a value. These switches are set for the main process and all subprocesses. See the description of the [cefpython](cefpython.md).Initialize() function to see how to preview the final command line strings formed by CEF.

There are two types of switches, Chromium switches and CEF switches:
  * An assembled list of all Chromium switches can be found on this webite: [peter.sh/experiments/chromium-command-line-switches](http://peter.sh/experiments/chromium-command-line-switches/)
  * A list of all CEF switches can be found in [cef_switches.cc](https://bitbucket.org/chromiumembedded/cef/src/master/libcef/common/cef_switches.cc)

Some of the switches in Chromium are experimental, and may crash application if used inappropriately.

When debbugging is On, the whole command line string will be displayed in console, with both CEF switches set internally, and the ones appended by cefpython. On Linux you will also see in console the command line string for subprocesses. On Windows, command line strings for subprocesses won't be seen in console, you can view them by opening the debug.log file. Example command line strings from debug logs, for the main process and the renderer process:

```text
# Main process
python --browser-subprocess-path="C:\cefpython\cefpython\cef3\windows\binaries
/subprocess" --lang=en-US --log-file="C:\cefpython\cefpython\cef3\windows
\binaries\debug.log" --log-severity=info --enable-release-dcheck
--no-sandbox wxpython.py

# Renderer process
"C:\cefpython\cefpython\cef3\windows\binaries/subprocess" --type=renderer
--no-sandbox --lang=en-US --lang=en-US --log-file="C:\cefpython\cefpython\
cef3\windows\binaries\debug.log" --log-severity=info --enable-release-dcheck
--channel="4152.0.209609692\1183564454" /prefetch:673131151
```


## Example switches


### enable-media-stream

To enable media (WebRTC audio/video) streaming set the "enable-media-stream" CEF switch. This will enable the `getUserMedia` function in javascript.


### proxy-server

To set custom proxy set the "proxy-server" Chromium switch to "socks5://127.0.0.1:8888" for example. See also [Proxy Resolution](https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage.md#markdown-header-proxy-resolution) page.


### no-proxy-server

By default Chromium uses the IE proxy settings (set in Internet Explorer options), to disable that set the "no-proxy-server" Chromium switch. See also [Proxy Resolution](https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage.md#markdown-header-proxy-resolution) page.


### disable-gpu

Disable GPU rendering and switch to CPU software rendering. This flag can fix the [black/white browser screen](../Knowledge-base.md#blackwhite-browser-screen) issue.


## Chromium switches by category

The peter.sh website should list all Chromium switches that are assembled from many Chromium files. Though, some switches may be missing there. Here is a list (in some way categorized) of all Chromium source files that define switches (list assembled on January 16, 2014):

  * [apps/switches.cc](https://src.chromium.org/svn/trunk/src/apps/switches.cc)
  * [ash/ash_switches.cc](https://src.chromium.org/svn/trunk/src/ash/ash_switches.cc)
  * [base/base_switches.cc](https://src.chromium.org/svn/trunk/src/base/base_switches.cc)
  * [cc/base/switches.cc](https://src.chromium.org/svn/trunk/src/cc/base/switches.cc)
  * [chrome/common/chrome_switches.cc](https://src.chromium.org/svn/trunk/src/chrome/common/chrome_switches.cc)
  * [components/autofill/core/common/autofill_switches.cc](https://src.chromium.org/svn/trunk/src/components/autofill/core/common/autofill_switches.cc)
  * [components/nacl/common/nacl_switches.cc](https://src.chromium.org/svn/trunk/src/components/nacl/common/nacl_switches.cc)
  * [content/public/common/content_switches.cc](https://src.chromium.org/svn/trunk/src/content/public/common/content_switches.cc)
  * [google_apis/gaia/gaia_switches.cc](https://src.chromium.org/svn/trunk/src/google_apis/gaia/gaia_switches.cc)
  * [gpu/command_buffer/service/gpu_switches.cc](https://src.chromium.org/svn/trunk/src/gpu/command_buffer/service/gpu_switches.cc)
  * [ipc/ipc_switches.cc](https://src.chromium.org/svn/trunk/src/ipc/ipc_switches.cc)
  * [media/base/media_switches.cc](https://src.chromium.org/svn/trunk/src/media/base/media_switches.cc)
  * [ppapi/shared_impl/ppapi_switches.cc](https://src.chromium.org/svn/trunk/src/ppapi/shared_impl/ppapi_switches.cc)
  * [ui/base/ui_base_switches.cc](https://src.chromium.org/svn/trunk/src/ui/base/ui_base_switches.cc)
  * [ui/base/ui_base_switches_util.cc](https://src.chromium.org/svn/trunk/src/ui/base/ui_base_switches_util.cc)
  * [ui/compositor/compositor_switches.cc](https://src.chromium.org/svn/trunk/src/ui/compositor/compositor_switches.cc)
  * [ui/gfx/switches.cc](https://src.chromium.org/svn/trunk/src/ui/gfx/switches.cc)
  * [ui/gl/gl_switches.cc](https://src.chromium.org/svn/trunk/src/ui/gl/gl_switches.cc)
  * [ui/keyboard/keyboard_switches.cc](https://src.chromium.org/svn/trunk/src/ui/keyboard/keyboard_switches.cc)
