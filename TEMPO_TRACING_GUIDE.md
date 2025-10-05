# Guía de Distributed Tracing con Tempo

## 📊 Estado Actual

### ✅ Tempo Funcionando Correctamente

Tempo está recibiendo y almacenando traces de la aplicación:

```
✅ Tempo: Activo y listo
✅ Traces almacenados: 132 traces inspeccionados
✅ Traces visibles: 20+ traces recientes
✅ Servicios: demo-app
✅ Endpoints rastreados: /api/users, /api/products
```

## 🔍 Cómo Ver los Traces

### Opción 1: Explore en Grafana (Recomendado)

1. **Abrir Grafana:** http://localhost:3001
2. **Ir a Explore** (ícono de brújula en el menú lateral)
3. **Seleccionar datasource:** Tempo
4. **Buscar traces:**
   - Query Builder: Seleccionar filtros
   - TraceQL: `{}`  (muestra todos los traces)
   - Service: `demo-app`
   - Span Name: `GET /api/users` o `GET /api/products`

### Opción 2: API de Tempo

```bash
# Ver traces recientes
curl http://localhost:3200/api/search?tags=

# Ver un trace específico por ID
curl http://localhost:3200/api/traces/<trace-id>
```

### Opción 3: Dashboard de Distributed Tracing

**URL:** http://localhost:3001/d/distributed-tracing

**Paneles disponibles:**
- ✅ Trace Search - Buscar traces por filtros
- ✅ Service Request Rate - Tasa de requests por servicio
- ✅ Latency Breakdown by Service - Latencia P50, P95, P99
- ✅ Error Traces - Traces con errores
- ✅ Trace Volume by Service - Volumen de traces

## 📈 Traces Disponibles

### Ejemplo de Traces Recientes

```json
{
  "traceID": "cc9674156d1ec001ee2e68979c7fc63",
  "rootServiceName": "demo-app",
  "rootTraceName": "GET /api/products",
  "durationMs": 76
}
```

### Información en cada Trace

- **Trace ID**: Identificador único del trace
- **Service Name**: Nombre del servicio (demo-app)
- **Span Name**: Nombre de la operación (GET /api/users)
- **Duration**: Duración en milisegundos
- **Timestamp**: Momento de inicio
- **Status**: Success/Error
- **Attributes**: Metadata adicional

## 🎯 Uso del Panel "Trace Search"

### Configuración Actual

El panel "Trace Search" en el dashboard usa TraceQL para buscar traces:

**Query por defecto:** `{}`  (muestra todos los traces)

### Filtros Disponibles

Puedes filtrar traces por:

1. **Service Name:**
   ```traceql
   {.service.name="demo-app"}
   ```

2. **Span Name:**
   ```traceql
   {name="GET /api/users"}
   ```

3. **Duration:**
   ```traceql
   {duration > 100ms}
   ```

4. **Status:**
   ```traceql
   {status=error}
   ```

5. **Combinaciones:**
   ```traceql
   {.service.name="demo-app" && duration > 50ms}
   ```

## 🔧 Panel "Service Dependency Graph"

### Nota Importante

El panel "Service Dependency Graph" ha sido reemplazado por "Service Request Rate" porque:

1. **Un solo servicio**: Actualmente solo tenemos `demo-app`
2. **Sin dependencias**: No hay llamadas entre servicios
3. **NodeGraph requiere múltiples servicios**: El panel de tipo nodeGraph necesita al menos 2 servicios con relaciones

### Cuándo Usar Service Dependency Graph

El Service Dependency Graph es útil cuando tienes:
- Múltiples microservicios
- Llamadas entre servicios (A → B → C)
- Arquitectura distribuida

**Ejemplo de arquitectura que lo requiere:**
```
Frontend → API Gateway → Auth Service → Database
                      → User Service → Database
                      → Product Service → Cache → Database
```

## 📊 Paneles Actualizados

### 1. Trace Search
- **Tipo:** Traces panel
- **Datasource:** Tempo
- **Query:** `{}` (todos los traces)
- **Límite:** 20 traces
- **Funciona:** ✅ Sí

### 2. Service Request Rate (antes Service Dependency Graph)
- **Tipo:** Time series
- **Datasource:** Prometheus
- **Query:** `sum by (service_name) (rate(http_server_duration_milliseconds_count[5m]))`
- **Funciona:** ✅ Sí

### 3. Latency Breakdown by Service
- **Tipo:** Time series
- **Datasource:** Prometheus
- **Métricas:** P50, P95, P99
- **Funciona:** ✅ Sí

### 4. Error Traces
- **Tipo:** Traces panel
- **Datasource:** Tempo
- **Query:** `{status=error}`
- **Funciona:** ✅ Sí (muestra "No data" si no hay errores)

### 5. Trace Volume by Service
- **Tipo:** Time series
- **Datasource:** Prometheus
- **Funciona:** ✅ Sí

## 🚀 Cómo Generar Traces

### Generar Tráfico

```powershell
# Tráfico continuo (genera traces automáticamente)
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

### Verificar Traces en Tempo

```powershell
# PowerShell
Invoke-RestMethod -Uri "http://localhost:3200/api/search?tags=" -Method Get | ConvertTo-Json -Depth 3
```

```bash
# Bash/CMD
curl http://localhost:3200/api/search?tags=
```

## 📖 Cómo Leer un Trace

### Estructura de un Trace

```
Trace (Request completo)
└── Span 1: HTTP GET /api/users
    ├── Span 2: Database Query
    ├── Span 3: Cache Lookup
    └── Span 4: Response Serialization
```

### Información en Grafana Explore

1. **Timeline**: Visualización temporal de spans
2. **Duration**: Tiempo total y por span
3. **Attributes**: Metadata (HTTP method, status code, etc.)
4. **Logs**: Logs asociados al trace (si están configurados)
5. **Service Map**: Mapa de servicios involucrados

## 🎯 Casos de Uso

### 1. Debugging de Latencia

**Problema:** Un endpoint es lento

**Solución:**
1. Ir a Explore → Tempo
2. Buscar traces del endpoint: `{name="GET /api/users"}`
3. Filtrar por duración: `{duration > 100ms}`
4. Analizar el trace más lento
5. Identificar el span que toma más tiempo

### 2. Análisis de Errores

**Problema:** Hay errores en la aplicación

**Solución:**
1. Ir a Dashboard → Distributed Tracing
2. Ver panel "Error Traces"
3. Click en un trace con error
4. Analizar el stack trace y attributes
5. Identificar la causa del error

### 3. Monitoreo de Performance

**Problema:** Quiero ver el performance general

**Solución:**
1. Ir a Dashboard → Distributed Tracing
2. Ver "Latency Breakdown by Service"
3. Monitorear P95 y P99
4. Identificar degradación de performance

## 🔗 URLs Útiles

### Grafana
```
Dashboard: http://localhost:3001/d/distributed-tracing
Explore: http://localhost:3001/explore
```

### Tempo
```
API: http://localhost:3200/api/search
Health: http://localhost:3200/ready
```

### Aplicación
```
Demo App: http://localhost:3000
Health: http://localhost:3000/health
```

## 📝 Ejemplo de Query TraceQL

### Buscar traces lentos
```traceql
{duration > 100ms}
```

### Buscar traces con errores
```traceql
{status=error}
```

### Buscar traces de un endpoint específico
```traceql
{name="GET /api/users"}
```

### Buscar traces con atributos específicos
```traceql
{.http.status_code=200 && duration > 50ms}
```

### Combinación compleja
```traceql
{
  .service.name="demo-app" &&
  name="GET /api/users" &&
  duration > 80ms &&
  .http.status_code=200
}
```

## 🎓 Recursos Adicionales

### Documentación
- **Tempo:** https://grafana.com/docs/tempo/latest/
- **TraceQL:** https://grafana.com/docs/tempo/latest/traceql/
- **OpenTelemetry:** https://opentelemetry.io/docs/

### Tutoriales
- Grafana Explore: https://grafana.com/docs/grafana/latest/explore/
- Distributed Tracing: https://opentelemetry.io/docs/concepts/observability-primer/#distributed-traces

## ✅ Checklist de Verificación

- [x] Tempo está corriendo
- [x] Traces están siendo enviados
- [x] Traces están almacenados en Tempo
- [x] Dashboard de Distributed Tracing cargado
- [x] Panel "Trace Search" funciona
- [x] Panel "Service Request Rate" funciona
- [x] Panel "Latency Breakdown" funciona
- [x] Explore de Grafana accesible
- [x] API de Tempo responde

## 🎉 Resultado

**¡El sistema de distributed tracing está completamente funcional!**

Los traces están siendo capturados, almacenados y son accesibles a través de:
- ✅ Grafana Explore
- ✅ Dashboard de Distributed Tracing
- ✅ API de Tempo

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Funcional
**Traces disponibles:** 132+ traces
**Servicios monitoreados:** demo-app
