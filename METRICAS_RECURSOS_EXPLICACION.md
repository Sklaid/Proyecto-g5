# Explicación: Métricas de CPU, Memory y Heap

## 🔍 Situación Actual

### Paneles Mostrando "No Data"

En el Application Performance Dashboard, los siguientes paneles muestran "No data":
- CPU Utilization
- Memory Utilization  
- Current CPU Usage
- Current Heap Usage

## ❓ ¿Por Qué Son Importantes?

### 1. CPU Utilization
**Propósito:** Monitorear el uso de CPU de la aplicación

**Utilidad:**
- Detectar procesos que consumen mucha CPU
- Identificar cuellos de botella de procesamiento
- Alertar cuando el CPU está al límite
- Planificar escalamiento horizontal/vertical

**Ejemplo de uso:**
```
Si CPU > 80% durante 5 minutos → Alerta
Si CPU > 90% → Escalar automáticamente
```

### 2. Memory Utilization
**Propósito:** Monitorear el uso de memoria RAM

**Utilidad:**
- Detectar memory leaks (fugas de memoria)
- Identificar cuándo la app necesita más memoria
- Prevenir crashes por falta de memoria
- Optimizar uso de recursos

**Ejemplo de uso:**
```
Si Memory > 400MB → Warning
Si Memory > 500MB → Critical
Tendencia creciente → Posible memory leak
```

### 3. Heap Usage (Node.js)
**Propósito:** Monitorear el heap de JavaScript en Node.js

**Utilidad:**
- Detectar memory leaks específicos de JavaScript
- Monitorear garbage collection
- Optimizar uso de objetos en memoria
- Prevenir crashes por heap overflow

**Ejemplo de uso:**
```
Si Heap Used / Heap Total > 85% → Warning
Heap creciendo constantemente → Memory leak
```

## 🔧 ¿Por Qué Muestran "No Data"?

### Causa Raíz

La aplicación **demo-app** no está exportando métricas de runtime de Node.js.

**Métricas disponibles actualmente:**
- ✅ HTTP requests (latencia, throughput, status codes)
- ✅ Traces distribuidos
- ❌ CPU usage de la aplicación
- ❌ Memory usage de la aplicación
- ❌ Heap usage de Node.js
- ❌ Event loop lag
- ❌ Garbage collection stats

### Métricas Encontradas

Las únicas métricas de recursos son de **Prometheus** (no de demo-app):
```
process_cpu_seconds_total{service="prometheus"}
process_resident_memory_bytes{service="prometheus"}
```

## ✅ Soluciones

### Opción 1: Agregar Métricas de Runtime (Recomendado)

Instalar y configurar `prom-client` para exportar métricas de Node.js:

```javascript
// En demo-app/src/index.js
const promClient = require('prom-client');

// Habilitar métricas por defecto de Node.js
promClient.collectDefaultMetrics({
  prefix: 'nodejs_',
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
  eventLoopMonitoringPrecision: 10
});

// Endpoint para Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});
```

**Métricas que se exportarían:**
- `nodejs_heap_size_total_bytes` - Tamaño total del heap
- `nodejs_heap_size_used_bytes` - Heap usado
- `nodejs_external_memory_bytes` - Memoria externa
- `process_cpu_user_seconds_total` - CPU en modo usuario
- `process_cpu_system_seconds_total` - CPU en modo sistema
- `process_resident_memory_bytes` - Memoria residente
- `nodejs_eventloop_lag_seconds` - Event loop lag
- `nodejs_gc_duration_seconds` - Duración de GC

### Opción 2: Usar Métricas de OpenTelemetry

Configurar OpenTelemetry para exportar métricas de runtime:

```javascript
const { MeterProvider } = require('@opentelemetry/sdk-metrics');
const { PrometheusExporter } = require('@opentelemetry/exporter-prometheus');

const exporter = new PrometheusExporter({
  port: 9464,
  endpoint: '/metrics'
});

const meterProvider = new MeterProvider({
  readers: [exporter]
});
```

### Opción 3: Remover los Paneles (No Recomendado)

Si no necesitas monitorear recursos, puedes remover estos paneles del dashboard.

**Desventajas:**
- Pierdes visibilidad de uso de recursos
- No puedes detectar memory leaks
- No puedes planificar escalamiento
- Debugging más difícil

### Opción 4: Usar Métricas de Contenedor (Docker)

Si la app corre en Docker, puedes usar cAdvisor para métricas de contenedor:

```yaml
# docker-compose.yml
cadvisor:
  image: gcr.io/cadvisor/cadvisor:latest
  ports:
    - "8080:8080"
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
```

**Métricas disponibles:**
- `container_cpu_usage_seconds_total`
- `container_memory_usage_bytes`
- `container_memory_working_set_bytes`
- `container_network_receive_bytes_total`

## 🎯 Recomendación

### Para Producción: Opción 1 (prom-client)

**Ventajas:**
- ✅ Fácil de implementar
- ✅ Métricas específicas de Node.js
- ✅ Bajo overhead
- ✅ Estándar de la industria

**Implementación:**

1. **Instalar dependencia:**
   ```bash
   cd demo-app
   npm install prom-client
   ```

2. **Agregar código de métricas** (ver ejemplo arriba)

3. **Actualizar Prometheus config:**
   ```yaml
   - job_name: 'demo-app-metrics'
     static_configs:
       - targets: ['demo-app:3000']
     metrics_path: '/metrics'
   ```

4. **Reiniciar servicios:**
   ```bash
   docker-compose restart demo-app prometheus
   ```

### Para Desarrollo: Opción 4 (cAdvisor)

Si solo necesitas métricas básicas para desarrollo, cAdvisor es suficiente.

## 📊 Métricas Actuales vs Deseadas

### Actualmente Disponibles
```
✅ http_server_duration_milliseconds (latencia)
✅ http_server_duration_milliseconds_count (throughput)
✅ Traces distribuidos en Tempo
✅ Status codes
```

### Faltantes (Importantes)
```
❌ CPU usage de demo-app
❌ Memory usage de demo-app
❌ Heap usage de Node.js
❌ Event loop lag
❌ Garbage collection metrics
❌ Active handles/requests
```

## 🔄 Próximos Pasos

### Paso 1: Decidir Estrategia
- ¿Necesitas métricas de recursos?
- ¿Vas a producción?
- ¿Qué nivel de detalle necesitas?

### Paso 2: Implementar (Si es necesario)
- Agregar prom-client a demo-app
- Configurar exportación de métricas
- Actualizar Prometheus scrape config

### Paso 3: Validar
- Verificar que métricas aparezcan en Prometheus
- Confirmar que dashboards muestren datos
- Configurar alertas basadas en recursos

### Paso 4: Optimizar
- Ajustar umbrales de alertas
- Configurar auto-scaling basado en métricas
- Documentar baseline de recursos

## 📝 Alternativa Temporal

Mientras decides si implementar métricas de recursos, puedes:

1. **Remover paneles vacíos** del dashboard
2. **Agregar nota explicativa** de por qué no hay datos
3. **Usar métricas de HTTP** como proxy:
   - Alto throughput → Probablemente alto CPU
   - Latencia creciente → Posible problema de recursos

## 🎓 Mejores Prácticas

### Métricas Esenciales para Producción

**Golden Signals (Google SRE):**
1. ✅ **Latency** - Ya tienes (http_server_duration)
2. ✅ **Traffic** - Ya tienes (request count)
3. ✅ **Errors** - Ya tienes (status codes)
4. ❌ **Saturation** - Falta (CPU, Memory, Heap)

**Para completar observabilidad:**
- Agregar métricas de recursos (CPU, Memory)
- Monitorear event loop lag
- Trackear garbage collection
- Medir active connections

## 📚 Referencias

- **prom-client:** https://github.com/siimon/prom-client
- **OpenTelemetry Metrics:** https://opentelemetry.io/docs/instrumentation/js/metrics/
- **Node.js Metrics:** https://nodejs.org/api/process.html#process_process_memoryusage
- **Google SRE Book:** https://sre.google/sre-book/monitoring-distributed-systems/

---

**Fecha:** 5 de octubre de 2025
**Estado:** Métricas de HTTP funcionando, métricas de recursos faltantes
**Recomendación:** Implementar prom-client para métricas completas
