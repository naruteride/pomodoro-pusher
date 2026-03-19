@echo off
:: 터미널 인코딩을 UTF-8로 변경하여 한글 깨짐 방지
chcp 65001 >nul
setlocal

:: 1. 드래그 앤 드롭으로 전달된 경로(%1)가 있는지 확인
if "%~1"=="" (
    set /p repo_path="작업할 Git 레포지토리의 경로를 입력하시오: "
) else (
    set "repo_path=%~1"
    echo [폴더 드래그 앤 드롭 인식됨] 
)

:: 경로 검증 및 이동
if "%repo_path%"=="" goto :eof
cd /d "%repo_path%"
if errorlevel 1 (
    echo [오류] 지정한 경로를 찾을 수 없습니다: %repo_path%
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
echo [현재 작업 위치: %CD%]
echo [현재 브랜치: %current_branch%]
echo ===================================================
echo.

:: 3. 보여줄 커밋 개수 입력받기 (디폴트 10)
set log_count=10
set /p input_count="몇 개의 최근 커밋 내역을 확인하시겠습니까? (기본값 10개): "
if not "%input_count%"=="" set log_count=%input_count%

echo [최근 커밋 내역 %log_count%개]
echo ===================================================
echo.

:: 입력받은 개수(%log_count%)만큼 커밋 로그를 출력합니다.
git log --oneline -n %log_count%
echo.
echo ===================================================
echo.

:: 4. 푸시할 커밋 해시 입력받기
set /p commit_hash="원격에 올릴 마지막 커밋의 해시(ID)를 입력하시오 (예: 27c2b731fb3): "

if "%commit_hash%"=="" (
    echo 커밋 해시가 입력되지 않았습니다.
    pause
    goto :eof
)

:: 5. 특정 커밋까지만 푸시 실행
echo.
echo ===================================================
echo [origin] 원격 저장소의 [%current_branch%] 브랜치에 [%commit_hash%] 커밋까지만 반영합니다...
echo 실행 명령어: git push origin %commit_hash%:%current_branch%
echo ===================================================
echo.

git push origin %commit_hash%:%current_branch%

echo.
echo ===================================================
echo 작업이 완료되었습니다.
echo ===================================================
pause
endlocal