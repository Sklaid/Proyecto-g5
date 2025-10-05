# Dashboard and Visualization Validation Script
# Task 11.3: Validate dashboards and visualizations

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Dashboard Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$grafanaUrl = "http://localhost:3001"
$grafanaUser = "admin"
$grafanaPass = "admin"

# Create auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${grafanaUser}:${grafanaPass}"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# Step 1: Check Grafana health
Write-Host "[Step 1] Checking Grafana health..." -ForegroundColor Yellow

try {
    $healthResponse = Invoke-RestMethod -Uri "$grafanaUrl/api/health" -Method Get -TimeoutSec 10
    Write-Host "  Grafana status: $($healthResponse.database)" -ForegroundColor Green
    $grafanaHealthy = $true
} catch {
    Write-Host "  Grafana is not accessible" -ForegroundColor Red
    $grafanaHealthy = $false
    exit 1
}

# Step 2: Verify datasources
Write-Host "`n[Step 2] Verifying datasources..." -ForegroundColor Yellow

try {
    $datasources = Invoke-RestMethod -Uri "$grafanaUrl/api/datasources" -Method Get -Headers $headers -TimeoutSec 10
    
    $prometheusDs = $datasources | Where-Object { $_.type -eq "prometheus" }
    $tempoDs = $datasources | Where-Object { $_.type -eq "tempo" }
    
    if ($prometheusDs) {
        Write-Host "  Prometheus datasource: Found ($($prometheusDs.name))" -ForegroundColor Green
        
        # Test Prometheus connection
        try {
            $testUrl = "$grafanaUrl/api/datasources/proxy/$($prometheusDs.id)/api/v1/query?query=up"
            $testResponse = Invoke-RestMethod -Uri $testUrl -Method Get -Headers $headers -TimeoutSec 10
            if ($testResponse.status -eq "success") {
                Write-Host "    Connection test: Passed" -ForegroundColor Green
                $prometheusConnected = $true
            } else {
                Write-Host "    Connection test: Failed" -ForegroundColor Red
                $prometheusConnected = $false
            }
        } catch {
            Write-Host "    Connection test: Failed" -ForegroundColor Red
            $prometheusConnected = $false
        }
    } else {
        Write-Host "  Prometheus datasource: Not found" -ForegroundColor Red
        $prometheusConnected = $false
    }
    
    if ($tempoDs) {
        Write-Host "  Tempo datasource: Found ($($tempoDs.name))" -ForegroundColor Green
        $tempoConnected = $true
    } else {
        Write-Host "  Tempo datasource: Not found" -ForegroundColor Red
        $tempoConnected = $false
    }
    
} catch {
    Write-Host "  Failed to retrieve datasources" -ForegroundColor Red
    $prometheusConnected = $false
    $tempoConnected = $false
}

# Step 3: Verify dashboards
Write-Host "`n[Step 3] Verifying dashboards..." -ForegroundColor Yellow

try {
    $dashboards = Invoke-RestMethod -Uri "$grafanaUrl/api/search?type=dash-db" -Method Get -Headers $headers -TimeoutSec 10
    
    Write-Host "  Total dashboards found: $($dashboards.Count)" -ForegroundColor Cyan
    
    $expectedDashboards = @(
        "SLI/SLO Dashboard",
        "Application Performance",
        "Distributed Tracing"
    )
    
    $foundDashboards = @{}
    
    foreach ($expectedDash in $expectedDashboards) {
        $found = $dashboards | Where-Object { $_.title -like "*$expectedDash*" }
        if ($found) {
            Write-Host "  $expectedDash : Found" -ForegroundColor Green
            $foundDashboards[$expectedDash] = $true
        } else {
            Write-Host "  $expectedDash : Not found" -ForegroundColor Yellow
            $foundDashboards[$expectedDash] = $false
        }
    }
    
    $dashboardsFound = ($foundDashboards.Values | Where-Object { $_ -eq $true }).Count
    
} catch {
    Write-Host "  Failed to retrieve dashboards" -ForegroundColor Red
    $dashboardsFound = 0
}

# Step 4: Test dashboard queries
Write-Host "`n[Step 4] Testing dashboard queries..." -ForegroundColor Yellow

$testQueries = @(
    @{
        Name = "Request Rate"
        Query = "rate(business_requests_total[5m])"
    },
    @{
        Name = "HTTP Duration P95"
        Query = "histogram_quantile(0.95, rate(http_server_duration_milliseconds_bucket[5m]))"
    },
    @{
        Name = "Process Memory"
        Query = "nodejs_process_resident_memory_bytes"
    }
)

$queriesWorking = 0
$queriesFailed = 0

if ($prometheusDs) {
    foreach ($testQuery in $testQueries) {
        try {
            $queryUrl = "$grafanaUrl/api/datasources/proxy/$($prometheusDs.id)/api/v1/query?query=$([System.Web.HttpUtility]::UrlEncode($testQuery.Query))"
            $queryResponse = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers -TimeoutSec 10
            
            if ($queryResponse.status -eq "success" -and $queryResponse.data.result.Count -gt 0) {
                Write-Host "  $($testQuery.Name): Working ($($queryResponse.data.result.Count) series)" -ForegroundColor Green
                $queriesWorking++
            } else {
                Write-Host "  $($testQuery.Name): No data" -ForegroundColor Yellow
                $queriesFailed++
            }
        } catch {
            Write-Host "  $($testQuery.Name): Failed" -ForegroundColor Red
            $queriesFailed++
        }
    }
} else {
    Write-Host "  Skipping query tests (Prometheus not connected)" -ForegroundColor Yellow
}

# Step 5: Check for alerts
Write-Host "`n[Step 5] Checking alert rules..." -ForegroundColor Yellow

try {
    $alertRules = Invoke-RestMethod -Uri "$grafanaUrl/api/ruler/grafana/api/v1/rules" -Method Get -Headers $headers -TimeoutSec 10
    
    $totalRules = 0
    foreach ($namespace in $alertRules.PSObject.Properties) {
        foreach ($group in $namespace.Value) {
            $totalRules += $group.rules.Count
        }
    }
    
    Write-Host "  Alert rules configured: $totalRules" -ForegroundColor $(if ($totalRules -gt 0) { "Green" } else { "Yellow" })
    $alertsConfigured = $totalRules -gt 0
    
} catch {
    Write-Host "  Could not retrieve alert rules" -ForegroundColor Yellow
    $alertsConfigured = $false
}

# Step 6: Verify panel data
Write-Host "`n[Step 6] Verifying dashboard panels have data..." -ForegroundColor Yellow

if ($dashboards.Count -gt 0) {
    $dashboardWithData = 0
    $dashboardsChecked = 0
    
    foreach ($dashboard in $dashboards | Select-Object -First 3) {
        try {
            $dashboardDetail = Invoke-RestMethod -Uri "$grafanaUrl/api/dashboards/uid/$($dashboard.uid)" -Method Get -Headers $headers -TimeoutSec 10
            $panelCount = 0
            
            if ($dashboardDetail.dashboard.panels) {
                $panelCount = $dashboardDetail.dashboard.panels.Count
            }
            
            Write-Host "  $($dashboard.title): $panelCount panels" -ForegroundColor Cyan
            $dashboardsChecked++
            
            if ($panelCount -gt 0) {
                $dashboardWithData++
            }
        } catch {
            Write-Host "  $($dashboard.title): Could not load" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n  Dashboards with panels: $dashboardWithData/$dashboardsChecked" -ForegroundColor Cyan
} else {
    Write-Host "  No dashboards to check" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nGrafana Health:" -ForegroundColor Cyan
Write-Host "  Status: $(if ($grafanaHealthy) { 'Healthy' } else { 'Unhealthy' })" -ForegroundColor $(if ($grafanaHealthy) { "Green" } else { "Red" })

Write-Host "`nDatasources:" -ForegroundColor Cyan
Write-Host "  Prometheus: $(if ($prometheusConnected) { 'Connected' } else { 'Not connected' })" -ForegroundColor $(if ($prometheusConnected) { "Green" } else { "Red" })
Write-Host "  Tempo: $(if ($tempoConnected) { 'Connected' } else { 'Not connected' })" -ForegroundColor $(if ($tempoConnected) { "Green" } else { "Yellow" })

Write-Host "`nDashboards:" -ForegroundColor Cyan
Write-Host "  Total found: $($dashboards.Count)" -ForegroundColor White
Write-Host "  Expected dashboards: $dashboardsFound/3" -ForegroundColor $(if ($dashboardsFound -ge 2) { "Green" } else { "Yellow" })

Write-Host "`nQueries:" -ForegroundColor Cyan
Write-Host "  Working: $queriesWorking/$($testQueries.Count)" -ForegroundColor $(if ($queriesWorking -ge 2) { "Green" } else { "Yellow" })

Write-Host "`nAlerts:" -ForegroundColor Cyan
Write-Host "  Configured: $(if ($alertsConfigured) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($alertsConfigured) { "Green" } else { "Yellow" })

# Overall status
Write-Host ""
$overallSuccess = $grafanaHealthy -and $prometheusConnected -and ($dashboardsFound -ge 2) -and ($queriesWorking -ge 2)

if ($overallSuccess) {
    Write-Host "Dashboards are operational!" -ForegroundColor Green
    Write-Host "`nAccess Grafana:" -ForegroundColor Cyan
    Write-Host "  URL: http://localhost:3001" -ForegroundColor White
    Write-Host "  Username: admin" -ForegroundColor White
    Write-Host "  Password: admin" -ForegroundColor White
    Write-Host "`nAvailable dashboards:" -ForegroundColor Cyan
    foreach ($dash in $dashboards | Select-Object -First 5) {
        Write-Host "  - $($dash.title)" -ForegroundColor White
    }
    exit 0
} else {
    Write-Host "Some dashboard components need attention" -ForegroundColor Yellow
    Write-Host "`nTroubleshooting:" -ForegroundColor Cyan
    Write-Host "  1. Check Grafana logs: docker logs grafana" -ForegroundColor White
    Write-Host "  2. Verify datasource configuration in Grafana UI" -ForegroundColor White
    Write-Host "  3. Check dashboard provisioning files" -ForegroundColor White
    Write-Host "  4. Ensure metrics are flowing (run validate-telemetry.ps1)" -ForegroundColor White
    exit 1
}
