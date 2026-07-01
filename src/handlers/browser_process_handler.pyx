# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"

cdef public void BrowserProcessHandler_OnContextInitialized() noexcept with gil:
    try:
        global g_context_initialized
        Debug("BrowserProcessHandler_OnContextInitialized()")
        g_context_initialized = True
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnRenderProcessThreadCreated(
        CefRefPtr[CefListValue] extra_info
        ) noexcept with gil:
    try:
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnBeforeChildProcessLaunch(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) noexcept with gil:
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
        IF UNAME_SYSNAME == "Linux":
            _StripPseudonymizationSaltHandle(cefCommandLine)  # strips crash-inducing switches
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


IF UNAME_SYSNAME == "Linux":
    # Switches that must be stripped from every child-process command line on
    # Linux to prevent crashes in CEF 146 subprocesses.
    #
    # --pseudonymization-salt-handle (Chrome 130+):
    #   Passed to directly-launched (non-zygote) utility subprocesses,
    #   expecting GlobalDescriptors[key=7] to already be populated.
    #   CEF 146 does not perform this GlobalDescriptors initialization for
    #   the non-zygote path, so the subprocess crashes:
    #     "Failed global descriptor lookup: 7"
    #   Removing the switch causes Chrome to use a per-process random salt.
    #
    # --change-stack-guard-on-fork (Chrome / Linux zygote):
    #   Tells a Zygote-forked child to randomize its stack canary after fork.
    #   ChangeStackGuard() is called from inside the Zygote event-loop stack
    #   frames that the fork() inherited.  Those frames have the pre-fork
    #   canary saved; when they return the canary check fails:
    #     "*** stack smashing detected ***: terminated"
    #   The subprocess exits before Chrome's initialization completes, so
    #   OnContextInitialized never fires.  Removing the switch prevents
    #   ChangeStackGuard() from being called at all; the child keeps the
    #   Zygote's canary (which is still randomized at Zygote startup).
    _STRIP_CHILD_SWITCHES = frozenset([
        "pseudonymization-salt-handle",
        "change-stack-guard-on-fork",
    ])

    cdef void _StripPseudonymizationSaltHandle(
            CefRefPtr[CefCommandLine] cefCommandLine) except * with gil:
        cdef CefString cefSwitchName
        cdef bint needs_strip = False
        for sw in _STRIP_CHILD_SWITCHES:
            cefSwitchName = PyToCefStringValue(sw)
            if cefCommandLine.get().HasSwitch(cefSwitchName):
                needs_strip = True
                break
        if not needs_strip:
            return

        # Capture current state before resetting.
        cdef CefString program
        program = cefCommandLine.get().GetProgram()

        cdef cpp_map[CefString, CefString] switches
        cefCommandLine.get().GetSwitches(switches)

        cdef cpp_vector[CefString] arguments
        cefCommandLine.get().GetArguments(arguments)

        # Rebuild command line omitting the problem switches.
        cefCommandLine.get().Reset()
        cefCommandLine.get().SetProgram(program)

        cdef cpp_map[CefString, CefString].iterator it = switches.begin()
        while it != switches.end():
            if CefToPyString(deref(it).first) not in _STRIP_CHILD_SWITCHES:
                if deref(it).second.empty():
                    cefCommandLine.get().AppendSwitch(deref(it).first)
                else:
                    cefCommandLine.get().AppendSwitchWithValue(
                        deref(it).first, deref(it).second)
            preinc(it)

        cdef size_t i
        for i in range(arguments.size()):
            cefCommandLine.get().AppendArgument(arguments[i])
