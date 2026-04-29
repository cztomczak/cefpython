// Copyright (c) 2025 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#import <CoreFoundation/CoreFoundation.h>

// Called from main.cpp before CefExecuteProcess on macOS.
//
// CEF 130+ builds the MachPortRendezvousClient lookup name as:
//   CFBundleIdentifier + ".MachPortRendezvousServer." + parent_pid
//
// The parent (browser process) has CFBundleIdentifier = "org.cefpython"
// injected in util_mac.mm / MacInitialize().  The subprocess is a flat
// binary without an app bundle, so CFBundleGetMainBundle() returns no
// CFBundleIdentifier and the lookup name starts with ".", which never
// matches the registered service name.  Inject the same identifier here
// so both sides agree and bootstrap_look_up succeeds.
extern "C" void SubprocessMacInit() {
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    if (mainBundle) {
        CFStringRef bundleID = CFBundleGetIdentifier(mainBundle);
        if (!bundleID || CFStringGetLength(bundleID) == 0) {
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
