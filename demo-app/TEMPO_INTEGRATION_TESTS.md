# Tempo Integration Tests

This document describes the integration tests for Tempo trace storage and how to run them.

## Overview

The Tempo integration tests verify that:
1. Traces are successfully stored in Tempo
2. Trace query API returns expected results
3. Trace retention policy is configured correctly
4. Tempo service maintains health and availability

## Requirements

- Docker and Docker Compose installed
- All services running via `docker-compose up`
- Node.js and npm installed

## Test Coverage

### Test Suite 1: Traces are successfully stored in Tempo
- **Test 1.1**: Store traces from demo app requests
- **Test 1.2**: Store traces with complete span information
- **Test 1.3**: Store error traces with error information
- **Test 1.4**: Handle high volume of traces

### Test Suite 2: Trace query API returns expected results
- **Test 2.1**: Search traces by service name
- **Test 2.2**: Retrieve trace by trace ID
- **Test 2.3**: Support time range queries
- **Test 2.4**: Limit search results correctly
- **Test 2.5**: Return 404 for non-existent trace ID
- **Test 2.6**: Handle concurrent queries efficiently

### Test Suite 3: Trace retention policy
- **Test 3.1**: Have retention policy configured (14 days)
- **Test 3.2**: Store traces with timestamp metadata
- **Test 3.3**: Maintain trace data integrity over time
- **Test 3.4**: Handle storage efficiently

### Test Suite 4: Tempo service health and availability
- **Test 4.1**: Respond to health check endpoint
- **Test 4.2**: Handle malformed queries gracefully
- **Test 4.3**: Maintain availability under load

## Running the Tests

### Step 1: Start the Docker Compose Stack

From the project root directory:

```bash
docker-compose up -d
```

Wait for all services to be healthy (approximately 30-60 seconds):

```bash
docker-compose ps
```

All services should show status as "healthy".

### Step 2: Run the Tempo Integration Tests

From the `demo-app` directory:

```bash
cd demo-app
npm run test:integration -- tempo.integration.test.js
```

Or from the project root:

```bash
cd demo-app && npm run test:integration -- tempo.integration.test.js
```

### Step 3: View Test Results

The tests will output detailed results showing:
- Number of tests passed/failed
- Execution time for each test
- Any error messages or failures

## Expected Output

When all tests pass, you should see output similar to:

```
PASS  src/tempo.integration.test.js
  Tempo Trace Storage Integration Tests
    Test 1: Traces are successfully stored in Tempo
      ✓ should store traces from demo app requests (5234ms)
      ✓ should store traces with complete span information (4123ms)
      ✓ should store error traces with error information (3456ms)
      ✓ should handle high volume of traces (8765ms)
    Test 2: Trace query API returns expected results
      ✓ should search traces by service name (3234ms)
      ✓ should retrieve trace by trace ID (4567ms)
      ✓ should support time range queries (2345ms)
      ✓ should limit search results correctly (6789ms)
      ✓ should return 404 for non-existent trace ID (1234ms)
      ✓ should handle concurrent queries efficiently (4567ms)
    Test 3: Trace retention policy
      ✓ should have retention policy configured (5678ms)
      ✓ should store traces with timestamp metadata (3456ms)
      ✓ should maintain trace data integrity over time (4567ms)
      ✓ should handle storage efficiently (8901ms)
    Test 4: Tempo service health and availability
      ✓ should respond to health check endpoint (1234ms)
      ✓ should handle malformed queries gracefully (2345ms)
      ✓ should maintain availability under load (9876ms)

Test Suites: 1 passed, 1 total
Tests:       17 passed, 17 total
```

## Troubleshooting

### Services Not Ready

If tests fail with "Timeout waiting for condition":

1. Check that all services are running:
   ```bash
   docker-compose ps
   ```

2. Check service logs:
   ```bash
   docker-compose logs tempo
   docker-compose logs demo-app
   ```

3. Verify Tempo is accessible:
   ```bash
   curl http://localhost:3200/ready
   ```

4. Verify demo app is accessible:
   ```bash
   curl http://localhost:3000/health
   ```

### Port Conflicts

If services fail to start due to port conflicts:

1. Check what's using the ports:
   ```bash
   # Windows
   netstat -ano | findstr :3200
   netstat -ano | findstr :3000
   
   # Linux/Mac
   lsof -i :3200
   lsof -i :3000
   ```

2. Stop conflicting services or modify `docker-compose.yml` to use different ports

### Tempo Not Storing Traces

If traces aren't being stored:

1. Check OTel Collector is forwarding traces:
   ```bash
   curl http://localhost:8889/metrics | grep otelcol_exporter
   ```

2. Check Tempo logs for errors:
   ```bash
   docker-compose logs tempo | grep -i error
   ```

3. Verify network connectivity:
   ```bash
   docker-compose exec demo-app ping tempo
   ```

### Test Timeouts

If tests timeout but services are running:

1. Increase wait times in the test file
2. Check system resources (CPU, memory)
3. Reduce concurrent test load

## Environment Variables

You can customize the test endpoints using environment variables:

```bash
# Windows PowerShell
$env:DEMO_APP_URL="http://localhost:3000"
$env:TEMPO_URL="http://localhost:3200"
npm run test:integration -- tempo.integration.test.js

# Linux/Mac
DEMO_APP_URL=http://localhost:3000 TEMPO_URL=http://localhost:3200 npm run test:integration -- tempo.integration.test.js
```

## CI/CD Integration

To run these tests in CI/CD:

```yaml
# Example GitHub Actions workflow
- name: Start services
  run: docker-compose up -d

- name: Wait for services
  run: |
    timeout 60 bash -c 'until curl -f http://localhost:3200/ready; do sleep 2; done'
    timeout 60 bash -c 'until curl -f http://localhost:3000/health; do sleep 2; done'

- name: Run Tempo integration tests
  run: |
    cd demo-app
    npm run test:integration -- tempo.integration.test.js

- name: Stop services
  run: docker-compose down
```

## Requirements Mapping

These tests verify the following requirements from the spec:

- **Requirement 3.1**: Distributed tracing with Tempo
  - Tests verify traces are stored and queryable
  
- **Requirement 3.2**: Trace visualization and analysis
  - Tests verify trace query API functionality
  
- **Requirement 3.3**: Trace retention and storage
  - Tests verify retention policy and data integrity

## Related Documentation

- [Integration Tests Overview](./INTEGRATION_TESTS.md)
- [Quick Start Guide](./QUICK_START_TESTS.md)
- [Collector Integration Tests](./src/collector.integration.test.js)
- [Tempo Configuration](../tempo/tempo.yaml)
