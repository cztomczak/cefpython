# UNAME_SYSNAME and PY_MAJOR_VERSION are Cython built-in compile-time
# constants; no DEF needed. INT_MIN/INT_MAX come from libc.limits.
from libc.limits cimport INT_MIN, INT_MAX
