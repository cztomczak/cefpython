[API categories](API-categories.md) | [API index](API-index.md)


# WebPluginInfo (object)

See also [RequestHandler](RequestHandler.md)._OnBeforePluginLoad().

Web Plugin API available in upstream CEF, but not yet exposed in CEF Python
(see src/include/cef_web_plugin.h):

* CefRegisterCdmCallback
* CefRegisterWidevineCdm
* CefIsWebPluginUnstable
* CefRegisterWebPluginCrash
* CefUnregisterInternalWebPlugin
* CefRefreshWebPlugins
* CefVisitWebPluginInfo


Table of contents:
* [Methods](#methods)
  * [GetName](#getname)
  * [GetPath](#getpath)
  * [GetVersion](#getversion)
  * [GetDescription](#getdescription)

## Methods


### GetName

| | |
| --- | --- |
| __Return__ | string |

Returns the plugin name (i.e. Flash).


### GetPath

| | |
| --- | --- |
| __Return__ | string |

Returns the plugin file path (DLL/bundle/library).


### GetVersion

| | |
| --- | --- |
| __Return__ | string |

Returns the version of the plugin (may be OS-specific).


### GetDescription

| | |
| --- | --- |
| __Return__ | string |

Returns a description of the plugin from the version information.
