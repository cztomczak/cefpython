# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"
from libcpp cimport bool as cpp_bool
from libc.stddef cimport wchar_t

cdef extern from "include/internal/cef_types.h":
    cdef enum cef_log_severity_t:
        LOGSEVERITY_VERBOSE = -1,
        LOGSEVERITY_INFO,
        LOGSEVERITY_WARNING,
        LOGSEVERITY_ERROR,
        LOGSEVERITY_ERROR_REPORT,
        LOGSEVERITY_DISABLE = 99,

    cdef enum cef_thread_id_t:
            TID_UI = 0,
            TID_IO = 1,
            TID_FILE = 2,

    ctypedef long long int64
    ctypedef unsigned int uint32
    ctypedef int int32

    IF UNAME_SYSNAME == "Windows":
        ctypedef wchar_t char16
    ELSE:
        ctypedef unsigned short char16

    # LoadHandler > OnLoadError - ErrorCode.
    # Some of the constants are missing, for an up to date list see:
    # http://src.chromium.org/viewvc/chrome/trunk/src/net/base/net_error_list.h?view=markup
    cdef enum cef_handler_errorcode_t:
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

    # KeyboardHandler > OnKeyEvent - KeyEventType.
    cdef enum cef_handler_keyevent_type_t:
        KEYEVENT_RAWKEYDOWN = 0,
        KEYEVENT_KEYDOWN,
        KEYEVENT_KEYUP,
        KEYEVENT_CHAR
    cdef enum cef_handler_keyevent_modifiers_t:
        KEY_SHIFT = 1 << 0,
        KEY_CTRL = 1 << 1,
        KEY_ALT = 1 << 2,
        KEY_META  = 1 << 3,
        KEY_KEYPAD = 1 << 4,  # Only used on Mac OS-X

    # V8 api
    cdef enum cef_v8_propertyattribute_t:
        V8_PROPERTY_ATTRIBUTE_NONE = 0,       # Writeable, Enumerable,
        #  Configurable
        V8_PROPERTY_ATTRIBUTE_READONLY = 1 << 0,  # Not writeable
        V8_PROPERTY_ATTRIBUTE_DONTENUM = 1 << 1,  # Not enumerable
        V8_PROPERTY_ATTRIBUTE_DONTDELETE = 1 << 2   # Not configurable

    # CefRequestHandler > OnBeforeBrowse > NavType
    cdef enum cef_handler_navtype_t:
        NAVTYPE_LINKCLICKED = 0,
        NAVTYPE_FORMSUBMITTED,
        NAVTYPE_BACKFORWARD,
        NAVTYPE_RELOAD,
        NAVTYPE_FORMRESUBMITTED,
        NAVTYPE_OTHER,
        NAVTYPE_LINKDROPPED

    # CefDisplayHandler > StatusType
    cdef enum cef_handler_statustype_t:
        STATUSTYPE_TEXT = 0,
        STATUSTYPE_MOUSEOVER_URL,
        STATUSTYPE_KEYBOARD_FOCUS_URL,

    # Browser > GetImage(), RenderHandler > OnPaint().
    ctypedef enum cef_paint_element_type_t:
        PET_VIEW = 0,
        PET_POPUP,

    # Browser > SendKeyEvent().
    ctypedef enum cef_key_type_t:
        KT_KEYUP = 0,
        KT_KEYDOWN,
        KT_CHAR,

    # Browser > SendMouseClickEvent().
    ctypedef enum cef_mouse_button_type_t:
        MBT_LEFT = 0,
        MBT_MIDDLE,
        MBT_RIGHT,

    # CefRequest
    enum cef_postdataelement_type_t:
        PDE_TYPE_EMPTY  = 0,
        PDE_TYPE_BYTES,
        PDE_TYPE_FILE,

    enum cef_weburlrequest_flags_t:
        WUR_FLAG_NONE = 0,
        WUR_FLAG_SKIP_CACHE = 0x1,
        WUR_FLAG_ALLOW_CACHED_CREDENTIALS = 0x2,
        WUR_FLAG_ALLOW_COOKIES = 0x4,
        WUR_FLAG_REPORT_UPLOAD_PROGRESS = 0x8,
        WUR_FLAG_REPORT_LOAD_TIMING = 0x10,
        WUR_FLAG_REPORT_RAW_HEADERS = 0x20

    enum cef_weburlrequest_state_t:
        WUR_STATE_UNSENT = 0,
        WUR_STATE_STARTED = 1,
        WUR_STATE_HEADERS_RECEIVED = 2,
        WUR_STATE_LOADING = 3,
        WUR_STATE_DONE = 4,
        WUR_STATE_ERROR = 5,
        WUR_STATE_ABORT = 6,
