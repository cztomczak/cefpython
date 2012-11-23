#pragma once

#include <windows.h>
#include "AuthCredentials.h"

#define HTTP_AUTHENTICATION_USERNAME 1001
#define HTTP_AUTHENTICATION_PASSWORD 1002
#define HTTP_AUTHENTICATION_OK 1003
#define HTTP_AUTHENTICATION_CANCEL 1004

AuthCredentialsData* AuthDialog(HWND parent);
INT_PTR CALLBACK AuthDialogProc(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam);

