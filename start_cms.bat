@echo off
setlocal
cd /d "%~dp0"

REM Ensure Python is available
where python >nul 2>nul || (
  echo Python not found in PATH. Please install Python and try again.
  pause
  exit /b 1
)

REM Create venv if missing
if not exist "env\Scripts\python.exe" (
  echo Creating virtual environment...
  python -m venv env || (
    echo Failed to create virtual environment.
    pause
    exit /b 1
  )
)

REM Prefer using venv python directly (works even if activate.bat is unavailable)
set "VENV_PY=env\Scripts\python.exe"
if exist "%VENV_PY%" (
  set "PYEXE=%VENV_PY%"
) else (
  set "PYEXE=python"
)

REM Ensure pip exists in venv (handles cases where pip is missing)
"%PYEXE%" -m ensurepip --upgrade >nul 2>nul

REM Upgrade pip and install requirements if present
"%PYEXE%" -m pip install --upgrade pip
if exist "requirements.txt" (
  echo Installing dependencies from requirements.txt ...
  "%PYEXE%" -m pip install -r requirements.txt || (
    echo Failed to install dependencies.
    pause
    exit /b 1
  )
)

REM Apply migrations
echo Applying database migrations...
"%PYEXE%" manage.py migrate || (
  echo Migrations failed.
  pause
  exit /b 1
)

REM Open browser and start server
start "" http://127.0.0.1:8000/
echo Starting Django development server...
"%PYEXE%" manage.py runserver

endlocal


