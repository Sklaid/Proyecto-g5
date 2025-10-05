# Integration Tests Validation Checklist

Use this checklist to verify the integration tests are working correctly.

## Pre-Test Checklist

- [ ] Docker is installed and running
- [ ] Docker Compose is installed
- [ ] Ports 3000, 3001, 4317, 4318, 8889, 9090, 3200 are available
- [ ] At least 4GB RAM available
- [ ] Node.js and npm are installed (for running tests)

## Service Startup Checklist

```bash
docker-compose up -d
```

- [ ] demo-app container is running
- [ ] otel-collector container is running
- [ ] prometheus container is running
- [ ] tempo container is running
- [ ] grafana container is running
- [ ] All containers show "healthy" status (wait 30-60 seconds)

Verify with:
```bash
docker-compose ps
```

## Manual Service Verification

### Demo App (Port 3000)
```bash
curl http://localhost:3000/health
```
- [ ] Returns 200 OK with JSON response

### OTel Collector (Port 8889)
```bash
curl http://localhost:8889/metrics
```
- [ ] Returns 200 OK with Prometheus metrics format
- [ ] Contains `otelcol_` metrics

### Prometheus (Port 9090)
```bash
curl http://localhost:9090/-/healthy
```
- [ ] Returns 200 OK
- [ ] Web UI accessible at http://localhost:9090

### Tempo (Port 3200)
```bash
curl http://localhost:3200/ready
```
- [ ] Returns 200 OK

## Test Execution Checklist

### Run Integration Tests
```bash
cd demo-app
npm run test:integration
```

### Expected Test Results

#### Suite 1: Collector receives OTLP data
- [ ] ✓ should receive metrics from demo app via OTLP
- [ ] ✓ should receive traces from demo app via OTLP

#### Suite 2: Metrics exported to Prometheus
- [ ] ✓ should expose metrics in Prometheus format on port 8889
- [ ] ✓ should export application metrics to Prometheus
- [ ] ✓ should export custom business metrics

#### Suite 3: Traces forwarded to Tempo
- [ ] ✓ should forward traces to Tempo backend
- [ ] ✓ should preserve trace context and spans
- [ ] ✓ should handle error traces correctly

#### Suite 4: End-to-end pipeline
- [ ] ✓ should process telemetry through the complete pipeline

### Overall Test Results
- [ ] All tests passed (0 failures)
- [ ] No timeout errors
- [ ] No connection errors
- [ ] Test execution time < 2 minutes

## Post-Test Verification

### Verify Data in Prometheus
1. Open http://localhost:9090
2. Go to "Status" → "Targets"
   - [ ] otel-collector target is UP
3. Execute query: `http_server_request_duration_milliseconds_count`
   - [ ] Returns results with demo-app metrics

### Verify Data in Tempo
1. Open http://localhost:3200/api/search?tags=service.name=demo-app&limit=10
   - [ ] Returns JSON with traces array
   - [ ] Traces have valid traceID fields

### Verify in Grafana (Optional)
1. Open http://localhost:3001 (admin/admin)
2. Go to Explore
3. Select Prometheus datasource
   - [ ] Can query metrics
4. Select Tempo datasource
   - [ ] Can search traces

## Troubleshooting Checklist

### If tests fail with connection errors:
- [ ] Check all services are running: `docker-compose ps`
- [ ] Check service logs: `docker-compose logs <service-name>`
- [ ] Verify ports are not blocked by firewall
- [ ] Wait longer for services to be ready (try 60 seconds)

### If tests fail with timeout errors:
- [ ] Increase timeout values in test file
- [ ] Check system resources (CPU, memory)
- [ ] Verify network connectivity between containers
- [ ] Check Docker network: `docker network ls`

### If no metrics found in Prometheus:
- [ ] Check Prometheus targets: http://localhost:9090/targets
- [ ] Verify collector is exporting: `docker-compose logs otel-collector`
- [ ] Check demo app is sending data: `docker-compose logs demo-app`
- [ ] Verify prometheus.yml configuration

### If no traces found in Tempo:
- [ ] Check Tempo logs: `docker-compose logs tempo`
- [ ] Verify collector trace pipeline: `docker-compose logs otel-collector`
- [ ] Check tempo.yaml configuration
- [ ] Generate more traffic: `curl http://localhost:3000/api/users`

## Cleanup Checklist

### Stop services (keep data):
```bash
docker-compose stop
```
- [ ] All containers stopped

### Stop and remove services (remove data):
```bash
docker-compose down -v
```
- [ ] All containers removed
- [ ] All volumes removed

## Success Criteria

✅ All integration tests pass  
✅ All services are healthy  
✅ Metrics visible in Prometheus  
✅ Traces visible in Tempo  
✅ No errors in service logs  
✅ Test execution completes in < 2 minutes  

## Notes

- Tests should be run in a clean environment for best results
- If tests fail, check logs before re-running
- Tests are idempotent and can be run multiple times
- For CI/CD, use the automated scripts (run-integration-tests.bat/sh)

## Date Tested: _______________
## Tested By: _______________
## Result: ☐ PASS  ☐ FAIL
## Notes: _______________________________________________
