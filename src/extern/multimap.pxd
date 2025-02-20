# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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
        multimap() except + nogil
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
