# Quick Start - Smoke Tests

## Prerequisites

Before running smoke tests, ensure:
1. Docker and Docker Compose are installed
2. All services are deployed: `docker-compose up -d`
3. Wait 30-60 seconds for services to fully start

## Running Smoke Tests

### Option 1: Linux/Mac (Bash)
```bash
# Make script executable (first time only)
chmod +x scripts/smoke-tests.sh

# Run tests
./scripts/smoke-tests.sh
```

### Option 2: Windows (PowerShell)
```powershell
# Run tests
.\scripts\smoke-tests.ps1
```

### Option 3: CI/CD Version (Faster)
```bash
# Make script executable (first time only)
chmod +x scripts/ci-smoke-tests.sh

# Run tests
./scripts/ci-smoke-tests.sh
```

## Expected Output

### ✅ Success
```
🧪 Running CI/CD Smoke Tests...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Health Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Demo App Health - OK
✓ Demo App Ready - OK
✓ Prometheus Health - OK
✓ Grafana Health - OK
✓ Tempo Ready - OK

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. Metrics Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Prometheus is collecting metrics
✓ Demo app is reporting metrics to Prometheus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. Trace Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Test traffic generated
✓ At least one trace is visible in Tempo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. Grafana Dashboards
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Prometheus datasource is configured
✓ Tempo datasource is configured
✓ Grafana dashboards are accessible (3 found)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Smoke Tests Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All smoke tests passed!
The system is ready for use.
```

### ❌ Failure
```
✗ Demo App Health - FAILED
✗ Prometheus Health - FAILED

❌ Some smoke tests failed!
Check the logs above for details.
```

## What Each Test Validates

| Test | Validates | Requirement |
|------|-----------|-------------|
| **Health Checks** | All services are running and responding | 9.2 |
| **Metrics Validation** | Metrics are being collected in Prometheus | 9.2 |
| **Trace Validation** | Traces are being stored in Tempo | 9.3 |
| **Grafana Dashboards** | Dashboards and datasources are accessible | 9.3 |

## Troubleshooting

### Services not starting
```bash
# Check container status
docker-compose ps

# View logs for specific service
docker-compose logs demo-app
docker-compose logs prometheus
docker-compose logs tempo
```

### Tests timing out
```bash
# Restart all services
docker-compose restart

# Wait longer before running tests
sleep 60
./scripts/smoke-tests.sh
```

### Metrics not found
```bash
# Generate some traffic first
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products

# Wait for scrape interval
sleep 20

# Run tests again
./scripts/smoke-tests.sh
```

## Integration with CI/CD

These smoke tests run automatically in GitHub Actions after deployment:

```yaml
# .github/workflows/deploy.yml
- name: Run smoke tests
  run: ./scripts/ci-smoke-tests.sh
```

If tests fail, the deployment is automatically rolled back.

## Next Steps

After smoke tests pass:
1. ✅ Access Grafana: http://localhost:3001 (admin/admin)
2. ✅ View dashboards and metrics
3. ✅ Generate traffic: `./generate-traffic.bat`
4. ✅ Monitor SLIs and SLOs

## More Information

- Full documentation: [SMOKE_TESTS_README.md](./SMOKE_TESTS_README.md)
- CI/CD guide: [../QUICK-START-CI-CD.md](../QUICK-START-CI-CD.md)
- Deployment status: [../DEPLOYMENT_STATUS.md](../DEPLOYMENT_STATUS.md)
