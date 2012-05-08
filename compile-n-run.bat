del "cefapi.pyd"
del "setup/cefapi.pyx"
del "setup/cefbindings.pyx"
del "setup/cefapi.pyd"
del "setup/cefapi.cpp"
rmdir /S /Q "setup/build"
copy "cefapi.pyx" "setup/cefapi.pyx"
copy "cefbindings.pyx" "setup/cefbindings.pyx"
cd "setup"
call python "combine.py"
call python "setup.py" build_ext --inplace
@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit
move "cefapi.pyd" "../cefapi.pyd"
cd ..
call python "cefclient.py"
pause