// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

// OS_WIN is not defined on Windows when CEF is not included.
// _WIN32 is defined on both 32bit and 64bit.
#if defined(_WIN32)
#include "windows.h"
#include <stdio.h>
#else
#include <string.h>
#endif

#include <stdint.h>

void FlipBufferUpsideDown(void* _dest, const void* _src, int width, int height \
        ) {
  // In CEF the buffer passed to Browser.GetImage() & RenderHandler.OnPaint()
  // has upper-left origin, but some libraries like Panda3D require
  // bottom-left origin.
  int32_t* dest = (int32_t*)_dest;
  int32_t* src = (int32_t*)_src;
  unsigned int tb;
  int length = width*height;
  for (int y = 0; y < height; y++) {
    tb = length - ((y+1)*width);
    memcpy(&dest[tb], &src[y*width], width*4);
  }
}

void SwapBufferFromBgraToRgba(void* _dest, const void* _src, int width, \
        int height) {
  int32_t* dest = (int32_t*)_dest;
  int32_t* src = (int32_t*)_src;
  int32_t rgba;
  int32_t bgra;
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
