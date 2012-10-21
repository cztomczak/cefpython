del "cefexample\cefpython.pyd"
del "setup\cefpython.pyd"

for /R %~dp0setup\ %%f in (*.pyx) do del "%%f"

rmdir /S /Q "%dp0setup\build\"

REM copy all src\*.pyx to src\setup\ - commentint out, as it copies recursively from all subdirectories.
REM for /R %~dp0 %%f in (*.pyx) do del "%%f"

cd "setup"

call python "fixincludes.py"
call python "setup.py" build_ext --inplace

for /R %~dp0setup\ %%f in (*.pyx) do del "%%f"

REM %~dp0 doesn't work with rmdir.
rmdir /S /Q "build\"

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

call "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\mt.exe" -nologo -manifest %~dp0\cefpython.pyd.manifest -outputresource:%~dp0\setup\cefpython.pyd;2

move "cefpython.pyd" "../cefexample/cefpython.pyd"

cd ..
cd cefexample

call python "cefsimple.py"

pause