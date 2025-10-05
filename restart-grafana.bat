@echo off
REM Script para reiniciar Grafana y aplicar los cambios en los dashboards

echo ========================================
echo Reiniciando Grafana
echo ========================================
echo.

echo [1/3] Deteniendo Grafana...
docker-compose stop grafana
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo detener Grafana
    pause
    exit /b 1
)

echo.
echo [2/3] Iniciando Grafana...
docker-compose start grafana
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo iniciar Grafana
    pause
    exit /b 1
)

echo.
echo [3/3] Esperando a que Grafana este listo...
timeout /t 10 /nobreak > nul

echo.
echo ========================================
echo Grafana reiniciado exitosamente
echo ========================================
echo.
echo Los dashboards actualizados ya estan disponibles en:
echo   URL: http://localhost:3001
echo   Usuario: admin
echo   Password: admin
echo.
echo Dashboards actualizados:
echo   - Application Performance Dashboard
echo   - Distributed Tracing Dashboard
echo   - SLI/SLO Dashboard
echo.
echo Para verificar las metricas, ejecuta:
echo   verify-error-rate.ps1
echo.
echo Para generar trafico de prueba, ejecuta:
echo   generate-traffic.bat
echo.

pause
