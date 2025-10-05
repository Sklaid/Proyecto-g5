# ✅ Generador de Errores - Implementado

## 🎉 Scripts Creados

Se han creado 3 scripts para generar errores controlados y demostrar el error tracking:

### 1. generate-test-errors.ps1
**Genera errores puros para testing**

```powershell
.\generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 1
```

**Resultado:** ✅ 5 errores generados exitosamente

### 2. generate-mixed-traffic.ps1
**Genera tráfico mixto (normal + errores)**

```powershell
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 10
```

**Características:**
- Mezcla requests normales y errores
- Tasa de errores configurable
- Simula tráfico real con fallos

### 3. generate-test-errors.bat
**Versión batch para Windows**

```bash
.\generate-test-errors.bat
```

## 🎯 Tipos de Errores Generados

Todos los errores tienen nombres claros indicando que son PRUEBAS:

1. **Error 500 - Internal Server Error (PRUEBA)**
   - Endpoint: `/api/error/500`
   - Simula error interno del servidor

2. **Error 404 - Not Found (PRUEBA)**
   - Endpoint: `/api/nonexistent-endpoint`
   - Endpoint que no existe

3. **Error 500 - Exception (PRUEBA)**
   - Endpoint: `/api/error/exception`
   - Simula excepción no manejada

4. **Error 404 - Invalid User ID (PRUEBA)**
   - Endpoint: `/api/users/99999`
   - Usuario que no existe

5. **Error 404 - Invalid Product ID (PRUEBA)**
   - Endpoint: `/api/products/99999`
   - Producto que no existe

## 📊 Dónde Ver los Errores

### 1. Application Performance Dashboard
```
http://localhost:3001/d/app-performance-dashboard
```

**Paneles:**
- Error Rate Breakdown by Status Code
- Response Status Code Distribution

### 2. Distributed Tracing Dashboard
```
http://localhost:3001/d/distributed-tracing
```

**Paneles:**
- Error Traces

### 3. SLI/SLO Dashboard
```
http://localhost:3001/d/slo-dashboard
```

**Paneles:**
- Error Rate (Threshold: 1%)
- Success Rate (SLO: 99.9%)
- Error Budget Burn Rate

### 4. Tempo Explore
```
http://localhost:3001/explore
Query: {status=error}
```

O ejecuta: `.\open-tempo-explore.bat`

## 🚀 Uso Rápido

### Generar Errores Simples
```powershell
.\generate-test-errors.ps1
```

### Generar Muchos Errores
```powershell
.\generate-test-errors.ps1 -ErrorCount 20 -DelaySeconds 0
```

### Simular Tráfico con Errores
```powershell
# 10% de errores
.\generate-mixed-traffic.ps1

# 20% de errores
.\generate-mixed-traffic.ps1 -ErrorRatePercent 20

# 30% de errores (incidente mayor)
.\generate-mixed-traffic.ps1 -ErrorRatePercent 30
```

## 🎓 Escenarios de Demo

### Demo 1: Sistema Saludable → Errores → Recuperación

```powershell
# 1. Tráfico normal (30 segundos)
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5

# 2. Generar errores
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1

# 3. Tráfico normal nuevamente (recuperación)
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5
```

### Demo 2: Simular Degradación de Servicio

```powershell
# Servicio con 25% de errores
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 25
```

### Demo 3: Análisis de Traces con Errores

```powershell
# 1. Generar errores
.\generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 2

# 2. Abrir Tempo Explore
.\open-tempo-explore.bat

# 3. Buscar: {status=error}
# 4. Click en un trace para ver detalles
```

## ⏱️ Timing

**Tiempo para ver resultados:**
- Prometheus scrape: ~15 segundos
- Grafana refresh: ~30 segundos
- **Total: 30-45 segundos** después de generar errores

**Tip:** Configura auto-refresh en Grafana (5s o 10s)

## ✅ Verificación

### Errores Generados Exitosamente
```
✅ Total de errores generados: 5
✅ Errores exitosos: 5
✅ Fallidos: 0
```

### Métricas Esperadas

**Después de 5 errores:**
- Error Rate: Visible en dashboard
- Status Codes: 404 y 500 aparecen
- Error Traces: Disponibles en Tempo
- SLO: Puede verse afectado

## 📝 Notas Importantes

### Errores son Seguros
- ✅ Controlados e intencionales
- ✅ No dañan la aplicación
- ✅ No afectan datos reales
- ✅ Nombres claros: "(PRUEBA)"

### Limpieza
- No requiere limpieza manual
- Métricas se retienen 15 días
- Traces se retienen según configuración de Tempo

## 📚 Documentación

- **GENERADOR_ERRORES_GUIA.md** - Guía completa
- **generate-test-errors.ps1** - Script principal
- **generate-mixed-traffic.ps1** - Tráfico mixto
- **generate-test-errors.bat** - Versión batch

## 🎉 Resultado

**¡Scripts de generación de errores listos y funcionando!**

Ahora puedes:
1. Demostrar error tracking
2. Probar dashboards de errores
3. Simular incidentes
4. Analizar traces con errores
5. Validar alertas de error rate

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Implementado y Probado
**Errores generados:** 5/5 exitosos
