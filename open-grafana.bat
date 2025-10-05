@echo off
REM Script para abrir Grafana en el navegador

echo ========================================
echo Abriendo Grafana
echo ========================================
echo.
echo URL: http://localhost:3001
echo Usuario: admin
echo Password: grupo5_devops
echo.
echo Abriendo navegador...
start http://localhost:3001
echo.
echo Dashboards disponibles:
echo   - Application Performance Dashboard
echo   - Distributed Tracing Dashboard
echo   - SLI/SLO Dashboard
echo.
pause
