// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#include "windows.h"
#include "stdio.h"

void FlipBufferUpsideDown(void* _dest, void* _src, int width, int height) {
  // In CEF the buffer passed to Browser.GetImage() & RenderHandler.OnPaint()
  // has upper-left origin, but some libraries like Panda3D require
  // bottom-left origin.
  __int32* dest = (__int32*)_dest;
  __int32* src = (__int32*)_src;
  unsigned int tb;
  int length = width*height;
  for (int y = 0; y < height; y++) {
    tb = length - ((y+1)*width);
    memcpy(&dest[tb], &src[y*width], width*4);
  }
}

void SwapBufferFromBgraToRgba(void* _dest, void* _src, int width, int height) {
  __int32* dest = (__int32*)_dest;
  __int32* src = (__int32*)_src;
  __int32 rgba;
  __int32 bgra;
  int length = width*height;
  for (int i = 0; i < length; i++) {
    bgra = src[i];
    rgba = (bgra & 0x00ff0000) >> 16
           | (bgra & 0xff00ff00)
           | (bgra & 0x000000ff) << 16;
    dest[i] = rgba;
  }
}
