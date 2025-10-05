@echo off
echo ========================================
echo  Verificando Metricas en Prometheus
echo ========================================
echo.

echo [1/3] Verificando que Prometheus esta corriendo...
curl -s http://localhost:9090/-/healthy
echo.
echo.

echo [2/3] Verificando targets en Prometheus...
echo Abre en tu navegador: http://localhost:9090/targets
echo.
echo Presiona Enter para continuar...
pause > nul

echo [3/3] Consultando metricas de la demo app...
curl -s "http://localhost:9090/api/v1/query?query=up" | findstr "success"
echo.
echo.

echo Verificando metricas HTTP especificas...
curl -s "http://localhost:9090/api/v1/query?query=http_server_requests_total"
echo.
echo.

echo ========================================
echo  Instrucciones
echo ========================================
echo.
echo 1. Abre Prometheus: http://localhost:9090
echo 2. Ve a Status ^> Targets
echo 3. Verifica que todos los targets esten "UP"
echo.
echo 4. En la pagina principal de Prometheus, ejecuta esta query:
echo    http_server_requests_total
echo.
echo 5. Si no ves datos, revisa los logs:
echo    docker-compose logs demo-app
echo    docker-compose logs otel-collector
echo    docker-compose logs prometheus
echo.
pause
