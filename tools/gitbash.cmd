@echo off
setlocal

REM Run a single Git Bash command from Windows cmd.exe.
REM This avoids accidental routing through WSL relays when invoking `bash`.

set "BASH=C:\Program Files\Git\usr\bin\bash.exe"
if not exist "%BASH%" set "BASH=C:\Program Files\Git\bin\bash.exe"

if not exist "%BASH%" (
  echo ERROR: Git Bash not found. Expected at:
  echo   C:\Program Files\Git\usr\bin\bash.exe
  echo   C:\Program Files\Git\bin\bash.exe
  exit /b 1
)

if "%~1"=="" (
  echo Usage: tools\gitbash.cmd "<bash command>"
  exit /b 2
)

"%BASH%" -lc "%~1"
