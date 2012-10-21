#pragma once

#include <windows.h>
#include "AuthCredentials.h"

#define HTTPAUTH_USERNAME 1001
#define HTTPAUTH_PASSWORD 1002
#define HTTPAUTH_OK 1003
#define HTTPAUTH_CANCEL 1004

AuthCredentialsData* AuthDialog(HWND parent);
INT_PTR CALLBACK AuthDialogProc(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam);

