// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

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
	CefMainArgs mainArgs(hInstance);

#else // Mac, Linux

int main(int argc, char **argv)
{
	CefMainArgs mainArgs(argc, argv);

#endif

	CefRefPtr<CefPythonApp> app(new CefPythonApp);
	int exitCode = CefExecuteProcess(mainArgs, app.get(), NULL);
	return exitCode;
}
