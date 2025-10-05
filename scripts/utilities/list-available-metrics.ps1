# List Available Metrics
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Metricas Disponibles en Prometheus" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing
    
    if ($response.status -eq "success") {
        $metrics = $response.data | Where-Object { $_ -match "http" }
        
        Write-Host "[OK] Metricas HTTP disponibles:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($metric in $metrics) {
            Write-Host "  - $metric" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Total: $($metrics.Count) metricas HTTP" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Queries recomendadas para Grafana:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Request Rate:" -ForegroundColor Yellow
        Write-Host "   rate(http_server_duration_milliseconds_count[5m])" -ForegroundColor White
        Write-Host ""
        Write-Host "2. Latency P95:" -ForegroundColor Yellow
        Write-Host "   histogram_quantile(0.95, rate(http_server_duration_milliseconds_bucket[5m]))" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Latency P99:" -ForegroundColor Yellow
        Write-Host "   histogram_quantile(0.99, rate(http_server_duration_milliseconds_bucket[5m]))" -ForegroundColor White
        Write-Host ""
        Write-Host "4. Error Rate:" -ForegroundColor Yellow
        Write-Host "   rate(http_server_duration_milliseconds_count{http_status_code=~\"5..\"}[5m])" -ForegroundColor White
        Write-Host ""
    }
}
catch {
    Write-Host "[ERROR] No se pudo consultar Prometheus" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Presiona Enter para continuar..."
Read-Host
