#!/bin/bash

# Script para validar localmente que el CI pasará
# Ejecuta los mismos checks que GitHub Actions

set -e

echo "🔍 Validando CI localmente..."
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Validar Node.js app
echo "📦 Validando demo-app (Node.js)..."
cd demo-app

if [ ! -f "package.json" ]; then
    print_status 1 "package.json no encontrado"
fi

echo "  Instalando dependencias..."
npm ci > /dev/null 2>&1
print_status $? "Dependencias instaladas"

echo "  Ejecutando tests..."
npm test > /dev/null 2>&1
print_status $? "Tests pasaron"

if command -v npm run lint &> /dev/null; then
    echo "  Ejecutando linter..."
    npm run lint > /dev/null 2>&1
    print_status $? "Linter pasó"
else
    print_warning "Linter no configurado (opcional)"
fi

cd ..

# 2. Validar Python service
echo ""
echo "🐍 Validando anomaly-detector (Python)..."
cd anomaly-detector

if [ ! -f "requirements.txt" ]; then
    print_status 1 "requirements.txt no encontrado"
fi

echo "  Instalando dependencias..."
pip install -q -r requirements.txt > /dev/null 2>&1
pip install -q flake8 black pylint pytest-cov > /dev/null 2>&1
print_status $? "Dependencias instaladas"

echo "  Ejecutando flake8..."
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status 0 "Flake8 pasó"
else
    print_warning "Flake8 encontró warnings (no crítico)"
fi

echo "  Ejecutando black..."
black --check . > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status 0 "Black pasó"
else
    print_warning "Black encontró formato incorrecto (ejecuta: black .)"
fi

echo "  Ejecutando tests..."
pytest test_*.py --verbose > /dev/null 2>&1
print_status $? "Tests pasaron"

cd ..

# 3. Validar Docker builds
echo ""
echo "🐳 Validando Docker builds..."

echo "  Building demo-app..."
docker build -t demo-app:test ./demo-app > /dev/null 2>&1
print_status $? "demo-app build exitoso"

echo "  Building anomaly-detector..."
docker build -t anomaly-detector:test ./anomaly-detector > /dev/null 2>&1
print_status $? "anomaly-detector build exitoso"

# 4. Validar YAML syntax
echo ""
echo "📝 Validando sintaxis de workflows..."

if command -v yamllint &> /dev/null; then
    yamllint .github/workflows/*.yml > /dev/null 2>&1
    print_status $? "Sintaxis YAML válida"
else
    print_warning "yamllint no instalado (opcional)"
fi

# 5. Validar docker-compose
echo ""
echo "🔧 Validando docker-compose.yml..."
docker-compose config > /dev/null 2>&1
print_status $? "docker-compose.yml válido"

# Resumen final
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Todas las validaciones pasaron!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tu código está listo para push. El CI debería pasar sin problemas."
echo ""
