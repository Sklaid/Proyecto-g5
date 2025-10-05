@echo off
REM Wrapper para ejecutar smoke-tests.ps1 desde CMD

echo Ejecutando Smoke Tests...
echo.

REM Ejecutar PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0smoke-tests.ps1"

REM Capturar el exit code
set EXITCODE=%ERRORLEVEL%

echo.
if %EXITCODE% EQU 0 (
    echo Script completado exitosamente
) else (
    echo Script completado con errores
)

pause
exit /b %EXITCODE%
