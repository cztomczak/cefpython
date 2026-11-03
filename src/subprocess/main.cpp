// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "cefpython_app.h"
#include "include/base/cef_compiler_specific.h"

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

#if defined(OS_LINUX)
// Fixes "stack smashing detected" crash when a process forked
// from the zygote returns from main(), see CEF Issue 3912:
// https://github.com/chromiumembedded/cef/issues/3912
NO_STACK_PROTECTOR
#endif
int main(int argc, char **argv)
{
	CefMainArgs mainArgs(argc, argv);

#endif // Mac, Linux

	CefRefPtr<CefPythonApp> app(new CefPythonApp);
	int exitCode = CefExecuteProcess(mainArgs, app.get(), NULL);
	return exitCode;
}
