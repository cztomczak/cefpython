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

inline void CopyPaintBuffer(void* _dest, const void* _src, int width,
                            int height, bool rgba, bool flip) {
  // In CEF the buffer passed to RenderHandler.OnPaint() is BGRA with
  // upper-left origin, but some libraries need RGBA or bottom-left origin
  // (e.g. Panda3D). Convert in a single pass, writing |dest| rows in order.
  if (width <= 0 || height <= 0)
    return;
  const size_t row_size = static_cast<size_t>(width) * 4;
  const uint8_t* src = static_cast<const uint8_t*>(_src);
  uint8_t* dest = static_cast<uint8_t*>(_dest);
  if (!rgba && !flip) {
    memcpy(dest, src, row_size * static_cast<size_t>(height));
    return;
  }
  for (int y = 0; y < height; y++) {
    const uint8_t* src_row =
        src + row_size * static_cast<size_t>(flip ? height - 1 - y : y);
    if (rgba) {
      for (int x = 0; x < width; x++) {
        // BGRA in hex = 0xAARRGGBB. memcpy instead of uint32_t* casts
        // avoids alignment and aliasing assumptions about the buffers.
        uint32_t bgra;
        memcpy(&bgra, src_row + 4 * static_cast<size_t>(x), 4);
        uint32_t rgba_px = (bgra & 0x00ff0000) >> 16 // Red >> Blue.
                           | (bgra & 0xff00ff00) // Green Alpha.
                           | (bgra & 0x000000ff) << 16; // Blue >> Red.
        memcpy(dest + 4 * static_cast<size_t>(x), &rgba_px, 4);
      }
    } else {
      memcpy(dest, src_row, row_size);
    }
    dest += row_size;
  }
}
