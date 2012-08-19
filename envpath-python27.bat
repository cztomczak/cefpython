@echo off

@REM # So that replacement on string can be done.
SETLOCAL EnableDelayedExpansion

@echo Current PATH: %PATH%
@echo.

SET newpath=%PATH:python32=python27%

@echo New PATH:
@echo %newpath%

@REM # http://stackoverflow.com/questions/531998/is-there-a-way-to-set-the-environment-path-programatically-in-c-on-windows
REG ADD "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%newpath%" /f

CALL python %~dp0envpath-changed.py

@REM # %SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;C:\Documents and Settings\Admin\Dane aplikacji\npm;C:\Program Files\nodejs\;D:\bin;D:\bin\python27
@REM # C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\Documents and Settings\Admin\Dane aplikacji\npm;C:\Program Files\nodejs\;D:\bin;D:\bin\python32

@echo.
PAUSE
