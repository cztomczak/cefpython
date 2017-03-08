# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "gtk/gtk.h" nogil:
    ctypedef void* GdkNativeWindow
    ctypedef void* GtkWidget
    cdef GtkWidget* gtk_plug_new(GdkNativeWindow socket_id)
    cdef void gtk_widget_show(GtkWidget* widget)
