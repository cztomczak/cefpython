// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "cefpython_app.h"

#if defined(OS_WIN)

#include <windows.h>
int APIENTRY wWinMain(HINSTANCE hInstance,
                      HINSTANCE hPrevInstance,
                      LPTSTR    lpCmdLine,
                      int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	// lpCmdLine does not include program name argument, must
	// use GetCommandLineW(). Cannot use CefCommandLine::GetGlobalCommandLine,
	// as CEF was not yet initialized.
	CefRefPtr<CefCommandLine> command_line = \
	        CefCommandLine::CreateCommandLine();
    command_line->InitFromString(GetCommandLineW());

	CefMainArgs mainArgs(hInstance);

#else // defined(OS_WIN)

#include <string.h>

#if defined(OS_MAC)
// CEF 130+: MachPortRendezvousClientMac builds the service name as
//   CFBundleIdentifier + ".MachPortRendezvousServer." + parent_pid
// The browser process injects CFBundleIdentifier = "org.cefpython" in
// MacInitialize() before CefInitialize().  This subprocess binary is a flat
// binary (not an app bundle), so CFBundleGetMainBundle() returns no
// CFBundleIdentifier, producing a lookup name starting with "." that never
// matches the registered service.  Call SubprocessMacInit() to inject the
// same identifier so bootstrap_look_up finds the server.
extern "C" void SubprocessMacInit();
#endif

int main(int argc, char **argv)
{
#if defined(OS_MAC)
	SubprocessMacInit();
#endif
#if defined(OS_LINUX)
	// Chrome 130+ passes --pseudonymization-salt-handle to directly-launched
	// (non-zygote) subprocesses, expecting GlobalDescriptors[key] to be
	// pre-populated before InitializePseudonymizationSalt() runs.
	// CEF 146 does not perform this initialization for the non-zygote path.
	// Strip the switch here so Chrome falls back to a per-process random salt.
	// This switch is added by the browser process after OnBeforeChildProcessLaunch
	// fires, so it cannot be stripped via that callback alone.
	{
		static const char kSaltSwitch[] = "--pseudonymization-salt-handle";
		static const int kSaltSwitchLen = sizeof(kSaltSwitch) - 1;
		int new_argc = 0;
		for (int i = 0; i < argc; i++) {
			if (strncmp(argv[i], kSaltSwitch, kSaltSwitchLen) != 0)
				argv[new_argc++] = argv[i];
		}
		argc = new_argc;
	}
#endif

	CefMainArgs mainArgs(argc, argv);

#endif // Mac, Linux

	CefRefPtr<CefPythonApp> app(new CefPythonApp);
	int exitCode = CefExecuteProcess(mainArgs, app.get(), NULL);
	return exitCode;
}
