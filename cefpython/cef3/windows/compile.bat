for /f %%i in ('python -c "import sys; print(str(sys.version_info[0])+str(sys.version_info[1]));"') do set PYVERSION=%%i

del "binaries\cefpython_py%PYVERSION%.pyd"
del "setup\cefpython_py%PYVERSION%.pyd"

for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"

rmdir /S /Q "%dp0setup\build\"

cd "setup"

call python "fix_includes.py"

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

call python "setup.py" build_ext --inplace

REM -- the setup above has disabled ECHO for commands, turning it back on.
ECHO ON

@if %ERRORLEVEL% neq 0 for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"
@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"

rmdir /S /Q "build\"
@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

call "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\mt.exe" -nologo -manifest %~dp0\cefpython.pyd.manifest -outputresource:%~dp0\setup\cefpython_py%PYVERSION%.pyd;2

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

move "cefpython_py%PYVERSION%.pyd" "../binaries/cefpython_py%PYVERSION%.pyd"
@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

cd ..

copy "%~dp0..\subprocess\Release\subprocess.exe" "%~dp0binaries\subprocess.exe"
@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

cd binaries

call python "example.py"

pause