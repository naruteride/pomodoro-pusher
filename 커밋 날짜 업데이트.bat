@echo off
:: 터미널 인코딩을 UTF-8로 변경하여 한글 깨짐 방지
chcp 65001 >nul
setlocal

:: 1. 드래그 앤 드롭으로 전달된 경로(%1)가 있는지 확인
if "%~1"=="" (
    :: 그냥 더블클릭해서 실행한 경우 수동 입력 요청
    set /p repo_path="작업할 Git 레포지토리의 경로를 입력하시오: "
) else (
    :: 폴더를 드래그 앤 드롭한 경우 해당 경로를 자동 할당
    set "repo_path=%~1"
    echo [폴더 드래그 앤 드롭 인식됨] 
)

:: 경로가 비어있는지 검증
if "%repo_path%"=="" (
    echo 경로가 입력되지 않았습니다.
    pause
    goto :eof
)

:: 2. 입력받은 경로로 이동
cd /d "%repo_path%"

:: 정상적인 폴더인지 검증
if errorlevel 1 (
    echo [오류] 지정한 경로를 찾을 수 없습니다: %repo_path%
    pause
    goto :eof
)

:: Git 레포지토리가 맞는지 검증 (괄호 이스케이프 처리)
if not exist ".git" (
    echo [오류] 해당 경로는 Git 레포지토리가 아닙니다. ^(.git 폴더 없음^)
    pause
    goto :eof
)

:: 3. 현재 작업 위치 및 브랜치 확인
for /f "delims=" %%i in ('git branch --show-current') do set "current_branch=%%i"

echo.
echo ===================================================
echo [현재 작업 위치: %CD%]
echo [현재 브랜치: %current_branch%]
echo ===================================================
echo.

:: 4. 변경할 커밋 개수를 입력받음
set /p count="날짜를 갱신할 최근 커밋의 개수를 입력하시오: "

:: 커밋 개수 입력값 검증
if "%count%"=="" (
    echo 숫자만 입력하십시오.
    pause
    goto :eof
)

echo.
echo ===================================================
echo [%current_branch%] 브랜치의 최근 [%count%]개 커밋 날짜를 현재 시간으로 업데이트합니다...
echo ===================================================
echo.

:: 5. git rebase --exec 실행
git rebase HEAD~%count% --exec "git commit --amend --no-edit --reset-author --no-verify"

echo.
echo ===================================================
echo 작업이 완료되었습니다.
echo ===================================================
pause
endlocal