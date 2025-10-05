# Guía: Generador de Errores de Prueba

## 🎯 Propósito

Estos scripts generan **errores controlados** para demostrar el funcionamiento de los dashboards de error tracking y monitoreo.

## 📝 Scripts Disponibles

### 1. generate-test-errors.ps1
**Genera errores puros para testing**

```powershell
# Generar 5 errores (default)
.\generate-test-errors.ps1

# Generar 10 errores con delay de 1 segundo
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1

# Generar 20 errores rápidamente
.\generate-test-errors.ps1 -ErrorCount 20 -DelaySeconds 0
```

**Tipos de errores generados:**
- ✅ Error 500 - Internal Server Error (PRUEBA)
- ✅ Error 404 - Not Found (PRUEBA)
- ✅ Error 500 - Exception (PRUEBA)
- ✅ Error 404 - Invalid User ID (PRUEBA)
- ✅ Error 404 - Invalid Product ID (PRUEBA)

### 2. generate-mixed-traffic.ps1
**Genera tráfico mixto (normal + errores)**

```powershell
# Tráfico mixto con 10% de errores (default)
.\generate-mixed-traffic.ps1

# 60 segundos, 5 req/s, 20% errores
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 20

# Tráfico intenso con pocos errores
.\generate-mixed-traffic.ps1 -DurationSeconds 120 -RequestsPerSecond 10 -ErrorRatePercent 5

# Simular alta tasa de errores
.\generate-mixed-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5 -ErrorRatePercent 30
```

**Características:**
- Mezcla requests normales y errores
- Tasa de errores configurable
- Simula tráfico real con fallos
- Útil para demos de SLO/SLI

### 3. generate-test-errors.bat
**Versión batch para Windows**

```bash
.\generate-test-errors.bat
```

Ejecuta el script PowerShell con parámetros por defecto.

## 🎨 Visualización de Errores

### Leyenda en Scripts

**generate-test-errors.ps1:**
```
✅ OK Error generado correctamente
⚠️ ADVERTENCIA: Status inesperado
❌ ERROR: No se pudo conectar
```

**generate-mixed-traffic.ps1:**
```
. = Request exitoso (verde)
E = Error generado (rojo)
```

## 📊 Dónde Ver los Errores

### 1. Application Performance Dashboard
**URL:** http://localhost:3001/d/app-performance-dashboard

**Paneles que muestran errores:**
- **Error Rate Breakdown by Status Code**
  - Muestra tasa de errores 4xx y 5xx
  - Gráfico de líneas con porcentaje
  
- **Response Status Code Distribution**
  - Pie chart con distribución de status codes
  - Muestra 2xx, 3xx, 4xx, 5xx

### 2. Distributed Tracing Dashboard
**URL:** http://localhost:3001/d/distributed-tracing

**Paneles que muestran errores:**
- **Error Traces**
  - Lista de traces con errores
  - Click para ver detalles del trace

### 3. SLI/SLO Dashboard
**URL:** http://localhost:3001/d/slo-dashboard

**Paneles que muestran errores:**
- **Error Rate (Threshold: 1%)**
  - Tasa de errores vs threshold
  - Alertas cuando supera 1%
  
- **Success Rate (SLO: 99.9%)**
  - Porcentaje de requests exitosos
  - Gauge mostrando compliance con SLO
  
- **Error Budget Burn Rate**
  - Velocidad de consumo del error budget
  - Multi-window (1h, 6h, 24h)

### 4. Tempo Explore
**URL:** http://localhost:3001/explore

**Query para ver errores:**
```traceql
{status=error}
```

O ejecuta:
```bash
.\open-tempo-explore.bat
```

### 5. Prometheus
**URL:** http://localhost:9090/graph

**Queries útiles:**
```promql
# Tasa de errores 4xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"4.."}[5m])) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100

# Tasa de errores 5xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100

# Total de errores
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"[45].."}[5m]))
```

## 🎯 Casos de Uso

### Demo 1: Mostrar Error Tracking Básico

```powershell
# 1. Generar tráfico normal
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5

# 2. Generar errores
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1

# 3. Ver en dashboard
# http://localhost:3001/d/app-performance-dashboard
```

### Demo 2: Simular Degradación de Servicio

```powershell
# Simular servicio con 25% de errores
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 25

# Ver impacto en SLO dashboard
# http://localhost:3001/d/slo-dashboard
```

### Demo 3: Probar Alertas de Error Rate

```powershell
# Generar muchos errores rápidamente
.\generate-test-errors.ps1 -ErrorCount 50 -DelaySeconds 0

# Ver si se disparan alertas (si están configuradas)
```

### Demo 4: Análisis de Traces con Errores

```powershell
# 1. Generar errores
.\generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 2

# 2. Abrir Tempo Explore
.\open-tempo-explore.bat

# 3. Buscar traces con errores
# Query: {status=error}

# 4. Click en un trace para ver detalles
```

## 📈 Métricas Esperadas

### Después de Generar Errores

**Error Rate:**
- Sin errores: 0%
- Con 5 errores de 100 requests: ~5%
- Con 10% error rate: ~10%

**Success Rate:**
- Sin errores: 100%
- Con 5% errores: 95%
- Con 10% errores: 90%

**Error Budget:**
- SLO: 99.9% (0.1% error budget)
- Con 1% errores: Budget consumido 10x más rápido
- Con 5% errores: Budget consumido 50x más rápido

## ⏱️ Timing

**Tiempo para ver resultados:**
- Prometheus scrape: 15 segundos
- Grafana refresh: 30 segundos (default)
- Total: ~30-45 segundos después de generar errores

**Tip:** Configura auto-refresh en Grafana:
- Click en el reloj (arriba derecha)
- Selecciona "5s" o "10s" para refresh automático

## 🎓 Escenarios de Demo

### Escenario 1: Sistema Saludable
```powershell
# Solo tráfico normal
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

**Resultado esperado:**
- Error Rate: 0%
- Success Rate: 100%
- SLO: Cumplido
- Error Budget: Intacto

### Escenario 2: Errores Ocasionales
```powershell
# 5% de errores
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 5
```

**Resultado esperado:**
- Error Rate: ~5%
- Success Rate: ~95%
- SLO: Violado (< 99.9%)
- Error Budget: Consumiéndose

### Escenario 3: Incidente Mayor
```powershell
# 30% de errores
.\generate-mixed-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5 -ErrorRatePercent 30
```

**Resultado esperado:**
- Error Rate: ~30%
- Success Rate: ~70%
- SLO: Severamente violado
- Error Budget: Consumido rápidamente
- Alertas: Deberían dispararse

### Escenario 4: Recuperación
```powershell
# 1. Generar incidente
.\generate-mixed-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5 -ErrorRatePercent 30

# 2. Esperar 10 segundos

# 3. Tráfico normal (recuperación)
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

**Resultado esperado:**
- Error Rate: Baja gradualmente
- Success Rate: Sube gradualmente
- Error Budget: Deja de consumirse

## 🔧 Troubleshooting

### Los errores no aparecen en dashboards

1. **Espera 30-45 segundos** para que Prometheus scrape
2. **Refresca el dashboard** (Ctrl+F5)
3. **Verifica time range** (debe incluir el momento de los errores)
4. **Genera más errores** para tener datos suficientes

### Error rate muestra 0% después de generar errores

1. **Verifica en Prometheus:**
   ```
   http://localhost:9090/graph
   Query: http_server_duration_milliseconds_count{http_status_code=~"[45].."}
   ```

2. **Verifica que los errores se generaron:**
   ```powershell
   # Debe mostrar "OK Error generado correctamente"
   .\generate-test-errors.ps1 -ErrorCount 1 -DelaySeconds 0
   ```

3. **Genera más errores:**
   ```powershell
   .\generate-test-errors.ps1 -ErrorCount 20 -DelaySeconds 0
   ```

### Script falla con "No se pudo conectar"

1. **Verifica que demo-app esté corriendo:**
   ```bash
   docker-compose ps demo-app
   ```

2. **Verifica que responda:**
   ```bash
   curl http://localhost:3000/health
   ```

3. **Reinicia demo-app si es necesario:**
   ```bash
   docker-compose restart demo-app
   ```

## 📝 Notas Importantes

### Errores son Controlados

Todos los errores generados son **intencionales y seguros**:
- ✅ No dañan la aplicación
- ✅ No afectan datos reales
- ✅ Son para demostración y testing
- ✅ Tienen nombres claros indicando que son pruebas

### Endpoints de Error

La aplicación tiene endpoints específicos para generar errores:
```
/api/error/500 - Error 500 simulado
/api/error/exception - Excepción simulada
/api/error/timeout - Timeout simulado (5 segundos)
```

### Limpieza

Los errores generados:
- Se almacenan en métricas de Prometheus (15 días retention)
- Se almacenan en traces de Tempo
- No requieren limpieza manual
- Desaparecen automáticamente después del retention period

## 🚀 Comandos Rápidos

```powershell
# Generar 5 errores
.\generate-test-errors.ps1

# Tráfico mixto 10% errores
.\generate-mixed-traffic.ps1

# Tráfico mixto 20% errores, 2 minutos
.\generate-mixed-traffic.ps1 -DurationSeconds 120 -ErrorRatePercent 20

# Ver errores en Tempo
.\open-tempo-explore.bat

# Abrir todos los dashboards
.\open-all-dashboards.bat
```

---

**Fecha:** 5 de octubre de 2025
**Propósito:** Demostración y testing de error tracking
**Estado:** ✅ Scripts listos para usar
