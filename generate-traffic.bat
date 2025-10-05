@echo off
echo ========================================
echo  Generating Traffic to Demo App
echo ========================================
echo.

set DEMO_URL=http://localhost:3000

echo [1/4] Testing health endpoint...
curl -s %DEMO_URL%/health
echo.

echo [2/4] Generating normal traffic (100 requests)...
for /L %%i in (1,1,100) do (
    curl -s %DEMO_URL%/api/users > nul
    curl -s %DEMO_URL%/api/products > nul
    if %%i==25 echo   25%% complete...
    if %%i==50 echo   50%% complete...
    if %%i==75 echo   75%% complete...
)
echo   100%% complete!
echo.

echo [3/4] Generating some errors (10 requests)...
for /L %%i in (1,1,10) do (
    curl -s %DEMO_URL%/api/error > nul
)
echo   Done!
echo.

echo [4/4] Summary
echo ========================================
echo Total requests sent: 210
echo   - Normal: 200
echo   - Errors: 10
echo.
echo Wait 30 seconds, then check:
echo   - Grafana: http://localhost:3001
echo   - Prometheus: http://localhost:9090
echo.
pause
