// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cefpython_app.h"

/*
// Declared "inline" to get rid of the "already defined" errors when linking.
inline void DebugLog(const char* szString)
{
  // TODO: get the log_file option from CefSettings.
  FILE* pFile = fopen("debug.log", "a");
  fprintf(pFile, "cefpython_app: %s\n", szString);
  fclose(pFile);
}
*/

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
	int exitCode = CefExecuteProcess(mainArgs, app.get());
	return exitCode;
}
