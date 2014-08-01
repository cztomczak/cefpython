# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# More options/flags can be specified for Chromium through
# CefApp::OnBeforeCommandLineProcessing(), see comment 10 by Marshall:
# https://code.google.com/p/chromiumembedded/issues/detail?id=878#c10

IF CEF_VERSION == 3:
    LOGSEVERITY_DEFAULT = cef_types.LOGSEVERITY_DEFAULT
LOGSEVERITY_VERBOSE = cef_types.LOGSEVERITY_VERBOSE
LOGSEVERITY_INFO = cef_types.LOGSEVERITY_INFO
LOGSEVERITY_WARNING = cef_types.LOGSEVERITY_WARNING
LOGSEVERITY_ERROR = cef_types.LOGSEVERITY_ERROR
LOGSEVERITY_ERROR_REPORT = cef_types.LOGSEVERITY_ERROR_REPORT
LOGSEVERITY_DISABLE = cef_types.LOGSEVERITY_DISABLE

IF UNAME_SYSNAME == "Windows":
    IF CEF_VERSION == 1:
        ANGLE_IN_PROCESS = <int>cef_types_win.ANGLE_IN_PROCESS
        ANGLE_IN_PROCESS_COMMAND_BUFFER = <int>cef_types_win.ANGLE_IN_PROCESS_COMMAND_BUFFER
        DESKTOP_IN_PROCESS = <int>cef_types_win.DESKTOP_IN_PROCESS
        DESKTOP_IN_PROCESS_COMMAND_BUFFER = <int>cef_types_win.DESKTOP_IN_PROCESS_COMMAND_BUFFER

cdef void SetApplicationSettings(
        dict appSettings,
        CefSettings* cefAppSettings
        ) except *:
    cdef CefString* cefString

    for key in appSettings:
        # Setting string: CefString(&browserDefaults.default_encoding).FromASCII("UTF-8");
        # cefString = CefString(&cefSettings.user_agent)
        # cefString.FromASCII(<char*>settings[key])

        # ---------------------------------------------------------------------
        # CEF 1
        # ---------------------------------------------------------------------
        IF CEF_VERSION == 1:
            if key == "string_encoding"\
                    or key == "debug":
                # CEF Python only options. These are not to be found in CEF.
                continue
            elif key == "multi_threaded_message_loop":
                cefAppSettings.multi_threaded_message_loop = bool(appSettings[key])
            elif key == "cache_path":
                cefString = new CefString(&cefAppSettings.cache_path)
                PyToCefStringPointer(appSettings[key], cefString)
                del cefString
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
            elif key == "graphics_implementation" and platform.system() == "Windows":
                # Cython compiler error: cef_types_win not defined on linux
                IF UNAME_SYSNAME == "Windows":
                    cefAppSettings.graphics_implementation = <cef_types_win.cef_graphics_implementation_t?><int>int(appSettings[key])
            elif key == "local_storage_quota":
                cefAppSettings.local_storage_quota = <int>int(appSettings[key])
            elif key == "session_storage_quota":
                cefAppSettings.session_storage_quota = <int>int(appSettings[key])
            elif key == "javascript_flags":
                cefString = new CefString(&cefAppSettings.javascript_flags)
                PyToCefStringPointer(appSettings[key], cefString)
                del cefString
            elif key == "auto_detect_proxy_settings_enabled":
                IF UNAME_SYSNAME == "Windows":
                    cefAppSettings.auto_detect_proxy_settings_enabled = bool(appSettings[key])
                ELSE:
                    raise Exception("auto_detect_proxy_settings_enabled is a Windows-only option")
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
            else:
                raise Exception("Invalid appSettings key: %s" % key)

        # ---------------------------------------------------------------------
        # CEF 3
        # ---------------------------------------------------------------------
        ELIF CEF_VERSION == 3:
            if key == "string_encoding"\
                    or key == "debug"\
                    or key == "unique_request_context_per_browser"\
                    or key == "downloads_enabled"\
                    or key == "context_menu":
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
                cefAppSettings.background_color = int(appSettings[key])
            else:
                raise Exception("Invalid appSettings key: %s" % key)

cdef void SetBrowserSettings(
        dict browserSettings,
        CefBrowserSettings* cefBrowserSettings
        ) except *:
    cdef CefString* cefString

    for key in browserSettings:

        IF CEF_VERSION == 1:

            if key == "animation_frame_rate":
                cefBrowserSettings.animation_frame_rate = int(browserSettings[key])
            elif key == "drag_drop_disabled":
                cefBrowserSettings.drag_drop_disabled = bool(browserSettings[key])
            elif key == "load_drops_disabled":
                cefBrowserSettings.load_drops_disabled = bool(browserSettings[key])
            elif key == "history_disabled":
                cefBrowserSettings.history_disabled = bool(browserSettings[key])
            elif key == "standard_font_family":
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
            elif key == "remote_fonts_disabled":
                cefBrowserSettings.remote_fonts_disabled = bool(browserSettings[key])
            elif key == "default_encoding":
                cefString = new CefString(&cefBrowserSettings.default_encoding)
                PyToCefStringPointer(browserSettings[key], cefString)
                del cefString
            elif key == "encoding_detector_enabled":
                cefBrowserSettings.encoding_detector_enabled = bool(browserSettings[key])
            elif key == "javascript_disabled":
                cefBrowserSettings.javascript_disabled = bool(browserSettings[key])
            elif key == "javascript_open_windows_disallowed":
                cefBrowserSettings.javascript_open_windows_disallowed = bool(browserSettings[key])
            elif key == "javascript_close_windows_disallowed":
                cefBrowserSettings.javascript_close_windows_disallowed = bool(browserSettings[key])
            elif key == "javascript_access_clipboard_disallowed":
                cefBrowserSettings.javascript_access_clipboard_disallowed = bool(browserSettings[key])
            elif key == "dom_paste_disabled":
                cefBrowserSettings.dom_paste_disabled = bool(browserSettings[key])
            elif key == "caret_browsing_enabled":
                cefBrowserSettings.caret_browsing_enabled = bool(browserSettings[key])
            elif key == "java_disabled":
                cefBrowserSettings.java_disabled = bool(browserSettings[key])
            elif key == "plugins_disabled":
                cefBrowserSettings.plugins_disabled = bool(browserSettings[key])
            elif key == "universal_access_from_file_urls_allowed":
                cefBrowserSettings.universal_access_from_file_urls_allowed = bool(browserSettings[key])
            elif key == "file_access_from_file_urls_allowed":
                cefBrowserSettings.file_access_from_file_urls_allowed = bool(browserSettings[key])
            elif key == "web_security_disabled":
                cefBrowserSettings.web_security_disabled = bool(browserSettings[key])
            elif key == "xss_auditor_enabled":
                cefBrowserSettings.xss_auditor_enabled = bool(browserSettings[key])
            elif key == "image_load_disabled":
                cefBrowserSettings.image_load_disabled = bool(browserSettings[key])
            elif key == "shrink_standalone_images_to_fit":
                cefBrowserSettings.shrink_standalone_images_to_fit = bool(browserSettings[key])
            elif key == "site_specific_quirks_disabled":
                cefBrowserSettings.site_specific_quirks_disabled = bool(browserSettings[key])
            elif key == "text_area_resize_disabled":
                cefBrowserSettings.text_area_resize_disabled = bool(browserSettings[key])
            elif key == "page_cache_disabled":
                cefBrowserSettings.page_cache_disabled = bool(browserSettings[key])
            elif key == "tab_to_links_disabled":
                cefBrowserSettings.tab_to_links_disabled = bool(browserSettings[key])
            elif key == "hyperlink_auditing_disabled":
                cefBrowserSettings.hyperlink_auditing_disabled = bool(browserSettings[key])
            elif key == "user_style_sheet_enabled":
                cefBrowserSettings.user_style_sheet_enabled = bool(browserSettings[key])
            elif key == "user_style_sheet_location":
                cefString = new CefString(&cefBrowserSettings.user_style_sheet_location)
                PyToCefStringPointer(browserSettings[key], cefString)
                del cefString
            elif key == "author_and_user_styles_disabled":
                cefBrowserSettings.author_and_user_styles_disabled = bool(browserSettings[key])
            elif key == "local_storage_disabled":
                cefBrowserSettings.local_storage_disabled = bool(browserSettings[key])
            elif key == "databases_disabled":
                cefBrowserSettings.databases_disabled = bool(browserSettings[key])
            elif key == "application_cache_disabled":
                cefBrowserSettings.application_cache_disabled = bool(browserSettings[key])
            elif key == "webgl_disabled":
                cefBrowserSettings.webgl_disabled = bool(browserSettings[key])
            elif key == "accelerated_compositing_enabled":
                cefBrowserSettings.accelerated_compositing_enabled = bool(browserSettings[key])
            elif key == "accelerated_layers_disabled":
                cefBrowserSettings.accelerated_layers_disabled = bool(browserSettings[key])
            elif key == "accelerated_video_disabled":
                cefBrowserSettings.accelerated_video_disabled = bool(browserSettings[key])
            elif key == "accelerated_2d_canvas_disabled":
                cefBrowserSettings.accelerated_2d_canvas_disabled = bool(browserSettings[key])
            elif key == "accelerated_filters_disabled":
                cefBrowserSettings.accelerated_filters_disabled = bool(browserSettings[key])
            elif key == "accelerated_plugins_disabled":
                cefBrowserSettings.accelerated_plugins_disabled = bool(browserSettings[key])
            elif key == "developer_tools_disabled":
                cefBrowserSettings.developer_tools_disabled = bool(browserSettings[key])
            elif key == "fullscreen_enabled":
                cefBrowserSettings.fullscreen_enabled = bool(browserSettings[key])
            else:
                raise Exception("Invalid browserSettings key: %s" % key)

        ELIF CEF_VERSION == 3:

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
