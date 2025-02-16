[API categories](API-categories.md) | [API index](API-index.md)


# Browser settings


Table of contents:
* [Introduction](#introduction)
* [Settings](#settings)
  * [Font settings](#font-settings)
  * [application_cache_disabled](#application_cache_disabled)
  * [background_color](#background_color)
  * [databases_disabled](#databases_disabled)
  * [default_encoding](#default_encoding)
  * [dom_paste_disabled](#dom_paste_disabled)
  * [inherit_client_handlers_for_popups](#inherit_client_handlers_for_popups)
  * [image_load_disabled](#image_load_disabled)
  * [javascript_disabled](#javascript_disabled)
  * [javascript_close_windows_disallowed](#javascript_close_windows_disallowed)
  * [javascript_access_clipboard_disallowed](#javascript_access_clipboard_disallowed)
  * [local_storage_disabled](#local_storage_disabled)
  * [remote_fonts](#remote_fonts)
  * [shrink_standalone_images_to_fit](#shrink_standalone_images_to_fit)
  * [tab_to_links_disabled](#tab_to_links_disabled)
  * [text_area_resize_disabled](#text_area_resize_disabled)
  * [universal_access_from_file_urls_allowed](#universal_access_from_file_urls_allowed)
  * [user_style_sheet_location](#user_style_sheet_location)
  * [webgl_disabled](#webgl_disabled)
  * [windowless_frame_rate](#windowless_frame_rate)


## Introduction

This dictionary of settings can be passed to
[cefpython](cefpython.md).CreateBrowser().

Many of these settings have their command line switch equivalent, see the [CommandLineSwitches](CommandLineSwitches.md) page.

In some cases, the default values of settings that are suggested by its name may not always be correct. This is because in one of CEF releases naming of these settings changed, and they started to accept states (enabled or disabled), instead of the state being included in its name (some_option_disabled). CEF Python tries to be backwards compatible, that's why the old naming convention is still used. Read description of setting and if you see that it mentions command line switch that starts with "disable-", it means that its default state is "enabled". If the command line switch starts with "enable-" then its default state is "disabled".


## Settings


### Font settings

* standard_font_family (string)
* fixed_font_family (string)
* serif_font_family (string)
* sans_serif_font_family (string)
* cursive_font_family (string)
* fantasy_font_family (string)
* default_font_size (int)
* default_fixed_font_size (int)
* minimum_font_size (int)
* minimum_logical_font_size (int)


### application_cache_disabled

(bool) Controls whether the application cache can be used. Also configurable using the --disable-application-cache switch.


### background_color

(int)
Description from upstream CEF:
> Background color used for the browser before a document is loaded and when
> no document color is specified. The alpha component must be either fully
> opaque (0xFF) or fully transparent (0x00). If the alpha component is fully
> opaque then the RGB components will be used as the background color. If the
> alpha component is fully transparent for a windowed browser then the
> CefSettings.background_color value will be used. If the alpha component is
> fully transparent for a windowless (off-screen) browser then transparent
> painting will be enabled.

32-bit ARGB color value, not premultiplied. The color components are always
in a known order. Equivalent to the `SkColor` type in Chromium.


### databases_disabled

(bool) Controls whether databases can be used. Also configurable using the --disable-databases switch.


### default_encoding

(string) Default encoding for Web content. If empty "ISO-8859-1" will be used. Also configurable using the --default-encoding switch.


### dom_paste_disabled

(bool) Controls whether DOM pasting is supported in the editor via `execCommand("paste")`. The |javascript_access_clipboard_disallowed| setting must also be set (to true or false). Also configurable using the --disable-javascript-dom-paste switch.


### inherit_client_handlers_for_popups


(bool) Default: True.

Whether to inherit client handlers and callbacks for popup windows
opened with "window.open". For example when you set a handler using
`browser.SetClientHandler` then this handler will also be resued
for popup windows that are created implicitilly via "window.open"
call in javascript or similar. If you implement
`LifespanHandler.OnBeforePopup` then you can control explicitilly
what handlers are set for the popup browser. To disable the default
behavior set this option to False.


### image_load_disabled

(bool) Controls whether image URLs will be loaded from the network. A cached image will still be rendered if requested. Also configurable using the --disable-image-loading switch.


### javascript_disabled

(bool) Controls whether Javascript can be executed. Also configurable using the --disable-javascript switch.


### javascript_close_windows_disallowed

(bool) Controls whether JavaScript can be used to close windows that were not
opened via JavaScript. JavaScript can still be used to close windows that
were opened via JavaScript or that have no back/forward history. Also
configurable using the "disable-javascript-close-windows" command-line
switch.


### javascript_access_clipboard_disallowed

(bool) Controls whether Javascript can access the clipboard. Also configurable using the --disable-javascript-access-clipboard switch.


### local_storage_disabled

(bool) Controls whether local storage can be used. Also configurable using the --disable-local-storage switch.


### remote_fonts

(bool) Controls the loading of fonts from remote sources. Also configurable using the --disable-remote-fonts switch.


### shrink_standalone_images_to_fit

(bool) Controls whether standalone images will be shrunk to fit the page. Also configurable using the --image-shrink-standalone-to-fit switch.


### tab_to_links_disabled

(bool) Controls whether the tab key can advance focus to links. Also configurable using the --disable-tab-to-links switch.


### text_area_resize_disabled

(bool) Controls whether text areas can be resized. Also configurable using the --disable-text-area-resize switch.


### user_style_sheet_location

(string) Location of the user style sheet that will be used for all pages. This must be a data URL of the form `data:text/css;charset=utf-8;base64,content` where "content" is the base64 encoded contents of the CSS file. Also configurable using the "user-style-sheet-location" command-line switch.

This setting was removed in Chrome 33. Soon it will be removed from cefpython as well.


### webgl_disabled

(bool) Controls whether WebGL can be used. Note that WebGL requires hardware support and may not work on all systems even when enabled. Also configurable using the --disable-webgl switch.


### windowless_frame_rate

(int) The maximum rate in frames per second (fps) that
CefRenderHandler::OnPaint will be called for a windowless browser.
The actual fps may be lower if the browser cannot generate frames at the
requested rate. The minimum value is 1 and the maximum value is 60
(default 30). This value can also be changed dynamically via
CefBrowserHost::SetWindowlessFrameRate.
