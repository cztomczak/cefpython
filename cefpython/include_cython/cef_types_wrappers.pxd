# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from libcpp cimport bool as c_bool
from cef_string cimport cef_string_t

cdef extern from "include/internal/cef_types_wrappers.h":

    cdef cppclass CefStructBase:
        pass

    IF CEF_VERSION == 1:

        ctypedef struct CefSettings:
            c_bool multi_threaded_message_loop
            cef_string_t cache_path
            cef_string_t user_agent
            cef_string_t product_version
            cef_string_t locale
            cef_string_t log_file
            int log_severity
            c_bool release_dcheck_enabled
            int graphics_implementation
            unsigned int local_storage_quota
            unsigned int session_storage_quota
            cef_string_t javascript_flags
            c_bool auto_detect_proxy_settings_enabled
            cef_string_t resources_dir_path
            cef_string_t locales_dir_path
            c_bool pack_loading_disabled
            int uncaught_exception_stack_size

    ELIF CEF_VERSION == 3:

        ctypedef struct CefSettings:
            c_bool multi_threaded_message_loop
            cef_string_t cache_path
            cef_string_t user_agent
            cef_string_t product_version
            cef_string_t locale
            cef_string_t log_file
            int log_severity
            c_bool release_dcheck_enabled
            cef_string_t javascript_flags
            c_bool auto_detect_proxy_settings_enabled
            cef_string_t resources_dir_path
            cef_string_t locales_dir_path
            c_bool pack_loading_disabled
            int uncaught_exception_stack_size
            c_bool single_process
            cef_string_t browser_subprocess_path
            c_bool command_line_args_disabled
            int remote_debugging_port

    IF CEF_VERSION == 1:

        ctypedef struct CefBrowserSettings:
            int animation_frame_rate
            c_bool drag_drop_disabled
            c_bool load_drops_disabled
            c_bool history_disabled
            cef_string_t standard_font_family
            cef_string_t fixed_font_family
            cef_string_t serif_font_family
            cef_string_t sans_serif_font_family
            cef_string_t cursive_font_family
            cef_string_t fantasy_font_family
            int default_font_size
            int default_fixed_font_size
            int minimum_font_size
            int minimum_logical_font_size
            c_bool remote_fonts_disabled
            cef_string_t default_encoding
            c_bool encoding_detector_enabled
            c_bool javascript_disabled
            c_bool javascript_open_windows_disallowed
            c_bool javascript_close_windows_disallowed
            c_bool javascript_access_clipboard_disallowed
            c_bool dom_paste_disabled
            c_bool caret_browsing_enabled
            c_bool java_disabled
            c_bool plugins_disabled
            c_bool universal_access_from_file_urls_allowed
            c_bool file_access_from_file_urls_allowed
            c_bool web_security_disabled
            c_bool xss_auditor_enabled
            c_bool image_load_disabled
            c_bool shrink_standalone_images_to_fit
            c_bool site_specific_quirks_disabled
            c_bool text_area_resize_disabled
            c_bool page_cache_disabled
            c_bool tab_to_links_disabled
            c_bool hyperlink_auditing_disabled
            c_bool user_style_sheet_enabled
            cef_string_t user_style_sheet_location
            c_bool author_and_user_styles_disabled
            c_bool local_storage_disabled
            c_bool databases_disabled
            c_bool application_cache_disabled
            c_bool webgl_disabled
            c_bool accelerated_compositing_enabled
            c_bool accelerated_layers_disabled
            c_bool accelerated_video_disabled
            c_bool accelerated_2d_canvas_disabled
            c_bool accelerated_painting_disabled
            c_bool accelerated_filters_disabled
            c_bool accelerated_plugins_disabled
            c_bool developer_tools_disabled
            c_bool fullscreen_enabled

    ELIF CEF_VERSION == 3:

        ctypedef struct CefBrowserSettings:
            cef_string_t standard_font_family
            cef_string_t fixed_font_family
            cef_string_t serif_font_family
            cef_string_t sans_serif_font_family
            cef_string_t cursive_font_family
            cef_string_t fantasy_font_family
            int default_font_size
            int default_fixed_font_size
            int minimum_font_size
            int minimum_logical_font_size
            c_bool remote_fonts_disabled
            cef_string_t default_encoding
            c_bool encoding_detector_enabled
            c_bool javascript_disabled
            c_bool javascript_open_windows_disallowed
            c_bool javascript_close_windows_disallowed
            c_bool javascript_access_clipboard_disallowed
            c_bool dom_paste_disabled
            c_bool caret_browsing_enabled
            c_bool java_disabled
            c_bool plugins_disabled
            c_bool universal_access_from_file_urls_allowed
            c_bool file_access_from_file_urls_allowed
            c_bool web_security_disabled
            c_bool xss_auditor_enabled
            c_bool image_load_disabled
            c_bool shrink_standalone_images_to_fit
            c_bool site_specific_quirks_disabled
            c_bool text_area_resize_disabled
            c_bool page_cache_disabled
            c_bool tab_to_links_disabled
            c_bool hyperlink_auditing_disabled
            c_bool user_style_sheet_enabled
            cef_string_t user_style_sheet_location
            c_bool author_and_user_styles_disabled
            c_bool local_storage_disabled
            c_bool databases_disabled
            c_bool application_cache_disabled
            c_bool webgl_disabled
            c_bool accelerated_compositing_disabled
            c_bool accelerated_layers_disabled
            c_bool accelerated_video_disabled
            c_bool accelerated_2d_canvas_disabled
            c_bool accelerated_painting_enabled
            c_bool accelerated_filters_enabled
            c_bool accelerated_plugins_disabled
            c_bool developer_tools_disabled
            c_bool fullscreen_enabled