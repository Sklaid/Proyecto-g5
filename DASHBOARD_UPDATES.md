# Actualización de Dashboards de Grafana

## Resumen de Cambios

Se han actualizado los tres dashboards principales de Grafana para usar las métricas correctas disponibles en el sistema.

## Cambios Realizados

### 1. Application Performance Dashboard

**Archivo:** `grafana/provisioning/dashboards/json/application-performance-dashboard.json`

**Cambios:**
- ✅ Actualizado de `http_server_request_duration_seconds_bucket` a `http_server_duration_milliseconds_bucket`
- ✅ Eliminada conversión innecesaria de segundos a milisegundos (la métrica ya está en ms)
- ✅ Corregido el nombre del label de `status_code` a `http_status_code`
- ✅ Todas las queries de latencia (P50, P90, P95, P99) ahora funcionan correctamente

**Paneles actualizados:**
- Request Duration Histogram (by Percentile)
- Request Duration Distribution by Endpoint
- Throughput by Endpoint
- Top 10 Endpoints by Request Rate
- Error Rate Breakdown by Status Code
- Response Status Code Distribution

### 2. Distributed Tracing Dashboard

**Archivo:** `grafana/provisioning/dashboards/json/distributed-tracing-dashboard.json`

**Cambios:**
- ✅ Actualizado de `http_server_request_duration_seconds_bucket` a `http_server_duration_milliseconds_bucket`
- ✅ Eliminada conversión innecesaria de segundos a milisegundos
- ✅ Corregido el nombre del label de `status_code` a `http_status_code`

**Paneles actualizados:**
- Latency Breakdown by Service
- Trace Volume by Service and Status

### 3. SLI/SLO Dashboard

**Archivo:** `grafana/provisioning/dashboards/json/sli-slo-dashboard.json`

**Cambios:**
- ✅ Reemplazadas métricas de recording rules inexistentes por queries directas
- ✅ Actualizado de métricas `sli:*` a queries basadas en `http_server_duration_milliseconds`
- ✅ Implementadas fórmulas correctas para:
  - Success Rate
  - Error Rate
  - Error Budget Burn Rate
  - Latency SLO Compliance

**Paneles actualizados:**
- Request Latency (P95 / P99)
- Success Rate (SLO: 99.9%)
- Error Budget Remaining (30d)
- Error Rate (Threshold: 1%)
- Error Budget Burn Rate (Multi-Window)
- Current Burn Rate (1h Window)
- Request Rate (Throughput)
- Latency SLO Compliance

## Métricas Utilizadas

### Métrica Principal
```
http_server_duration_milliseconds
```

**Labels disponibles:**
- `service_name`: Nombre del servicio (ej: "demo-app")
- `http_route`: Ruta HTTP (ej: "/api/users", "/health")
- `http_status_code`: Código de estado HTTP (ej: "200", "404", "500")
- `http_method`: Método HTTP (ej: "GET", "POST")

### Tipos de Métricas
1. **Counter:** `http_server_duration_milliseconds_count` - Número total de requests
2. **Histogram:** `http_server_duration_milliseconds_bucket` - Distribución de latencias
3. **Sum:** `http_server_duration_milliseconds_sum` - Suma total de latencias

## Queries Importantes

### Latencia por Percentil
```promql
# P95
histogram_quantile(0.95, sum(rate(http_server_duration_milliseconds_bucket[5m])) by (le, http_route))

# P99
histogram_quantile(0.99, sum(rate(http_server_duration_milliseconds_bucket[5m])) by (le, http_route))
```

### Tasa de Errores
```promql
# Error rate 4xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"4.."}[5m])) by (http_status_code) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100

# Error rate 5xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) by (http_status_code) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100
```

### Success Rate
```promql
(1 - (sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) by (service_name) / sum(rate(http_server_duration_milliseconds_count[5m])) by (service_name))) * 100
```

### Throughput
```promql
sum(rate(http_server_duration_milliseconds_count[5m])) by (http_route)
```

## Sobre el Error Rate

### ¿Por qué no muestra datos?

Es **CORRECTO** que el Error Rate no muestre datos si:
- ✅ La aplicación no ha tenido errores recientemente
- ✅ Todos los requests han sido exitosos (status 2xx)
- ✅ No hay tráfico con errores 4xx o 5xx

### Esto indica que:
- ✅ La aplicación está funcionando correctamente
- ✅ No hay errores de servidor (5xx)
- ✅ No hay errores de cliente (4xx)

### Para verificar el Error Rate:

1. **Ejecutar el script de verificación:**
   ```powershell
   .\verify-error-rate.ps1
   ```

2. **Generar tráfico con errores (opcional):**
   ```bash
   # Generar un error 500
   curl http://localhost:3000/error
   
   # Generar un error 404
   curl http://localhost:3000/ruta-inexistente
   ```

3. **Esperar 1-2 minutos** para que Prometheus scrape las métricas

4. **Verificar en Grafana** que ahora aparecen datos en los paneles de Error Rate

## Cómo Aplicar los Cambios

### Opción 1: Reiniciar Grafana (Recomendado)
```bash
docker-compose restart grafana
```

### Opción 2: Recargar Dashboards desde la UI
1. Ir a Grafana (http://localhost:3001)
2. Navegar a cada dashboard
3. Hacer clic en el ícono de configuración (⚙️)
4. Seleccionar "JSON Model"
5. Copiar el contenido del archivo JSON actualizado
6. Pegar y guardar

### Opción 3: Reiniciar toda la plataforma
```bash
docker-compose down
docker-compose up -d
```

## Validación

Para validar que los dashboards funcionan correctamente:

1. **Generar tráfico:**
   ```bash
   .\generate-traffic.bat
   ```

2. **Verificar métricas:**
   ```bash
   .\verify-error-rate.ps1
   ```

3. **Abrir Grafana:**
   - URL: http://localhost:3001
   - Usuario: admin
   - Contraseña: admin

4. **Verificar cada dashboard:**
   - Application Performance Dashboard
   - Distributed Tracing Dashboard
   - SLI/SLO Dashboard

5. **Confirmar que se muestran datos en:**
   - ✅ Latency panels (P50, P90, P95, P99)
   - ✅ Throughput panels
   - ✅ Success Rate
   - ✅ CPU y Memory utilization
   - ⚠️ Error Rate (solo si hay errores)

## Troubleshooting

### No se muestran datos en ningún panel

**Causa:** No hay tráfico en la aplicación

**Solución:**
```bash
.\generate-traffic.bat
```

### Error Rate siempre muestra "No data"

**Causa:** No hay errores en la aplicación (esto es correcto)

**Solución:** Si quieres probar el error rate:
```bash
curl http://localhost:3000/error
```

### Latency muestra valores muy altos

**Causa:** La métrica ya está en milisegundos, no necesita conversión

**Solución:** Ya corregido en esta actualización

### Dashboards no se actualizan

**Causa:** Grafana no ha recargado los archivos

**Solución:**
```bash
docker-compose restart grafana
```

## Referencias

- **Métricas OpenTelemetry:** https://opentelemetry.io/docs/specs/semconv/http/http-metrics/
- **PromQL:** https://prometheus.io/docs/prometheus/latest/querying/basics/
- **Grafana Dashboards:** https://grafana.com/docs/grafana/latest/dashboards/

## Próximos Pasos

1. ✅ Dashboards actualizados con métricas correctas
2. ✅ Script de verificación de error rate creado
3. ⏭️ Configurar alertas basadas en estas métricas
4. ⏭️ Crear recording rules para optimizar queries complejas
5. ⏭️ Implementar dashboards adicionales según necesidades

---

**Fecha de actualización:** 2025-10-05
**Versión:** 2.0
**Estado:** ✅ Completado
