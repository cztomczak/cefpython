# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
# noinspection PyUnresolvedReferences
from libc.stddef cimport wchar_t
# noinspection PyUnresolvedReferences
from libc.stdint cimport int32_t, uint32_t, int64_t, uint64_t
from cef_string cimport cef_string_t
# noinspection PyUnresolvedReferences
from libc.limits cimport UINT_MAX

cdef extern from "include/internal/cef_types.h":

    IF UNAME_SYSNAME == "Windows":
        # noinspection PyUnresolvedReferences
        ctypedef wchar_t char16_t
    ELSE:
        ctypedef unsigned short char16_t

    ctypedef uint32_t cef_color_t

    ctypedef struct CefSettings:
        cef_string_t browser_subprocess_path
        int command_line_args_disabled
        cef_string_t cache_path
        int enable_net_security_expiration
        int persist_session_cookies
        cef_string_t user_agent
        cef_string_t product_version
        cef_string_t locale
        cef_string_t log_file
        int log_severity
        int multi_threaded_message_loop
        cef_string_t javascript_flags
        cef_string_t resources_dir_path
        cef_string_t locales_dir_path
        int pack_loading_disabled
        int remote_debugging_port
        int uncaught_exception_stack_size
        int context_safety_implementation # Not exposed.
        cef_color_t background_color
        int persist_user_preferences
        int windowless_rendering_enabled
        int no_sandbox
        int external_message_pump
        cef_string_t framework_dir_path

    ctypedef struct CefBrowserSettings:
        cef_color_t background_color
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
        cef_state_t remote_fonts
        cef_state_t javascript
        cef_state_t javascript_close_windows
        cef_state_t javascript_access_clipboard
        cef_state_t javascript_dom_paste
        cef_state_t plugins
        cef_state_t universal_access_from_file_urls
        cef_state_t file_access_from_file_urls
        cef_state_t web_security
        cef_state_t image_loading
        cef_state_t image_shrink_standalone_to_fit
        cef_state_t text_area_resize
        cef_state_t tab_to_links
        cef_state_t local_storage
        cef_state_t databases
        cef_state_t application_cache
        cef_state_t webgl
        int windowless_frame_rate

    cdef cppclass CefRect:
        int x, y, width, height
        CefRect()
        CefRect(int x, int y, int width, int height)

    cdef cppclass CefSize:
        int width, height
        CefSize()
        CefSize(int width, int height)

    cdef cppclass CefPoint:
        int x
        int y

    ctypedef struct CefRequestContextSettings:
        pass

    ctypedef enum cef_log_severity_t:
        LOGSEVERITY_DEFAULT,
        LOGSEVERITY_VERBOSE,
        LOGSEVERITY_DEBUG = LOGSEVERITY_VERBOSE,
        LOGSEVERITY_INFO,
        LOGSEVERITY_WARNING,
        LOGSEVERITY_ERROR,
        LOGSEVERITY_DISABLE = 99,

    ctypedef enum cef_thread_id_t:
        TID_UI,
        TID_FILE_BACKGROUND
        TID_FILE,
        TID_FILE_USER_VISIBLE,
        TID_FILE_USER_BLOCKING,
        TID_IO,
        TID_RENDERER

    ctypedef enum cef_v8_propertyattribute_t:
        V8_PROPERTY_ATTRIBUTE_NONE = 0,       # Writeable, Enumerable,
        #  Configurable
        V8_PROPERTY_ATTRIBUTE_READONLY = 1 << 0,  # Not writeable
        V8_PROPERTY_ATTRIBUTE_DONTENUM = 1 << 1,  # Not enumerable
        V8_PROPERTY_ATTRIBUTE_DONTDELETE = 1 << 2   # Not configurable

    ctypedef enum cef_navigation_type_t:
        NAVIGATION_LINK_CLICKED = 0,
        NAVIGATION_FORM_SUBMITTED,
        NAVIGATION_BACK_FORWARD,
        NAVIGATION_RELOAD,
        NAVIGATION_FORM_RESUBMITTED,
        NAVIGATION_OTHER,

    ctypedef enum cef_process_id_t:
        PID_BROWSER,
        PID_RENDERER,

    ctypedef enum cef_state_t:
        STATE_DEFAULT = 0,
        STATE_ENABLED,
        STATE_DISABLED,

    ctypedef enum cef_postdataelement_type_t:
        PDE_TYPE_EMPTY  = 0,
        PDE_TYPE_BYTES,
        PDE_TYPE_FILE,
        
    # WebRequest
    ctypedef enum cef_urlrequest_flags_t:
        UR_FLAG_NONE = 0,
        UR_FLAG_SKIP_CACHE = 1 << 0,
        UR_FLAG_ONLY_FROM_CACHE = 1 << 1,
        UR_FLAG_ALLOW_STORED_CREDENTIALS = 1 << 2,
        UR_FLAG_REPORT_UPLOAD_PROGRESS = 1 << 3,
        UR_FLAG_NO_DOWNLOAD_DATA = 1 << 4,
        UR_FLAG_NO_RETRY_ON_5XX = 1 << 5,
        UR_FLAG_STOP_ON_REDIRECT = 1 << 6,

    # CefListValue, CefDictionaryValue - types.
    ctypedef enum cef_value_type_t:
        VTYPE_INVALID = 0,
        VTYPE_NULL,
        VTYPE_BOOL,
        VTYPE_INT,
        VTYPE_DOUBLE,
        VTYPE_STRING,
        VTYPE_BINARY,
        VTYPE_DICTIONARY,
        VTYPE_LIST,

    # KeyboardHandler
    ctypedef void* CefEventHandle
    ctypedef enum cef_key_event_type_t:
        KEYEVENT_RAWKEYDOWN = 0,
        KEYEVENT_KEYDOWN,
        KEYEVENT_KEYUP,
        KEYEVENT_CHAR
    ctypedef struct _cef_key_event_t:
        cef_key_event_type_t type
        uint32_t modifiers
        int windows_key_code
        int native_key_code
        int is_system_key
        char16_t character
        char16_t unmodified_character
        cpp_bool focus_on_editable_field
    ctypedef _cef_key_event_t CefKeyEvent
    ctypedef enum cef_event_flags_t:
        EVENTFLAG_NONE                = 0,
        EVENTFLAG_CAPS_LOCK_ON        = 1 << 0,
        EVENTFLAG_SHIFT_DOWN          = 1 << 1,
        EVENTFLAG_CONTROL_DOWN        = 1 << 2,
        EVENTFLAG_ALT_DOWN            = 1 << 3,
        EVENTFLAG_LEFT_MOUSE_BUTTON   = 1 << 4,
        EVENTFLAG_MIDDLE_MOUSE_BUTTON = 1 << 5,
        EVENTFLAG_RIGHT_MOUSE_BUTTON  = 1 << 6,
        # Mac OS-X command key.
        EVENTFLAG_COMMAND_DOWN        = 1 << 7,
        EVENTFLAG_NUM_LOCK_ON         = 1 << 8,
        EVENTFLAG_IS_KEY_PAD          = 1 << 9,
        EVENTFLAG_IS_LEFT             = 1 << 10,
        EVENTFLAG_IS_RIGHT            = 1 << 11,

    # LoadHandler
    ctypedef enum cef_termination_status_t:
        TS_ABNORMAL_TERMINATION,
        TS_PROCESS_WAS_KILLED,
        TS_PROCESS_CRASHED,

    ctypedef enum cef_errorcode_t:
        ERR_NONE = 0,
        ERR_FAILED = -2,
        ERR_ABORTED = -3,
        ERR_INVALID_ARGUMENT = -4,
        ERR_INVALID_HANDLE = -5,
        ERR_FILE_NOT_FOUND = -6,
        ERR_TIMED_OUT = -7,
        ERR_FILE_TOO_BIG = -8,
        ERR_UNEXPECTED = -9,
        ERR_ACCESS_DENIED = -10,
        ERR_NOT_IMPLEMENTED = -11,
        ERR_CONNECTION_CLOSED = -100,
        ERR_CONNECTION_RESET = -101,
        ERR_CONNECTION_REFUSED = -102,
        ERR_CONNECTION_ABORTED = -103,
        ERR_CONNECTION_FAILED = -104,
        ERR_NAME_NOT_RESOLVED = -105,
        ERR_INTERNET_DISCONNECTED = -106,
        ERR_SSL_PROTOCOL_ERROR = -107,
        ERR_ADDRESS_INVALID = -108,
        ERR_ADDRESS_UNREACHABLE = -109,
        ERR_SSL_CLIENT_AUTH_CERT_NEEDED = -110,
        ERR_TUNNEL_CONNECTION_FAILED = -111,
        ERR_NO_SSL_VERSIONS_ENABLED = -112,
        ERR_SSL_VERSION_OR_CIPHER_MISMATCH = -113,
        ERR_SSL_RENEGOTIATION_REQUESTED = -114,
        ERR_CERT_COMMON_NAME_INVALID = -200,
        ERR_CERT_DATE_INVALID = -201,
        ERR_CERT_AUTHORITY_INVALID = -202,
        ERR_CERT_CONTAINS_ERRORS = -203,
        ERR_CERT_NO_REVOCATION_MECHANISM = -204,
        ERR_CERT_UNABLE_TO_CHECK_REVOCATION = -205,
        ERR_CERT_REVOKED = -206,
        ERR_CERT_INVALID = -207,
        ERR_CERT_END = -208,
        ERR_INVALID_URL = -300,
        ERR_DISALLOWED_URL_SCHEME = -301,
        ERR_UNKNOWN_URL_SCHEME = -302,
        ERR_TOO_MANY_REDIRECTS = -310,
        ERR_UNSAFE_REDIRECT = -311,
        ERR_UNSAFE_PORT = -312,
        ERR_INVALID_RESPONSE = -320,
        ERR_INVALID_CHUNKED_ENCODING = -321,
        ERR_METHOD_NOT_SUPPORTED = -322,
        ERR_UNEXPECTED_PROXY_AUTH = -323,
        ERR_EMPTY_RESPONSE = -324,
        ERR_RESPONSE_HEADERS_TOO_BIG = -325,
        ERR_CACHE_MISS = -400,
        ERR_INSECURE_RESPONSE = -501,

    # Browser > GetImage(), RenderHandler > OnPaint().

    ctypedef enum cef_paint_element_type_t:
        PET_VIEW = 0,
        PET_POPUP,
    ctypedef cef_paint_element_type_t PaintElementType

    # Browser > SendMouseClickEvent().
    ctypedef enum cef_mouse_button_type_t:
        MBT_LEFT = 0,
        MBT_MIDDLE,
        MBT_RIGHT,
    ctypedef struct cef_mouse_event_t:
        int x
        int y
        uint32_t modifiers
    ctypedef cef_mouse_event_t CefMouseEvent

    # RenderHandler > GetScreenInfo():
    ctypedef struct cef_rect_t:
        int x
        int y
        int width
        int height
    ctypedef struct cef_screen_info_t:
        float device_scale_factor
        int depth
        int depth_per_component
        cpp_bool is_monochrome
        cef_rect_t rect
        cef_rect_t available_rect
    ctypedef cef_screen_info_t CefScreenInfo

    # CefURLRequest.GetStatus()
    ctypedef enum cef_urlrequest_status_t:
        UR_UNKNOWN = 0
        UR_SUCCESS
        UR_IO_PENDING
        UR_CANCELED
        UR_FAILED

    # CefJSDialogHandler.OnJSDialog()
    ctypedef enum cef_jsdialog_type_t:
        JSDIALOGTYPE_ALERT = 0,
        JSDIALOGTYPE_CONFIRM,
        JSDIALOGTYPE_PROMPT,
    ctypedef cef_jsdialog_type_t JSDIalogType

    # LifespanHandler and RequestHandler

    ctypedef enum cef_window_open_disposition_t:
        CEF_WOD_UNKNOWN,
        CEF_WOD_CURRENT_TAB,
        CEF_WOD_SINGLETON_TAB,
        CEF_WOD_NEW_FOREGROUND_TAB,
        CEF_WOD_NEW_BACKGROUND_TAB,
        CEF_WOD_NEW_POPUP,
        CEF_WOD_NEW_WINDOW,
        CEF_WOD_SAVE_TO_DISK,
        CEF_WOD_OFF_THE_RECORD,
        CEF_WOD_IGNORE_ACTION,
        CEF_WOD_SWITCH_TO_TAB,
        CEF_WOD_NEW_PICTURE_IN_PICTURE
    ctypedef cef_window_open_disposition_t WindowOpenDisposition

    ctypedef enum cef_path_key_t:
        PK_DIR_CURRENT,
        PK_DIR_EXE,
        PK_DIR_MODULE,
        PK_DIR_TEMP,
        PK_FILE_EXE,
        PK_FILE_MODULE,
        PK_LOCAL_APP_DATA,
        PK_USER_DATA,
        PK_DIR_RESOURCES,
    ctypedef cef_path_key_t PathKey

    ctypedef enum cef_referrer_policy_t:
        REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_FROM_SECURE_TO_INSECURE
        REFERRER_POLICY_DEFAULT = REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_FROM_SECURE_TO_INSECURE,
        REFERRER_POLICY_REDUCE_REFERRER_GRANULARITY_ON_TRANSITION_CROSS_ORIGIN,
        REFERRER_POLICY_ORIGIN_ONLY_ON_TRANSITION_CROSS_ORIGIN,
        REFERRER_POLICY_NEVER_CLEAR_REFERRER,
        REFERRER_POLICY_ORIGIN,
        REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_CROSS_ORIGIN,
        REFERRER_POLICY_ORIGIN_CLEAR_ON_TRANSITION_FROM_SECURE_TO_INSECURE,
        REFERRER_POLICY_NO_REFERRER,
        REFERRER_POLICY_LAST_VALUE
    ctypedef cef_referrer_policy_t ReferrerPolicy

    # Drag & drop

    ctypedef enum cef_drag_operations_mask_t:
        DRAG_OPERATION_NONE    = 0
        DRAG_OPERATION_COPY    = 1
        DRAG_OPERATION_LINK    = 2
        DRAG_OPERATION_GENERIC = 4
        DRAG_OPERATION_PRIVATE = 8
        DRAG_OPERATION_MOVE    = 16
        DRAG_OPERATION_DELETE  = 32
        DRAG_OPERATION_EVERY   = UINT_MAX

    ctypedef enum cef_color_type_t:
        CEF_COLOR_TYPE_RGBA_8888,
        CEF_COLOR_TYPE_BGRA_8888,

    ctypedef enum cef_alpha_type_t:
        CEF_ALPHA_TYPE_OPAQUE,
        CEF_ALPHA_TYPE_PREMULTIPLIED,
        CEF_ALPHA_TYPE_POSTMULTIPLIED,

    ctypedef enum cef_focus_source_t:
        FOCUS_SOURCE_NAVIGATION,
        FOCUS_SOURCE_SYSTEM,

    cdef cppclass CefRange:
        int from_val "from"
        int to_val "to"
