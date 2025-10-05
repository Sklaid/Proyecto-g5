#!/usr/bin/env pwsh
# Script para verificar si hay datos de Error Rate en Prometheus

Write-Host "=== Verificacion de Error Rate ===" -ForegroundColor Cyan
Write-Host ""

$prometheusUrl = "http://localhost:9090"

# Cargar System.Web para UrlEncode
Add-Type -AssemblyName System.Web

# Funcion para ejecutar query en Prometheus
function Invoke-PrometheusQuery {
    param(
        [string]$Query,
        [string]$Description
    )
    
    Write-Host "Verificando: $Description" -ForegroundColor Yellow
    Write-Host "Query: $Query" -ForegroundColor Gray
    
    try {
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
        $url = "$prometheusUrl/api/v1/query?query=$encodedQuery"
        
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response.status -eq "success") {
            $resultCount = $response.data.result.Count
            
            if ($resultCount -gt 0) {
                Write-Host "OK Datos encontrados: $resultCount series" -ForegroundColor Green
                
                foreach ($result in $response.data.result) {
                    $labels = $result.metric | ConvertTo-Json -Compress
                    $value = $result.value[1]
                    Write-Host "  - $labels = $value" -ForegroundColor White
                }
            }
            else {
                Write-Host "X No hay datos disponibles" -ForegroundColor Red
            }
        }
        else {
            Write-Host "X Error en la query: $($response.error)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "X Error al ejecutar query: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "1. Verificando metricas base disponibles..." -ForegroundColor Cyan
Write-Host ""

# Verificar si hay metricas http_server_duration_milliseconds
Invoke-PrometheusQuery -Query "http_server_duration_milliseconds_count" -Description "Metricas HTTP totales"

# Verificar si hay requests con status 2xx (exito)
Invoke-PrometheusQuery -Query 'http_server_duration_milliseconds_count{http_status_code=~"2.."}' -Description "Requests exitosos (2xx)"

# Verificar si hay requests con status 4xx (errores de cliente)
Invoke-PrometheusQuery -Query 'http_server_duration_milliseconds_count{http_status_code=~"4.."}' -Description "Errores de cliente (4xx)"

# Verificar si hay requests con status 5xx (errores de servidor)
Invoke-PrometheusQuery -Query 'http_server_duration_milliseconds_count{http_status_code=~"5.."}' -Description "Errores de servidor (5xx)"

Write-Host "2. Verificando tasas de error..." -ForegroundColor Cyan
Write-Host ""

# Calcular error rate de 4xx
Invoke-PrometheusQuery -Query 'sum(rate(http_server_duration_milliseconds_count{http_status_code=~"4.."}[5m])) by (http_status_code) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100' -Description "Tasa de errores 4xx (%)"

# Calcular error rate de 5xx
Invoke-PrometheusQuery -Query 'sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) by (http_status_code) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100' -Description "Tasa de errores 5xx (%)"

# Calcular error rate total
Invoke-PrometheusQuery -Query 'sum(rate(http_server_duration_milliseconds_count{http_status_code=~"[45].."}[5m])) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100' -Description "Tasa de errores total (4xx + 5xx) (%)"

Write-Host "3. Analisis de resultados..." -ForegroundColor Cyan
Write-Host ""

# Obtener conteo total de requests
$totalQuery = "sum(increase(http_server_duration_milliseconds_count[5m]))"
$encodedQuery = [System.Web.HttpUtility]::UrlEncode($totalQuery)
$url = "$prometheusUrl/api/v1/query?query=$encodedQuery"

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    if ($response.status -eq "success" -and $response.data.result.Count -gt 0) {
        $totalRequests = [math]::Round([double]$response.data.result[0].value[1], 2)
        Write-Host "Total de requests en los ultimos 5 minutos: $totalRequests" -ForegroundColor White
        
        if ($totalRequests -eq 0) {
            Write-Host ""
            Write-Host "! No hay trafico en la aplicacion" -ForegroundColor Yellow
            Write-Host "  Esto es normal si:" -ForegroundColor Gray
            Write-Host "  - La aplicacion no ha recibido requests recientemente" -ForegroundColor Gray
            Write-Host "  - No se ha generado trafico de prueba" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Para generar trafico, ejecuta: .\generate-traffic.bat" -ForegroundColor Cyan
        }
    }
}
catch {
    Write-Host "No se pudo obtener el total de requests" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Conclusion ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si NO hay datos de error rate:" -ForegroundColor Yellow
Write-Host "  OK Esto es CORRECTO si no hay errores en la aplicacion" -ForegroundColor Green
Write-Host "  OK Los dashboards mostraran 'No data' para error rate" -ForegroundColor Green
Write-Host "  OK Esto indica que la aplicacion esta funcionando correctamente" -ForegroundColor Green
Write-Host ""
Write-Host "Para probar el error rate:" -ForegroundColor Cyan
Write-Host "  1. Genera trafico con errores:" -ForegroundColor White
Write-Host "     curl http://localhost:3000/error" -ForegroundColor Gray
Write-Host "  2. Verifica nuevamente este script" -ForegroundColor White
Write-Host ""
