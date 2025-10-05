# Integration Tests for OpenTelemetry Collector

This document describes the integration tests for the OpenTelemetry Collector and how to run them.

## Overview

The integration tests verify the complete telemetry pipeline:
1. Demo App → OpenTelemetry Collector (OTLP)
2. Collector → Prometheus (Metrics)
3. Collector → Tempo (Traces)

## Requirements

- Docker and Docker Compose installed
- All services running (demo-app, otel-collector, prometheus, tempo)
- Node.js and npm installed

## Running the Tests

### 1. Start all services with Docker Compose

From the project root directory:

```bash
# Docker Compose V2 (Docker Desktop)
docker compose up -d

# OR Docker Compose V1 (standalone)
docker-compose up -d
```

Wait for all services to be healthy (about 30-60 seconds):

```bash
# Docker Compose V2
docker compose ps

# OR Docker Compose V1
docker-compose ps
```

### 2. Run the integration tests

From the demo-app directory:

```bash
npm run test:integration
```

Or from the project root:

```bash
cd demo-app
npm run test:integration
```

### 3. Run with custom service URLs

If your services are running on different ports or hosts:

```bash
DEMO_APP_URL=http://localhost:3000 \
COLLECTOR_PROMETHEUS_URL=http://localhost:8889 \
PROMETHEUS_URL=http://localhost:9090 \
TEMPO_URL=http://localhost:3200 \
npm run test:integration
```

## Test Coverage

### Test Suite 1: Collector receives OTLP data from demo app
- ✓ Verifies collector receives metrics via OTLP
- ✓ Verifies collector receives traces via OTLP
- ✓ Checks collector's internal metrics for received data

### Test Suite 2: Metrics are exported to Prometheus format
- ✓ Verifies metrics endpoint exposes Prometheus format
- ✓ Verifies application metrics are available in Prometheus
- ✓ Verifies custom business metrics are exported

### Test Suite 3: Traces are forwarded to Tempo
- ✓ Verifies traces are forwarded to Tempo backend
- ✓ Verifies trace context and spans are preserved
- ✓ Verifies error traces are handled correctly

### Test Suite 4: End-to-end telemetry pipeline
- ✓ Verifies complete pipeline from app to storage backends
- ✓ Tests with diverse traffic patterns (success, errors, etc.)

## Troubleshooting

### Services not ready
If tests fail with connection errors, ensure all services are healthy:

```bash
# Check service status
docker compose ps  # or: docker-compose ps

# Check logs
docker compose logs otel-collector  # or: docker-compose logs otel-collector
docker compose logs prometheus      # or: docker-compose logs prometheus
docker compose logs tempo           # or: docker-compose logs tempo
```

### Timeout errors
Integration tests have built-in retries and waits. If you still see timeouts:
- Increase the timeout values in the test file
- Check if services are under heavy load
- Verify network connectivity between containers

### No metrics/traces found
If tests pass but no data is found:
- Check collector logs: `docker compose logs otel-collector`
- Verify collector configuration: `cat otel-collector/otel-collector-config.yaml`
- Check Prometheus targets: http://localhost:9090/targets
- Verify demo app is sending telemetry: `docker compose logs demo-app`

## CI/CD Integration

To run these tests in CI/CD:

```yaml
# Example GitHub Actions workflow
- name: Start services
  run: docker compose up -d

- name: Wait for services
  run: sleep 30

- name: Run integration tests
  run: |
    cd demo-app
    npm run test:integration

- name: Stop services
  run: docker compose down
```

## Requirements Mapping

These tests verify the following requirements:
- **Requirement 1.3**: OpenTelemetry SDK sends metrics and traces to Collector
- **Requirement 2.1**: Collector exports metrics to Prometheus
- **Requirement 3.1**: Collector exports traces to Tempo

## Notes

- Tests run sequentially (`--runInBand`) to avoid race conditions
- Each test generates traffic and waits for data propagation
- Tests use polling with timeouts to handle async data processing
- All tests are idempotent and can be run multiple times
