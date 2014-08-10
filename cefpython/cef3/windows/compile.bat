@echo on

@if [%1] == [] (
    @echo Version not provided. Example usage: compile.bat 31.0 
    goto EOF
)

for /f %%i in ('python -c "import sys; print(str(sys.version_info[0])+str(sys.version_info[1]));"') do set PYVERSION=%%i

del "%~dp0binaries\cefpython_py%PYVERSION%.pyd"
del "%~dp0setup\cefpython_py%PYVERSION%.pyd"
for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"
rmdir /S /Q "%dp0setup\build\"

@rem Compile .rc file to a .res object.
cd %~dp0setup\
call python compile_rc.py -v %1
@if %errorlevel% neq 0 goto EOF

cd %~dp0setup
call python "fix_includes.py"
@if %errorlevel% neq 0 goto EOF

cd %~dp0setup
call python "setup.py" build_ext --inplace
@rem setup.py disabled echo
@echo on
@if %errorlevel% neq 0 for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"
@if %errorlevel% neq 0 for /R %~dp0setup\ %%f in (*.res) do @del "%%f"
@if %errorlevel% neq 0 goto EOF
for /R %~dp0setup\ %%f in (*.pyx) do @del "%%f"
for /R %~dp0setup\ %%f in (*.res) do @del "%%f"

rmdir /S /Q "%~dp0setup\build\"
@if %errorlevel% neq 0 goto EOF

@rem Embed manifest file into .pyd module.
call "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\mt.exe" -nologo -manifest %~dp0cefpython.pyd.manifest -outputresource:%~dp0setup\cefpython_py%PYVERSION%.pyd;2
@if %errorlevel% neq 0 goto EOF

move "%~dp0setup\cefpython_py%PYVERSION%.pyd" "%~dp0binaries/cefpython_py%PYVERSION%.pyd"
@if %errorlevel% neq 0 goto EOF

copy "%~dp0..\subprocess\Release\subprocess.exe" "%~dp0binaries\subprocess.exe"
@if %errorlevel% neq 0 goto EOF

@echo Compilation succeeded. Running wxpython.py example..

cd %~dp0binaries\
call python "wxpython.py"

:EOF
pause
cd %~dp0
