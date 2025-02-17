// Copyright (c) 2014 Marshall A. Greenblatt. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//    * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//    * Neither the name of Google Inc. nor the name Chromium Embedded
// Framework nor the names of its contributors may be used to endorse
// or promote products derived from this software without specific prior
// written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef CEF_INCLUDE_INTERNAL_CEF_TYPES_MAC_H_
#define CEF_INCLUDE_INTERNAL_CEF_TYPES_MAC_H_
#pragma once

#include "include/base/cef_build.h"

#if defined(OS_MAC)
#include "include/internal/cef_string.h"
#include "include/internal/cef_types_geometry.h"

// Handle types.
// Actually NSCursor*
#define cef_cursor_handle_t void*
// Acutally NSEvent*
#define cef_event_handle_t void*
// Actually NSView*
#define cef_window_handle_t void*

#define kNullCursorHandle NULL
#define kNullEventHandle NULL
#define kNullWindowHandle NULL

#ifdef __OBJC__
#if __has_feature(objc_arc)
#define CAST_CEF_CURSOR_HANDLE_TO_NSCURSOR(handle) ((__bridge NSCursor*)handle)
#define CAST_CEF_EVENT_HANDLE_TO_NSEVENT(handle) ((__bridge NSEvent*)handle)
#define CAST_CEF_WINDOW_HANDLE_TO_NSVIEW(handle) ((__bridge NSView*)handle)

#define CAST_NSCURSOR_TO_CEF_CURSOR_HANDLE(cursor) ((__bridge void*)cursor)
#define CAST_NSEVENT_TO_CEF_EVENT_HANDLE(event) ((__bridge void*)event)
#define CAST_NSVIEW_TO_CEF_WINDOW_HANDLE(view) ((__bridge void*)view)
#else  // __has_feature(objc_arc)
#define CAST_CEF_CURSOR_HANDLE_TO_NSCURSOR(handle) ((NSCursor*)handle)
#define CAST_CEF_EVENT_HANDLE_TO_NSEVENT(handle) ((NSEvent*)handle)
#define CAST_CEF_WINDOW_HANDLE_TO_NSVIEW(handle) ((NSView*)handle)

#define CAST_NSCURSOR_TO_CEF_CURSOR_HANDLE(cursor) ((void*)cursor)
#define CAST_NSEVENT_TO_CEF_EVENT_HANDLE(event) ((void*)event)
#define CAST_NSVIEW_TO_CEF_WINDOW_HANDLE(view) ((void*)view)
#endif  // __has_feature(objc_arc)
#endif  // __OBJC__

#ifdef __cplusplus
extern "C" {
#endif

///
/// Structure representing CefExecuteProcess arguments.
///
typedef struct _cef_main_args_t {
  int argc;
  char** argv;
} cef_main_args_t;

///
/// Class representing window information.
///
typedef struct _cef_window_info_t {
  cef_string_t window_name;

  ///
  /// Initial window bounds.
  ///
  cef_rect_t bounds;

  ///
  /// Set to true (1) to create the view initially hidden.
  ///
  int hidden;

  ///
  /// NSView pointer for the parent view.
  ///
  cef_window_handle_t parent_view;

  ///
  /// Set to true (1) to create the browser using windowless (off-screen)
  /// rendering. No view will be created for the browser and all rendering will
  /// occur via the CefRenderHandler interface. The |parent_view| value will be
  /// used to identify monitor info and to act as the parent view for dialogs,
  /// context menus, etc. If |parent_view| is not provided then the main screen
  /// monitor will be used and some functionality that requires a parent view
  /// may not function correctly. In order to create windowless browsers the
  /// CefSettings.windowless_rendering_enabled value must be set to true.
  /// Transparent painting is enabled by default but can be disabled by setting
  /// CefBrowserSettings.background_color to an opaque value.
  ///
  int windowless_rendering_enabled;

  ///
  /// Set to true (1) to enable shared textures for windowless rendering. Only
  /// valid if windowless_rendering_enabled above is also set to true. Currently
  /// only supported on Windows (D3D11).
  ///
  int shared_texture_enabled;

  ///
  /// Set to true (1) to enable the ability to issue BeginFrame from the client
  /// application.
  ///
  int external_begin_frame_enabled;

  ///
  /// NSView pointer for the new browser view. Only used with windowed
  /// rendering.
  ///
  cef_window_handle_t view;
} cef_window_info_t;

#ifdef __cplusplus
}
#endif

#endif  // OS_MAC

#endif  // CEF_INCLUDE_INTERNAL_CEF_TYPES_MAC_H_
