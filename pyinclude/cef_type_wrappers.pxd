# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cbool
from cef_string cimport cef_string_t

cdef extern from "include/internal/cef_types_wrappers.h":
	
	ctypedef struct CefSettings:
		cbool multi_threaded_message_loop
		cef_string_t cache_path
		cef_string_t user_agent
		cef_string_t product_version
		cef_string_t locale
		cef_string_t log_file
		int log_severity
		int graphics_implementation
		unsigned int local_storage_quota
		unsigned int session_storage_quota
		cef_string_t javascript_flags
		cef_string_t pack_file_path
		cef_string_t locales_dir_path

	ctypedef struct CefBrowserSettings:
		cbool drag_drop_disabled
		cbool load_drops_disabled
		cbool history_disabled
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
		cbool remote_fonts_disabled
		cef_string_t default_encoding
		cbool encoding_detector_enabled
		cbool javascript_disabled
		cbool javascript_open_windows_disallowed
		cbool javascript_close_windows_disallowed
		cbool javascript_access_clipboard_disallowed
		cbool dom_paste_disabled
		cbool caret_browsing_enabled
		cbool java_disabled
		cbool plugins_disabled
		cbool universal_access_from_file_urls_allowed
		cbool file_access_from_file_urls_allowed
		cbool web_security_disabled
		cbool xss_auditor_enabled
		cbool image_load_disabled
		cbool shrink_standalone_images_to_fit
		cbool site_specific_quirks_disabled
		cbool text_area_resize_disabled
		cbool page_cache_disabled
		cbool tab_to_links_disabled
		cbool hyperlink_auditing_disabled
		cbool user_style_sheet_enabled
		cef_string_t user_style_sheet_location
		cbool author_and_user_styles_disabled
		cbool local_storage_disabled
		cbool databases_disabled
		cbool application_cache_disabled
		cbool webgl_disabled
		cbool accelerated_compositing_enabled
		cbool threaded_compositing_enabled
		cbool accelerated_layers_disabled
		cbool accelerated_video_disabled
		cbool accelerated_2d_canvas_disabled
		cbool accelerated_painting_disabled
		cbool accelerated_filters_disabled
		cbool accelerated_plugins_disabled
		cbool developer_tools_disabled
		cbool fullscreen_enabled