@echo off
REM Quick rebuild: Only rebuild changed files

cd /d e:\PC_RustDesk

REM Initialize VS environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Set VCPKG_ROOT
set VCPKG_ROOT=C:\vcpkg

REM Set Flutter mirrors for China
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM Add Flutter to PATH
set PATH=C:\flutter\bin;C:\flutter\bin\cache\dart-sdk\bin;%PATH%

echo ========================================
echo Step 1: Build Rust library (incremental)
echo ========================================
REM Note: hwcodec disabled due to missing swresample in local vcpkg FFmpeg
REM GitHub Actions build has hwcodec enabled with proper FFmpeg config
C:\Users\Administrator\.cargo\bin\cargo.exe build --features flutter --lib --release
if errorlevel 1 (
    echo Rust build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 2: Build Flutter app
echo ========================================
cd /d e:\PC_RustDesk\flutter

REM Build without clean for faster rebuild
C:\flutter\bin\flutter.bat build windows --release

if errorlevel 1 (
    echo Flutter build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 3: Embed manifest and copy files
echo ========================================
cd /d e:\PC_RustDesk

REM Embed manifest for UAC elevation
echo Embedding manifest...
mt.exe -manifest flutter\windows\runner\runner.exe.manifest -outputresource:flutter\build\windows\x64\runner\Release\rustdesk.exe;1

REM Copy virtual display dll
copy /Y target\release\deps\dylib_virtual_display.dll flutter\build\windows\x64\runner\Release\

echo.
echo ========================================
echo Build complete!
echo ========================================
echo Executable: e:\PC_RustDesk\flutter\build\windows\x64\runner\Release\rustdesk.exe
echo.
echo NOTE: Right-click the exe and select "Run as administrator" for full functionality.
pause
