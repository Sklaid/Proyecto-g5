@echo off
REM Script para generar errores de prueba

echo ========================================
echo Generador de Errores de Prueba
echo ========================================
echo.
echo Este script genera errores CONTROLADOS
echo para demostrar el error tracking.
echo.

powershell -ExecutionPolicy Bypass -File generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 2

pause
