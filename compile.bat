del "cefexample\cefpython.pyd"
del "setup\cefpython.pyx"
del "setup\cefpython.pyd"
del "setup\cefpython.cpp"
rmdir /S /Q "setup/build"


copy "cefpython.pyx" "setup/cefpython.pyx"
copy "bindings.pyx" "setup/bindings.pyx"

REM for /R %~dp0\pyinclude\ %%f in (*.pxd) do copy %%f %~dp0\setup\

cd "setup"

REM call python "combine.py"
call python "setup.py" build_ext --inplace

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

call "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\mt.exe" -nologo -manifest %~dp0\cefpython.pyd.manifest -outputresource:%~dp0\setup\cefpython.pyd;2

move "cefpython.pyd" "../cefexample/cefpython.pyd"

cd ..
cd cefexample

call python "cefadvanced.py"

pause