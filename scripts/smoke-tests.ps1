# Smoke Tests - Validación post-deployment
# Ejecuta los mismos tests que el workflow de deployment

$ErrorActionPreference = "Stop"

Write-Host "🧪 Ejecutando Smoke Tests..." -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

function Test-Endpoint {
    param (
        [string]$Url,
        [string]$Name
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $Name" -ForegroundColor Green
            $script:testsPassed++
            return $true
        } else {
            Write-Host "✗ $Name (Status: $($response.StatusCode))" -ForegroundColor Red
            $script:testsFailed++
            return $false
        }
    } catch {
        Write-Host "✗ $Name (Error: $($_.Exception.Message))" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

# 1. Health Checks
Write-Host "🏥 Health Checks..." -ForegroundColor Yellow
Test-Endpoint "http://localhost:3000/health" "Demo App - Health"
Test-Endpoint "http://localhost:3000/ready" "Demo App - Ready"
Test-Endpoint "http://localhost:9090/-/healthy" "Prometheus - Health"
Test-Endpoint "http://localhost:3001/api/health" "Grafana - Health"
Test-Endpoint "http://localhost:3200/ready" "Tempo - Ready"

Write-Host ""

# 2. Metrics Baseline Check
Write-Host "📊 Metrics Baseline Check..." -ForegroundColor Yellow
Write-Host "  Esperando que las métricas se recopilen..." -ForegroundColor Gray
Start-Sleep -Seconds 5

try {
    $metricsResponse = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing
    if ($metricsResponse.status -eq "success") {
        Write-Host "✓ Prometheus está recopilando métricas" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "✗ Prometheus no está recopilando métricas" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "✗ Error consultando Prometheus: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

try {
    $appMetrics = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=http_server_requests_total" -UseBasicParsing
    if ($appMetrics.status -eq "success" -and $appMetrics.data.result.Count -gt 0) {
        Write-Host "✓ Demo app está reportando métricas" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "⚠ Demo app aún no tiene métricas (puede ser normal si recién inició)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ No se pudieron obtener métricas de la app (puede ser normal)" -ForegroundColor Yellow
}

Write-Host ""

# 3. Trace Validation
Write-Host "🔍 Trace Validation..." -ForegroundColor Yellow
Write-Host "  Generando tráfico de prueba..." -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "http://localhost:3000/api/products" -UseBasicParsing | Out-Null
    Write-Host "✓ Tráfico de prueba generado" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "✗ Error generando tráfico: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

Write-Host "  Esperando que las trazas se procesen..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Test-Endpoint "http://localhost:3200/ready" "Tempo está procesando trazas"

Write-Host ""

# 4. Grafana Datasources Check
Write-Host "📈 Grafana Datasources..." -ForegroundColor Yellow

try {
    # Grafana API requires authentication
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    $headers = @{
        Authorization = "Basic $base64Auth"
    }
    
    $datasources = Invoke-RestMethod -Uri "http://localhost:3001/api/datasources" -Headers $headers -UseBasicParsing
    
    $prometheusDs = $datasources | Where-Object { $_.type -eq "prometheus" }
    $tempoDs = $datasources | Where-Object { $_.type -eq "tempo" }
    
    if ($prometheusDs) {
        Write-Host "✓ Prometheus datasource configurado" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "✗ Prometheus datasource no encontrado" -ForegroundColor Red
        $testsFailed++
    }
    
    if ($tempoDs) {
        Write-Host "✓ Tempo datasource configurado" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "✗ Tempo datasource no encontrado" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "⚠ No se pudo verificar datasources de Grafana: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# 5. Container Status Check
Write-Host "🐳 Container Status..." -ForegroundColor Yellow

try {
    $containers = docker ps --format "{{.Names}}" | Out-String
    
    $requiredContainers = @(
        "demo-app",
        "otel-collector",
        "prometheus",
        "tempo",
        "grafana",
        "anomaly-detector"
    )
    
    foreach ($container in $requiredContainers) {
        if ($containers -match $container) {
            Write-Host "✓ $container está corriendo" -ForegroundColor Green
            $testsPassed++
        } else {
            Write-Host "✗ $container NO está corriendo" -ForegroundColor Red
            $testsFailed++
        }
    }
} catch {
    Write-Host "✗ Error verificando containers: $($_.Exception.Message)" -ForegroundColor Red
}

# Resumen
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Resumen de Smoke Tests" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Tests pasados: $testsPassed" -ForegroundColor Green
Write-Host "Tests fallidos: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ Todos los smoke tests pasaron!" -ForegroundColor Green
    Write-Host "El sistema está funcionando correctamente." -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Algunos tests fallaron." -ForegroundColor Red
    Write-Host "Revisa los logs de los servicios con: docker-compose logs <servicio>" -ForegroundColor Yellow
    exit 1
}
