# Smoke Tests Execution Guide

## Overview

This guide provides step-by-step instructions for running smoke tests in different scenarios.

---

## Prerequisites

### System Requirements
- Docker and Docker Compose installed
- Bash shell (Linux/Mac) or PowerShell (Windows)
- curl command available
- Network access to localhost ports: 3000, 3001, 3200, 9090

### Service Requirements
All services must be running:
```bash
docker-compose ps
```

Expected output:
```
NAME                STATUS
demo-app            Up
otel-collector      Up
prometheus          Up
tempo               Up
grafana             Up
anomaly-detector    Up
```

---

## Scenario 1: Local Development Testing

### Step 1: Start Services
```bash
# Start all services
docker-compose up -d

# Verify services are starting
docker-compose ps
```

### Step 2: Wait for Initialization
```bash
# Wait 30-60 seconds for services to fully initialize
sleep 60
```

### Step 3: Run Smoke Tests

**Linux/Mac:**
```bash
# Make script executable (first time only)
chmod +x scripts/smoke-tests.sh

# Run tests
./scripts/smoke-tests.sh
```

**Windows:**
```powershell
# Run tests
.\scripts\smoke-tests.ps1
```

### Step 4: Interpret Results

**Success:**
```
✓ All smoke tests passed!
The system is functioning correctly.
Exit code: 0
```

**Failure:**
```
✗ Some tests failed.
Review service logs with: docker-compose logs <service>
Exit code: 1
```

---

## Scenario 2: CI/CD Pipeline Testing

### Automated Execution

The smoke tests run automatically in GitHub Actions:

```yaml
# .github/workflows/deploy.yml
- name: Deploy with Docker Compose
  run: docker-compose up -d

- name: Run smoke tests
  id: smoke-tests
  run: |
    chmod +x scripts/ci-smoke-tests.sh
    ./scripts/ci-smoke-tests.sh
```

### Manual CI-Style Test

To test locally with the same script used in CI:

```bash
# Start services
docker-compose up -d
sleep 30

# Run CI smoke tests
chmod +x scripts/ci-smoke-tests.sh
./scripts/ci-smoke-tests.sh
```

---

## Scenario 3: Quick Health Check

For a fast health check without full smoke tests:

```bash
# Check all health endpoints
curl -f http://localhost:3000/health && echo "✓ Demo App"
curl -f http://localhost:3000/ready && echo "✓ Demo App Ready"
curl -f http://localhost:9090/-/healthy && echo "✓ Prometheus"
curl -f http://localhost:3001/api/health && echo "✓ Grafana"
curl -f http://localhost:3200/ready && echo "✓ Tempo"
```

---

## Scenario 4: Debugging Failed Tests

### Step 1: Identify Failed Component

Run smoke tests and note which tests fail:
```bash
./scripts/smoke-tests.sh
```

### Step 2: Check Container Status

```bash
# List all containers
docker-compose ps

# Check specific container
docker-compose ps demo-app
```

### Step 3: View Logs

```bash
# View logs for failed service
docker-compose logs demo-app
docker-compose logs prometheus
docker-compose logs tempo
docker-compose logs grafana
docker-compose logs otel-collector

# Follow logs in real-time
docker-compose logs -f demo-app
```

### Step 4: Restart Service

```bash
# Restart specific service
docker-compose restart demo-app

# Wait and retest
sleep 20
./scripts/smoke-tests.sh
```

### Step 5: Full Reset

If issues persist:
```bash
# Stop all services
docker-compose down

# Remove volumes (WARNING: deletes data)
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build

# Wait for initialization
sleep 60

# Retest
./scripts/smoke-tests.sh
```

---

## Scenario 5: Pre-Deployment Validation

Before deploying to production:

### Step 1: Validate Code
```bash
# Run CI validation
./scripts/validate-ci.sh  # Linux/Mac
.\scripts\validate-ci.ps1  # Windows
```

### Step 2: Deploy to Staging
```bash
docker-compose up -d
sleep 60
```

### Step 3: Run Full Smoke Tests
```bash
./scripts/smoke-tests.sh
```

### Step 4: Generate Load
```bash
# Generate traffic to test under load
./generate-traffic.bat  # Windows
./generate-traffic.sh   # Linux/Mac (if exists)
```

### Step 5: Retest After Load
```bash
# Wait for metrics to stabilize
sleep 30

# Retest
./scripts/smoke-tests.sh
```

### Step 6: Verify Dashboards
```bash
# Open Grafana
open http://localhost:3001  # Mac
start http://localhost:3001  # Windows
xdg-open http://localhost:3001  # Linux

# Login: admin/admin
# Verify all dashboards show data
```

---

## Scenario 6: Continuous Monitoring

For ongoing health monitoring:

### Option 1: Periodic Execution

```bash
# Run smoke tests every 5 minutes
while true; do
  ./scripts/smoke-tests.sh
  sleep 300
done
```

### Option 2: Cron Job (Linux/Mac)

```bash
# Add to crontab
crontab -e

# Add line:
*/5 * * * * cd /path/to/project && ./scripts/smoke-tests.sh >> /var/log/smoke-tests.log 2>&1
```

### Option 3: Scheduled Task (Windows)

```powershell
# Create scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\path\to\scripts\smoke-tests.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SmokeTests"
```

---

## Test Categories and Timing

### 1. Health Checks (10-30 seconds)
- Fast endpoint checks
- Retry logic with 5-10 second delays
- Critical for basic availability

### 2. Metrics Validation (20-40 seconds)
- Requires metrics scrape interval
- Wait 15+ seconds for data
- Validates telemetry pipeline

### 3. Trace Validation (15-30 seconds)
- Generates test traffic
- Wait 10+ seconds for processing
- Confirms distributed tracing

### 4. Grafana Dashboards (5-10 seconds)
- Fast API checks
- Validates visualization layer
- Confirms datasource connectivity

### 5. Container Status (1-5 seconds)
- Quick Docker API check
- Validates deployment

**Total Expected Time:** 1-2 minutes

---

## Exit Codes and Automation

### Exit Codes
- **0** - All tests passed (success)
- **1** - One or more tests failed (failure)

### Use in Scripts

```bash
#!/bin/bash

# Run smoke tests
./scripts/smoke-tests.sh

# Check exit code
if [ $? -eq 0 ]; then
  echo "Deployment successful!"
  # Continue with next steps
else
  echo "Deployment failed!"
  # Trigger rollback
  docker-compose down
  exit 1
fi
```

### Use in CI/CD

```yaml
- name: Run smoke tests
  run: ./scripts/ci-smoke-tests.sh

- name: Deploy to production
  if: success()
  run: |
    # Production deployment

- name: Rollback
  if: failure()
  run: |
    # Rollback logic
```

---

## Troubleshooting Common Issues

### Issue: "Connection refused"

**Cause:** Service not started or not ready

**Solution:**
```bash
# Check if service is running
docker-compose ps

# Check logs
docker-compose logs <service>

# Restart service
docker-compose restart <service>

# Wait longer
sleep 60
```

### Issue: "Metrics not found"

**Cause:** Prometheus hasn't scraped yet or no traffic

**Solution:**
```bash
# Generate traffic
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products

# Wait for scrape interval (15 seconds)
sleep 20

# Retest
./scripts/smoke-tests.sh
```

### Issue: "No traces visible"

**Cause:** Traces not generated or not processed yet

**Solution:**
```bash
# Generate more traffic
for i in {1..10}; do
  curl http://localhost:3000/api/users
done

# Wait for processing
sleep 15

# Check OTel Collector
docker-compose logs otel-collector | grep -i trace

# Retest
./scripts/smoke-tests.sh
```

### Issue: "Grafana datasources not found"

**Cause:** Provisioning failed or Grafana not fully started

**Solution:**
```bash
# Restart Grafana
docker-compose restart grafana

# Wait for startup
sleep 20

# Check provisioning logs
docker-compose logs grafana | grep -i provision

# Retest
./scripts/smoke-tests.sh
```

### Issue: "Permission denied" (Linux/Mac)

**Cause:** Script not executable

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Retest
./scripts/smoke-tests.sh
```

---

## Best Practices

### 1. Always Wait After Deployment
```bash
docker-compose up -d
sleep 60  # Give services time to initialize
./scripts/smoke-tests.sh
```

### 2. Check Logs on Failure
```bash
if ! ./scripts/smoke-tests.sh; then
  docker-compose logs
fi
```

### 3. Use Appropriate Script
- **Development:** `smoke-tests.sh` (detailed output)
- **CI/CD:** `ci-smoke-tests.sh` (optimized)
- **Quick check:** Manual curl commands

### 4. Monitor Trends
```bash
# Log results over time
./scripts/smoke-tests.sh >> smoke-tests-$(date +%Y%m%d).log
```

### 5. Automate in CI/CD
Always run smoke tests after deployment before promoting to production.

---

## Quick Reference

### Commands Cheat Sheet

```bash
# Start services
docker-compose up -d

# Run smoke tests (Linux/Mac)
./scripts/smoke-tests.sh

# Run smoke tests (Windows)
.\scripts\smoke-tests.ps1

# Run CI smoke tests
./scripts/ci-smoke-tests.sh

# Check container status
docker-compose ps

# View logs
docker-compose logs <service>

# Restart service
docker-compose restart <service>

# Stop all services
docker-compose down

# Full reset
docker-compose down -v && docker-compose up -d
```

### Port Reference

| Service | Port | Health Endpoint |
|---------|------|----------------|
| Demo App | 3000 | /health, /ready |
| Grafana | 3001 | /api/health |
| Tempo | 3200 | /ready |
| OTel Collector | 4317, 4318 | N/A |
| Prometheus | 9090 | /-/healthy |

---

## Additional Resources

- [Smoke Tests README](SMOKE_TESTS_README.md) - Comprehensive documentation
- [Quick Start Guide](QUICK_START_SMOKE_TESTS.md) - Quick reference
- [CI/CD Implementation](../CI-CD-IMPLEMENTATION.md) - Full CI/CD docs
- [Task 8.4 Summary](../TASK-8.4-SMOKE-TESTS-SUMMARY.md) - Implementation details

---

**Last Updated:** 2025-10-04  
**Version:** 1.0  
**Maintained by:** DevOps Team
