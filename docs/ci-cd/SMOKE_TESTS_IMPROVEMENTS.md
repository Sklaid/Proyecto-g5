# Mejoras al Script de Smoke Tests

## 🔧 Cambios Realizados

### 1. Manejo de Errores Mejorado

**Antes:**
```powershell
$ErrorActionPreference = "Stop"
# El script se detenía ante cualquier error
```

**Después:**
```powershell
$ErrorActionPreference = "Continue"
# El script continúa y reporta todos los errores
```

**Beneficio:** Ahora ves todos los problemas, no solo el primero.

### 2. Retry Logic

**Antes:**
```powershell
# Un solo intento por endpoint
Test-Endpoint "http://localhost:3000/health"
```

**Después:**
```powershell
# 3 intentos con delay de 2 segundos
Test-Endpoint "http://localhost:3000/health" "Demo App" 3 2
```

**Beneficio:** Más robusto ante servicios que tardan en iniciar.

### 3. Verificación de Prerequisites

**Nuevo:**
```powershell
# Verifica que Docker esté instalado y corriendo
Write-Host "📋 Verificando prerequisites..."
docker --version
```

**Beneficio:** Detecta problemas antes de ejecutar tests.

### 4. Mejor Detección de Contenedores

**Antes:**
```powershell
# Podía fallar silenciosamente
$containers = docker ps --format "{{.Names}}"
```

**Después:**
```powershell
# Verifica que Docker esté corriendo primero
$dockerRunning = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker no está corriendo"
}
```

**Beneficio:** Mensajes de error más claros.

### 5. Resumen Mejorado

**Nuevo:**
```powershell
# Muestra tasa de éxito
$successRate = ($testsPassed / $totalTests) * 100
Write-Host "Tasa de éxito: $successRate%"

# Próximos pasos si todo pasa
Write-Host "Próximos pasos:"
Write-Host "  1. Acceder a Grafana..."

# Troubleshooting si algo falla
Write-Host "Troubleshooting:"
Write-Host "  1. Verificar servicios..."
```

**Beneficio:** Guía clara sobre qué hacer después.

---

## 🚀 Cómo Usar el Script Mejorado

### Uso Básico

```powershell
.\scripts\smoke-tests.ps1
```

### Salida Esperada (Éxito)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Smoke Tests - AIOps Platform
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Verificando prerequisites...
✓ Docker instalado: Docker version 28.4.0

🧪 Ejecutando tests...

🏥 Health Checks...
✓ Demo App - Health
✓ Demo App - Ready
✓ Prometheus - Health
✓ Grafana - Health
✓ Tempo - Ready

📊 Metrics Baseline Check...
✓ Prometheus está recopilando métricas
✓ Demo app está reportando métricas

🔍 Trace Validation...
✓ Tráfico de prueba generado
✓ Tempo está procesando trazas

📈 Grafana Datasources...
✓ Prometheus datasource configurado
✓ Tempo datasource configurado

🐳 Container Status...
✓ demo-app está corriendo
✓ otel-collector está corriendo
✓ prometheus está corriendo
✓ tempo está corriendo
✓ grafana está corriendo
✓ anomaly-detector está corriendo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Resumen de Smoke Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests pasados:  17
Tests fallidos: 0
Tasa de éxito: 100%

✅ ¡Todos los smoke tests pasaron!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
El sistema está funcionando correctamente.

Próximos pasos:
  1. Acceder a Grafana: http://localhost:3001 (admin/admin)
  2. Generar tráfico: .\generate-traffic.bat
  3. Ver dashboards y métricas
```

### Salida Esperada (Con Errores)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Smoke Tests - AIOps Platform
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Verificando prerequisites...
✓ Docker instalado: Docker version 28.4.0

🧪 Ejecutando tests...

🏥 Health Checks...
  Intento 1/3 falló, reintentando...
  Intento 2/3 falló, reintentando...
✗ Demo App - Health (Error: Connection refused)
✓ Prometheus - Health
✓ Grafana - Health

...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Resumen de Smoke Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests pasados:  12
Tests fallidos: 5
Tasa de éxito: 70.59%

❌ Algunos tests fallaron (5/17)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Troubleshooting:
  1. Verificar servicios: docker-compose ps
  2. Ver logs: docker-compose logs
  3. Reiniciar: docker-compose restart
  4. Rebuild: docker-compose down && docker-compose up -d

Ver logs específicos:
  docker-compose logs demo-app
  docker-compose logs prometheus
  docker-compose logs grafana
```

---

## 🔍 Troubleshooting

### Problema: Docker no está corriendo

**Síntoma:**
```
✗ Docker no está corriendo o no es accesible
```

**Solución:**
1. Abrir Docker Desktop
2. Esperar a que inicie completamente
3. Volver a ejecutar el script

### Problema: Servicios no responden

**Síntoma:**
```
Intento 1/3 falló, reintentando...
Intento 2/3 falló, reintentando...
✗ Demo App - Health (Falló después de 3 intentos)
```

**Solución:**
```powershell
# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs demo-app

# Reiniciar servicio
docker-compose restart demo-app

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Reintentar tests
.\scripts\smoke-tests.ps1
```

### Problema: Contenedores no están corriendo

**Síntoma:**
```
✗ demo-app NO está corriendo
✗ prometheus NO está corriendo
```

**Solución:**
```powershell
# Iniciar servicios
docker-compose up -d

# Esperar inicialización
Start-Sleep -Seconds 60

# Ejecutar tests
.\scripts\smoke-tests.ps1
```

### Problema: Métricas no disponibles

**Síntoma:**
```
⚠ Demo app aún no tiene métricas (puede ser normal si recién inició)
```

**Solución:**
```powershell
# Generar tráfico
.\generate-traffic.bat

# Esperar scrape interval
Start-Sleep -Seconds 30

# Reintentar tests
.\scripts\smoke-tests.ps1
```

---

## 📊 Interpretación de Resultados

### Tasa de Éxito

| Tasa | Estado | Acción |
|------|--------|--------|
| 100% | ✅ Perfecto | Sistema completamente funcional |
| 80-99% | ⚠️ Aceptable | Algunos servicios pueden estar iniciando |
| 50-79% | ⚠️ Problemas | Revisar logs y reiniciar servicios |
| <50% | ❌ Crítico | Rebuild completo necesario |

### Tests Críticos

Estos tests DEBEN pasar:
- ✅ Docker instalado
- ✅ Al menos 4/6 contenedores corriendo
- ✅ Prometheus Health
- ✅ Grafana Health

### Tests Opcionales

Estos pueden fallar inicialmente:
- ⚠️ Demo app métricas (necesita tráfico)
- ⚠️ Trazas en Tempo (necesita tráfico)

---

## 🎯 Mejores Prácticas

### 1. Esperar Antes de Ejecutar

```powershell
# Después de docker-compose up -d
Start-Sleep -Seconds 60
.\scripts\smoke-tests.ps1
```

### 2. Generar Tráfico Primero

```powershell
# Iniciar servicios
docker-compose up -d
Start-Sleep -Seconds 60

# Generar tráfico
.\generate-traffic.bat

# Ejecutar tests
.\scripts\smoke-tests.ps1
```

### 3. Ejecutar Múltiples Veces

```powershell
# Primera ejecución (puede tener warnings)
.\scripts\smoke-tests.ps1

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Segunda ejecución (debería pasar todo)
.\scripts\smoke-tests.ps1
```

---

## 📚 Documentación Relacionada

- [Quick Start](QUICK_START.md)
- [Validation Guide](VALIDATION_GUIDE.md)
- [Execution Summary](EXECUTION_SUMMARY.md)
- [Smoke Tests README](scripts/SMOKE_TESTS_README.md)

---

## ✅ Checklist de Validación

Antes de ejecutar smoke tests:

- [ ] Docker Desktop está corriendo
- [ ] Servicios levantados (`docker-compose up -d`)
- [ ] Esperado 60 segundos para inicialización
- [ ] Generado tráfico de prueba (opcional)

Durante la ejecución:

- [ ] Prerequisites pasan
- [ ] Health checks pasan
- [ ] Métricas disponibles
- [ ] Contenedores corriendo

Después de la ejecución:

- [ ] Tasa de éxito >= 80%
- [ ] Tests críticos pasan
- [ ] Grafana accesible
- [ ] Dashboards muestran datos

---

**Script mejorado y listo para usar!** 🎉

Ejecuta: `.\scripts\smoke-tests.ps1`
