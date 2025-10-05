# Setup Prerequisites for Integration Tests

## Current Status

The integration tests require Docker to be installed and running. It appears Docker is not currently available on your system.

## Required Software

### 1. Docker Desktop (Required)

**Download and Install:**
- Visit: https://docs.docker.com/desktop/install/windows-install/
- Download Docker Desktop for Windows
- Run the installer
- Restart your computer if prompted

**After Installation:**
1. Launch Docker Desktop
2. Wait for Docker to start (whale icon in system tray)
3. Verify installation:
   ```cmd
   docker --version
   docker compose version
   ```

**System Requirements:**
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- OR Windows 11 64-bit
- WSL 2 feature enabled
- At least 4GB RAM available for Docker

### 2. Node.js (Required for running tests)

**Check if installed:**
```cmd
node --version
npm --version
```

**If not installed:**
- Visit: https://nodejs.org/
- Download LTS version
- Run installer
- Verify: `node --version`

### 3. Git (Optional, for version control)

**Check if installed:**
```cmd
git --version
```

**If not installed:**
- Visit: https://git-scm.com/download/win
- Download and install

## Setup Steps

### Step 1: Install Docker Desktop

1. Download from: https://www.docker.com/products/docker-desktop/
2. Run the installer
3. Follow installation wizard
4. Enable WSL 2 if prompted
5. Restart computer
6. Launch Docker Desktop
7. Wait for "Docker Desktop is running" message

### Step 2: Verify Docker Installation

Open Command Prompt or PowerShell:

```cmd
docker --version
```
Expected output: `Docker version 24.x.x` (or similar)

```cmd
docker compose version
```
Expected output: `Docker Compose version v2.x.x`

```cmd
docker ps
```
Expected output: Empty list (no containers running yet)

### Step 3: Install Project Dependencies

Navigate to the demo-app directory:

```cmd
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5\demo-app
npm install
```

### Step 4: Start Services

From the project root:

```cmd
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5
docker compose up -d
```

Wait 30-60 seconds for services to start.

### Step 5: Run Integration Tests

```cmd
cd demo-app
npm run test:integration
```

OR use the automated script:

```cmd
cd demo-app
run-integration-tests.bat
```

## Troubleshooting

### Docker Desktop won't start

**Issue**: Docker Desktop shows error on startup

**Solutions**:
1. Enable WSL 2:
   ```cmd
   wsl --install
   wsl --set-default-version 2
   ```
2. Enable Hyper-V (Windows Pro/Enterprise):
   - Open PowerShell as Administrator
   - Run: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`
3. Check BIOS virtualization is enabled
4. Restart computer

### "Cannot connect to Docker daemon"

**Issue**: Docker commands fail with connection error

**Solutions**:
1. Make sure Docker Desktop is running (check system tray)
2. Restart Docker Desktop
3. Check Docker Desktop settings → Resources
4. Try running Command Prompt as Administrator

### Port conflicts

**Issue**: "Port already in use" error

**Solutions**:
1. Check what's using the port:
   ```cmd
   netstat -ano | findstr :3000
   ```
2. Stop the conflicting process
3. Or change ports in docker-compose.yml

### WSL 2 installation issues

**Issue**: WSL 2 required but not installed

**Solutions**:
1. Open PowerShell as Administrator
2. Run:
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```
3. Restart computer
4. Verify: `wsl --status`

## Alternative: Run Without Docker (Not Recommended)

If you cannot install Docker, you can run services individually, but this is complex:

1. Install Node.js, Prometheus, Tempo, Grafana manually
2. Configure each service separately
3. Update connection URLs in test files

**This is NOT recommended.** Docker Compose makes everything much easier.

## Verification Checklist

Before running integration tests, verify:

- [ ] Docker Desktop is installed
- [ ] Docker Desktop is running (whale icon in system tray)
- [ ] `docker --version` works
- [ ] `docker compose version` works
- [ ] `docker ps` works (shows empty list or running containers)
- [ ] Node.js is installed (`node --version`)
- [ ] npm is installed (`npm --version`)
- [ ] Project dependencies installed (`npm install` in demo-app)
- [ ] At least 4GB RAM available
- [ ] Ports 3000, 3001, 4317, 4318, 8889, 9090, 3200 are free

## Next Steps

Once Docker Desktop is installed and running:

1. Navigate to project root
2. Run: `docker compose up -d`
3. Wait 30 seconds
4. Run: `cd demo-app && npm run test:integration`

## Getting Help

If you encounter issues:

1. Check Docker Desktop logs (Settings → Troubleshoot → View logs)
2. Check Windows Event Viewer for errors
3. Visit Docker Desktop documentation: https://docs.docker.com/desktop/
4. Check Docker Desktop system requirements
5. Try Docker Desktop forums: https://forums.docker.com/

## Estimated Setup Time

- Docker Desktop installation: 10-15 minutes
- First-time Docker image downloads: 5-10 minutes
- Total: ~20-25 minutes

## System Impact

Docker Desktop will:
- Use ~2-4GB RAM when running
- Use ~10-20GB disk space for images
- Run in background (can be stopped when not needed)
- Start automatically with Windows (can be disabled in settings)

## Ready to Test?

Once everything is installed:

```cmd
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5\demo-app
run-integration-tests.bat
```

The script will:
1. ✅ Check Docker is available
2. ✅ Start all services
3. ✅ Wait for services to be ready
4. ✅ Run integration tests
5. ✅ Show results

Good luck! 🚀
