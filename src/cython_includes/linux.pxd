# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "gtk/gtk.h" nogil:
    ctypedef void* GdkNativeWindow
    ctypedef void* GtkWidget
    cdef GtkWidget* gtk_plug_new(GdkNativeWindow socket_id)
    cdef void gtk_widget_show(GtkWidget* widget)
