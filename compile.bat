del "cefexample/cefpython.pyd"

del "setup/cefpython.pyx"
del "setup/bindings.pyx"
del "setup/cefpython.pyd"
del "setup/cefpython.cpp"

rmdir /S /Q "setup/build"

copy "cefpython.pyx" "setup/cefpython.pyx"
copy "bindings.pyx" "setup/bindings.pyx"

cd "setup"

call python "combine.py"
call python "setup.py" build_ext --inplace

@if %ERRORLEVEL% neq 0 pause
@if %ERRORLEVEL% neq 0 exit

move "cefpython.pyd" "../cefexample/cefpython.pyd"

cd ..
cd cefexample

call python "cefexample.py"

pause