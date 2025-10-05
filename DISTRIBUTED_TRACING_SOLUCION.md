# Solución: Distributed Tracing Dashboard

## ✅ Problema Resuelto

Los paneles del Distributed Tracing Dashboard ahora están funcionando correctamente.

## 🔍 Problemas Encontrados

### 1. Trace Search - Query Vacía
**Problema:** El panel tenía una query vacía `""`
**Solución:** Actualizado a `"{}"` para mostrar todos los traces

### 2. Service Dependency Graph - Sin Datos
**Problema:** El panel de tipo "nodeGraph" no mostraba datos porque:
- Solo hay un servicio (demo-app)
- No hay dependencias entre servicios
- NodeGraph requiere múltiples servicios con relaciones

**Solución:** Reemplazado por "Service Request Rate" (time series) que muestra la tasa de requests del servicio

## 📊 Estado Actual

### Tempo
```
✅ Estado: Funcionando
✅ Traces almacenados: 132+
✅ Traces recientes: 20+
✅ Servicios: demo-app
✅ Endpoints: /api/users, /api/products
```

### Dashboard Actualizado
```
✅ Trace Search - Funciona con query "{}"
✅ Service Request Rate - Muestra tasa de requests
✅ Latency Breakdown - P50, P95, P99 funcionando
✅ Error Traces - Funciona (muestra "No data" si no hay errores)
✅ Trace Volume - Funciona correctamente
```

## 🎯 Cómo Usar

### Ver Traces en el Dashboard

1. **Abrir Dashboard:**
   ```
   http://localhost:3001/d/distributed-tracing
   ```

2. **Panel "Trace Search":**
   - Muestra los últimos 20 traces
   - Click en un trace para ver detalles
   - Usa filtros para buscar traces específicos

3. **Panel "Service Request Rate":**
   - Muestra la tasa de requests por segundo
   - Útil para ver patrones de tráfico

4. **Panel "Latency Breakdown":**
   - Muestra P50, P95, P99 por servicio
   - Identifica degradación de performance

### Ver Traces en Explore (Recomendado)

1. **Ir a Explore:**
   ```
   http://localhost:3001/explore
   ```

2. **Seleccionar Tempo** como datasource

3. **Buscar traces:**
   - Query Builder: Usar filtros visuales
   - TraceQL: Escribir queries personalizadas

4. **Ejemplos de queries:**
   ```traceql
   # Todos los traces
   {}
   
   # Traces lentos (> 100ms)
   {duration > 100ms}
   
   # Traces con errores
   {status=error}
   
   # Traces de un endpoint específico
   {name="GET /api/users"}
   
   # Combinación
   {.service.name="demo-app" && duration > 80ms}
   ```

## 📈 Generar Tráfico

Para ver datos en los paneles:

```powershell
# Tráfico continuo
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

## 🔧 Cambios Realizados

### Archivo Modificado
```
grafana/provisioning/dashboards/json/distributed-tracing-dashboard.json
```

### Cambios Específicos

1. **Panel "Trace Search":**
   ```json
   "query": "{}"  // Antes: ""
   ```

2. **Panel "Service Dependency Graph" → "Service Request Rate":**
   ```json
   "type": "timeseries"  // Antes: "nodeGraph"
   ```

3. **Configuración actualizada:**
   - Agregado fieldConfig para timeseries
   - Actualizado options para legend y tooltip
   - Mantenida query de Prometheus

## 📊 Paneles del Dashboard

### 1. Trace Search
- **Tipo:** Traces
- **Datasource:** Tempo
- **Query:** `{}`
- **Límite:** 20 traces
- **Función:** Buscar y visualizar traces

### 2. Service Request Rate
- **Tipo:** Time Series
- **Datasource:** Prometheus
- **Query:** `sum by (service_name) (rate(http_server_duration_milliseconds_count[5m]))`
- **Función:** Mostrar tasa de requests

### 3. Latency Breakdown by Service
- **Tipo:** Time Series
- **Datasource:** Prometheus
- **Métricas:** P50, P95, P99
- **Función:** Análisis de latencia

### 4. Error Traces
- **Tipo:** Traces
- **Datasource:** Tempo
- **Query:** `{status=error}`
- **Función:** Mostrar traces con errores

### 5. Trace Volume by Service
- **Tipo:** Time Series
- **Datasource:** Prometheus
- **Función:** Volumen de traces por servicio

### 6. Average Spans per Trace
- **Tipo:** Gauge
- **Datasource:** Prometheus
- **Función:** Promedio de spans por trace

## 🎓 Sobre Service Dependency Graph

### ¿Por qué no funciona?

El Service Dependency Graph (nodeGraph) requiere:
1. **Múltiples servicios** con relaciones
2. **Datos de conexiones** entre servicios
3. **Métricas de dependencias**

### Arquitectura Actual
```
Cliente → demo-app
```

Solo hay un servicio, por lo que no hay grafo que mostrar.

### Cuándo Usar Service Dependency Graph

Cuando tengas una arquitectura como:
```
Frontend → API Gateway → Auth Service
                      → User Service → Database
                      → Product Service → Cache
```

En ese caso, el nodeGraph mostraría:
- Nodos: Cada servicio
- Edges: Conexiones entre servicios
- Métricas: Requests, latencia, errores por conexión

## 🔗 URLs Útiles

### Dashboards
```
Distributed Tracing: http://localhost:3001/d/distributed-tracing
Application Performance: http://localhost:3001/d/app-performance-dashboard
SLI/SLO: http://localhost:3001/d/slo-dashboard
```

### Explore
```
Grafana Explore: http://localhost:3001/explore
```

### APIs
```
Tempo API: http://localhost:3200/api/search
Prometheus: http://localhost:9090
Demo App: http://localhost:3000
```

## ✅ Verificación

### Checklist
- [x] Tempo funcionando
- [x] Traces siendo capturados
- [x] Dashboard actualizado
- [x] Panel "Trace Search" funciona
- [x] Panel "Service Request Rate" funciona
- [x] Panel "Latency Breakdown" funciona
- [x] Explore de Grafana accesible
- [x] Tráfico generado (125 requests)

### Verificar Traces en Tempo
```powershell
Invoke-RestMethod -Uri "http://localhost:3200/api/search?tags=" -Method Get
```

### Verificar Métricas en Prometheus
```powershell
Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=http_server_duration_milliseconds_count" -Method Get
```

## 📚 Documentación Adicional

Para más información, consulta:
- **TEMPO_TRACING_GUIDE.md** - Guía completa de tracing
- **DASHBOARDS_LISTOS.md** - Información de todos los dashboards
- **SOLUCION_DASHBOARDS_FINAL.md** - Solución completa

## 🎉 Resultado Final

**¡El Distributed Tracing Dashboard está completamente funcional!**

### Funcionalidades Disponibles
✅ Búsqueda de traces
✅ Visualización de latencia
✅ Análisis de errores
✅ Monitoreo de volumen
✅ Integración con Explore

### Próximos Pasos
1. Explorar traces en Grafana Explore
2. Crear queries TraceQL personalizadas
3. Configurar alertas basadas en traces
4. Agregar más servicios para ver el Service Dependency Graph

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Completado y Funcional
**Traces disponibles:** 132+
**Dashboard:** Actualizado y funcionando
