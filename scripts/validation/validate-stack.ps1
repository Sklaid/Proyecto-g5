# End-to-End Stack Validation Script
# Task 11.1: Deploy complete stack locally with Docker Compose

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AIOps Platform - Stack Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$allChecks = @()

function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    Write-Host "Checking $ServiceName..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host " OK" -ForegroundColor Green
            return $true
        } else {
            Write-Host " FAIL (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host " FAIL" -ForegroundColor Red
        return $false
    }
}

function Test-DockerService {
    param([string]$ServiceName)
    
    Write-Host "Checking Docker service: $ServiceName..." -NoNewline
    $container = docker ps --filter "name=$ServiceName" --format "{{.Names}}" 2>$null
    if ($container -eq $ServiceName) {
        $status = docker inspect --format='{{.State.Status}}' $ServiceName 2>$null
        if ($status -eq "running") {
            Write-Host " Running" -ForegroundColor Green
            return $true
        } else {
            Write-Host " Not running (Status: $status)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host " Container not found" -ForegroundColor Red
        return $false
    }
}

# Step 1: Check if Docker is running
Write-Host "`n[Step 1] Checking Docker..." -ForegroundColor Yellow
$dockerCheck = docker version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker is running" -ForegroundColor Green
} else {
    Write-Host "Docker is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Step 2: Check if docker-compose.yml exists
Write-Host "`n[Step 2] Checking docker-compose.yml..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "docker-compose.yml found" -ForegroundColor Green
} else {
    Write-Host "docker-compose.yml not found" -ForegroundColor Red
    exit 1
}

# Step 3: Check all Docker containers
Write-Host "`n[Step 3] Checking Docker containers..." -ForegroundColor Yellow
$services = @("demo-app", "otel-collector", "prometheus", "tempo", "grafana", "anomaly-detector")
$containerChecks = @{}

foreach ($service in $services) {
    $containerChecks[$service] = Test-DockerService $service
}

# Step 4: Check service health endpoints
Write-Host "`n[Step 4] Checking service health endpoints..." -ForegroundColor Yellow
$healthChecks = @{
    "Demo App" = "http://localhost:3000/health"
    "OTel Collector" = "http://localhost:8888/metrics"
    "Prometheus" = "http://localhost:9090/-/healthy"
    "Tempo" = "http://localhost:3200/ready"
    "Grafana" = "http://localhost:3001/api/health"
}

$healthResults = @{}
foreach ($service in $healthChecks.Keys) {
    $healthResults[$service] = Test-ServiceHealth -ServiceName $service -Url $healthChecks[$service]
}

# Step 5: Check for errors in logs
Write-Host "`n[Step 5] Checking container logs for errors..." -ForegroundColor Yellow
$errorPatterns = @("error", "fatal", "exception", "failed")
$logsWithErrors = @()

foreach ($service in $services) {
    if ($containerChecks[$service]) {
        $logs = docker logs $service --tail 50 2>&1
        $hasErrors = $false
        foreach ($pattern in $errorPatterns) {
            if ($logs -match $pattern) {
                $hasErrors = $true
                break
            }
        }
        
        if ($hasErrors) {
            Write-Host "  $service has errors in logs" -ForegroundColor Yellow
            $logsWithErrors += $service
        } else {
            Write-Host "  $service logs look clean" -ForegroundColor Green
        }
    }
}

# Step 6: Check network connectivity
Write-Host "`n[Step 6] Checking network connectivity..." -ForegroundColor Yellow
$network = docker network inspect observability-network 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "observability-network exists" -ForegroundColor Green
    $networkData = $network | ConvertFrom-Json
    if ($networkData.Containers) {
        Write-Host "  Connected containers: $($networkData.Containers.Count)" -ForegroundColor Cyan
    }
} else {
    Write-Host "observability-network not found" -ForegroundColor Red
}

# Step 7: Check volumes
Write-Host "`n[Step 7] Checking persistent volumes..." -ForegroundColor Yellow
$volumes = @("prometheus-data", "tempo-data", "grafana-data")
foreach ($volume in $volumes) {
    $volumeExists = docker volume inspect $volume 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $volume exists" -ForegroundColor Green
    } else {
        Write-Host "  $volume not found" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalContainers = $services.Count
$runningContainers = ($containerChecks.Values | Where-Object { $_ -eq $true }).Count
$healthyServices = ($healthResults.Values | Where-Object { $_ -eq $true }).Count
$totalHealthChecks = $healthResults.Count

Write-Host "`nContainer Status: $runningContainers/$totalContainers running" -ForegroundColor $(if ($runningContainers -eq $totalContainers) { "Green" } else { "Yellow" })
Write-Host "Health Checks: $healthyServices/$totalHealthChecks passing" -ForegroundColor $(if ($healthyServices -eq $totalHealthChecks) { "Green" } else { "Yellow" })

if ($logsWithErrors.Count -gt 0) {
    Write-Host "`nServices with errors in logs:" -ForegroundColor Yellow
    foreach ($service in $logsWithErrors) {
        Write-Host "  - $service" -ForegroundColor Yellow
    }
    Write-Host "`nTo view detailed logs, run: docker logs [service-name]" -ForegroundColor Cyan
}

# Overall status
Write-Host ""
if ($runningContainers -eq $totalContainers -and $healthyServices -eq $totalHealthChecks) {
    Write-Host "All systems operational!" -ForegroundColor Green
    Write-Host "`nAccess points:" -ForegroundColor Cyan
    Write-Host "  - Demo App: http://localhost:3000" -ForegroundColor White
    Write-Host "  - Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor White
    Write-Host "  - Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  - Tempo: http://localhost:3200" -ForegroundColor White
    exit 0
} else {
    Write-Host "Some services are not healthy" -ForegroundColor Yellow
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Cyan
    Write-Host "  1. Check logs: docker-compose logs [service-name]" -ForegroundColor White
    Write-Host "  2. Restart services: docker-compose restart" -ForegroundColor White
    Write-Host "  3. Rebuild: docker-compose up --build -d" -ForegroundColor White
    exit 1
}
