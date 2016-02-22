# Plugins #

CEF Python automatically loads plugins installed on your system, it works similarly to Chrome. To disable loading of plugins you have to set BrowserSettings.`plugins_disabled` to True for each browser you create.

Both CEF 1 & CEF 3 support NPAPI plugins. CEF 3 supports also PPAPI plugins, but it is not yet fully tested.

To see a list of plugins that are being loaded run `cefclient.exe`, a test browser that is included in cefpython binary zip, from the menu select Tests > Plugin Info.

## Enable Flash Player ##

To enable Flash player in CEF Python you have to install NPAPI version of Flash in your OS:

  1. Go to http://get.adobe.com/flashplayer/otherversions/
  1. Select your operating system
  1. Select NPAPI version of plugin (for Firefox)

After that run cefclient.exe > Tests > Plugin Info and you should see:

```
Flash is installed!
Name: Shockwave Flash 
Description: Shockwave Flash 11.5 r502 
Version: 11,5,502,110 
Path: C:\Windows\SysWOW64\Macromed\Flash\NPSWF32_11_5_502_110.dll 
```

## Flash on Linux ##

Flash plugin will crash on Linux in CEF 1, see [Issue 553 in CEF Issue Tracker](https://bitbucket.org/chromiumembedded/cef/issues/553/linux-crash-loading-flash-youtube-video).

## Custom plugins ##

With CEF you can load custom plugin by providing a path to it. In CEF 1 you can do this through ApplicationSettings.`extra_plugin_paths` option, but it is not yet implemented in cefpython 1. In CEF 3 there are functions `CefAddWebPluginPath()` & `CefAddWebPluginDirectory()` defined in `cef_web_plugin.h`, but it is also not yet implemented in cefpython 3.

Google Chrome comes with an internal flash player called Pepper Flash Player (a PPAPI plugin), it can be found in `"c:\Program Files (x86)\Google\Chrome\Application\23.0.1271.91\PepperFlash"`, but to be able to distribute it with your app you need a licensing agreement in place with Adobe.

There is an api in CEF for getting info about a plugin, the file is "include/cef\_web\_plugin.h", it is not yet implemented in cefpython.