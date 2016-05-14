@echo off
setlocal ENABLEDELAYEDEXPANSION

:: It's best to always call with a flag that specifies python
:: version and architecture (eg. --py27-32bit). This will ensure
:: that PATH contains only minimum set of directories and will
:: allow to detect possible issues early.

if "%1"=="" goto usage
if "%2"=="" goto usage

set version=%1

:: Add only Python/ and Python/Scripts/ to PATH.
:: --py27-32bit flag
echo.%*|findstr /C:"--py27-32bit" >nul 2>&1
if %errorlevel% equ 0 (
   set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python27;C:\Python27\Scripts
)
:: --py27-64bit flag
echo.%*|findstr /C:"--py27-64bit" >nul 2>&1
if %errorlevel% equ 0 (
    set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python27_x64;C:\Python27_amd64;C:\Python27_64;C:\Python27_x64\Scripts;C:\Python27_amd64\Scripts;C:\Python27_64\Scripts
)
:: --py34-32bit flag
echo.%*|findstr /C:"--py34-32bit" >nul 2>&1
if %errorlevel% equ 0 (
   set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python34;C:\Python34\Scripts
)
:: --py34-64bit flag
echo.%*|findstr /C:"--py34-64bit" >nul 2>&1
if %errorlevel% equ 0 (
    set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Python34_x64;C:\Python34_amd64;C:\Python34_64;C:\Python34_x64\Scripts;C:\Python34_amd64\Scripts;C:\Python34_64\Scripts
)
:: PATH
echo [compile.bat] PATH: %PATH%

:: Python architecture. %bits%=="32bit" or "64bit"
FOR /F "delims=" %%i IN ('python -c "import struct, sys; sys.stdout.write(str(8 * struct.calcsize('P')) + 'bit');"') do set bits=%%i
echo [compile.bat] Python architecture: %bits%
set success=0
if "%bits%"=="32bit" (
    set platform=win32
    set success=1
)
if "%bits%"=="64bit" (
    set platform=win-amd64
    set success=1
)
if %success% neq 1 (
    echo [build_all.bat] ERROR: invalid architecture: %bits%
    exit /B 1
)

echo [build_all.bat] PLATFORM: %platform%
echo [build_all.bat] VERSION: %version%

:: Python version
for /F %%i in ('python -c "import sys; sys.stdout.write(str(sys.version_info[0]) + '.' + str(sys.version_info[1]));"') do set pyverdot=%%i
echo [build_all.bat] Python version: py%pyverdot%

:: --disable-inno-setup flag
set DISABLE_INNO_SETUP=0
echo.%*|findstr /C:"--disable-inno-setup" >nul 2>&1
if %errorlevel% equ 0 (
   set DISABLE_INNO_SETUP=1
)

:: Clean directories from previous run
rmdir /s /q Output
for /f "tokens=*" %%f in ('dir .\cefpython3*setup /ad/b') do rmdir /s /q %%f
rmdir /s /q dist

mkdir dist

echo [build_all.bat] Installing setuptools and wheel
pip install setuptools wheel
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: pip install setuptools wheel
    exit /B 1
)

if %DISABLE_INNO_SETUP% equ 0 (
    echo [build_all.bat] Creating Inno Setup intaller
    python make-installer.py -v %version%
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%f in ('dir .\Output\*.exe /b') do (
            move .\Output\%%f dist/%%f
            if !errorlevel! neq 0 (
                echo [build_all.bat] ERROR: moving inno setup installer failed
                exit /B 1
            )
        )
        rmdir Output
        if !errorlevel! neq 0 (
            echo [build_all.bat] ERROR: deleting Output/ directory failed
            exit /B 1
        )
    )
    if !errorlevel! neq 0 (
        echo [build_all.bat] ERROR: creating Inno Setup installer failed
        exit /B 1
    )
)

echo [build_all.bat] Creating Distutils setup
python make-setup.py -v %version%
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating Distutils setup
    exit /B 1
)

:: Enter the setup directory
for /f "tokens=*" %%f in ('dir .\cefpython3*setup /ad/b') do cd %%f

echo [build_all.bat] Creating Distutils source package
python setup.py sdist
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating Distutils source package
    exit /B 1
)

echo [build_all.bat] Creating Python Egg
python setup.py bdist_egg
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating Python Egg failed
    exit /B 1
)

echo [build_all.bat] Creating Python Wheel
python setup.py bdist_wheel
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating Python Wheel failed
    exit /B 1
)

echo [build_all.bat] Creating MSI installer
python setup.py bdist_msi
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating MSI installer failed
    exit /B 1
)

echo [build_all.bat] Creating EXE installer
python setup.py bdist_wininst
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: creating EXE installer failed
    exit /B 1
)

echo [build_all.bat] Moving all packages to the dist/ directory
set success=0
for /f "tokens=*" %%f in ('dir .\dist\*.* /b') do (
    move .\dist\%%f .\..\dist\%%f
    if !errorlevel! neq 0 (
        echo [build_all.bat] ERROR: moving setup dist/ packages failed
        exit /B 1
    )
    if !errorlevel! equ 0 (
        set success=1
    )
)
if %success% neq 1 (
    echo [build_all.bat] ERROR: moving setup dist/ packages failed
    exit /B 1
)

:: Up to the installer/ directory
cd ../

echo [build_all.bat] Deleting the Distutils setup directory
for /f "tokens=*" %%f in ('dir .\cefpython3*setup /ad/b') do rmdir /s /q %%f
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: failed deleting the Distutils setup directory
    exit /B 1
)

cd dist/

echo [build_all.bat] Renaming some of the packages to include platform tag
for /R %%i in (*) do (
    set oldfile=%%i
    set newfile=!oldfile:.egg=-%platform%.egg!
    if "!oldfile!" neq "!newfile!" (
        move !oldfile! !newfile!
    )
    set oldfile=%%i
    set newfile=!oldfile:.zip=-py%pyverdot%-%platform%.zip!
    if "!oldfile!" neq "!newfile!" (
        move !oldfile! !newfile!
    )
    set oldfile=%%i
    set newfile=!oldfile:%platform%.exe=py%pyverdot%-%platform%.exe!
    if "!oldfile!" neq "!newfile!" (
        move !oldfile! !newfile!
    )
    set oldfile=%%i
    set newfile=!oldfile:%platform%.msi=py%pyverdot%-%platform%.msi!
    if "!oldfile!" neq "!newfile!" (
        move !oldfile! !newfile!
    )
)

echo [build_all.bat] Packages in the dist/ directory:
dir

echo OK

goto :eof
:usage
@echo [build_all.bat] ERROR: platform or version arguments missing or invalid
@echo [build_all.bat] ERROR: example usage: build_all.bat win32 31.2
exit /B 1
