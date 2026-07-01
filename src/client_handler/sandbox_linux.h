// Copyright (c) 2026 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

// Returns true if Chromium's Linux sandbox can run without --no-sandbox, i.e.
// either a CHROME_DEVEL_SANDBOX SUID-root helper is configured, or the process
// can create an unprivileged user namespace (the capability Chromium's zygote
// needs for its namespace sandbox).
//
// Conservative: returns false on any doubt so the caller falls back to the
// safe --no-sandbox path rather than risking a fatal "No usable sandbox"
// abort at CefInitialize().  See docs/Knowledge-Base.md
// "Linux: the Chromium sandbox".
bool LinuxSandboxAvailable();
