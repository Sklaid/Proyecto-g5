# ✅ Métricas de Node.js Implementadas

## 🎉 Estado: COMPLETADO

Las métricas de CPU, Memory y Heap de Node.js están ahora disponibles en Grafana.

## 📊 Métricas Implementadas

### 1. CPU Metrics
```
✅ nodejs_process_cpu_seconds_total
✅ nodejs_process_cpu_user_seconds_total
✅ nodejs_process_cpu_system_seconds_total
```

**Valor actual:** 0.65 segundos de CPU
**Dashboard:** CPU Utilization panel

### 2. Memory Metrics
```
✅ nodejs_process_resident_memory_bytes
✅ nodejs_process_virtual_memory_bytes
✅ nodejs_process_heap_bytes
```

**Valor actual:** 79.73 MB de memoria residente
**Dashboard:** Memory Utilization panel

### 3. Heap Metrics (Node.js)
```
✅ nodejs_process_heap_bytes
✅ nodejs_heap_size_total_bytes (si está disponible)
✅ nodejs_heap_size_used_bytes (si está disponible)
```

**Valor actual:** 109.29 MB de heap
**Dashboard:** Current Heap Usage panel

### 4. Métricas Adicionales
```
✅ nodejs_process_open_fds - File descriptors abiertos
✅ nodejs_process_max_fds - Máximo de file descriptors
✅ nodejs_nodejs_eventloop_lag_seconds - Event loop lag
✅ nodejs_process_start_time_seconds - Tiempo de inicio
```

## 🔧 Cambios Realizados

### 1. Instalación de prom-client
```bash
cd demo-app
npm install prom-client
```

### 2. Código Agregado en demo-app/src/index.js

**Importación y configuración:**
```javascript
const promClient = require('prom-client');

const register = new promClient.Registry();
promClient.collectDefaultMetrics({ 
  register,
  prefix: 'nodejs_',
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
  eventLoopMonitoringPrecision: 10
});
```

**Endpoint de métricas:**
```javascript
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});
```

### 3. Configuración de Prometheus

**Agregado en prometheus/prometheus.yml:**
```yaml
- job_name: 'demo-app-metrics'
  scrape_interval: 15s
  metrics_path: '/metrics'
  static_configs:
    - targets: ['demo-app:3000']
      labels:
        service: 'demo-app'
        service_name: 'demo-app'
```

### 4. Reconstrucción y Reinicio

```bash
docker-compose stop demo-app prometheus
docker-compose build demo-app
docker-compose up -d demo-app prometheus
```

## ✅ Verificación

### Endpoint /metrics
```bash
curl http://localhost:3000/metrics
```

**Resultado:**
```
✅ nodejs_process_cpu_seconds_total 0.647005
✅ nodejs_process_resident_memory_bytes 83607552
✅ nodejs_process_heap_bytes 114556928
✅ nodejs_nodejs_eventloop_lag_seconds 0.002531771
✅ ... y más métricas
```

### Prometheus
```bash
# CPU
curl "http://localhost:9090/api/v1/query?query=nodejs_process_cpu_seconds_total"

# Memory
curl "http://localhost:9090/api/v1/query?query=nodejs_process_resident_memory_bytes"

# Heap
curl "http://localhost:9090/api/v1/query?query=nodejs_process_heap_bytes"
```

**Resultado:**
```
✅ 1 serie encontrada para cada métrica
✅ Service: demo-app
✅ Valores actualizándose cada 15 segundos
```

### Grafana Dashboard

**URL:** http://localhost:3001/d/app-performance-dashboard

**Paneles que ahora muestran datos:**
- ✅ CPU Utilization
- ✅ Memory Utilization
- ✅ Current CPU Usage (Gauge)
- ✅ Current Heap Usage (Gauge)

## 📈 Métricas Disponibles

### Completas (4/4 Golden Signals)

1. ✅ **Latency** - http_server_duration_milliseconds
2. ✅ **Traffic** - request count
3. ✅ **Errors** - status codes
4. ✅ **Saturation** - CPU, Memory, Heap ← **NUEVO**

## 🎯 Uso de las Métricas

### 1. Monitoreo de CPU

**Query en Prometheus:**
```promql
# CPU usage rate
rate(nodejs_process_cpu_seconds_total{service_name="demo-app"}[5m])

# CPU percentage
rate(nodejs_process_cpu_seconds_total{service_name="demo-app"}[5m]) * 100
```

**Alertas recomendadas:**
```yaml
- alert: HighCPUUsage
  expr: rate(nodejs_process_cpu_seconds_total[5m]) > 0.8
  for: 5m
  annotations:
    summary: "High CPU usage on {{ $labels.service_name }}"
```

### 2. Monitoreo de Memory

**Query en Prometheus:**
```promql
# Memory in MB
nodejs_process_resident_memory_bytes{service_name="demo-app"} / 1024 / 1024

# Memory trend
rate(nodejs_process_resident_memory_bytes{service_name="demo-app"}[5m])
```

**Alertas recomendadas:**
```yaml
- alert: HighMemoryUsage
  expr: nodejs_process_resident_memory_bytes > 400000000
  for: 5m
  annotations:
    summary: "High memory usage: {{ $value | humanize }}B"
```

### 3. Monitoreo de Heap

**Query en Prometheus:**
```promql
# Heap in MB
nodejs_process_heap_bytes{service_name="demo-app"} / 1024 / 1024

# Heap usage percentage (si tienes heap_size_total)
(nodejs_heap_size_used_bytes / nodejs_heap_size_total_bytes) * 100
```

**Alertas recomendadas:**
```yaml
- alert: HighHeapUsage
  expr: (nodejs_heap_size_used_bytes / nodejs_heap_size_total_bytes) > 0.85
  for: 5m
  annotations:
    summary: "High heap usage: {{ $value }}%"
```

### 4. Event Loop Lag

**Query en Prometheus:**
```promql
# Event loop lag in milliseconds
nodejs_nodejs_eventloop_lag_seconds{service_name="demo-app"} * 1000
```

**Alertas recomendadas:**
```yaml
- alert: HighEventLoopLag
  expr: nodejs_nodejs_eventloop_lag_seconds > 0.1
  for: 2m
  annotations:
    summary: "High event loop lag: {{ $value }}s"
```

## 🔍 Debugging con Métricas

### Detectar Memory Leaks

1. **Ver tendencia de memoria:**
   ```promql
   nodejs_process_resident_memory_bytes{service_name="demo-app"}
   ```

2. **Si la memoria crece constantemente:**
   - Posible memory leak
   - Revisar código para objetos no liberados
   - Verificar event listeners no removidos

### Detectar CPU Bottlenecks

1. **Ver CPU usage:**
   ```promql
   rate(nodejs_process_cpu_seconds_total{service_name="demo-app"}[5m])
   ```

2. **Si CPU está alto:**
   - Revisar operaciones síncronas
   - Optimizar loops
   - Usar workers para tareas pesadas

### Detectar Event Loop Blocking

1. **Ver event loop lag:**
   ```promql
   nodejs_nodejs_eventloop_lag_seconds{service_name="demo-app"}
   ```

2. **Si lag es alto (> 100ms):**
   - Operaciones síncronas bloqueando
   - Usar async/await correctamente
   - Mover procesamiento pesado a workers

## 📊 Dashboards Actualizados

### Application Performance Dashboard

**Paneles funcionando:**
- ✅ Request Duration Histogram (P50, P90, P95, P99)
- ✅ Throughput by Endpoint
- ✅ Error Rate Breakdown
- ✅ CPU Utilization ← **NUEVO**
- ✅ Memory Utilization ← **NUEVO**
- ✅ Current CPU Usage ← **NUEVO**
- ✅ Current Heap Usage ← **NUEVO**
- ✅ Total Request Rate

## 🚀 Próximos Pasos

### Opcional: Métricas Adicionales

Si quieres más métricas, puedes agregar:

```javascript
// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 5, 15, 50, 100, 500]
});

// Middleware para medir duración
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});
```

### Configurar Alertas

Crear alertas basadas en las nuevas métricas en `prometheus/rules/`.

### Optimizar Aplicación

Usar las métricas para:
- Identificar cuellos de botella
- Optimizar uso de memoria
- Mejorar performance de CPU
- Reducir event loop lag

## 📚 Referencias

- **prom-client:** https://github.com/siimon/prom-client
- **Node.js Metrics:** https://nodejs.org/api/process.html
- **Prometheus Best Practices:** https://prometheus.io/docs/practices/naming/

## ✅ Checklist Final

- [x] prom-client instalado
- [x] Código de métricas agregado
- [x] Endpoint /metrics funcionando
- [x] Prometheus scrapeando métricas
- [x] Métricas visibles en Prometheus
- [x] Dashboards mostrando datos
- [x] CPU metrics funcionando
- [x] Memory metrics funcionando
- [x] Heap metrics funcionando
- [x] Event loop lag disponible

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Completado y Funcional
**Métricas:** CPU, Memory, Heap disponibles
**Dashboard:** Application Performance actualizado
