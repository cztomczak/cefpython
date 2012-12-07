setlocal
set PATH=%PATH%;C:\mingw\bin;C:\python27_32bit\PCbuild
C:\mingw\bin\gdb.exe --args C:\python27_32bit\PCbuild\python.exe %~dp0cefadvanced.py
REM type "run"
REM if error occurs type "backtrace"
REM type "help" for more commands
pause