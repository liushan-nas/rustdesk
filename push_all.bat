@echo off
REM 自动推送脚本 - 同时推送子模块和主仓库
REM 使用方法: push_all.bat "提交信息"

setlocal enabledelayedexpansion

if "%1"=="" (
    echo 用法: push_all.bat "提交信息"
    echo 示例: push_all.bat "修改配置"
    exit /b 1
)

set COMMIT_MSG=%1

echo ========================================
echo 开始推送改动...
echo 提交信息: %COMMIT_MSG%
echo ========================================

REM 进入子模块目录
cd libs\hbb_common
echo.
echo [1/5] 进入子模块目录: libs/hbb_common

REM 检查是否有改动
git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 无法访问git仓库
    exit /b 1
)

REM 添加子模块改动
echo [2/5] 添加改动...
git add .
if %errorlevel% neq 0 (
    echo [错误] git add 失败
    exit /b 1
)

REM 提交子模块改动
echo [3/5] 提交改动: %COMMIT_MSG%
git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo [警告] 子模块没有改动或提交失败
)

REM 推送子模块
echo [4/5] 推送子模块到 custom-config 分支...
git push origin custom-config
if %errorlevel% neq 0 (
    echo [错误] 推送子模块失败
    cd ..
    exit /b 1
)

REM 返回主仓库
cd ..
echo.
echo [5/5] 更新主仓库...

REM 更新主仓库的子模块指向
git add libs\hbb_common
git commit -m "Update hbb_common submodule: %COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo [警告] 主仓库没有改动或提交失败
)

REM 推送主仓库
echo 推送主仓库到 master 分支...
git push origin master
if %errorlevel% neq 0 (
    echo [错误] 推送主仓库失败
    exit /b 1
)

echo.
echo ========================================
echo 推送完成！
echo ========================================
pause
