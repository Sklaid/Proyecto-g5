#!/usr/bin/env pwsh
# Script para generar errores de prueba en la aplicacion

param(
    [int]$ErrorCount = 5,
    [int]$DelaySeconds = 2
)

Write-Host "=== Generador de Errores de Prueba ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script genera errores CONTROLADOS para demostrar" -ForegroundColor Yellow
Write-Host "el funcionamiento de los dashboards de error tracking." -ForegroundColor Yellow
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor White
Write-Host "  - Errores a generar: $ErrorCount" -ForegroundColor Gray
Write-Host "  - Delay entre errores: $DelaySeconds segundos" -ForegroundColor Gray
Write-Host ""

$errorTypes = @(
    @{
        Name = "Error 500 - Internal Server Error (PRUEBA)"
        Url = "http://localhost:3000/api/error/500"
        Description = "Simula un error interno del servidor"
        ExpectedStatus = 500
    },
    @{
        Name = "Error 404 - Not Found (PRUEBA)"
        Url = "http://localhost:3000/api/nonexistent-endpoint"
        Description = "Endpoint que no existe"
        ExpectedStatus = 404
    },
    @{
        Name = "Error 500 - Exception (PRUEBA)"
        Url = "http://localhost:3000/api/error/exception"
        Description = "Simula una excepcion no manejada"
        ExpectedStatus = 500
    },
    @{
        Name = "Error 404 - Invalid User ID (PRUEBA)"
        Url = "http://localhost:3000/api/users/99999"
        Description = "Usuario que no existe"
        ExpectedStatus = 404
    },
    @{
        Name = "Error 404 - Invalid Product ID (PRUEBA)"
        Url = "http://localhost:3000/api/products/99999"
        Description = "Producto que no existe"
        ExpectedStatus = 404
    }
)

$totalErrors = 0
$successfulErrors = 0

Write-Host "Iniciando generacion de errores..." -ForegroundColor Green
Write-Host ""

for ($i = 0; $i -lt $ErrorCount; $i++) {
    $errorType = $errorTypes[$i % $errorTypes.Count]
    
    Write-Host "[$($i + 1)/$ErrorCount] Generando: $($errorType.Name)" -ForegroundColor Yellow
    Write-Host "  URL: $($errorType.Url)" -ForegroundColor Gray
    Write-Host "  Descripcion: $($errorType.Description)" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $errorType.Url -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        
        # Si llegamos aqui sin error, verificar status code
        if ($response.StatusCode -eq $errorType.ExpectedStatus) {
            Write-Host "  OK Error generado correctamente (Status: $($response.StatusCode))" -ForegroundColor Green
            $successfulErrors++
        }
        else {
            Write-Host "  ADVERTENCIA: Status inesperado: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        # Para errores HTTP, esto es esperado
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            if ($statusCode -eq $errorType.ExpectedStatus) {
                Write-Host "  OK Error generado correctamente (Status: $statusCode)" -ForegroundColor Green
                $successfulErrors++
            }
            else {
                Write-Host "  ADVERTENCIA: Status inesperado: $statusCode" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  ERROR: No se pudo conectar - $_" -ForegroundColor Red
        }
    }
    
    $totalErrors++
    
    if ($i -lt ($ErrorCount - 1)) {
        Write-Host "  Esperando $DelaySeconds segundos..." -ForegroundColor Gray
        Start-Sleep -Seconds $DelaySeconds
    }
    
    Write-Host ""
}

Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "Total de errores generados: $totalErrors" -ForegroundColor White
Write-Host "Errores exitosos: $successfulErrors" -ForegroundColor Green
Write-Host "Fallidos: $($totalErrors - $successfulErrors)" -ForegroundColor Red
Write-Host ""

Write-Host "=== Donde Ver los Errores ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Application Performance Dashboard:" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/d/app-performance-dashboard" -ForegroundColor White
Write-Host "   - Panel: Error Rate Breakdown by Status Code" -ForegroundColor Gray
Write-Host "   - Panel: Response Status Code Distribution" -ForegroundColor Gray
Write-Host ""

Write-Host "2. Distributed Tracing Dashboard:" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/d/distributed-tracing" -ForegroundColor White
Write-Host "   - Panel: Error Traces" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Tempo Explore (para ver traces de errores):" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/explore" -ForegroundColor White
Write-Host "   - Query: {status=error}" -ForegroundColor Gray
Write-Host "   - O ejecuta: .\open-tempo-explore.bat" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Prometheus (metricas directas):" -ForegroundColor Yellow
Write-Host "   http://localhost:9090/graph" -ForegroundColor White
Write-Host "   - Query: http_server_duration_milliseconds_count{http_status_code=~\"[45]..\"}" -ForegroundColor Gray
Write-Host ""

Write-Host "Nota: Espera 15-30 segundos para que las metricas se actualicen" -ForegroundColor Yellow
Write-Host "en Prometheus y aparezcan en los dashboards." -ForegroundColor Yellow
Write-Host ""

Write-Host "Para generar mas errores, ejecuta:" -ForegroundColor Cyan
Write-Host "  .\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1" -ForegroundColor White
Write-Host ""
