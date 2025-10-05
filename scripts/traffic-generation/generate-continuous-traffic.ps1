#!/usr/bin/env pwsh
# Script para generar trafico continuo hacia la aplicacion

param(
    [int]$DurationSeconds = 60,
    [int]$RequestsPerSecond = 5
)

Write-Host "=== Generador de Trafico Continuo ===" -ForegroundColor Cyan
Write-Host "Duracion: $DurationSeconds segundos" -ForegroundColor White
Write-Host "Tasa: $RequestsPerSecond requests/segundo" -ForegroundColor White
Write-Host ""

$endpoints = @(
    "http://localhost:3000/api/users",
    "http://localhost:3000/api/products",
    "http://localhost:3000/health"
)

$startTime = Get-Date
$endTime = $startTime.AddSeconds($DurationSeconds)
$totalRequests = 0
$successfulRequests = 0
$failedRequests = 0

Write-Host "Iniciando generacion de trafico..." -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
Write-Host ""

while ((Get-Date) -lt $endTime) {
    $cycleStart = Get-Date
    
    for ($i = 0; $i -lt $RequestsPerSecond; $i++) {
        $endpoint = $endpoints | Get-Random
        
        try {
            $response = Invoke-WebRequest -Uri $endpoint -Method GET -UseBasicParsing -TimeoutSec 2
            $totalRequests++
            $successfulRequests++
            Write-Host "." -NoNewline -ForegroundColor Green
        }
        catch {
            $totalRequests++
            $failedRequests++
            Write-Host "x" -NoNewline -ForegroundColor Red
        }
        
        # Pequena pausa entre requests
        Start-Sleep -Milliseconds (1000 / $RequestsPerSecond)
    }
    
    # Ajustar para mantener la tasa de requests por segundo
    $cycleEnd = Get-Date
    $cycleDuration = ($cycleEnd - $cycleStart).TotalMilliseconds
    $sleepTime = 1000 - $cycleDuration
    
    if ($sleepTime -gt 0) {
        Start-Sleep -Milliseconds $sleepTime
    }
    
    # Mostrar progreso cada 10 segundos
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
    if ($elapsed % 10 -eq 0 -and $elapsed -gt 0) {
        Write-Host ""
        Write-Host "[$elapsed s] Total: $totalRequests, Exitosos: $successfulRequests, Fallidos: $failedRequests" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "Total de requests: $totalRequests" -ForegroundColor White
Write-Host "Exitosos: $successfulRequests" -ForegroundColor Green
Write-Host "Fallidos: $failedRequests" -ForegroundColor Red
Write-Host "Tasa promedio: $([math]::Round($totalRequests / $DurationSeconds, 2)) req/s" -ForegroundColor White
Write-Host ""
Write-Host "Ahora puedes verificar los dashboards en Grafana:" -ForegroundColor Cyan
Write-Host "  http://localhost:3001" -ForegroundColor White
Write-Host ""
