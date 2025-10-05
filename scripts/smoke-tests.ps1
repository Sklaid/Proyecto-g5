# Smoke Tests - Validacion post-deployment
$ErrorActionPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Smoke Tests - AIOps Platform" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

function Test-Endpoint {
    param (
        [string]$Url,
        [string]$Name
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] $Name" -ForegroundColor Green
            $script:testsPassed++
            return $true
        }
    }
    catch {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

# 1. Health Checks
Write-Host "1. Health Checks..." -ForegroundColor Yellow
Test-Endpoint "http://localhost:3000/health" "Demo App - Health"
Test-Endpoint "http://localhost:3000/ready" "Demo App - Ready"
Test-Endpoint "http://localhost:9090/-/healthy" "Prometheus - Health"
Test-Endpoint "http://localhost:3001/api/health" "Grafana - Health"
Test-Endpoint "http://localhost:3200/ready" "Tempo - Ready"
Write-Host ""

# 2. Metrics Check
Write-Host "2. Metrics Baseline..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

try {
    $metricsResponse = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing -ErrorAction Stop
    if ($metricsResponse.status -eq "success") {
        Write-Host "[OK] Prometheus collecting metrics" -ForegroundColor Green
        $testsPassed++
    }
}
catch {
    Write-Host "[FAIL] Prometheus metrics check" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# 3. Trace Validation
Write-Host "3. Trace Validation..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing -ErrorAction Stop | Out-Null
    Write-Host "[OK] Test traffic generated" -ForegroundColor Green
    $testsPassed++
}
catch {
    Write-Host "[FAIL] Could not generate traffic" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# 4. Grafana Datasources
Write-Host "4. Grafana Datasources..." -ForegroundColor Yellow
try {
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    $headers = @{ Authorization = "Basic $base64Auth" }
    $datasources = Invoke-RestMethod -Uri "http://localhost:3001/api/datasources" -Headers $headers -UseBasicParsing -ErrorAction Stop
    
    $prometheusDs = $datasources | Where-Object { $_.type -eq "prometheus" }
    $tempoDs = $datasources | Where-Object { $_.type -eq "tempo" }
    
    if ($prometheusDs) {
        Write-Host "[OK] Prometheus datasource configured" -ForegroundColor Green
        $testsPassed++
    }
    else {
        Write-Host "[FAIL] Prometheus datasource not found" -ForegroundColor Red
        $testsFailed++
    }
    
    if ($tempoDs) {
        Write-Host "[OK] Tempo datasource configured" -ForegroundColor Green
        $testsPassed++
    }
    else {
        Write-Host "[FAIL] Tempo datasource not found" -ForegroundColor Red
        $testsFailed++
    }
}
catch {
    Write-Host "[WARN] Could not verify Grafana datasources" -ForegroundColor Yellow
}
Write-Host ""

# 5. Container Status
Write-Host "5. Container Status..." -ForegroundColor Yellow
try {
    $containers = docker ps --format "{{.Names}}" 2>&1 | Out-String
    
    $requiredContainers = @("demo-app", "otel-collector", "prometheus", "tempo", "grafana", "anomaly-detector")
    
    foreach ($container in $requiredContainers) {
        if ($containers -match $container) {
            Write-Host "[OK] $container is running" -ForegroundColor Green
            $testsPassed++
        }
        else {
            Write-Host "[FAIL] $container is NOT running" -ForegroundColor Red
            $testsFailed++
        }
    }
}
catch {
    Write-Host "[FAIL] Error checking containers" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Tests passed:  $testsPassed" -ForegroundColor Green
Write-Host "Tests failed:  $testsFailed" -ForegroundColor Red

$totalTests = $testsPassed + $testsFailed
if ($totalTests -gt 0) {
    $successRate = [math]::Round(($testsPassed / $totalTests) * 100, 2)
    Write-Host "Success rate:  $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
}
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "All smoke tests passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Access Grafana: http://localhost:3001 (admin/admin)"
    Write-Host "  2. Generate traffic: .\generate-traffic.bat"
    Write-Host "  3. View dashboards and metrics"
    Write-Host ""
    exit 0
}
else {
    Write-Host "Some tests failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check services: docker-compose ps"
    Write-Host "  2. View logs: docker-compose logs"
    Write-Host "  3. Restart: docker-compose restart"
    Write-Host ""
    exit 1
}
