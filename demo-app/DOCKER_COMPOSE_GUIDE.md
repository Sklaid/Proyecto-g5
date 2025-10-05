# Docker Compose Command Guide

## Two Versions of Docker Compose

There are two versions of Docker Compose you might encounter:

### Docker Compose V2 (Recommended - Built into Docker Desktop)
```bash
docker compose up -d
docker compose ps
docker compose logs
docker compose down
```
- **Command**: `docker compose` (with space)
- **Included in**: Docker Desktop for Windows/Mac/Linux
- **Version**: 2.x
- **Status**: Current and actively maintained

### Docker Compose V1 (Legacy - Standalone)
```bash
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```
- **Command**: `docker-compose` (with hyphen)
- **Installation**: Separate installation required
- **Version**: 1.x
- **Status**: Legacy, but still works

## How to Check Which Version You Have

### Check for Docker Compose V2 (Plugin)
```bash
docker compose version
```
Expected output:
```
Docker Compose version v2.x.x
```

### Check for Docker Compose V1 (Standalone)
```bash
docker-compose --version
```
Expected output:
```
docker-compose version 1.x.x
```

## Windows-Specific Instructions

### If You Have Docker Desktop (Recommended)
Docker Desktop includes Docker Compose V2 by default. Use:
```cmd
docker compose up -d
```

### If You Don't Have Docker Desktop
1. Install Docker Desktop from: https://docs.docker.com/desktop/install/windows-install/
2. Or install standalone Docker Compose V1 from: https://docs.docker.com/compose/install/

## Our Test Script Handles Both

The `run-integration-tests.bat` script automatically detects which version you have:

```batch
REM It tries docker compose first (V2)
docker compose version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set DOCKER_COMPOSE_CMD=docker compose
) else (
    REM Falls back to docker-compose (V1)
    where docker-compose >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set DOCKER_COMPOSE_CMD=docker-compose
    )
)
```

## Common Issues and Solutions

### Issue: "docker-compose not found"
**Solution**: You likely have Docker Compose V2. Use `docker compose` instead of `docker-compose`

### Issue: "docker compose not found"
**Solution**: Install Docker Desktop or standalone Docker Compose

### Issue: "Cannot connect to Docker daemon"
**Solution**: 
1. Make sure Docker Desktop is running
2. Check Docker service status
3. Restart Docker Desktop

### Issue: "Port already in use"
**Solution**:
```bash
# Find what's using the port (example for port 3000)
netstat -ano | findstr :3000

# Stop the process or change the port in docker-compose.yml
```

## Quick Reference

| Task | Docker Compose V2 | Docker Compose V1 |
|------|-------------------|-------------------|
| Start services | `docker compose up -d` | `docker-compose up -d` |
| Check status | `docker compose ps` | `docker-compose ps` |
| View logs | `docker compose logs` | `docker-compose logs` |
| Stop services | `docker compose down` | `docker-compose down` |
| Restart service | `docker compose restart <service>` | `docker-compose restart <service>` |

## For This Project

### Recommended: Use the Test Script
```cmd
cd demo-app
run-integration-tests.bat
```
The script handles version detection automatically.

### Manual Commands (if needed)
```cmd
# Navigate to project root
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5

# Start services (use the command that works for you)
docker compose up -d
# OR
docker-compose up -d

# Wait for services
timeout /t 30

# Run tests
cd demo-app
npm run test:integration
```

## Verification

To verify Docker Compose is working:
```cmd
# Try V2 first
docker compose version

# If that fails, try V1
docker-compose --version

# Check Docker is running
docker ps
```

## Need Help?

If you're still having issues:
1. Verify Docker Desktop is installed and running
2. Check Docker Desktop settings
3. Try restarting Docker Desktop
4. Check Windows firewall settings
5. Run PowerShell/CMD as Administrator

## Links

- Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
- Docker Compose V2: https://docs.docker.com/compose/
- Docker Compose V1: https://docs.docker.com/compose/install/other/
