# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp.utility cimport pair

# Copied from: Cython/Includes/libcpp/map.pxd

cdef extern from "<map>" namespace "std":
    cdef cppclass multimap[T, U]:
        cppclass iterator:
            pair[T, U]& operator*() nogil
            iterator operator++() nogil
            iterator operator--() nogil
            bint operator==(iterator) nogil
            bint operator!=(iterator) nogil
        multimap() nogil except +
        U& operator[](T&) nogil
        iterator begin() nogil
        iterator end() nogil
        pair[iterator, bint] insert(pair[T, U]) nogil # XXX pair[T,U]&
        iterator find(T&) nogil
