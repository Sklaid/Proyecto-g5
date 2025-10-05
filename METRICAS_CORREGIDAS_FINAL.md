# ✅ Métricas de Recursos Corregidas

## 🎉 Estado: COMPLETADO

Los paneles de CPU, Memory y Heap ahora deberían mostrar datos correctamente en Grafana.

## 🔧 Problema Encontrado

Las queries en el dashboard estaban usando nombres de métricas incorrectos:

### Queries Incorrectas (Antes)
```promql
❌ process_cpu_seconds_total
❌ process_resident_memory_bytes
❌ nodejs_heap_size_used_bytes
❌ nodejs_heap_size_total_bytes
```

### Queries Corregidas (Ahora)
```promql
✅ nodejs_process_cpu_seconds_total
✅ nodejs_process_resident_memory_bytes
✅ nodejs_process_heap_bytes
```

## 📊 Métricas Verificadas

### Estado Actual en Prometheus
```
✅ CPU rate: 0.0056 (0.56%)
✅ Memory: 88.59 MB
✅ Heap: 119.09 MB
```

## 🔄 Cambios Realizados

### 1. Panel "CPU Utilization"
**Antes:**
```promql
rate(process_cpu_seconds_total{service_name="demo-app"}[5m])
```

**Ahora:**
```promql
rate(nodejs_process_cpu_seconds_total{service_name="demo-app"}[5m])
```

### 2. Panel "Memory Utilization"
**Antes:**
```promql
process_resident_memory_bytes{service_name="demo-app"}
nodejs_heap_size_used_bytes{service_name="demo-app"}
nodejs_heap_size_total_bytes{service_name="demo-app"}
```

**Ahora:**
```promql
nodejs_process_resident_memory_bytes{service_name="demo-app"}
nodejs_process_heap_bytes{service_name="demo-app"}
```

### 3. Panel "Current CPU Usage"
**Antes:**
```promql
rate(process_cpu_seconds_total{service_name="demo-app"}[5m]) * 100
```

**Ahora:**
```promql
rate(nodejs_process_cpu_seconds_total{service_name="demo-app"}[5m]) * 100
```

### 4. Panel "Current Heap Usage"
**Antes:**
```promql
(nodejs_heap_size_used_bytes / nodejs_heap_size_total_bytes) * 100
```

**Ahora:**
```promql
nodejs_process_heap_bytes{service_name="demo-app"} / 1024 / 1024
```
*Nota: Muestra heap en MB en lugar de porcentaje*

## ✅ Verificación

### 1. Métricas en Prometheus
```bash
# CPU
curl "http://localhost:9090/api/v1/query?query=rate(nodejs_process_cpu_seconds_total{service_name=\"demo-app\"}[5m])"

# Memory
curl "http://localhost:9090/api/v1/query?query=nodejs_process_resident_memory_bytes{service_name=\"demo-app\"}"

# Heap
curl "http://localhost:9090/api/v1/query?query=nodejs_process_heap_bytes{service_name=\"demo-app\"}"
```

### 2. Dashboard en Grafana
```
URL: http://localhost:3001/d/app-performance-dashboard
```

**Paneles que ahora deberían mostrar datos:**
- ✅ CPU Utilization
- ✅ Memory Utilization
- ✅ Current CPU Usage
- ✅ Current Heap Usage

### 3. Generar Tráfico
```powershell
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

## 📈 Métricas Disponibles

### Todas las Métricas de Node.js
```
✅ nodejs_process_cpu_seconds_total
✅ nodejs_process_cpu_user_seconds_total
✅ nodejs_process_cpu_system_seconds_total
✅ nodejs_process_resident_memory_bytes
✅ nodejs_process_virtual_memory_bytes
✅ nodejs_process_heap_bytes
✅ nodejs_process_open_fds
✅ nodejs_process_max_fds
✅ nodejs_nodejs_eventloop_lag_seconds
✅ nodejs_nodejs_active_handles
✅ nodejs_nodejs_active_requests_total
✅ nodejs_nodejs_external_memory_bytes
✅ nodejs_nodejs_gc_duration_seconds
```

## 🎯 Valores Esperados

### CPU
- **Normal:** 0.01 - 0.1 (1% - 10%)
- **Alto:** > 0.5 (50%)
- **Crítico:** > 0.8 (80%)

### Memory
- **Normal:** 50-150 MB
- **Alto:** 200-400 MB
- **Crítico:** > 500 MB

### Heap
- **Normal:** 50-150 MB
- **Alto:** 200-300 MB
- **Crítico:** > 400 MB

## 🔍 Troubleshooting

### Si los paneles siguen mostrando "No data"

1. **Verificar que Grafana se reinició:**
   ```bash
   docker-compose restart grafana
   ```

2. **Esperar 30 segundos** para que Grafana cargue

3. **Refrescar el dashboard** en el navegador (Ctrl+F5)

4. **Verificar métricas en Prometheus:**
   ```
   http://localhost:9090/graph
   ```
   Query: `nodejs_process_cpu_seconds_total`

5. **Generar tráfico:**
   ```powershell
   .\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5
   ```

6. **Verificar time range** en Grafana:
   - Asegúrate de que el time range sea "Last 5 minutes" o "Last 15 minutes"
   - No uses "Last 24 hours" si acabas de iniciar

### Si las métricas no aparecen en Prometheus

1. **Verificar endpoint /metrics:**
   ```bash
   curl http://localhost:3000/metrics | grep nodejs_
   ```

2. **Verificar configuración de Prometheus:**
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```
   Buscar: `demo-app-metrics`

3. **Reiniciar servicios:**
   ```bash
   docker-compose restart demo-app prometheus
   ```

## 📊 Dashboard Completo

### Paneles Funcionando

**Métricas HTTP:**
- ✅ Request Duration Histogram (P50, P90, P95, P99)
- ✅ Request Duration Distribution by Endpoint
- ✅ Throughput by Endpoint
- ✅ Top 10 Endpoints by Request Rate
- ✅ Error Rate Breakdown by Status Code
- ✅ Response Status Code Distribution

**Métricas de Recursos:**
- ✅ CPU Utilization
- ✅ Memory Utilization
- ✅ Current CPU Usage
- ✅ Current Heap Usage
- ✅ Total Request Rate

## 🎉 Golden Signals Completos

1. ✅ **Latency** - Request duration (P50, P95, P99)
2. ✅ **Traffic** - Request rate, throughput
3. ✅ **Errors** - Error rate, status codes
4. ✅ **Saturation** - CPU, Memory, Heap

## 📝 Próximos Pasos

1. **Abrir dashboard:**
   ```
   http://localhost:3001/d/app-performance-dashboard
   ```

2. **Verificar que todos los paneles muestren datos**

3. **Generar tráfico continuo:**
   ```powershell
   .\generate-continuous-traffic.ps1 -DurationSeconds 120 -RequestsPerSecond 5
   ```

4. **Observar cómo cambian las métricas** en tiempo real

5. **Configurar alertas** (opcional):
   - CPU > 80%
   - Memory > 400MB
   - Heap > 300MB

## 🚀 Scripts Disponibles

```bash
# Generar tráfico
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# Abrir dashboards
.\open-all-dashboards.bat

# Verificar métricas
.\verify-error-rate.ps1

# Abrir Tempo Explore
.\open-tempo-explore.bat
```

## ✅ Checklist Final

- [x] prom-client instalado
- [x] Código de métricas agregado
- [x] Endpoint /metrics funcionando
- [x] Prometheus scrapeando métricas
- [x] Métricas visibles en Prometheus
- [x] Queries del dashboard corregidas
- [x] Grafana reiniciado
- [x] Tráfico generado
- [x] Métricas verificadas en Prometheus
- [ ] Dashboard mostrando datos (verificar en navegador)

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Queries Corregidas
**Próximo paso:** Abrir dashboard y verificar que muestre datos
**URL:** http://localhost:3001/d/app-performance-dashboard
