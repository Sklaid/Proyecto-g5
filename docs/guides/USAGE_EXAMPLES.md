# Usage Examples and Scripts Guide

This guide provides practical examples and scripts for testing, demonstrating, and operating the AIOps & SRE Observability Platform.

## 📋 Table of Contents

- [Traffic Generation Scripts](#traffic-generation-scripts)
- [Error Simulation Scripts](#error-simulation-scripts)
- [Dashboard Access Scripts](#dashboard-access-scripts)
- [Verification Scripts](#verification-scripts)
- [Anomaly Testing](#anomaly-testing)
- [Complete Demo Scenarios](#complete-demo-scenarios)
- [Interpreting Results](#interpreting-results)

---

## 🚦 Traffic Generation Scripts

### 1. Generate Continuous Normal Traffic

**Purpose:** Create steady baseline traffic to populate metrics and traces

**Windows PowerShell:**
```powershell
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

**Parameters:**
- `-DurationSeconds`: How long to generate traffic (default: 60)
- `-RequestsPerSecond`: Rate of requests (default: 5)

**What it does:**
- Sends GET requests to `/api/users` and `/api/products`
- Alternates between endpoints
- Creates metrics and traces in the system
- Shows progress with request count and status codes

**Example output:**
```
Starting traffic generation...
Duration: 60 seconds
Rate: 5 requests/second
Target: http://localhost:3000

[1/300] GET /api/users - Status: 200 OK
[2/300] GET /api/products - Status: 200 OK
...
Traffic generation completed!
Total requests: 300
```

**When to use:**
- Initial system testing
- Creating baseline metrics
- Populating dashboards with data
- Load testing

### 2. Generate Mixed Traffic (Normal + Errors)

**Purpose:** Simulate realistic traffic with some errors

**Windows PowerShell:**
```powershell
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -ErrorRatePercent 15
```

**Parameters:**
- `-DurationSeconds`: How long to generate traffic (default: 60)
- `-ErrorRatePercent`: Percentage of requests that should error (default: 10)

**What it does:**
- Sends mix of successful and error requests
- Randomly triggers 404 and 500 errors
- Simulates real-world traffic patterns
- Useful for testing error tracking

**Example output:**
```
Starting mixed traffic generation...
Duration: 60 seconds
Error rate: 15%
Target: http://localhost:3000

[1/300] GET /api/users - Status: 200 OK
[2/300] GET /api/error/500 - Status: 500 Internal Server Error
[3/300] GET /api/products - Status: 200 OK
[4/300] GET /api/users/999 - Status: 404 Not Found
...
Summary:
- Total requests: 300
- Successful: 255 (85%)
- Errors: 45 (15%)
```

**When to use:**
- Testing error tracking
- Validating error budget calculations
- Testing SLO alerts
- Realistic load testing

### 3. Quick Traffic Batch

**Windows Batch:**
```cmd
generate-traffic.bat
```

**What it does:**
- Sends 10 quick requests to various endpoints
- Fast way to generate some data
- No parameters needed

**When to use:**
- Quick testing
- Verifying system is working
- Creating a few traces

---

## ❌ Error Simulation Scripts

### 1. Generate Test Errors

**Purpose:** Intentionally trigger errors to test error tracking and alerting

**Windows PowerShell:**
```powershell
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1
```

**Parameters:**
- `-ErrorCount`: Number of errors to generate (default: 10)
- `-DelaySeconds`: Delay between errors (default: 1)

**What it does:**
- Sends requests to error endpoints
- Triggers 500 Internal Server Errors
- Triggers 404 Not Found errors
- Creates error traces in Tempo

**Example output:**
```
Generating 10 test errors...
Delay between errors: 1 second

[1/10] Triggering 500 error... Status: 500
[2/10] Triggering 404 error... Status: 404
[3/10] Triggering 500 error... Status: 500
...
Error generation completed!
Total errors generated: 10
```

**When to use:**
- Testing error rate alerts
- Validating error budget consumption
- Testing anomaly detection
- Verifying error traces in Tempo

### 2. Trigger Anomaly Conditions

**Purpose:** Create unusual patterns to test anomaly detection

**Windows PowerShell:**
```powershell
# Spike in error rate
.\generate-test-errors.ps1 -ErrorCount 50 -DelaySeconds 0.1

# Sudden traffic increase
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 20

# Latency spike (use slow endpoint)
for ($i=1; $i -le 20; $i++) {
    Invoke-WebRequest -Uri "http://localhost:3000/api/error/timeout" -TimeoutSec 10
}
```

**What it does:**
- Creates abnormal patterns in metrics
- Triggers anomaly detector
- Tests ML-based detection
- Validates anomaly alerts

**When to use:**
- Testing anomaly detection
- Validating ML algorithms
- Demonstrating AIOps capabilities
- Testing alert thresholds

---

## 🖥️ Dashboard Access Scripts

### 1. Open All Dashboards

**Windows Batch:**
```cmd
open-all-dashboards.bat
```

**What it does:**
- Opens all three Grafana dashboards in your default browser
- SLI/SLO Dashboard
- Application Performance Dashboard
- Distributed Tracing Dashboard

**When to use:**
- Quick access to all dashboards
- Demos and presentations
- Monitoring sessions

### 2. Open Grafana

**Windows Batch:**
```cmd
open-grafana.bat
```

**What it does:**
- Opens Grafana home page
- URL: http://localhost:3001

### 3. Open Tempo Explore

**Windows Batch:**
```cmd
open-tempo-explore.bat
```

**What it does:**
- Opens Grafana Explore with Tempo datasource
- Ready to query traces
- URL: http://localhost:3001/explore

**Useful queries:**
- `{status=error}` - Find error traces
- `{service.name="demo-app"}` - Filter by service
- `{http.status_code="500"}` - Find 500 errors

---

## ✅ Verification Scripts

### 1. Verify Error Rate

**Windows PowerShell:**
```powershell
.\verify-error-rate.ps1
```

**What it does:**
- Queries Prometheus for current error rate
- Shows error rate percentage
- Compares against SLO threshold (1%)

**Example output:**
```
Querying Prometheus for error rate...
Current error rate: 0.5%
SLO threshold: 1.0%
Status: ✓ Within SLO
```

### 2. Verify Dashboards

**Windows PowerShell:**
```powershell
.\verify-dashboards.ps1
```

**What it does:**
- Checks if all dashboards are accessible
- Verifies datasources are connected
- Tests Grafana API

**Example output:**
```
Checking Grafana health...
✓ Grafana is healthy

Checking datasources...
✓ Prometheus datasource: OK
✓ Tempo datasource: OK

Checking dashboards...
✓ SLI/SLO Dashboard: Found
✓ Application Performance Dashboard: Found
✓ Distributed Tracing Dashboard: Found

All checks passed!
```

### 3. List Available Metrics

**Windows PowerShell:**
```powershell
.\list-available-metrics.ps1
```

**What it does:**
- Queries Prometheus for all available metrics
- Shows metric names and types
- Useful for debugging

**Example output:**
```
Querying Prometheus for available metrics...

HTTP Metrics:
- http_server_duration_milliseconds
- http_server_duration_milliseconds_bucket
- http_server_duration_milliseconds_count

Node.js Metrics:
- nodejs_process_cpu_seconds_total
- nodejs_process_resident_memory_bytes
- nodejs_process_heap_bytes
...
```

### 4. Diagnose Telemetry Pipeline

**Windows Batch:**
```cmd
diagnose-telemetry.bat
```

**What it does:**
- Checks all services are running
- Verifies metrics are flowing
- Tests trace collection
- Comprehensive health check

---

## 🧪 Anomaly Testing

### Test Scenario 1: Error Rate Spike

**Objective:** Trigger anomaly detection with sudden error increase

**Steps:**
```powershell
# 1. Establish baseline (2 minutes of normal traffic)
.\generate-continuous-traffic.ps1 -DurationSeconds 120 -RequestsPerSecond 5

# 2. Wait 30 seconds
Start-Sleep -Seconds 30

# 3. Generate error spike
.\generate-test-errors.ps1 -ErrorCount 50 -DelaySeconds 0.5

# 4. Check anomaly detector logs
docker-compose logs anomaly-detector | Select-String "anomaly"

# 5. Check Grafana for anomaly alerts
```

**Expected result:**
- Anomaly detector identifies unusual error pattern
- Alert generated with confidence score
- Visible in Grafana alerts

### Test Scenario 2: Latency Spike

**Objective:** Detect unusual latency patterns

**Steps:**
```powershell
# 1. Normal traffic baseline
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# 2. Trigger slow requests
for ($i=1; $i -le 30; $i++) {
    Invoke-WebRequest -Uri "http://localhost:3000/api/error/timeout" -TimeoutSec 10 -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
}

# 3. Check latency metrics in Grafana
# Open: http://localhost:3001/d/slo-dashboard
```

**Expected result:**
- P95/P99 latency spikes visible
- Latency SLO alert may trigger
- Anomaly detector may flag unusual pattern

### Test Scenario 3: Traffic Pattern Change

**Objective:** Detect sudden traffic increase

**Steps:**
```powershell
# 1. Low baseline traffic (1 minute)
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 2

# 2. Sudden traffic increase
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 20

# 3. Monitor throughput in Application Performance Dashboard
```

**Expected result:**
- Request rate increases 10x
- Visible in throughput panels
- May trigger resource utilization alerts

---

## 🎬 Complete Demo Scenarios

### Demo 1: Happy Path (5 minutes)

**Objective:** Show system working normally

```powershell
# 1. Start the platform
docker-compose up -d

# 2. Wait for services to be ready
Start-Sleep -Seconds 30

# 3. Generate normal traffic
.\generate-continuous-traffic.ps1 -DurationSeconds 120 -RequestsPerSecond 5

# 4. Open dashboards
.\open-all-dashboards.bat

# 5. Show metrics in Grafana
# - SLI/SLO Dashboard: Success rate ~100%, low latency
# - Application Performance: Steady throughput, no errors
# - Distributed Tracing: Clean traces, no errors
```

**Key points to highlight:**
- ✅ Success rate at 100%
- ✅ Latency P95 < 200ms
- ✅ Error budget not being consumed
- ✅ All services healthy

### Demo 2: Error Scenario (10 minutes)

**Objective:** Show error detection and tracking

```powershell
# 1. Establish baseline
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# 2. Introduce errors
.\generate-mixed-traffic.ps1 -DurationSeconds 120 -ErrorRatePercent 20

# 3. Show impact in dashboards
.\open-all-dashboards.bat

# 4. Demonstrate:
# - Error rate increasing in SLI/SLO Dashboard
# - Error budget being consumed
# - Burn rate accelerating
# - Error traces in Distributed Tracing

# 5. Show trace analysis
.\open-tempo-explore.bat
# Query: {status=error}
# Click on error trace to see details
```

**Key points to highlight:**
- 🔴 Error rate above 1% threshold
- 🔴 Error budget consumption accelerating
- 🔴 Burn rate alert may trigger
- 🔍 Traces show exact error location

### Demo 3: Anomaly Detection (15 minutes)

**Objective:** Demonstrate ML-based anomaly detection

```powershell
# 1. Create historical baseline (run for several minutes)
.\generate-continuous-traffic.ps1 -DurationSeconds 300 -RequestsPerSecond 5

# 2. Trigger anomaly - error spike
.\generate-test-errors.ps1 -ErrorCount 50 -DelaySeconds 0.5

# 3. Check anomaly detector
docker-compose logs anomaly-detector | Select-String "anomaly"

# 4. Show in Grafana
# - Anomaly alert in Alerting section
# - Unusual pattern in metrics

# 5. Trigger anomaly - latency spike
for ($i=1; $i -le 20; $i++) {
    Invoke-WebRequest -Uri "http://localhost:3000/api/error/timeout" -TimeoutSec 10 -ErrorAction SilentlyContinue
}

# 6. Show latency anomaly detection
```

**Key points to highlight:**
- 🤖 ML algorithm detects unusual patterns
- 🎯 Confidence scoring for anomalies
- ⚡ Faster detection than threshold-based alerts
- 📊 Reduces MTTR through early warning

### Demo 4: SLO Breach and Recovery (15 minutes)

**Objective:** Show SLO monitoring and error budget management

```powershell
# 1. Show healthy state
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
# Open SLI/SLO Dashboard - show 100% success rate

# 2. Breach SLO
.\generate-mixed-traffic.ps1 -DurationSeconds 180 -ErrorRatePercent 25
# Show error budget consumption, burn rate alert

# 3. Stop errors, recover
.\generate-continuous-traffic.ps1 -DurationSeconds 120 -RequestsPerSecond 5
# Show error rate returning to normal

# 4. Analyze impact
# - How much error budget was consumed?
# - How long until budget replenishes?
# - What was the burn rate?
```

**Key points to highlight:**
- 📉 Error budget as a shared resource
- ⏱️ Burn rate indicates severity
- 🔄 Budget replenishes over time
- 🎯 SLO-driven decision making

---

## 📊 Interpreting Results

### Understanding Metrics

#### Success Rate
```
Success Rate = (Total Requests - 5xx Errors) / Total Requests * 100
```
- **Target:** 99.9%
- **Good:** >99.5%
- **Warning:** 99-99.5%
- **Critical:** <99%

#### Error Budget
```
Error Budget = (1 - SLO Target) * Total Requests
Remaining = Error Budget - Errors Observed
```
- **Example:** 99.9% SLO = 0.1% error budget
- **For 1000 requests:** 1 error allowed
- **Remaining:** Shows how many errors before SLO breach

#### Burn Rate
```
Burn Rate = (Errors in Window / Window Duration) / (Error Budget / SLO Window)
```
- **1x:** Normal consumption
- **6x:** Budget exhausted in 5 days (Warning)
- **14.4x:** Budget exhausted in 2 days (Critical)

### Reading Traces

**Trace Structure:**
```
Trace ID: abc123...
├─ Span: HTTP GET /api/users (200ms)
   ├─ Span: fetch_users_operation (150ms)
   │  └─ Span: database_query (100ms)
   └─ Span: response_serialization (50ms)
```

**What to look for:**
- **Long spans:** Bottlenecks (database, external API)
- **Many spans:** Complex operations
- **Error spans:** Exceptions or failures
- **Span attributes:** Context (user ID, endpoint, etc.)

### Anomaly Scores

**Isolation Forest Scores:**
- **-1:** Anomaly (unusual pattern)
- **1:** Normal (expected pattern)
- **0 to -0.5:** Borderline (investigate)

**Confidence Levels:**
- **>0.95:** High confidence anomaly
- **0.8-0.95:** Medium confidence
- **<0.8:** Low confidence (may be false positive)

---

## 🔗 Quick Reference

### Common Commands

```powershell
# Start platform
docker-compose up -d

# Generate traffic
.\generate-continuous-traffic.ps1 -DurationSeconds 60

# Generate errors
.\generate-test-errors.ps1 -ErrorCount 10

# Open dashboards
.\open-all-dashboards.bat

# Check logs
docker-compose logs -f

# Stop platform
docker-compose down
```

### Important URLs

- **Grafana:** http://localhost:3001 (admin/grupo5_devops)
- **Prometheus:** http://localhost:9090
- **Tempo:** http://localhost:3200
- **Demo App:** http://localhost:3000

### Useful Queries

**Prometheus:**
```promql
# Error rate
rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])

# P95 latency
histogram_quantile(0.95, rate(http_server_duration_milliseconds_bucket[5m]))

# Request rate
rate(http_server_duration_milliseconds_count[5m])
```

**Tempo (in Grafana Explore):**
```
{status=error}                    # All error traces
{service.name="demo-app"}         # Traces from demo-app
{http.status_code="500"}          # 500 error traces
{http.route="/api/users"}         # Traces for specific endpoint
```

---

## 📚 Additional Resources

- [README.md](README.md) - Main project documentation
- [GRAFANA_QUICK_START.md](GRAFANA_QUICK_START.md) - Grafana setup guide
- [TEMPO_TRACING_GUIDE.md](TEMPO_TRACING_GUIDE.md) - Distributed tracing guide
- [GENERADOR_ERRORES_GUIA.md](GENERADOR_ERRORES_GUIA.md) - Error generation guide (Spanish)

---

**Last Updated:** October 5, 2025
**Version:** 1.0.0
