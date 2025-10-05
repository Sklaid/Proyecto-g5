@echo off
REM Script para aplicar cambios de metricas de Node.js

echo ========================================
echo Aplicando Cambios de Metricas
echo ========================================
echo.

echo [1/4] Deteniendo servicios...
docker-compose stop demo-app prometheus
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudieron detener los servicios
    pause
    exit /b 1
)

echo.
echo [2/4] Reconstruyendo demo-app con prom-client...
docker-compose build demo-app
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo reconstruir demo-app
    pause
    exit /b 1
)

echo.
echo [3/4] Iniciando servicios...
docker-compose up -d demo-app prometheus
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudieron iniciar los servicios
    pause
    exit /b 1
)

echo.
echo [4/4] Esperando a que los servicios esten listos...
timeout /t 15 /nobreak > nul

echo.
echo ========================================
echo Cambios Aplicados Exitosamente
echo ========================================
echo.
echo Verificando metricas...
echo.

timeout /t 5 /nobreak > nul

echo Probando endpoint /metrics de demo-app...
curl -s http://localhost:3000/metrics | findstr "nodejs_" > nul
if %ERRORLEVEL% EQU 0 (
    echo   OK Metricas de Node.js disponibles
) else (
    echo   ADVERTENCIA: Metricas aun no disponibles, espera unos segundos
)

echo.
echo Servicios actualizados:
echo   - demo-app: http://localhost:3000
echo   - Metrics: http://localhost:3000/metrics
echo   - Prometheus: http://localhost:9090
echo   - Grafana: http://localhost:3001
echo.
echo Ahora puedes:
echo   1. Generar trafico: generate-continuous-traffic.ps1
echo   2. Ver dashboards: open-all-dashboards.bat
echo   3. Verificar metricas en Prometheus
echo.

pause
