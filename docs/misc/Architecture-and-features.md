# Architecture & Features #

Table of contents: 

## CEF 3 summary ##
  * supports html5 audio/video, good performance of webgl and other accelerated content
  * uses multi process architecture and [Chromium Content API](http://www.chromium.org/developers/content-module/content-api), thus giving performance and features similar to Chrome
  * V8 engine is runing in a separate process so javascript integration can be done only through asynchronous messaging between processes, in CEF 1 you can call javascript and python back synchronously
  * single process is for debugging purposes only, it is unstable, it will likely be fixed in the future as Chromium for mobile devices needs a stable single-process mode

CEF 3 comes with the the latest version of Chrome.


For more information on CEF architecture see this wiki page on the Chromium Embedded project:
http://code.google.com/p/chromiumembedded/wiki/Architecture

## CEF 3 features ported in CEF Python 3 ##

  * [Frame](Frame) object
  * [Browser](Browser) object
  * [ApplicationSettings](ApplicationSettings)
  * [BrowserSettings](BrowserSettings)
  * [DownloadHandler](DownloadHandler)
  * [JavascriptBindings](JavascriptBindings)
  * [JavascriptCallback](JavascriptCallback)
  * Python callbacks
  * [JavascriptContextHandler](JavascriptContextHandler) (partially)
  * JavascriptDialogHandler
  * [RequestHandler](RequestHandler)
  * [Request](Request) object
  * [WebPluginInfo](WebPluginInfo)
  * [Cookie](Cookie)
  * [CookieManager](CookieManager)
  * [CookieVisitor](CookieVisitor)
  * [LoadHandler](LoadHandler)
  * [RenderHandler](RenderHandler)
  * [ResourceHandler](ResourceHandler)
  * [Response](Response) object
  * [WebRequest](WebRequest) and [WebRequestClient](WebRequestClient)
  * [LifespanHandler](LifespanHandler) (partially)

## CEF 3 features not yet ported to CEF Python 3 ##

  * [context menu handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_context_menu_handler.h) & [menu model](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_menu_model.h) - API is not provided, but context menu is configurable, see ApplicationSettings.`context_menu`
  * [dialog handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_dialog_handler.h)
  * [dom manipulation](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_dom.h) - won't be implemented as it was deprecated and has memory leaks. The recommended way is to manipulate DOM through javascript and report to python through javascript bindings.
  * [focus handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_focus_handler.h)
  * [geolocation](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_geolocation.h) & [geolocation handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_geolocation_handler.h)
  * [origin whitelist](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_origin_whitelist.h)
  * [proxy handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_proxy_handler.h)
  * [render process handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_render_process_handler.h)
  * [resource bundle handler](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_resource_bundle_handler.h)
  * [custom scheme](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_scheme.h)
  * [stream reader & writer](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_stream.h) for request response
  * [trace notifications](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_trace.h) & [trace event](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_trace_event.h)
  * [web plugin](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_web_plugin.h) (WebPluginInfo already implemented)
  * [xml reader](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_xml_reader.h)
  * [zip reader](https://bitbucket.org/chromiumembedded/cef/src/master/include/cef_zip_reader.h)

## CEF 1 summary ##
  * single process architecture
  * more feature complete API than in CEF 3 (as of the moment)
  * html5 audio and video support was removed (see [Issue 18](https://code.google.com/p/cefpython/issues/detail?id=18))
  * uses Webkit API
  * reduced memory usage and closer integration with the client application
  * [reduced performance](http://code.google.com/p/chromiumembedded/issues/detail?id=304) with certain types of accelerated content and [crashes](http://code.google.com/p/chromiumembedded/issues/detail?id=242) due to plugins like Flash running in the same process.

CEF 1 is currently in maintenance mode and the latest version available includes Chrome 27.

## Known problems in CEF 1 ##

Flash plugin will crash on Linux, see [Issue 553 in CEF Issue Tracker](http://code.google.com/p/chromiumembedded/issues/detail?id=553). However, Pepper Flash Player might work in CEF 3 on Linux (not yet tested).

## CEF 1 features ported to CEF Python 1 ##

  * [Frame](Frame) object
  * [Browser](Browser) object
  * [application settings](ApplicationSettings)
  * [browser settings](BrowserSettings)
  * [javascript bindings](JavascriptBindings)
  * [javascript callbacks](JavascriptCallback) & python callbacks
  * [display handler](DisplayHandler)
  * [keyboard handler](KeyboardHandler)
  * [lifespan handler](LifespanHandler) (partially)
  * [load handler](LoadHandler)
  * [render handler](RenderHandler)
  * [request handler](RequestHandler) (partially)
  * [Response](Response) object
  * [javascript context handler](JavascriptContextHandler) (partially)
  * [ContentFilter](ContentFilter) for resource response
  * [Request](Request) object
  * [StreamReader](StreamReader) for request response
  * [WebRequest](WebRequest)
  * [Cookie](Cookie) class
  * [CookieManager](CookieManager) class
  * [CookieVisitor](CookieVisitor) callbacks
  * [DownloadHandler](DownloadHandler)
  * [DragHandler](DragHandler)
  * [DragData](DragData)

## CEF 1 features not yet ported to CEF Python 1 ##

  * [dom manipulation](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_dom.h) - won't be implemented as it was deprecated and has memory leaks. The recommended way is to manipulate DOM through javascript and report to python through javascript bindings.
  * [find handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_find_handler.h)
  * [focus handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_focus_handler.h)
  * [geolocation](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_geolocation.h) & [geolocation handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_geolocation_handler.h)
  * [jsdialog handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_jsdialog_handler.h)
  * [menu handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_menu_handler.h)
  * [plugin info](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_nplugin.h)
  * [origin whitelist](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_origin_whitelist.h)
  * [javascript extensions](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_v8.h?r=972#53)
  * [permission handler for extensions](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_permission_handler.h)
  * [print handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_print_handler.h)
  * [proxy handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_proxy_handler.h)
  * [resource bundle handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_resource_bundle_handler.h)
  * [custom scheme](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_scheme.h)
  * [web plugin](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_web_plugin.h)
  * [xml reader](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_xml_reader.h)
  * [zip reader](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_zip_reader.h)
  * [zoom handler](http://code.google.com/p/chromiumembedded/source/browse/trunk/cef1/include/cef_zoom_handler.h)