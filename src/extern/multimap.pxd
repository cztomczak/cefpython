# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp.utility cimport pair

# Copied from: Cython/Includes/libcpp/map.pxd

cdef extern from "<map>" namespace "std":
    cdef cppclass multimap[T, U]:
        cppclass iterator:
            # noinspection PyUnresolvedReferences
            pair[T, U]& operator*() nogil
            iterator operator++() nogil
            iterator operator--() nogil
            bint operator==(iterator) nogil
            bint operator!=(iterator) nogil
        multimap() nogil except +
        # noinspection PyUnresolvedReferences
        U& operator[](T&) nogil
        # noinspection PyUnresolvedReferences
        iterator begin() nogil
        # noinspection PyUnresolvedReferences
        iterator end() nogil
        # noinspection PyUnresolvedReferences
        pair[iterator, bint] insert(pair[T, U]) nogil # XXX pair[T,U]&
        # noinspection PyUnresolvedReferences
        iterator find(T&) nogil
