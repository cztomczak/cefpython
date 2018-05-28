# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "gtk/gtk.h" nogil:
    ctypedef void* GdkNativeWindow
    ctypedef void* GtkWidget
    cdef GtkWidget* gtk_plug_new(GdkNativeWindow socket_id)
    cdef void gtk_widget_show(GtkWidget* widget)

    ctypedef char* XPointer
    ctypedef struct XImage:
        int width
        int height
        int xoffset             # number of pixels offset in X direction
        int format              # XYBitmap, XYPixmap, ZPixmap
        char *data              # pointer to image data
        int byte_order          # data byte order, LSBFirst, MSBFirst
        int bitmap_unit         # quant. of scanline 8, 16, 32
        int bitmap_bit_order    # LSBFirst, MSBFirst
        int bitmap_pad          # 8, 16, 32 either XY or ZPixmap
        int depth               # depth of image
        int bytes_per_line      # accelerator to next scanline
        int bits_per_pixel      # bits per pixel (ZPixmap)
        unsigned long red_mask  # bits in z arrangement
        unsigned long green_mask
        unsigned long blue_mask
        XPointer *obdata
        void *funcs
    void XDestroyImage(XImage *ximage)
    unsigned long XGetPixel(XImage* image, int x, int y)

