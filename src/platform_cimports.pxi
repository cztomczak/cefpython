IF UNAME_SYSNAME == "Windows":
    from windows cimport *
    from dpi_aware_win cimport *
ELIF UNAME_SYSNAME == "Darwin":
    from mac cimport *
ELSE:
    from linux cimport *
    cimport x11
