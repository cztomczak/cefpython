if platform.system() == "Windows":
	for_metro = False
	hwnd = browser.GetWindowID()
	# Logic copied from chromium > fullscreen_handler.cc > FullscreenHandler::SetFullscreenImpl:
	# http://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc
	if not browser.GetUserData("is_fullscreen"):
		browser.SetUserData("SavedWindowInfo_maximized", ctypes.windll.user32.IsZoomed(hwnd))
		if browser.GetUserData("SavedWindowInfo_maximized"):
			win32api.SendMessage(hwnd, win32con.WM_SYSCOMMAND, win32con.SC_RESTORE, 0)
		browser.SetUserData("SavedWindowInfo_gwl_style", win32api.GetWindowLong(hwnd, win32con.GWL_STYLE))
		browser.SetUserData("SavedWindowInfo_gwl_exstyle", win32api.GetWindowLong(hwnd, win32con.GWL_EXSTYLE))
		browser.SetUserData("SavedWindowInfo_window_rect", win32gui.GetWindowRect(hwnd)) 

	if not browser.GetUserData("is_fullscreen"):
		gwl_style = browser.GetUserData("SavedWindowInfo_gwl_style")
		gwl_exstyle = browser.GetUserData("SavedWindowInfo_gwl_exstyle")
		remove_style = win32con.WS_CAPTION | win32con.WS_THICKFRAME
		remove_exstyle = win32con.WS_EX_DLGMODALFRAME | win32con.WS_EX_WINDOWEDGE
		remove_exstyle += win32con.WS_EX_CLIENTEDGE | win32con.WS_EX_STATICEDGE
		win32api.SetWindowLong(hwnd, win32con.GWL_STYLE, gwl_style & ~(remove_style))
		win32api.SetWindowLong(hwnd, win32con.GWL_EXSTYLE, gwl_exstyle & ~(remove_exstyle))
		if not for_metro:
			# MONITOR_DEFAULTTONULL, MONITOR_DEFAULTTOPRIMARY, MONITOR_DEFAULTTONEAREST
			monitor = win32api.MonitorFromWindow(hwnd, win32con.MONITOR_DEFAULTTONEAREST)
			monitorInfo = win32api.GetMonitorInfo(monitor) # keys: Device, Work, Monitor
			(left, top, right, bottom) = monitorInfo["Monitor"]
			win32gui.SetWindowPos(hwnd, None, left, top, right-left, bottom-top,
					win32con.SWP_NOZORDER | win32con.SWP_NOACTIVATE | win32con.SWP_FRAMECHANGED)
	else:
		gwl_style = browser.GetUserData("SavedWindowInfo_gwl_style")
		gwl_exstyle = browser.GetUserData("SavedWindowInfo_gwl_exstyle")
		win32api.SetWindowLong(hwnd, win32con.GWL_STYLE, gwl_style)
		win32api.SetWindowLong(hwnd, win32con.GWL_EXSTYLE, gwl_exstyle)
		if not for_metro:
			(left, top, right, bottom) = browser.GetUserData("SavedWindowInfo_window_rect")
			win32gui.SetWindowPos(hwnd, None, left, top, right-left, bottom-top,
					win32con.SWP_NOZORDER | win32con.SWP_NOACTIVATE | win32con.SWP_FRAMECHANGED)
		if browser.GetUserData("SavedWindowInfo_maximized"):
			win32api.SendMessage(hwnd, win32con.WM_SYSCOMMAND, win32con.SC_MAXIMIZE, 0)

	browser.SetUserData("is_fullscreen", not bool(browser.GetUserData("is_fullscreen")))