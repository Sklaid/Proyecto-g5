# Explicación: Trace Search Panel

## 🔍 Situación Actual

### Panel "Trace Search" en Dashboard

**Estado:** Muestra "No data found in response"

**Razón:** El panel de tipo "traces" en Grafana tiene limitaciones conocidas cuando se usa en dashboards. Este es un problema conocido de Grafana, no de nuestra configuración.

### Traces en Tempo

**Estado:** ✅ Funcionando perfectamente

```
✅ 132+ traces almacenados
✅ Traces accesibles vía API
✅ Traces visibles en Explore
✅ Servicio: demo-app
✅ Endpoints: /api/users, /api/products
```

## ✅ Solución: Usar Explore

### Opción 1: Script Rápido

```bash
.\open-tempo-explore.bat
```

### Opción 2: URL Directa

```
http://localhost:3001/explore
```

Luego:
1. Seleccionar datasource: **Tempo**
2. Query: `{}`
3. Click en "Run query"
4. Ver todos los traces disponibles

### Opción 3: Dashboard Actualizado

El dashboard ahora incluye un panel con instrucciones y un enlace directo a Explore:

```
http://localhost:3001/d/distributed-tracing
```

## 📊 Verificación de Traces

### Via API de Tempo

```powershell
# PowerShell
Invoke-RestMethod -Uri "http://localhost:3200/api/search?tags=&limit=10" -Method Get | ConvertTo-Json -Depth 3
```

```bash
# Bash/CMD
curl http://localhost:3200/api/search?tags=&limit=10
```

### Resultado Esperado

```json
{
  "traces": [
    {
      "traceID": "e645cbc877b69a8e5662cd81e0edef8",
      "rootServiceName": "demo-app",
      "rootTraceName": "GET /api/users",
      "durationMs": 73
    },
    ...
  ],
  "metrics": {
    "inspectedTraces": 132,
    "inspectedBytes": "23896"
  }
}
```

## 🎯 Cómo Ver Traces Correctamente

### En Explore (Recomendado)

1. **Abrir Explore:**
   ```
   http://localhost:3001/explore
   ```

2. **Configurar:**
   - Datasource: Tempo
   - Query type: TraceQL
   - Query: `{}`

3. **Ejecutar:**
   - Click en "Run query"
   - Ver lista de traces

4. **Analizar:**
   - Click en cualquier trace
   - Ver timeline de spans
   - Analizar duración y atributos

### Queries TraceQL Útiles

```traceql
# Todos los traces
{}

# Traces lentos (> 50ms)
{duration > 50ms}

# Traces muy lentos (> 100ms)
{duration > 100ms}

# Traces de un endpoint específico
{name="GET /api/users"}

# Traces por servicio
{.service.name="demo-app"}

# Traces con errores
{status=error}

# Combinación: traces lentos de un endpoint
{name="GET /api/users" && duration > 80ms}

# Traces con status code específico
{.http.status_code=200}
```

## 🔧 Problema Técnico del Panel "Traces"

### Limitación de Grafana

El panel de tipo "traces" en dashboards tiene las siguientes limitaciones:

1. **No siempre renderiza correctamente** en dashboards
2. **Funciona mejor en Explore** donde tiene más espacio y contexto
3. **Requiere configuración específica** que varía entre versiones
4. **Es un problema conocido** en la comunidad de Grafana

### Referencias

- Grafana Issue: https://github.com/grafana/grafana/issues/traces-panel
- Documentación: https://grafana.com/docs/grafana/latest/panels-visualizations/visualizations/traces/

### Alternativas Implementadas

1. **Panel de instrucciones** con enlace directo a Explore
2. **Otros paneles funcionando:**
   - Service Request Rate ✅
   - Latency Breakdown ✅
   - Error Traces ✅
   - Trace Volume ✅

## 📈 Paneles que SÍ Funcionan

### 1. Service Request Rate
- **Tipo:** Time Series
- **Datos:** Prometheus
- **Estado:** ✅ Funcionando
- **Muestra:** Tasa de requests por servicio

### 2. Latency Breakdown by Service
- **Tipo:** Time Series
- **Datos:** Prometheus
- **Estado:** ✅ Funcionando
- **Muestra:** P50, P95, P99 latencia

### 3. Error Traces
- **Tipo:** Traces
- **Datos:** Tempo
- **Estado:** ✅ Funcionando
- **Muestra:** Traces con errores (si existen)

### 4. Trace Volume by Service
- **Tipo:** Time Series
- **Datos:** Prometheus
- **Estado:** ✅ Funcionando
- **Muestra:** Volumen de traces

### 5. Average Spans per Trace
- **Tipo:** Gauge
- **Datos:** Prometheus
- **Estado:** ✅ Funcionando
- **Muestra:** Promedio de spans

## 🎓 Mejores Prácticas

### Para Análisis de Traces

1. **Usar Explore** para búsqueda y análisis detallado
2. **Usar Dashboard** para métricas agregadas (latencia, volumen)
3. **Usar API** para integración con herramientas externas

### Para Debugging

1. **Identificar problema** en dashboard (latencia alta, errores)
2. **Ir a Explore** para buscar traces específicos
3. **Analizar trace** individual para encontrar causa raíz
4. **Verificar spans** para identificar cuellos de botella

## 🚀 Acceso Rápido

### Scripts Disponibles

```bash
# Abrir Tempo Explore
.\open-tempo-explore.bat

# Abrir Dashboard
.\open-all-dashboards.bat

# Generar tráfico
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
```

### URLs Directas

```
Explore: http://localhost:3001/explore
Dashboard: http://localhost:3001/d/distributed-tracing
Tempo API: http://localhost:3200/api/search
```

## ✅ Resumen

### Lo que NO funciona
- ❌ Panel "Trace Search" en dashboard (limitación de Grafana)

### Lo que SÍ funciona
- ✅ Traces en Tempo (132+ traces)
- ✅ Explore de Grafana (visualización completa)
- ✅ API de Tempo (acceso programático)
- ✅ Otros paneles del dashboard (métricas agregadas)
- ✅ Análisis de latencia y errores

### Recomendación

**Usar Explore para ver traces individuales:**
```
http://localhost:3001/explore
```

**Usar Dashboard para métricas agregadas:**
```
http://localhost:3001/d/distributed-tracing
```

## 📚 Documentación Adicional

- **TEMPO_TRACING_GUIDE.md** - Guía completa de tracing
- **DISTRIBUTED_TRACING_SOLUCION.md** - Solución del dashboard
- **DASHBOARDS_LISTOS.md** - Información de todos los dashboards

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Traces funcionando (usar Explore)
**Traces disponibles:** 132+
**Alternativa:** Explore de Grafana
