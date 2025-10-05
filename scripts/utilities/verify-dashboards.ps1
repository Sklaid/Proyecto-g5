# Verify Grafana Dashboards
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Verificando Dashboards de Grafana" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Esperando que Grafana reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    $headers = @{ Authorization = "Basic $base64Auth" }
    
    Write-Host "[1/3] Verificando conexion a Grafana..." -ForegroundColor Yellow
    $health = Invoke-RestMethod -Uri "http://localhost:3001/api/health" -Headers $headers -UseBasicParsing
    Write-Host "[OK] Grafana esta corriendo" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[2/3] Listando dashboards disponibles..." -ForegroundColor Yellow
    $dashboards = Invoke-RestMethod -Uri "http://localhost:3001/api/search?type=dash-db" -Headers $headers -UseBasicParsing
    
    if ($dashboards.Count -gt 0) {
        Write-Host "[OK] Encontrados $($dashboards.Count) dashboards" -ForegroundColor Green
        Write-Host ""
        foreach ($dashboard in $dashboards) {
            Write-Host "  - $($dashboard.title)" -ForegroundColor Cyan
            Write-Host "    URL: http://localhost:3001$($dashboard.url)" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "[WARN] No se encontraron dashboards" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "[3/3] Verificando datasources..." -ForegroundColor Yellow
    $datasources = Invoke-RestMethod -Uri "http://localhost:3001/api/datasources" -Headers $headers -UseBasicParsing
    
    foreach ($ds in $datasources) {
        Write-Host "  - $($ds.name) ($($ds.type))" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " Dashboards Actualizados!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Cyan
    Write-Host "  1. Abre Grafana: http://localhost:3001" -ForegroundColor White
    Write-Host "  2. Login: admin / admin" -ForegroundColor White
    Write-Host "  3. Ve a Dashboards" -ForegroundColor White
    Write-Host "  4. Abre 'SLI/SLO Dashboard'" -ForegroundColor White
    Write-Host "  5. Deberias ver datos ahora!" -ForegroundColor White
    Write-Host ""
    Write-Host "Si no ves datos:" -ForegroundColor Yellow
    Write-Host "  1. Genera mas trafico: .\generate-traffic.bat" -ForegroundColor White
    Write-Host "  2. Espera 30 segundos" -ForegroundColor White
    Write-Host "  3. Refresca el dashboard" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "[ERROR] No se pudo conectar a Grafana" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica que Grafana este corriendo:" -ForegroundColor Yellow
    Write-Host "  docker-compose ps grafana" -ForegroundColor White
    Write-Host "  docker-compose logs grafana" -ForegroundColor White
}

Write-Host "Presiona Enter para abrir Grafana en el navegador..."
Read-Host
Start-Process "http://localhost:3001"
