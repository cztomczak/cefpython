@echo off

:: It's best to always call with a flag that specifies python
:: version and architecture (eg. --py27-32bit). This will ensure
:: that PATH contains only minimum set of directories and will
:: allow to detect possible issues early.

:: Arguments
if [%1] == [] (
    echo [compile.bat] Version number not provided. Usage: compile.bat 31.0
    echo [compile.bat] Opt: --rebuild --py27-32bit --py27-64bit --py34-32bit
    echo                    --py34-64bit
    exit /B 1
)

:: --rebuild flag to rebuild all vcproj builds
set rebuild_flag=0
echo.%*|findstr /C:"--rebuild" >nul 2>&1
if %errorlevel% equ 0 (
   set rebuild_flag=1
)

:: Add only Python/ to PATH.
:: --py27-32bit flag
echo.%*|findstr /C:"--py27-32bit" >nul 2>&1
if %errorlevel% equ 0 (
   set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python27
)
:: --py27-64bit flag
echo.%*|findstr /C:"--py27-64bit" >nul 2>&1
if %errorlevel% equ 0 (
    set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python27_x64;C:\Python27_amd64;C:\Python27_64
)
:: --py34-32bit flag
echo.%*|findstr /C:"--py34-32bit" >nul 2>&1
if %errorlevel% equ 0 (
   set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python34
)
:: --py34-64bit flag
echo.%*|findstr /C:"--py34-64bit" >nul 2>&1
if %errorlevel% equ 0 (
    set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python34_x64;C:\Python34_amd64;C:\Python34_64
)
:: PATH
echo [compile.bat] PATH: %PATH%

:: Version number
set version=%1
echo [compile.bat] Version argument: %version%

:: Python architecture. %bits%=="32bit" or "64bit"
FOR /F "delims=" %%i IN ('python -c "import struct, sys; sys.stdout.write(str(8 * struct.calcsize('P')) + 'bit');"') do set bits=%%i
echo [compile.bat] Python architecture: %bits%

:: Cython version
FOR /F "delims=" %%i IN ('python -c "import sys, Cython; sys.stdout.write(Cython.__version__);"') do set cython_version=%%i
echo [compile.bat] Cython version: %cython_version%

:: Python version
for /F %%i in ('python -c "import sys; sys.stdout.write(str(sys.version_info[0])+str(sys.version_info[1]));"') do set pyver=%%i
echo [compile.bat] Python version: py%pyver%

:: Binaries directory
set binaries=%~dp0binaries_%bits%
echo [compile.bat] Binaries directory: %binaries%

:: Setup directory
set setup=%~dp0setup
echo [compile.bat] Setup directory: %setup%

:: Delete .pyd files
echo [compile.bat] Cleaning cython build files from previous run
del "%binaries%\cefpython_py%pyver%.pyd"
del "%setup%\cefpython_py%pyver%.pyd"
for /R %setup% %%f in (*.pyx) do del "%%f"
rmdir /S /Q "%setup%\build\"

:: Fix cefpython.h
echo [compile.bat] Fixing cefpython.h
cd %setup%
python fix_cefpython_h.py
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: failed to fix cefpython.h
    cd ../
    exit /B 1
)
cd ../

:: Compile VS projects: client_handler, libcefpythonapp, subprocess, cpp_utils

:: client_handler paths
set client_handler_dir=%~dp0..\client_handler
set client_handler_vcproj=%client_handler_dir%\client_handler_py%pyver%_%bits%.vcproj

set subprocess_dir=%~dp0..\subprocess

:: libcefpythonapp paths
set libcefpythonapp_vcproj=%subprocess_dir%\libcefpythonapp_py%pyver%_%bits%.vcproj

:: subprocess paths
set subprocess_vcproj=%subprocess_dir%\subprocess_%bits%.vcproj

:: cpp_utils paths
set cpp_utils_dir=%~dp0..\..\cpp_utils
set cpp_utils_vcproj=%cpp_utils_dir%\cpp_utils_%bits%.vcproj

set success=0
if "%pyver%"=="27" (
    if "%bits%"=="32bit" (
        set "vcbuild=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages\vcbuild.exe"
        set success=1
    )
    if "%bits%"=="64bit" (
        REM :: The same vcbuild.exe 32-bit for building x64
        set "vcbuild=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages\vcbuild.exe"
        set success=1
    )
    set "vcoptions=/nocolor /nologo /nohtmllog"
    if %rebuild_flag% equ 1 (
        set "vcoptions=%vcoptions% /rebuild"
    )
)
if "%pyver%"=="34" (
    :: In VS2010 vcbuild was replaced by msbuild.exe.
    :: /clp:disableconsolecolor
    :: msbuild /p:BuildProjectReferences=false project.proj
    :: MSBuild.exe MyProject.proj /t:build
)

if %success% neq 1 (
    echo [compile.bat] ERROR: failed determining tool to build vcproj files
    exit /B 1
)

echo [compile.bat] Building client_handler vcproj
"%vcbuild%" %vcoptions% %client_handler_vcproj%
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: building client_handler vcproj failed
    exit /B 1
)

echo [compile.bat] Building libcefpythonapp vcproj
"%vcbuild%" %vcoptions% %libcefpythonapp_vcproj%
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: building libcefpythonapp vcproj failed
    exit /B 1
)

echo [compile.bat] Building subprocess vcproj
"%vcbuild%" %vcoptions% %subprocess_vcproj%
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: building subprocess vcproj failed
    exit /B 1
)

echo [compile.bat] Building cpp_utils vcproj
"%vcbuild%" %vcoptions% %cpp_utils_vcproj%
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: building cpp_utils vcproj failed
    exit /B 1
)

:: Do not clean VS build files, as this would slow down the process
:: of recompiling.

:: Compile .rc file to a .res object.
echo [compile.bat] Compiling cefpython.rc file to a .res object
cd %setup%\
python compile_rc.py -v %version%
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: compiling .rc file failed
    exit /B 1
)

echo [compile.bat] Entering setup/ directory
cd %setup%

echo [compile.bat] Copying .pyx files to setup/ directory and fixing includes
python fix_includes.py
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: running fix_includes.py failed
    exit /B 1
)

echo [compile.bat] Running the cython setup.py script
python setup.py build_ext --inplace
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: the cython setup.py script failed
    :: Clean files from the build that failed
    for /R %setup% %%f in (*.pyx) do del "%%f"
    for /R %setup% %%f in (*.res) do del "%%f"
    rmdir /S /Q "%setup%\build\"
    cd ../
    exit /B 1
)

echo [compile.bat] Fixing cefpython.h
python fix_cefpython_h.py
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: failed to fix cefpython.h
    exit /B 1
)

echo [compile.bat] Cleaning files from the build
for /R %setup% %%f in (*.pyx) do del "%%f"
for /R %setup% %%f in (*.res) do del "%%f"
rmdir /S /Q "%setup%\build\"

echo [compile.bat] Moving the pyd module to the binaries directory
move "%setup%\cefpython_py%pyver%.pyd" "%binaries%/cefpython_py%pyver%.pyd"
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: Moving the pyd module failed
    exit /B 1
)

echo [compile.bat] Copying subprocess.exe to the binaries directory
copy "%~dp0..\subprocess\Release_%bits%\subprocess_%bits%.exe" "%binaries%\subprocess.exe"
if %errorlevel% neq 0 (
    echo [compile.bat] ERROR: Copying subprocess.exe failed
    exit /B 1
)

echo [compile.bat] Everything went OK. Running the wxpython.py example..

cd %binaries%
python wxpython.py & cd ../
