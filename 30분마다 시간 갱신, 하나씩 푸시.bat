@echo off
:: 터미널 인코딩을 UTF-8로 변경하여 한글 깨짐 방지
chcp 65001 >nul
:: 루프 안에서 변수값이 실시간으로 갱신되도록 지연된 환경 변수 확장 사용
setlocal enabledelayedexpansion

:: 1. 경로 입력 및 이동
if "%~1"=="" (
    set /p repo_path="작업할 Git 레포지토리의 경로를 입력하십시오: "
) else (
    set "repo_path=%~1"
    echo [폴더 드래그 앤 드롭 인식됨] 
)

if "!repo_path!"=="" goto :eof
cd /d "!repo_path!"

if errorlevel 1 (
    echo [오류] 지정한 경로를 찾을 수 없습니다: !repo_path!
    pause
    goto :eof
)
if not exist ".git" (
    echo [오류] 해당 경로는 Git 레포지토리가 아닙니다. ^(.git 폴더 없음^)
    pause
    goto :eof
)

:: 2. 현재 작업 위치 및 브랜치 확인
for /f "delims=" %%i in ('git branch --show-current') do set "current_branch=%%i"

echo.
echo ===================================================
echo [현재 위치: %CD%]
echo [현재 브랜치: %current_branch%]
echo ===================================================
echo.

set /p count="30분 간격으로 하나씩 푸시할 커밋의 총 개수를 입력하십시오: "

if "!count!"=="" (
    echo 개수가 입력되지 않았습니다.
    pause
    goto :eof
)

:: 4. 30분 간격 자동화 루프 시작
:drip_feed_loop
if !count! leq 0 (
    echo.
    echo ===================================================
    echo 모든 커밋의 푸시가 완료되었습니다.
    echo ===================================================
    goto :end
)

echo.
echo ===================================================
echo [남은 대기 커밋: !count!개]
echo ===================================================
echo 1. 남은 커밋들의 날짜를 현재 시간으로 갱신합니다...

:: 현재 남은 개수만큼만 리베이스하여 날짜 갱신
git rebase HEAD~!count! --exec "git commit --amend --no-edit --reset-author --no-verify"

:: 푸시할 타겟 커밋 계산 (N개 남았을 때, 가장 오래된 것은 HEAD~(N-1))
set /a push_index=!count! - 1

if !push_index! equ 0 (
    set push_target=HEAD
) else (
    set push_target=HEAD~!push_index!
)

echo.
echo 2. 대상 커밋(!push_target!)을 origin/!current_branch! 에 푸시합니다...
git push origin !push_target!:!current_branch!

:: 남은 개수 차감
set /a count=!count! - 1

if !count! equ 0 (
    echo.
    echo ===================================================
    echo 모든 작업이 성공적으로 완료되었습니다.
    echo ===================================================
    goto :end
)

echo.
echo 3. 다음 푸시까지 30분(1800초) 대기합니다... ^(스크립트를 강제 중단하려면 Ctrl+C 입력^)
:: timeout 명령어로 1800초 대기 (/nobreak 옵션으로 엔터키 등에 의한 스킵 방지)
timeout /t 1800 /nobreak
goto :drip_feed_loop

:end
pause
endlocal