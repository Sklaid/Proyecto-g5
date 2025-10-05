#!/usr/bin/env pwsh
# Script para generar trafico mixto (requests normales + errores)

param(
    [int]$DurationSeconds = 60,
    [int]$RequestsPerSecond = 5,
    [int]$ErrorRatePercent = 10
)

Write-Host "=== Generador de Trafico Mixto ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor White
Write-Host "  - Duracion: $DurationSeconds segundos" -ForegroundColor Gray
Write-Host "  - Tasa: $RequestsPerSecond requests/segundo" -ForegroundColor Gray
Write-Host "  - Tasa de errores: $ErrorRatePercent%" -ForegroundColor Gray
Write-Host ""

$normalEndpoints = @(
    "http://localhost:3000/api/users",
    "http://localhost:3000/api/products",
    "http://localhost:3000/health",
    "http://localhost:3000/api/users/1",
    "http://localhost:3000/api/users/2",
    "http://localhost:3000/api/products/1",
    "http://localhost:3000/api/products/2"
)

$errorEndpoints = @(
    "http://localhost:3000/api/error/500",
    "http://localhost:3000/api/nonexistent",
    "http://localhost:3000/api/users/99999",
    "http://localhost:3000/api/products/99999",
    "http://localhost:3000/api/error/exception"
)

$startTime = Get-Date
$endTime = $startTime.AddSeconds($DurationSeconds)
$totalRequests = 0
$successfulRequests = 0
$errorRequests = 0

Write-Host "Iniciando generacion de trafico mixto..." -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
Write-Host ""

while ((Get-Date) -lt $endTime) {
    $cycleStart = Get-Date
    
    for ($i = 0; $i -lt $RequestsPerSecond; $i++) {
        # Decidir si generar error o request normal
        $shouldError = (Get-Random -Minimum 1 -Maximum 101) -le $ErrorRatePercent
        
        if ($shouldError) {
            # Generar error
            $endpoint = $errorEndpoints | Get-Random
            $color = "Red"
            $symbol = "E"
        }
        else {
            # Request normal
            $endpoint = $normalEndpoints | Get-Random
            $color = "Green"
            $symbol = "."
        }
        
        try {
            $response = Invoke-WebRequest -Uri $endpoint -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            $totalRequests++
            
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                $successfulRequests++
                Write-Host $symbol -NoNewline -ForegroundColor $color
            }
            else {
                $errorRequests++
                Write-Host $symbol -NoNewline -ForegroundColor Red
            }
        }
        catch {
            $totalRequests++
            $errorRequests++
            Write-Host $symbol -NoNewline -ForegroundColor Red
        }
        
        # Pequena pausa entre requests
        Start-Sleep -Milliseconds (1000 / $RequestsPerSecond)
    }
    
    # Ajustar para mantener la tasa
    $cycleEnd = Get-Date
    $cycleDuration = ($cycleEnd - $cycleStart).TotalMilliseconds
    $sleepTime = 1000 - $cycleDuration
    
    if ($sleepTime -gt 0) {
        Start-Sleep -Milliseconds $sleepTime
    }
    
    # Mostrar progreso cada 10 segundos
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
    if ($elapsed % 10 -eq 0 -and $elapsed -gt 0) {
        $errorRate = if ($totalRequests -gt 0) { [math]::Round(($errorRequests / $totalRequests) * 100, 1) } else { 0 }
        Write-Host ""
        Write-Host "[$elapsed s] Total: $totalRequests, Exitosos: $successfulRequests, Errores: $errorRequests ($errorRate%)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
$actualErrorRate = if ($totalRequests -gt 0) { [math]::Round(($errorRequests / $totalRequests) * 100, 1) } else { 0 }
Write-Host "Total de requests: $totalRequests" -ForegroundColor White
Write-Host "Exitosos: $successfulRequests" -ForegroundColor Green
Write-Host "Errores: $errorRequests" -ForegroundColor Red
Write-Host "Tasa de errores real: $actualErrorRate%" -ForegroundColor Yellow
Write-Host "Tasa promedio: $([math]::Round($totalRequests / $DurationSeconds, 2)) req/s" -ForegroundColor White
Write-Host ""

Write-Host "=== Ver Resultados ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Error Rate Dashboard:" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/d/app-performance-dashboard" -ForegroundColor White
Write-Host ""
Write-Host "2. Error Traces:" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/d/distributed-tracing" -ForegroundColor White
Write-Host ""
Write-Host "3. SLI/SLO Dashboard:" -ForegroundColor Yellow
Write-Host "   http://localhost:3001/d/slo-dashboard" -ForegroundColor White
Write-Host ""

Write-Host "Leyenda:" -ForegroundColor Cyan
Write-Host "  . = Request exitoso" -ForegroundColor Green
Write-Host "  E = Error generado" -ForegroundColor Red
Write-Host ""
