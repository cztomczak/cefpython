IF UNAME_SYSNAME == "Windows":
    from cef_win cimport *
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport *
ELSE:
    from cef_linux cimport *
