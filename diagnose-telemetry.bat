@echo off
echo ========================================
echo  Diagnostico de Telemetria
echo ========================================
echo.

echo [1/5] Verificando conectividad de demo-app a otel-collector...
docker-compose exec demo-app ping -c 2 otel-collector
echo.

echo [2/5] Verificando que el puerto 4318 del collector este abierto...
docker-compose exec demo-app curl -s http://otel-collector:4318/v1/metrics -X POST -H "Content-Type: application/json" -d "{}"
echo.

echo [3/5] Generando trafico a la demo app...
curl -s http://localhost:3000/api/users
curl -s http://localhost:3000/api/products
echo Trafico generado
echo.

echo [4/5] Esperando 15 segundos para que las metricas se exporten...
timeout /t 15 /nobreak
echo.

echo [5/5] Verificando metricas en el endpoint del OTel Collector...
curl -s http://localhost:8889/metrics | findstr "http_server"
echo.

echo ========================================
echo  Verificacion Manual
echo ========================================
echo.
echo 1. Abre: http://localhost:8889/metrics
echo    Busca metricas que empiecen con "http_server"
echo.
echo 2. Si no ves metricas, revisa los logs:
echo    docker-compose logs demo-app
echo    docker-compose logs otel-collector
echo.
pause
