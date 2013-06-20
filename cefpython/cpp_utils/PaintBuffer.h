// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

// OS_WIN is not defined on Windows when CEF is not included.
// _WIN32 is defined on both 32bit and 64bit.
#if defined(_WIN32)
// FlipBufferUpsideDown and SwapBufferFromBgraToRgba
// are Windows only, as off-screen rendering is not
// supported on Linux. This code wouldn't compile on
// Linux as there is no __int32 type.

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
    // BGRA in hex = 0xAARRGGBB.
    rgba = (bgra & 0x00ff0000) >> 16 // Red >> Blue.
           | (bgra & 0xff00ff00) // Green Alpha.
           | (bgra & 0x000000ff) << 16; // Blue >> Red.
    dest[i] = rgba;
  }
}

#endif
