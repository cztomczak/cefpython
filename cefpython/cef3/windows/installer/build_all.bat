@echo off

if "%1"=="" goto usage
if "%2"=="" goto usage

set platform=%1
set version=%2

set success=0
if "%platform%"=="win32" set success=1
if "%platform%"=="win-amd64" set success=1
if %success% neq 1 (
    echo [build_all.bat] ERROR: invalid platform. Allowed: win32, win-amd64.
    goto usage
)

echo [build_all.bat] PLATFORM: %platform%
echo [build_all.bat] VERSION: %version%

set DISABLE_INNO_SETUP=0

echo.%*|findstr /C:"--disable-inno-setup" >nul 2>&1
if %errorlevel% equ 0 (
   set DISABLE_INNO_SETUP=1
)

:: Clean directories from previous run
rm -rf Output/
rm -rf cefpython3-*-setup/
rm -rf dist/

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
    if %errorlevel% equ 0 (
        mv Output/*.exe dist/
        if %errorlevel% neq 0 (
            echo [build_all.bat] ERROR: moving inno setup installer failed
            exit /B 1
        )
        rmdir Output
        if %errorlevel% neq 0 (
            echo [build_all.bat] ERROR: deleting Output/ directory failed
            exit /B 1
        )
    ) else if %errorlevel% neq 0 (
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
cd cefpython3-*-setup/

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
mv dist/* ../dist/
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: moving packages failed
    exit /B 1
)

:: Up to the installer/ directory
cd ../

echo [build_all.bat] Deleting the Distutils setup directory
rm -rf cefpython3-*-setup/
if %errorlevel% neq 0 (
    echo [build_all.bat] ERROR: failed deleting the Distutils setup directory
    exit /B 1
)

cd dist/

echo [build_all.bat] Renaming some of the packages to include platform tag
setlocal ENABLEDELAYEDEXPANSION
for /R %%i in (*) do (
    set oldfile=%%i
    set newfile=!oldfile:.egg=-%platform%.egg!
    if "!oldfile!" neq "!newfile!" (
        mv !oldfile! !newfile!
    )
    set oldfile=%%i
    set newfile=!oldfile:.zip=-%platform%.zip!
    if "!oldfile!" neq "!newfile!" (
        mv !oldfile! !newfile!
    )
)
endlocal

echo [build_all.bat] Packages in the dist/ directory:
dir

echo OK

goto :eof
:usage
@echo [build_all.bat] ERROR: platform or version arguments missing or invalid
@echo [build_all.bat] ERROR: example usage: build_all.bat win32 31.2
exit /B 1
