# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
from cef_string cimport cef_string_t
IF CEF_VERSION == 3:
      from cef_types cimport cef_state_t
      from cef_types cimport cef_color_t

cdef extern from "include/internal/cef_types_wrappers.h":

    cdef cppclass CefStructBase:
        pass

    IF CEF_VERSION == 1:

        ctypedef struct CefSettings:
            cpp_bool multi_threaded_message_loop
            cef_string_t cache_path
            cef_string_t user_agent
            cef_string_t product_version
            cef_string_t locale
            cef_string_t log_file
            int log_severity
            cpp_bool release_dcheck_enabled
            int graphics_implementation
            unsigned int local_storage_quota
            unsigned int session_storage_quota
            cef_string_t javascript_flags
            cpp_bool auto_detect_proxy_settings_enabled
            cef_string_t resources_dir_path
            cef_string_t locales_dir_path
            cpp_bool pack_loading_disabled
            int uncaught_exception_stack_size

    ELIF CEF_VERSION == 3:

        # Sorted the same as in cef_types.h
        ctypedef struct CefSettings:
            cpp_bool single_process
            cef_string_t browser_subprocess_path
            cpp_bool multi_threaded_message_loop
            cpp_bool command_line_args_disabled
            cef_string_t cache_path
            cpp_bool persist_session_cookies
            cef_string_t user_agent
            cef_string_t product_version
            cef_string_t locale
            cef_string_t log_file
            int log_severity
            cpp_bool release_dcheck_enabled
            cef_string_t javascript_flags
            cef_string_t resources_dir_path
            cef_string_t locales_dir_path
            cpp_bool pack_loading_disabled
            int remote_debugging_port
            int uncaught_exception_stack_size
            int context_safety_implementation # Not exposed.
            cpp_bool ignore_certificate_errors
            cef_color_t background_color

    IF CEF_VERSION == 1:

        ctypedef struct CefBrowserSettings:
            int animation_frame_rate
            cpp_bool drag_drop_disabled
            cpp_bool load_drops_disabled
            cpp_bool history_disabled
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
            cpp_bool remote_fonts_disabled
            cef_string_t default_encoding
            cpp_bool encoding_detector_enabled
            cpp_bool javascript_disabled
            cpp_bool javascript_open_windows_disallowed
            cpp_bool javascript_close_windows_disallowed
            cpp_bool javascript_access_clipboard_disallowed
            cpp_bool dom_paste_disabled
            cpp_bool caret_browsing_enabled
            cpp_bool java_disabled
            cpp_bool plugins_disabled
            cpp_bool universal_access_from_file_urls_allowed
            cpp_bool file_access_from_file_urls_allowed
            cpp_bool web_security_disabled
            cpp_bool xss_auditor_enabled
            cpp_bool image_load_disabled
            cpp_bool shrink_standalone_images_to_fit
            cpp_bool site_specific_quirks_disabled
            cpp_bool text_area_resize_disabled
            cpp_bool page_cache_disabled
            cpp_bool tab_to_links_disabled
            cpp_bool hyperlink_auditing_disabled
            cpp_bool user_style_sheet_enabled
            cef_string_t user_style_sheet_location
            cpp_bool author_and_user_styles_disabled
            cpp_bool local_storage_disabled
            cpp_bool databases_disabled
            cpp_bool application_cache_disabled
            cpp_bool webgl_disabled
            cpp_bool accelerated_compositing_enabled
            cpp_bool accelerated_layers_disabled
            cpp_bool accelerated_video_disabled
            cpp_bool accelerated_2d_canvas_disabled
            cpp_bool accelerated_filters_disabled
            cpp_bool accelerated_plugins_disabled
            cpp_bool developer_tools_disabled
            cpp_bool fullscreen_enabled

    ELIF CEF_VERSION == 3:

        # Sorted the same as in cef_types.h
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
            cef_string_t default_encoding
            cef_string_t user_style_sheet_location
            cef_state_t remote_fonts
            cef_state_t javascript
            cef_state_t javascript_open_windows
            cef_state_t javascript_close_windows
            cef_state_t javascript_access_clipboard
            cef_state_t javascript_dom_paste
            cef_state_t caret_browsing
            cef_state_t java
            cef_state_t plugins
            cef_state_t universal_access_from_file_urls
            cef_state_t file_access_from_file_urls
            cef_state_t web_security
            cef_state_t image_loading
            cef_state_t image_shrink_standalone_to_fit
            cef_state_t text_area_resize
            cef_state_t tab_to_links
            cef_state_t author_and_user_styles
            cef_state_t local_storage
            cef_state_t databases
            cef_state_t application_cache
            cef_state_t webgl
            cef_state_t accelerated_compositing

    IF CEF_VERSION == 1:
        cdef cppclass CefRect:
            int x, y, width, height
            CefRect()
            CefRect(int x, int y, int width, int height)

    ELIF CEF_VERSION == 3:
        cdef cppclass CefRect:
            int x, y, width, height
            CefRect()
            CefRect(int x, int y, int width, int height)
