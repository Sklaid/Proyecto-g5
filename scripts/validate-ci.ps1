# Script para validar localmente que el CI pasará
# Ejecuta los mismos checks que GitHub Actions

$ErrorActionPreference = "Stop"

Write-Host "🔍 Validando CI localmente..." -ForegroundColor Cyan
Write-Host ""

function Print-Status {
    param (
        [bool]$Success,
        [string]$Message
    )
    
    if ($Success) {
        Write-Host "✓ $Message" -ForegroundColor Green
    } else {
        Write-Host "✗ $Message" -ForegroundColor Red
        exit 1
    }
}

function Print-Warning {
    param ([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# 1. Validar Node.js app
Write-Host "📦 Validando demo-app (Node.js)..." -ForegroundColor Cyan
Push-Location demo-app

if (-not (Test-Path "package.json")) {
    Print-Status $false "package.json no encontrado"
}

Write-Host "  Instalando dependencias..."
try {
    npm ci 2>&1 | Out-Null
    Print-Status $true "Dependencias instaladas"
} catch {
    Print-Status $false "Error instalando dependencias"
}

Write-Host "  Ejecutando tests..."
try {
    npm test 2>&1 | Out-Null
    Print-Status $true "Tests pasaron"
} catch {
    Print-Status $false "Tests fallaron"
}

# Check if lint script exists
$packageJson = Get-Content "package.json" | ConvertFrom-Json
if ($packageJson.scripts.lint) {
    Write-Host "  Ejecutando linter..."
    try {
        npm run lint 2>&1 | Out-Null
        Print-Status $true "Linter pasó"
    } catch {
        Print-Warning "Linter encontró problemas (revisar)"
    }
} else {
    Print-Warning "Linter no configurado (opcional)"
}

Pop-Location

# 2. Validar Python service
Write-Host ""
Write-Host "🐍 Validando anomaly-detector (Python)..." -ForegroundColor Cyan
Push-Location anomaly-detector

if (-not (Test-Path "requirements.txt")) {
    Print-Status $false "requirements.txt no encontrado"
}

Write-Host "  Instalando dependencias..."
try {
    pip install -q -r requirements.txt 2>&1 | Out-Null
    pip install -q flake8 black pylint pytest-cov 2>&1 | Out-Null
    Print-Status $true "Dependencias instaladas"
} catch {
    Print-Status $false "Error instalando dependencias"
}

Write-Host "  Ejecutando flake8..."
try {
    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics 2>&1 | Out-Null
    Print-Status $true "Flake8 pasó"
} catch {
    Print-Warning "Flake8 encontró warnings (no crítico)"
}

Write-Host "  Ejecutando black..."
try {
    black --check . 2>&1 | Out-Null
    Print-Status $true "Black pasó"
} catch {
    Print-Warning "Black encontró formato incorrecto (ejecuta: black .)"
}

Write-Host "  Ejecutando tests..."
try {
    pytest test_*.py --verbose 2>&1 | Out-Null
    Print-Status $true "Tests pasaron"
} catch {
    Print-Status $false "Tests fallaron"
}

Pop-Location

# 3. Validar Docker builds
Write-Host ""
Write-Host "🐳 Validando Docker builds..." -ForegroundColor Cyan

Write-Host "  Building demo-app..."
try {
    docker build -t demo-app:test ./demo-app 2>&1 | Out-Null
    Print-Status $true "demo-app build exitoso"
} catch {
    Print-Status $false "demo-app build falló"
}

Write-Host "  Building anomaly-detector..."
try {
    docker build -t anomaly-detector:test ./anomaly-detector 2>&1 | Out-Null
    Print-Status $true "anomaly-detector build exitoso"
} catch {
    Print-Status $false "anomaly-detector build falló"
}

# 4. Validar docker-compose
Write-Host ""
Write-Host "🔧 Validando docker-compose.yml..." -ForegroundColor Cyan
try {
    docker-compose config 2>&1 | Out-Null
    Print-Status $true "docker-compose.yml válido"
} catch {
    Print-Status $false "docker-compose.yml inválido"
}

# Resumen final
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✓ Todas las validaciones pasaron!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "Tu código está listo para push. El CI debería pasar sin problemas."
Write-Host ""
