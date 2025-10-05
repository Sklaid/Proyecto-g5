# Check OTel Collector Metrics
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Verificando Metricas del OTel Collector" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Consultando endpoint de metricas del OTel Collector..." -ForegroundColor Yellow
Write-Host "URL: http://localhost:8889/metrics" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8889/metrics" -UseBasicParsing
    $content = $response.Content
    
    Write-Host "[OK] Endpoint respondio correctamente" -ForegroundColor Green
    Write-Host ""
    
    # Buscar métricas HTTP
    Write-Host "Buscando metricas HTTP..." -ForegroundColor Yellow
    $httpMetrics = $content -split "`n" | Where-Object { $_ -match "http" -and $_ -notmatch "^#" }
    
    if ($httpMetrics.Count -gt 0) {
        Write-Host "[OK] Encontradas $($httpMetrics.Count) metricas HTTP" -ForegroundColor Green
        Write-Host ""
        Write-Host "Primeras 20 metricas HTTP:" -ForegroundColor Cyan
        $httpMetrics | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
    }
    else {
        Write-Host "[WARN] No se encontraron metricas HTTP" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Mostrando todas las metricas disponibles (primeras 30 lineas):" -ForegroundColor Cyan
        $allMetrics = $content -split "`n" | Where-Object { $_ -notmatch "^#" -and $_.Trim() -ne "" }
        $allMetrics | Select-Object -First 30 | ForEach-Object { Write-Host "  $_" }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total de lineas de metricas: $($allMetrics.Count)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] No se pudo conectar al endpoint" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica que el OTel Collector este corriendo:" -ForegroundColor Yellow
    Write-Host "  docker-compose ps otel-collector" -ForegroundColor White
}

Write-Host ""
Write-Host "Presiona Enter para continuar..."
Read-Host
