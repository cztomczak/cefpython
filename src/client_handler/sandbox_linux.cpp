// Copyright (c) 2026 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// _GNU_SOURCE is required for unshare() and CLONE_NEWUSER from <sched.h>.
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include "sandbox_linux.h"

#include <cstdio>
#include <cstdlib>
#include <sched.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

namespace {

// Read a single integer from a /proc/sys file.  Returns true and sets |out|
// on success; false if the file is missing or cannot be parsed.
bool ReadProcInt(const char* path, long* out) {
    FILE* f = fopen(path, "r");
    if (!f) {
        return false;
    }
    long value = 0;
    int matched = fscanf(f, "%ld", &value);
    fclose(f);
    if (matched != 1) {
        return false;
    }
    *out = value;
    return true;
}

// Can this process create an unprivileged user namespace?  Runs unshare() in a
// short-lived forked child so the new namespace never affects this process.
// This is exactly the capability Chromium's zygote needs for its namespace
// sandbox, so success here reliably predicts that CEF's subprocesses can
// sandbox themselves.  It also catches container seccomp policies (e.g.
// Docker's default) that block the syscall but are not reflected in the
// /proc/sys switches checked above.  The child does no interpreter work and
// exits via _exit(), so this is safe even in a Python process holding the GIL.
bool CanCreateUserNamespace() {
    pid_t pid = fork();
    if (pid < 0) {
        return false;
    }
    if (pid == 0) {
        // Child: attempt the unshare and report the result via exit code only.
        int rc = (unshare(CLONE_NEWUSER) == 0) ? 0 : 1;
        _exit(rc);
    }
    int status = 0;
    if (waitpid(pid, &status, 0) < 0) {
        return false;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

}  // namespace

bool LinuxSandboxAvailable() {
    // 1. A SUID-root chrome-sandbox helper explicitly configured -> usable.
    const char* helper = getenv("CHROME_DEVEL_SANDBOX");
    if (helper && helper[0] != '\0') {
        struct stat st;
        if (stat(helper, &st) == 0) {
            return true;
        }
    }

    // 2. Known kernel switches that make the unprivileged-userns sandbox
    //    unusable.  AppArmor restriction is the common modern-distro default
    //    (Ubuntu 23.10+, Debian 12+).
    long value = 0;
    if (ReadProcInt("/proc/sys/kernel/apparmor_restrict_unprivileged_userns",
                    &value) && value == 1) {
        return false;
    }
    if (ReadProcInt("/proc/sys/kernel/unprivileged_userns_clone", &value)
            && value == 0) {
        return false;
    }
    if (ReadProcInt("/proc/sys/user/max_user_namespaces", &value)
            && value == 0) {
        return false;
    }

    // 3. No known blocker: confirm the capability for real.
    return CanCreateUserNamespace();
}
