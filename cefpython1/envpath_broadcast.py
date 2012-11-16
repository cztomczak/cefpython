import win32api
import win32con

# http://stackoverflow.com/questions/531998/is-there-a-way-to-set-the-environment-path-programatically-in-c-on-windows
win32api.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, "Environment")
print("WM_SETTINGCHANGE \"Environment\" broadcasted to all windows.")
