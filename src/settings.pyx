# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# More options/flags can be specified for Chromium through
# CefApp::OnBeforeCommandLineProcessing(), see comment 10 by Marshall:
# https://code.google.com/p/chromiumembedded/issues/detail?id=878#c10

include "cefpython.pyx"

cimport cef_types
from libc.stdint cimport uint32_t

LOGSEVERITY_DEFAULT = cef_types.LOGSEVERITY_DEFAULT
LOGSEVERITY_VERBOSE = cef_types.LOGSEVERITY_VERBOSE
# LOGSEVERITY_DEBUG is not exposed, as it is the same
# as LOGSEVERITY_VERBOSE, and because it would be confusing
# as currently passing --debug arg to app causes it to
# set logseverity to LOGSEVERITY_INFO. Verbose logseverity
# contains too much information.
LOGSEVERITY_INFO = cef_types.LOGSEVERITY_INFO
LOGSEVERITY_WARNING = cef_types.LOGSEVERITY_WARNING
LOGSEVERITY_ERROR = cef_types.LOGSEVERITY_ERROR
# keep for BC
LOGSEVERITY_ERROR_REPORT = cef_types.LOGSEVERITY_ERROR
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
                or key == "auto_zooming"\
                or key == "app_user_model_id":
            # CEF Python only options. These are not to be found in CEF.
            continue
        elif key == "cache_path":
            cefString = new CefString(&cefAppSettings.cache_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "persist_session_cookies":
            cefAppSettings.persist_session_cookies = int(appSettings[key])
        elif key == "user_agent":
            cefString = new CefString(&cefAppSettings.user_agent)
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
        elif key == "multi_threaded_message_loop":
            cefAppSettings.multi_threaded_message_loop = int(appSettings[key])
        elif key == "release_dcheck_enabled":
            # Keep for BC, just log info - no error
            Debug("DEPRECATED: 'release_dcheck_enabled' setting")
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
            cefAppSettings.pack_loading_disabled = int(appSettings[key])
        elif key == "uncaught_exception_stack_size":
            cefAppSettings.uncaught_exception_stack_size = <int>int(appSettings[key])
        elif key == "browser_subprocess_path":
            cefString = new CefString(&cefAppSettings.browser_subprocess_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        elif key == "command_line_args_disabled":
            cefAppSettings.command_line_args_disabled = int(appSettings[key])
        elif key == "remote_debugging_port":
            cefAppSettings.remote_debugging_port = int(appSettings[key])
        elif key == "background_color":
            cefAppSettings.background_color = \
                    <uint32_t>int(appSettings[key])
        elif key == "persist_user_preferences":
            cefAppSettings.persist_user_preferences = \
                    int(appSettings[key])
        elif key == "windowless_rendering_enabled":
            cefAppSettings.windowless_rendering_enabled = \
                    int(appSettings[key])
        elif key == "external_message_pump":
            cefAppSettings.external_message_pump = \
                    int(appSettings[key])
        elif key == "framework_dir_path":
            cefString = new CefString(&cefAppSettings.framework_dir_path)
            PyToCefStringPointer(appSettings[key], cefString)
            del cefString
        else:
            raise Exception("Invalid appSettings key: %s" % key)

cdef void SetBrowserSettings(
        dict browserSettings,
        CefBrowserSettings* cefBrowserSettings
        ) except *:
    cdef CefString* cefString

    for key in browserSettings:
        if key == "inherit_client_handlers_for_popups":
            # CEF Python only options. These are not to be found in CEF.
            continue
        elif key == "background_color":
            cefBrowserSettings.background_color = \
                    <uint32_t>int(browserSettings[key])
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
        elif key == "default_encoding":
            cefString = new CefString(&cefBrowserSettings.default_encoding)
            PyToCefStringPointer(browserSettings[key], cefString)
            del cefString
        elif key == "user_style_sheet_location":
            # Keep for BC, just log info - no error
            Debug("DEPRECATED: 'user_style_sheet_location' setting")
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
            Debug("DEPRECATED: 'javascript_open_windows_disallowed' setting")
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
            # Keep the key for BC
            Debug("DEPRECATED: 'caret_browsing_enabled' setting")
        elif key == "java_disabled":
            # Keep the key for BC
            Debug("DEPRECATED: 'java_disabled' setting")
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
            Debug("DEPRECATED: 'author_and_user_styles_disabled' setting")
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
        elif key == "webgl_disabled":
            if browserSettings[key]:
                cefBrowserSettings.webgl = cef_types.STATE_DISABLED
            else:
                cefBrowserSettings.webgl = cef_types.STATE_ENABLED
        elif key == "accelerated_compositing_disabled":
            Debug("DEPRECATED: 'accelerated_compositing_disabled' setting")
        elif key == "windowless_frame_rate":
            cefBrowserSettings.windowless_frame_rate =\
                    <int>int(browserSettings[key])
        else:
            raise Exception("Invalid browserSettings key: %s" % key)
