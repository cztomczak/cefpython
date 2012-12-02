#include "AuthDialog.h"
#include "DialogTemplate.h"
#include <stdio.h>

AuthCredentialsData* AuthDialog(HWND parent)
{
	// We want close button, but no sysmenu.
	DialogTemplate dialogTemplate("Http Authentication", WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | DS_CENTER,
		WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE, 10, 10, 257, 80, "Tahoma", 8);
	dialogTemplate.AddStatic("Username:", WS_VISIBLE, 0, 2 + 3, 7, 37, 8, -1);
	dialogTemplate.AddStatic("Password:", WS_VISIBLE, 0, 2 + 3, 24, 37, 8, -1);
	dialogTemplate.AddEditBox("", WS_VISIBLE | WS_TABSTOP, WS_EX_STATICEDGE, 45 + 3, 7, 80, 10, HTTP_AUTHENTICATION_USERNAME);
	dialogTemplate.AddEditBox("", WS_VISIBLE | WS_TABSTOP | ES_PASSWORD, WS_EX_STATICEDGE, 45 + 3, 24, 80, 10, HTTP_AUTHENTICATION_PASSWORD);
	dialogTemplate.AddButton("OK", WS_VISIBLE | WS_TABSTOP, 0, 2 + 3, 41, 48, 13, HTTP_AUTHENTICATION_OK);
	dialogTemplate.AddButton("Cancel", WS_VISIBLE | WS_TABSTOP, 0, 55 + 3, 41, 48, 13, HTTP_AUTHENTICATION_CANCEL);
	
	INT_PTR ret = DialogBoxIndirect(GetModuleHandle(0), dialogTemplate, parent, (DLGPROC)AuthDialogProc);
	if (1 == ret) {
		// OK.
		AuthCredentialsData* credentialsData = AuthCredentials::GetData(parent);
		if (credentialsData == NULL) {
			// Wrong HWND, parent == innerWindowID,
			// but in AuthDialogProc() > GetWindow(hDlg, GW_OWNER) returned topWindowID.
			HWND tryParent = GetParent(parent);
			if (!tryParent) {
				// GetParent() works fine, calling GW_OWNER just in case.
				// Yes, the order is the reversed compared to what is in AuthDialogProc().
				tryParent = GetWindow(parent, GW_OWNER);
			}
			credentialsData = AuthCredentials::GetData(tryParent);
		}
		return credentialsData;
	} else {
		// Cancel.
		return NULL;
	}
}

INT_PTR CALLBACK AuthDialogProc(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
	HWND parent;
	AuthCredentialsData* credentialsData;
	TCHAR text[128];

	switch (msg)
	{
	case WM_INITDIALOG:
		break;

	case WM_COMMAND:
		switch (LOWORD(wParam))
		{
		case HTTP_AUTHENTICATION_OK: // OK button.
		case IDOK: // Enter.
			
			parent = GetWindow(hDlg, GW_OWNER);
			if (!parent) {
				// GW_OWNER works fine, calling GetParent just in case.
				// Yes, the order is reversed compared to what is in AuthDialog().
				parent = GetParent(hDlg);
			}

			credentialsData = AuthCredentials::GetData(parent);
			if (credentialsData == NULL) {
				credentialsData = new AuthCredentialsData();
			}
			
			GetDlgItemText(hDlg, HTTP_AUTHENTICATION_USERNAME, text, 128);
			credentialsData->username.assign(text, 128);

			GetDlgItemText(hDlg, HTTP_AUTHENTICATION_PASSWORD, text, 128);
			credentialsData->password.assign(text, 128);

			AuthCredentials::SetData(parent, credentialsData);

			EndDialog(hDlg, 1);
			return TRUE;
		
		case HTTP_AUTHENTICATION_CANCEL: // Cancel button.
		case IDCANCEL: // Close Button or Escape key.
			EndDialog(hDlg, 2);
			return TRUE;
		}
		break;	
	}
	return FALSE;
}
