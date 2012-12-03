@echo off
setlocal
set PATH=c:\gtk_2.24.10_32bit\bin;c:\python27_32bit;%PATH%
CALL c:\python27_32bit\python.exe %~dp0pygtk_.py
pause