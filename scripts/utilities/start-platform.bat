@echo off
echo ========================================
echo  AIOps Platform - Starting Services
echo ========================================
echo.

echo [1/4] Stopping any existing containers...
docker-compose down

echo.
echo [2/4] Building images...
docker-compose build

echo.
echo [3/4] Starting all services...
docker-compose up -d

echo.
echo [4/4] Waiting for services to be ready...
timeout /t 30 /nobreak

echo.
echo ========================================
echo  Services Status
echo ========================================
docker-compose ps

echo.
echo ========================================
echo  Access Information
echo ========================================
echo.
echo Grafana:     http://localhost:3001
echo   User: admin / Password: admin
echo.
echo Prometheus:  http://localhost:9090
echo Tempo:       http://localhost:3200
echo Demo App:    http://localhost:3000
echo.
echo ========================================
echo  Next Steps
echo ========================================
echo.
echo 1. Wait 1-2 minutes for all services to initialize
echo 2. Run smoke tests: .\scripts\smoke-tests.ps1
echo 3. Access Grafana to view dashboards
echo.
echo To view logs: docker-compose logs -f [service-name]
echo To stop: docker-compose down
echo.
pause
