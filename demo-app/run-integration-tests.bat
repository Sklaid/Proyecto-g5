@echo off
REM Integration test runner script for Windows
REM This script starts the services, runs the tests, and shows results

echo.
echo Starting OpenTelemetry Collector Integration Tests
echo ==================================================
echo.

REM Check if docker compose (plugin) is available
docker compose version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set DOCKER_COMPOSE_CMD=docker compose
    echo [INFO] Using 'docker compose' command
) else (
    REM Check if docker-compose (standalone) is available
    where docker-compose >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set DOCKER_COMPOSE_CMD=docker-compose
        echo [INFO] Using 'docker-compose' command
    ) else (
        echo [ERROR] Docker Compose not found. Please install Docker Desktop or Docker Compose.
        echo [INFO] Visit: https://docs.docker.com/desktop/install/windows-install/
        exit /b 1
    )
)

REM Navigate to project root
cd /d "%~dp0\.."

echo [INFO] Starting services with Docker Compose...
%DOCKER_COMPOSE_CMD% up -d

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start services
    exit /b 1
)

echo [INFO] Waiting for services to be healthy (30 seconds)...
timeout /t 30 /nobreak >nul

echo [INFO] Checking service health...
%DOCKER_COMPOSE_CMD% ps

echo [INFO] Running integration tests...
cd demo-app

call npm run test:integration

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==================================================
    echo [SUCCESS] Integration tests passed!
    echo ==================================================
    exit /b 0
) else (
    echo.
    echo ==================================================
    echo [ERROR] Integration tests failed!
    echo ==================================================
    echo.
    echo [INFO] Showing service logs...
    cd ..
    %DOCKER_COMPOSE_CMD% logs --tail=50 otel-collector
    %DOCKER_COMPOSE_CMD% logs --tail=50 demo-app
    exit /b 1
)
