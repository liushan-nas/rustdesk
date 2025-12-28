@echo off
cd /d e:\PC_RustDesk

REM Initialize Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Add Rust, Python, and Flutter to PATH
set PATH=%USERPROFILE%\.cargo\bin;C:\flutter\bin;C:\flutter\bin\cache\dart-sdk\bin;%PATH%

REM Find Python installation
for /f "delims=" %%i in ('where python 2^>nul') do set PYTHON_PATH=%%i
if defined PYTHON_PATH (
    echo Found Python at: %PYTHON_PATH%
) else (
    echo Warning: Python not found in PATH
)

REM Set Flutter mirrors for China
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM Install flutter_rust_bridge_codegen v1.80.1
echo Installing flutter_rust_bridge_codegen v1.80.1...
cargo install flutter_rust_bridge_codegen --version 1.80.1 --features "uuid" --locked --force

REM Generate Flutter Rust Bridge bindings
echo.
echo Generating Flutter Rust Bridge bindings...
call %USERPROFILE%\.cargo\bin\flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs --dart-output ./flutter/lib/generated_bridge.dart --c-output ./flutter/macos/Runner/bridge_generated.h

REM Build RustDesk with Flutter
echo.
echo Building RustDesk Flutter app...
cd /d e:\PC_RustDesk\flutter
flutter build windows --release

echo.
echo Build complete!
pause
