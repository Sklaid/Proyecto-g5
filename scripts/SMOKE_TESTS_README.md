# Smoke Tests Documentation

## Overview

Smoke tests are critical post-deployment validation tests that ensure the observability platform is functioning correctly. These tests verify that all components are healthy, communicating properly, and collecting telemetry data.

## Test Scripts

### 1. `smoke-tests.sh` / `smoke-tests.ps1`
**Purpose:** Comprehensive smoke tests for local development and manual validation.

**Features:**
- Detailed output with color-coded results
- Retry logic for flaky endpoints
- Container status verification
- Comprehensive metrics and trace validation
- Dashboard accessibility checks

**Usage:**
```bash
# Linux/Mac
./scripts/smoke-tests.sh

# Windows PowerShell
.\scripts\smoke-tests.ps1
```

### 2. `ci-smoke-tests.sh`
**Purpose:** Streamlined smoke tests optimized for CI/CD pipelines.

**Features:**
- Fast execution with appropriate timeouts
- Clear pass/fail status for CI integration
- Focused on critical functionality
- Minimal dependencies

**Usage:**
```bash
# In CI/CD pipeline
chmod +x scripts/ci-smoke-tests.sh
./scripts/ci-smoke-tests.sh
```

## Test Categories

### 1. Health Checks ✅
**Requirement:** 9.2 - Validate service health endpoints

Tests that all services are running and responding to health checks:
- **Demo App Health** (`/health`) - Application is alive
- **Demo App Ready** (`/ready`) - Application is ready to serve traffic
- **Prometheus Health** (`/-/healthy`) - Prometheus is operational
- **Grafana Health** (`/api/health`) - Grafana is operational
- **Tempo Ready** (`/ready`) - Tempo is ready to receive traces

**Why it matters:** If any service fails health checks, the entire observability pipeline may be compromised.

### 2. Metrics Validation 📊
**Requirement:** 9.2 - Test metrics are being reported to Prometheus

Tests that metrics are being collected and stored:
- **Prometheus Collection** - Verifies Prometheus is scraping targets
- **Demo App Metrics** - Confirms application metrics are being reported
- **OTel Collector Metrics** - Validates collector is processing telemetry

**Queries tested:**
```promql
# Check if targets are up
up

# Check application metrics
http_server_requests_total

# Check OTel Collector metrics
otelcol_receiver_accepted_spans
```

**Why it matters:** Without metrics, we cannot monitor SLIs, SLOs, or detect anomalies.

### 3. Trace Validation 🔍
**Requirement:** 9.3 - Test at least one trace is visible in Tempo

Tests that distributed tracing is working:
- **Traffic Generation** - Creates sample requests to generate traces
- **Trace Processing** - Verifies traces are being sent to Tempo
- **Trace Storage** - Confirms traces are queryable in Tempo

**Test flow:**
1. Generate HTTP requests to demo app endpoints
2. Wait for traces to be processed (10 seconds)
3. Query Tempo API to verify traces exist
4. Validate trace API responds with 200 status

**Why it matters:** Traces are essential for debugging distributed systems and understanding request flows.

### 4. Grafana Dashboards 📈
**Requirement:** 9.3 - Test Grafana dashboards are accessible

Tests that visualization layer is functional:
- **Datasource Configuration** - Verifies Prometheus and Tempo datasources
- **Dashboard Accessibility** - Confirms dashboards are loaded
- **API Connectivity** - Tests Grafana API is responding

**Checks performed:**
```bash
# Check datasources
GET /api/datasources
# Expected: Prometheus and Tempo datasources present

# Check dashboards
GET /api/search?type=dash-db
# Expected: At least one dashboard found
```

**Why it matters:** Dashboards are the primary interface for SREs to monitor system health and investigate issues.

### 5. Container Status 🐳
**Requirement:** 6.1, 6.2 - Validate Docker Compose deployment

Tests that all required containers are running:
- demo-app
- otel-collector
- prometheus
- tempo
- grafana
- anomaly-detector

**Why it matters:** Missing containers indicate deployment failures that will cause observability gaps.

## Exit Codes

- **0** - All tests passed successfully
- **1** - One or more tests failed

## Integration with CI/CD

### GitHub Actions Integration

The smoke tests are integrated into the deployment workflow (`.github/workflows/deploy.yml`):

```yaml
- name: Run smoke tests
  id: smoke-tests
  run: |
    chmod +x scripts/ci-smoke-tests.sh
    ./scripts/ci-smoke-tests.sh

- name: Rollback on failure
  if: failure() && steps.smoke-tests.outcome == 'failure'
  run: |
    echo "Deployment failed! Rolling back..."
    # Rollback logic here
```

### Rollback Mechanism

If smoke tests fail:
1. Current deployment is stopped
2. Previous stable images are pulled
3. System is redeployed with stable version
4. Deployment is marked as failed

## Troubleshooting

### Common Issues

#### 1. Health checks failing
**Symptom:** Services not responding to health endpoints

**Solutions:**
- Check if containers are running: `docker-compose ps`
- Check container logs: `docker-compose logs <service>`
- Verify network connectivity: `docker network inspect proyecto-g5_observability-network`

#### 2. Metrics not found
**Symptom:** Prometheus queries return no data

**Solutions:**
- Wait longer for metrics to be collected (initial scrape interval)
- Check OTel Collector logs: `docker-compose logs otel-collector`
- Verify Prometheus scrape config: `curl http://localhost:9090/api/v1/targets`
- Check demo app is generating traffic

#### 3. Traces not visible
**Symptom:** Tempo has no traces

**Solutions:**
- Generate more traffic to create traces
- Check OTel Collector is forwarding traces: `docker-compose logs otel-collector`
- Verify Tempo configuration: `docker-compose logs tempo`
- Check trace sampling rate (may be sampling out traces)

#### 4. Grafana datasources not configured
**Symptom:** Datasources not found in Grafana

**Solutions:**
- Check Grafana provisioning: `docker-compose logs grafana`
- Verify provisioning files are mounted: `docker-compose config`
- Restart Grafana: `docker-compose restart grafana`

## Best Practices

### When to Run Smoke Tests

1. **After deployment** - Always run after deploying to any environment
2. **Before promoting to production** - Validate staging environment
3. **After configuration changes** - Verify changes didn't break functionality
4. **During troubleshooting** - Identify which components are failing

### Test Timing

- **Health checks:** Retry with 5-10 second delays (services need startup time)
- **Metrics validation:** Wait 15+ seconds for initial scrape
- **Trace validation:** Wait 10+ seconds for trace processing
- **Total runtime:** Expect 1-2 minutes for complete test suite

### Interpreting Results

- **All green (✓):** System is healthy, ready for use
- **Yellow warnings (⚠):** Non-critical issues, may be timing-related
- **Red failures (✗):** Critical issues, deployment should be rolled back

## Extending the Tests

To add new smoke tests:

1. **Identify critical functionality** - What must work for the system to be usable?
2. **Add test function** - Create a new test in the appropriate category
3. **Set appropriate timeouts** - Balance speed vs. reliability
4. **Update documentation** - Document what the test validates and why

Example:
```bash
# Test anomaly detector is running
test_endpoint "http://localhost:8080/health" "Anomaly Detector Health" 3 5
```

## Related Documentation

- [CI/CD Pipeline Documentation](../CI-CD-IMPLEMENTATION.md)
- [Deployment Guide](../DEPLOYMENT_STATUS.md)
- [Quick Start Guide](../QUICK-START-CI-CD.md)
- [Grafana Setup](../GRAFANA_QUICK_START.md)

## Requirements Mapping

| Test Category | Requirements | Description |
|--------------|-------------|-------------|
| Health Checks | 9.2 | Validate all service endpoints |
| Metrics Validation | 9.2 | Verify metrics collection |
| Trace Validation | 9.3 | Confirm trace storage |
| Grafana Dashboards | 9.3 | Test dashboard accessibility |
| Container Status | 6.1, 6.2 | Validate deployment |

## Maintenance

### Updating Tests

When adding new services or changing endpoints:
1. Update both `smoke-tests.sh` and `smoke-tests.ps1`
2. Update `ci-smoke-tests.sh` for CI integration
3. Update this documentation
4. Test locally before committing

### Version History

- **v1.0** - Initial implementation with core smoke tests
- **v1.1** - Added CI-specific streamlined version
- **v1.2** - Enhanced retry logic and error reporting
