@echo off
REM Script para abrir todos los dashboards de Grafana

echo ========================================
echo Abriendo Dashboards de Grafana
echo ========================================
echo.
echo Credenciales:
echo   Usuario: admin
echo   Password: grupo5_devops
echo.
echo Abriendo dashboards en el navegador...
echo.

timeout /t 2 /nobreak > nul

echo [1/3] Application Performance Dashboard
start http://localhost:3001/d/app-performance-dashboard/application-performance-dashboard
timeout /t 2 /nobreak > nul

echo [2/3] Distributed Tracing Dashboard
start http://localhost:3001/d/distributed-tracing/distributed-tracing-dashboard
timeout /t 2 /nobreak > nul

echo [3/3] SLI/SLO Dashboard
start http://localhost:3001/d/slo-dashboard/sli-slo-dashboard
timeout /t 1 /nobreak > nul

echo.
echo ========================================
echo Dashboards abiertos exitosamente
echo ========================================
echo.
echo Para generar trafico:
echo   generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 4
echo.
pause
