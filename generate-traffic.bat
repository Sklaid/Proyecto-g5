@echo off
echo ========================================
echo   Generador de Trafico - Demo App
echo ========================================
echo.

echo [1/4] Verificando que la aplicacion este corriendo...
curl -s http://localhost:3000/health > nul
if %errorlevel% neq 0 (
    echo ERROR: La aplicacion no esta corriendo en http://localhost:3000
    echo Ejecuta: docker-compose up -d
    pause
    exit /b 1
)
echo OK - Aplicacion corriendo!
echo.

echo [2/4] Generando requests normales (40 requests)...
for /L %%i in (1,1,20) do (
    curl -s http://localhost:3000/api/users > nul
    curl -s http://localhost:3000/api/products > nul
    if %%i LSS 20 timeout /t 1 /nobreak > nul
)
echo OK - Requests normales generados
echo.

echo [3/4] Generando errores 500 (10 requests)...
for /L %%i in (1,1,10) do (
    curl -s http://localhost:3000/api/error/500 > nul
    if %%i LSS 10 timeout /t 1 /nobreak > nul
)
echo OK - Errores 500 generados
echo.

echo [4/4] Generando excepciones (5 requests)...
for /L %%i in (1,1,5) do (
    curl -s http://localhost:3000/api/error/exception > nul
    if %%i LSS 5 timeout /t 1 /nobreak > nul
)
echo OK - Excepciones generadas
echo.

echo ========================================
echo   Trafico Generado Exitosamente!
echo ========================================
echo.
echo Total de requests: ~55
echo - Requests exitosos: 40
echo - Errores 500: 10
echo - Excepciones: 5
echo.
echo Espera 30-60 segundos para que las metricas se procesen
echo.
echo Luego accede a Grafana:
echo URL: http://localhost:3001
echo Usuario: admin
echo Password: admin
echo.
pause
