// Copyright (c) 2013 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#import "util_mac.h"
#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>
#include "include/cef_app.h"
#include "include/cef_application_mac.h"
#include "include/cef_browser.h"

namespace {

BOOL g_handling_send_event = false;

}  // namespace

// Add the necessary CrAppControlProtocol
// functionality to NSApplication using categories and swizzling.
@interface NSApplication (CEFPythonApplication)

- (BOOL)isHandlingSendEvent;
- (void)setHandlingSendEvent:(BOOL)handlingSendEvent;
- (void)_swizzled_sendEvent:(NSEvent*)event;
- (void)_swizzled_terminate:(id)sender;

@end

@implementation NSApplication (CEFPythonApplication)

// This selector is called very early during the application initialization.
+ (void)load {
  // Swap NSApplication::sendEvent with _swizzled_sendEvent.
  Method original = class_getInstanceMethod(self, @selector(sendEvent));
  Method swizzled =
      class_getInstanceMethod(self, @selector(_swizzled_sendEvent));
  method_exchangeImplementations(original, swizzled);

  Method originalTerm = class_getInstanceMethod(self, @selector(terminate:));
  Method swizzledTerm =
      class_getInstanceMethod(self, @selector(_swizzled_terminate:));
  method_exchangeImplementations(originalTerm, swizzledTerm);
}

- (BOOL)isHandlingSendEvent {
  return g_handling_send_event;
}

- (void)setHandlingSendEvent:(BOOL)handlingSendEvent {
  g_handling_send_event = handlingSendEvent;
}

- (void)_swizzled_sendEvent:(NSEvent*)event {
  CefScopedSendingEvent sendingEventScoper;
  // Calls NSApplication::sendEvent due to the swizzling.
  [self _swizzled_sendEvent:event];
}

- (void)_swizzled_terminate:(id)sender {
  [self _swizzled_terminate:sender];
}

@end

void MacInitialize() {
    [NSApplication sharedApplication];
}

void MacSetWindowTitle(CefRefPtr<CefBrowser> browser, char* title) {
    NSView* view = browser->GetHost()->GetWindowHandle();
    NSString* nstitle = [NSString stringWithFormat:@"%s" , title];
    view.window.title = nstitle;
}
