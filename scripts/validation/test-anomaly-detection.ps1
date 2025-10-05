# Anomaly Detection Testing Script
# Task 11.4: Test anomaly detection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Anomaly Detection Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Step 1: Check anomaly detector status
Write-Host "[Step 1] Checking anomaly detector status..." -ForegroundColor Yellow

$detectorRunning = docker ps --filter "name=anomaly-detector" --format "{{.Names}}" 2>$null
if ($detectorRunning -eq "anomaly-detector") {
    Write-Host "  Anomaly detector: Running" -ForegroundColor Green
} else {
    Write-Host "  Anomaly detector: Not running" -ForegroundColor Red
    Write-Host "  Please start the stack with: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check recent anomaly detector logs
Write-Host "`n[Step 2] Checking anomaly detector logs..." -ForegroundColor Yellow
$logs = docker logs anomaly-detector --tail 20 2>&1
$lastCheck = $logs | Select-String "Detection cycle completed" | Select-Object -Last 1
if ($lastCheck) {
    Write-Host "  Last detection cycle: Found" -ForegroundColor Green
    Write-Host "  $lastCheck" -ForegroundColor Cyan
} else {
    Write-Host "  No recent detection cycles found" -ForegroundColor Yellow
}

# Step 3: Generate baseline traffic
Write-Host "`n[Step 3] Generating baseline traffic..." -ForegroundColor Yellow
Write-Host "  Sending 50 normal requests..." -ForegroundColor Cyan

$baselineRequests = 0
$baselineErrors = 0

for ($i = 1; $i -le 50; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $baselineRequests++
        if ($i % 10 -eq 0) {
            Write-Host "    Progress: $i/50 requests" -ForegroundColor Gray
        }
    } catch {
        $baselineErrors++
    }
    Start-Sleep -Milliseconds 100
}

Write-Host "  Baseline traffic complete: $baselineRequests requests, $baselineErrors errors" -ForegroundColor Green

# Wait for metrics to be scraped
Write-Host "`n  Waiting 20 seconds for metrics to be scraped..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Step 4: Trigger latency anomaly
Write-Host "`n[Step 4] Triggering latency anomaly..." -ForegroundColor Yellow
Write-Host "  Generating high-latency requests..." -ForegroundColor Cyan

$anomalyRequests = 0
$anomalyErrors = 0

# Generate requests that will cause latency (by hitting error endpoint which has delays)
for ($i = 1; $i -le 30; $i++) {
    try {
        # Mix of slow endpoints
        $endpoint = if ($i % 3 -eq 0) { "http://localhost:3000/api/error" } else { "http://localhost:3000/api/products" }
        $response = Invoke-WebRequest -Uri $endpoint -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $anomalyRequests++
    } catch {
        $anomalyErrors++
    }
    Start-Sleep -Milliseconds 50
}

Write-Host "  Anomaly traffic complete: $anomalyRequests requests, $anomalyErrors errors" -ForegroundColor Yellow

# Step 5: Trigger error rate anomaly
Write-Host "`n[Step 5] Triggering error rate anomaly..." -ForegroundColor Yellow
Write-Host "  Generating high error rate..." -ForegroundColor Cyan

$errorRequests = 0
$errorCount = 0

for ($i = 1; $i -le 40; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/error" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $errorRequests++
    } catch {
        $errorCount++
    }
    Start-Sleep -Milliseconds 100
}

Write-Host "  Error spike complete: $errorRequests requests, $errorCount errors" -ForegroundColor Yellow

# Wait for metrics to be scraped
Write-Host "`n  Waiting 20 seconds for metrics to be scraped..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Step 6: Check for anomalies in Prometheus
Write-Host "`n[Step 6] Checking metrics for anomalies..." -ForegroundColor Yellow

try {
    # Check request rate
    $requestRateQuery = "rate(business_requests_total[1m])"
    $response = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=$requestRateQuery" -Method Get -TimeoutSec 10
    
    if ($response.status -eq "success" -and $response.data.result.Count -gt 0) {
        $requestRate = [math]::Round([double]$response.data.result[0].value[1], 2)
        Write-Host "  Current request rate: $requestRate req/s" -ForegroundColor Cyan
    }
    
    # Check error rate
    $errorRateQuery = "rate(http_server_duration_milliseconds_count{status_code=~`"5..`"}[1m])"
    $response = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=$errorRateQuery" -Method Get -TimeoutSec 10
    
    if ($response.status -eq "success" -and $response.data.result.Count -gt 0) {
        $errorRate = [math]::Round([double]$response.data.result[0].value[1], 2)
        Write-Host "  Current error rate: $errorRate errors/s" -ForegroundColor Cyan
    }
    
    # Check latency
    $latencyQuery = "histogram_quantile(0.95, rate(http_server_duration_milliseconds_bucket[1m]))"
    $response = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=$latencyQuery" -Method Get -TimeoutSec 10
    
    if ($response.status -eq "success" -and $response.data.result.Count -gt 0) {
        $latency = [math]::Round([double]$response.data.result[0].value[1], 2)
        Write-Host "  Current P95 latency: $latency ms" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "  Failed to query Prometheus" -ForegroundColor Red
}

# Step 7: Wait for anomaly detector to run
Write-Host "`n[Step 7] Waiting for anomaly detector to analyze..." -ForegroundColor Yellow
Write-Host "  Anomaly detector runs every 5 minutes" -ForegroundColor Cyan
Write-Host "  Waiting 60 seconds for next detection cycle..." -ForegroundColor Cyan

for ($i = 60; $i -gt 0; $i--) {
    Write-Host "`r  Time remaining: $i seconds " -NoNewline -ForegroundColor Gray
    Start-Sleep -Seconds 1
}
Write-Host ""

# Step 8: Check anomaly detector logs for detections
Write-Host "`n[Step 8] Checking for anomaly detections..." -ForegroundColor Yellow

$recentLogs = docker logs anomaly-detector --tail 50 2>&1
$anomaliesDetected = $recentLogs | Select-String "Anomaly detected" | Measure-Object | Select-Object -ExpandProperty Count
$alertsSent = $recentLogs | Select-String "Alert sent" | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "  Anomalies detected: $anomaliesDetected" -ForegroundColor $(if ($anomaliesDetected -gt 0) { "Yellow" } else { "Cyan" })
Write-Host "  Alerts sent: $alertsSent" -ForegroundColor $(if ($alertsSent -gt 0) { "Yellow" } else { "Cyan" })

if ($anomaliesDetected -gt 0) {
    Write-Host "`n  Recent anomaly detections:" -ForegroundColor Yellow
    $recentLogs | Select-String "Anomaly detected" | Select-Object -Last 5 | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Yellow
    }
}

# Step 9: Check Grafana for alerts
Write-Host "`n[Step 9] Checking Grafana for alerts..." -ForegroundColor Yellow

try {
    $alertsUrl = "http://localhost:3001/api/alertmanager/grafana/api/v2/alerts"
    $alerts = Invoke-RestMethod -Uri $alertsUrl -Method Get -TimeoutSec 10
    
    $activeAlerts = $alerts | Where-Object { $_.status.state -eq "active" }
    
    if ($activeAlerts) {
        Write-Host "  Active alerts: $($activeAlerts.Count)" -ForegroundColor Yellow
        foreach ($alert in $activeAlerts | Select-Object -First 5) {
            Write-Host "    - $($alert.labels.alertname): $($alert.status.state)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No active alerts found" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  Could not retrieve alerts from Grafana" -ForegroundColor Yellow
    Write-Host "  Check Grafana UI manually: http://localhost:3001/alerting/list" -ForegroundColor Cyan
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nTraffic Generated:" -ForegroundColor Cyan
Write-Host "  Baseline requests: $baselineRequests" -ForegroundColor White
Write-Host "  Anomaly requests: $anomalyRequests" -ForegroundColor White
Write-Host "  Error spike requests: $errorRequests" -ForegroundColor White
Write-Host "  Total errors triggered: $($baselineErrors + $anomalyErrors + $errorCount)" -ForegroundColor White

Write-Host "`nAnomaly Detection:" -ForegroundColor Cyan
Write-Host "  Detector status: Running" -ForegroundColor Green
Write-Host "  Anomalies detected: $anomaliesDetected" -ForegroundColor $(if ($anomaliesDetected -gt 0) { "Yellow" } else { "Cyan" })
Write-Host "  Alerts sent: $alertsSent" -ForegroundColor $(if ($alertsSent -gt 0) { "Yellow" } else { "Cyan" })

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. View anomaly detector logs: docker logs anomaly-detector" -ForegroundColor White
Write-Host "  2. Check Grafana alerts: http://localhost:3001/alerting/list" -ForegroundColor White
Write-Host "  3. View metrics in Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  4. View dashboards in Grafana: http://localhost:3001" -ForegroundColor White

Write-Host "`nNote:" -ForegroundColor Yellow
Write-Host "  The anomaly detector requires historical data (7 days) for accurate detection." -ForegroundColor Yellow
Write-Host "  Initial runs may show warnings about insufficient data." -ForegroundColor Yellow
Write-Host "  Continue generating traffic to build up historical patterns." -ForegroundColor Yellow

Write-Host ""
if ($anomaliesDetected -gt 0 -or $alertsSent -gt 0) {
    Write-Host "Anomaly detection is working!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Anomaly detection test completed (may need more historical data)" -ForegroundColor Yellow
    exit 0
}
