@echo off
REM Script para abrir Tempo Explore en Grafana

echo ========================================
echo Abriendo Tempo Explore
echo ========================================
echo.
echo Credenciales:
echo   Usuario: admin
echo   Password: grupo5_devops
echo.
echo Abriendo Tempo en Explore...
echo.

REM URL con query preconfigurada para mostrar todos los traces
start "http://localhost:3001/explore?left={\"datasource\":\"tempo\",\"queries\":[{\"refId\":\"A\",\"datasource\":{\"type\":\"tempo\",\"uid\":\"tempo\"},\"queryType\":\"traceql\",\"limit\":20,\"query\":\"{}\"}],\"range\":{\"from\":\"now-1h\",\"to\":\"now\"}}"

timeout /t 2 /nobreak > nul

echo.
echo ========================================
echo Tempo Explore abierto
echo ========================================
echo.
echo En Explore puedes:
echo   - Ver todos los traces disponibles
echo   - Filtrar por servicio, endpoint, duracion
echo   - Click en un trace para ver detalles
echo   - Analizar latencia y errores
echo.
echo Traces disponibles: 132+
echo Servicio: demo-app
echo Endpoints: /api/users, /api/products
echo.
pause
