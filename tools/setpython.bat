:: Change Python in user env Path. See usage at the bottom.

@echo off
if "%1"=="" goto usage
setlocal EnableDelayedExpansion

for /f "tokens=2*" %%a in ('REG QUERY "HKCU\Environment" /v Path') do set "UserPath=%%~b"
set pyversion=%1

set UserPath=%UserPath:Python27=Python!pyversion!%
set UserPath=%UserPath:Python27-64=Python!pyversion!%
set UserPath=%UserPath:Python34=Python!pyversion!%
set UserPath=%UserPath:Python34-64=Python!pyversion!%
set UserPath=%UserPath:Python35=Python!pyversion!%
set UserPath=%UserPath:Python35-64=Python!pyversion!%

reg add "HKCU\Environment" /v Path /t REG_SZ /d "%UserPath%" /f
python -c "import win32api; import win32con; win32api.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, 'Environment');"
if %errorlevel% neq 0 (
    echo ERROR refreshing Environment: python -c...
    exit /B 1
)
echo OK
echo Restart your console to refresh %%PATH%%

goto :eof
:usage
echo Usage: setpython.bat 27-64 (to set C:\Python27-64)
exit /B 1
