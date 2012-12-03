#include "client_app.h"

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

	CefRefPtr<ClientApp> app(new ClientApp);
	int exitCode = CefExecuteProcess(mainArgs, app.get());
	return exitCode;
}
