setlocal
set PATH=%PATH%;C:\mingw\bin;C:\python27
C:\mingw\bin\gdb.exe --args C:\python27\python.exe %~dp0cefadvanced.py
REM type "run"
REM if error occurs type "backtrace"
REM type "help" for more commands
pause