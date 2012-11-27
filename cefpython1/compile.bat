for /f %%i in ('python -c "import sys; print(str(sys.version_info[0])+str(sys.version_info[1]));"') do set PYVERSION=%%i

del "windows_example\cefpython_py%PYVERSION%.pyd"
del "setup\cefpython_py%PYVERSION%.pyd"

for /R %~dp0setup\ %%f in (*.pyx) do del "%%f"

rmdir /S /Q "%dp0setup\build\"

REM copy all src\*.pyx to src\setup\ - commenting out, as it copies recursively from all subdirectories.
REM for /R %~dp0 %%f in (*.pyx) do del "%%f"

cd "setup"

call python "fix_includes.py"
call python "setup.py" build_ext --inplace

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

for /R %~dp0setup\ %%f in (*.pyx) do del "%%f"

REM %~dp0 doesn't work with rmdir.
rmdir /S /Q "build\"

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

call "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\mt.exe" -nologo -manifest %~dp0\cefpython.pyd.manifest -outputresource:%~dp0\setup\cefpython_py%PYVERSION%.pyd;2

move "cefpython_py%PYVERSION%.pyd" "../windows_example/cefpython_py%PYVERSION%.pyd"

cd ..
cd windows_example

call python "cefadvanced.py"

pause