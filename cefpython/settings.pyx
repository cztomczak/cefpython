# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# More options/flags can be specified for Chromium through
# CefApp::OnBeforeCommandLineProcessing(), see comment 10 by Marshall:
# https://code.google.com/p/chromiumembedded/issues/detail?id=878#c10

LOGSEVERITY_DEFAULT = cef_types.LOGSEVERITY_DEFAULT
LOGSEVERITY_VERBOSE = cef_types.LOGSEVERITY_VERBOSE
LOGSEVERITY_INFO = cef_types.LOGSEVERITY_INFO
LOGSEVERITY_WARNING = cef_types.LOGSEVERITY_WARNING
LOGSEVERITY_ERROR = cef_types.LOGSEVERITY_ERROR
LOGSEVERITY_ERROR_REPORT = cef_types.LOGSEVERITY_ERROR_REPORT
LOGSEVERITY_DISABLE = cef_types.LOGSEVERITY_DISABLE


cdef void SetApplicationSettings(
        dict appSettings,
        CefSettings* cefAppSettings
        ) except *:
    cdef CefString* cefString

    for key in appSettings:
        # Setting string: CefString(&browserDefaults.default_encoding).FromASCII("UTF-8");
        # cefString = CefString(&cefSettings.user_agent)
        # cefString.FromASCII(<char*>settings[key])

        if key == "string_encoding"\
                or key == "debug"\
                or key == "unique_request_context_per_browser"\
                or key == "downloads_enabled"\
                or key == "context_menu" \
                or key == "auto_zooming":
            # CEF Python only options. These are not to be found in CEF.
            continue
        elif key == "multi_threaded_message_loop":
            cefAppSettings.multi_threaded_message_loop = bool(appSettings[key])
        elif key == "cache_path":
            cefString = new CefString(&cefAppSettings.cache_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "persist_session_cookies":
            cefAppSettings.persist_session_cookies = bool(appSettings[key])
        elif key == "user_agent":
            cefString = new CefString(&cefAppSettings.user_agent)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "product_version":
            cefString = new CefString(&cefAppSettings.product_version)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "log_file":
            cefString = new CefString(&cefAppSettings.log_file)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "locale":
            cefString = new CefString(&cefAppSettings.locale)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "log_severity":
            cefAppSettings.log_severity = <cef_types.cef_log_severity_t><int>int(appSettings[key])
        elif key == "release_dcheck_enabled":
            cefAppSettings.release_dcheck_enabled = bool(appSettings[key])
        elif key == "javascript_flags":
            cefString = new CefString(&cefAppSettings.javascript_flags)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "resources_dir_path":
            cefString = new CefString(&cefAppSettings.resources_dir_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "locales_dir_path":
            cefString = new CefString(&cefAppSettings.locales_dir_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "pack_loading_disabled":
            cefAppSettings.pack_loading_disabled = bool(appSettings[key])
        elif key == "uncaught_exception_stack_size":
            cefAppSettings.uncaught_exception_stack_size = <int>int(appSettings[key])
        elif key == "single_process":
            cefAppSettings.single_process = bool(appSettings[key])
        elif key == "browser_subprocess_path":
            cefString = new CefString(&cefAppSettings.browser_subprocess_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "command_line_args_disabled":
            cefAppSettings.command_line_args_disabled = bool(appSettings[key])
        elif key == "remote_debugging_port":
            cefAppSettings.remote_debugging_port = int(appSettings[key])
        elif key == "ignore_certificate_errors":
            cefAppSettings.ignore_certificate_errors = bool(appSettings[key])
        elif key == "background_color":
            cefAppSettings.background_color = \
                    <cef_types.uint32>int(appSettings[key])
        else:
            raise Exception("Invalid appSettings key: %s" % key)

cdef void SetBrowserSettings(
        dict browserSettings,
        CefBrowserSettings* cefBrowserSettings
        ) except *:
    cdef CefString* cefString

    for key in browserSettings:
        if key == "standard_font_family":
            cefString = new CefString(&cefBrowserSettings.standard_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "fixed_font_family":
            cefString = new CefString(&cefBrowserSettings.fixed_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "serif_font_family":
            cefString = new CefString(&cefBrowserSettings.serif_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "sans_serif_font_family":
            cefString = new CefString(&cefBrowserSettings.sans_serif_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "cursive_font_family":
            cefString = new CefString(&cefBrowserSettings.cursive_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "fantasy_font_family":
            cefString = new CefString(&cefBrowserSettings.fantasy_font_family)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "default_font_size":
            cefBrowserSettings.default_font_size = <int>int(browserSettings[key])
        elif key == "default_fixed_font_size":
            cefBrowserSettings.default_fixed_font_size = <int>int(browserSettings[key])
        elif key == "minimum_font_size":
            cefBrowserSettings.minimum_font_size = <int>int(browserSettings[key])
        elif key == "minimum_logical_font_size":
            cefBrowserSettings.minimum_logical_font_size = <int>int(browserSettings[key])
        elif key == "default_encoding":
            cefString = new CefString(&cefBrowserSettings.default_encoding)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "user_style_sheet_location":
            cefString = new CefString(&cefBrowserSettings.user_style_sheet_location)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "remote_fonts_disabled":
            if browserSettings[key]:
                cefBrowserSettings.remote_fonts = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.remote_fonts = cef_types.STATE_ENABLED
        elif key == "javascript_disabled":
            if browserSettings[key]:
                cefBrowserSettings.javascript = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.javascript = cef_types.STATE_ENABLED
        elif key == "javascript_open_windows_disallowed":
            if browserSettings[key]:
                cefBrowserSettings.javascript_open_windows = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.javascript_open_windows = (
                        cef_types.STATE_ENABLED)
        elif key == "javascript_close_windows_disallowed":
            if browserSettings[key]:
                cefBrowserSettings.javascript_close_windows = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.javascript_close_windows = (
                        cef_types.STATE_ENABLED)
        elif key == "javascript_access_clipboard_disallowed":
            if browserSettings[key]:
                cefBrowserSettings.javascript_access_clipboard = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.javascript_access_clipboard = (
                        cef_types.STATE_ENABLED)
        elif key == "dom_paste_disabled":
            if browserSettings[key]:
                cefBrowserSettings.javascript_dom_paste = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.javascript_dom_paste = (
                        cef_types.STATE_ENABLED)
        elif key == "caret_browsing_enabled":
            if browserSettings[key]:
                cefBrowserSettings.caret_browsing = (
                        cef_types.STATE_ENABLED)
            else:
                cefBrowserSettings.caret_browsing = (
                        cef_types.STATE_DISABLED)
        elif key == "java_disabled":
            if browserSettings[key]:
                cefBrowserSettings.java = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.java = cef_types.STATE_ENABLED
        elif key == "plugins_disabled":
            if browserSettings[key]:
                cefBrowserSettings.plugins = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.plugins = cef_types.STATE_ENABLED
        elif key == "universal_access_from_file_urls_allowed":
            if browserSettings[key]:
                cefBrowserSettings.universal_access_from_file_urls = (
                        cef_types.STATE_ENABLED)
            else:
                cefBrowserSettings.universal_access_from_file_urls = (
                        cef_types.STATE_DISABLED)
        elif key == "file_access_from_file_urls_allowed":
            if browserSettings[key]:
                cefBrowserSettings.file_access_from_file_urls = (
                        cef_types.STATE_ENABLED)
            else:
                cefBrowserSettings.file_access_from_file_urls = (
                        cef_types.STATE_DISABLED)
        elif key == "web_security_disabled":
            if browserSettings[key]:
                cefBrowserSettings.web_security = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.web_security = cef_types.STATE_ENABLED
        elif key == "image_load_disabled":
            if browserSettings[key]:
                cefBrowserSettings.image_loading = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.image_loading = cef_types.STATE_ENABLED
        elif key == "shrink_standalone_images_to_fit":
            if browserSettings[key]:
                cefBrowserSettings.image_shrink_standalone_to_fit = (
                        cef_types.STATE_ENABLED)
            else:
                cefBrowserSettings.image_shrink_standalone_to_fit = (
                        cef_types.STATE_DISABLED)
        elif key == "text_area_resize_disabled":
            if browserSettings[key]:
                cefBrowserSettings.text_area_resize = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.text_area_resize = (
                        cef_types.STATE_ENABLED)
        elif key == "tab_to_links_disabled":
            if browserSettings[key]:
                cefBrowserSettings.tab_to_links = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.tab_to_links = cef_types.STATE_ENABLED
        elif key == "author_and_user_styles_disabled":
            if browserSettings[key]:
                cefBrowserSettings.author_and_user_styles = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.author_and_user_styles = (
                        cef_types.STATE_ENABLED)
        elif key == "local_storage_disabled":
            if browserSettings[key]:
                cefBrowserSettings.local_storage = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.local_storage = cef_types.STATE_ENABLED
        elif key == "databases_disabled":
            if browserSettings[key]:
                cefBrowserSettings.databases = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.databases = cef_types.STATE_ENABLED
        elif key == "application_cache_disabled":
            if browserSettings[key]:
                cefBrowserSettings.application_cache = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.application_cache = (
                        cef_types.STATE_ENABLED)
        elif key == "webgl_disabled":
            if browserSettings[key]:
                cefBrowserSettings.webgl = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.webgl = cef_types.STATE_ENABLED
        elif key == "accelerated_compositing_disabled":
            if browserSettings[key]:
                cefBrowserSettings.accelerated_compositing = (
                        cef_types.STATE_DISABLED)
            else:
                cefBrowserSettings.accelerated_compositing = (
                        cef_types.STATE_ENABLED)
        else:
            raise Exception("Invalid browserSettings key: %s" % key)
