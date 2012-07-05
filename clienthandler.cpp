#include "clienthandler.h"
#include "setup/cefpython_api.h"
#include <stdio.h>
#include "util.h"
#include "Python.h"

// CefLoadHandler methods
void ClientHandler::OnLoadEnd(CefRefPtr<CefBrowser> browser,
					CefRefPtr<CefFrame> frame,
					int httpStatusCode) 
{
	REQUIRE_UI_THREAD();
	printf("clienthandler.h: OnLoadEnd()\n");
	this->OnLoadEnd_Callback(browser, frame, httpStatusCode);
	//LoadHandler_OnLoadEnd(browser, frame, httpStatusCode);
}
