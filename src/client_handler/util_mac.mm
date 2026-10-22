// Copyright (c) 2013 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

// Copyright (c) 2015 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// Some code was copied from here:
// java-cef: src/master/native/util_mac.mm
// upstream cef: src/tests/ceftests/run_all_unittests_mac.mm
// upstream cef: src/tests/cefclient/cefclient_mac.mm
// upstream cef: src/tests/cefsimple/cefsimple_mac.mm

#import "util_mac.h"
#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>
#include "include/cef_app.h"
#include "include/cef_application_mac.h"
#include "include/cef_browser.h"

namespace {

// static NSAutoreleasePool* g_autopool = nil;
BOOL g_handling_send_event = false;

}  // namespace

// Add the necessary CefAppProtocol functionality to NSApplication
// using categories and swizzling (Issue #442, Issue #156).
@interface NSApplication (CEFPythonApplication)<CefAppProtocol>

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
    // OFF: it's causing a crash during shutdown release
    // g_autopool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];

    // CEF 130+ builds the MachPortRendezvousServer bootstrap service name as
    //   BaseBundleID() + ".MachPortRendezvousServer." + pid
    // When the process has no app bundle (e.g. a bare Python script),
    // BaseBundleID() returns "" and the name starts with ".", which
    // bootstrap_register rejects as invalid.  All renderer subprocesses then
    // crash with "Unknown service name" (1102) on bootstrap_look_up.
    // Inject a synthetic CFBundleIdentifier before CefInitialize() so the
    // service name becomes a valid reverse-DNS label ("org.cefpython...").
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    if (mainBundle) {
        CFStringRef bundleID = CFBundleGetIdentifier(mainBundle);
        if (!bundleID || CFStringGetLength(bundleID) == 0) {
            // CFBundleGetInfoDictionary returns the bundle's internal mutable
            // dictionary; casting to CFMutableDictionaryRef is safe here.
            CFMutableDictionaryRef infoDict =
                (CFMutableDictionaryRef)CFBundleGetInfoDictionary(mainBundle);
            if (infoDict) {
                CFDictionarySetValue(infoDict,
                                     CFSTR("CFBundleIdentifier"),
                                     CFSTR("org.cefpython"));
            }
        }
    }
}

void MacShutdown() {
    // OFF: it's causing a crash during shutdown release
    // [g_autopool release];
}

std::string MacGetMainBundlePath() {
    @autoreleasepool {
        NSBundle* mainBundle = [NSBundle mainBundle];
        if (!mainBundle) {
            return std::string();
        }

        NSString* bundlePath = [mainBundle bundlePath];
        if (!bundlePath || ![bundlePath isAbsolutePath] ||
            ![bundlePath hasSuffix:@".app"]) {
            return std::string();
        }

        const char* fileSystemPath = [bundlePath fileSystemRepresentation];
        return fileSystemPath ? std::string(fileSystemPath) : std::string();
    }
}

void MacSetWindowTitle(CefRefPtr<CefBrowser> browser, char* title) {
    NSView* view = CAST_CEF_WINDOW_HANDLE_TO_NSVIEW(browser->GetHost()->GetWindowHandle());
    NSString* nstitle = [NSString stringWithFormat:@"%s" , title];
    view.window.title = nstitle;
}
