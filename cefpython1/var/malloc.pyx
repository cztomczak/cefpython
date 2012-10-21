from libc.stdlib cimport malloc, free

cdef RECT* rect2 = <RECT*>malloc(sizeof(RECT))
free(rect2)