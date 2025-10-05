# Paneles de Errores - Correcciones y Guía

## 📊 Estado de los Paneles

### 1. Error Rate Breakdown by Status Code

**Estado:** ✅ Funcionando (requiere errores recientes)

**Por qué muestra "No data":**
- El panel usa `rate()` con ventana de 5 minutos
- Solo muestra datos si hay errores en los últimos 5 minutos
- Los errores generados hace más de 5 minutos no aparecen

**Solución:**
```powershell
# Generar errores recientes
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 0

# O generar tráfico mixto continuo
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -ErrorRatePercent 15
```

**Query del panel:**
```promql
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"4.."}[5m])) by (http_status_code) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100
```

### 2. Distributed Tracing Dashboard - Error Traces

**Decisión:** ✅ Correcto eliminar el panel

**Razón:**
- El panel de tipo "traces" tiene limitaciones en dashboards
- Es mejor usar **Explore** para ver traces con errores
- Explore ofrece mejor visualización y análisis

**Cómo ver traces con errores:**
```bash
# Opción 1: Script
.\open-tempo-explore.bat

# Opción 2: Manual
# 1. Ir a http://localhost:3001/explore
# 2. Seleccionar datasource: Tempo
# 3. Query: {status=error}
# 4. Run query
```

### 3. Error Budget Exhaustion

**Estado:** ✅ Corregido

**Problema anterior:**
- Query dividía por rate de errores
- Si no había errores recientes → división por cero → "-∞ years"

**Solución aplicada:**
- Cambiado a mostrar **porcentaje de budget restante**
- Query más robusta que maneja caso sin errores
- Unidad cambiada de "days" a "percent"

**Query nueva:**
```promql
(1 - (sum(increase(http_server_duration_milliseconds_count{http_status_code=~"5.."}[30d])) by (service_name) or vector(0)) / (sum(increase(http_server_duration_milliseconds_count[30d])) by (service_name) + 1)) * 100
```

**Interpretación:**
- 100% = Error budget intacto (sin errores)
- 80-99% = Budget saludable (verde)
- 50-80% = Budget consumiéndose (amarillo)
- <50% = Budget crítico (rojo)

## 🎯 Cómo Generar Errores para Ver en Dashboards

### Opción 1: Errores Puros (Rápido)

```powershell
# Generar 10 errores inmediatamente
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 0

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Refrescar dashboard
```

### Opción 2: Tráfico Mixto (Realista)

```powershell
# Tráfico con 15% de errores por 60 segundos
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 15
```

### Opción 3: Tráfico Continuo con Errores

```powershell
# Terminal 1: Tráfico normal
.\generate-continuous-traffic.ps1 -DurationSeconds 300 -RequestsPerSecond 3

# Terminal 2: Errores periódicos
while ($true) {
    .\generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 0
    Start-Sleep -Seconds 30
}
```

## 📈 Paneles de Errores Funcionando

### Application Performance Dashboard

**Paneles que muestran errores:**

1. **Error Rate Breakdown by Status Code**
   - Gráfico de líneas
   - Muestra % de errores 4xx y 5xx
   - Requiere errores en últimos 5 minutos

2. **Response Status Code Distribution**
   - Pie chart
   - Muestra distribución de todos los status codes
   - Incluye 2xx, 3xx, 4xx, 5xx

### SLI/SLO Dashboard

**Paneles que muestran errores:**

1. **Error Rate (Threshold: 1%)**
   - Gráfico de líneas
   - Muestra tasa de errores vs threshold
   - Alerta visual cuando supera 1%

2. **Success Rate (SLO: 99.9%)**
   - Gauge
   - Muestra % de requests exitosos
   - Verde si cumple SLO, rojo si no

3. **Error Budget Remaining (30d)**
   - Stat panel
   - Muestra % de budget restante
   - Verde (>80%), Amarillo (50-80%), Rojo (<50%)

4. **Error Budget Burn Rate**
   - Gráfico de líneas
   - Muestra velocidad de consumo del budget
   - Multi-window: 1h, 6h, 24h

## ⏱️ Timing Importante

### Para Ver Errores en Dashboards

1. **Generar errores:** Inmediato
2. **Prometheus scrape:** ~15 segundos
3. **Grafana refresh:** ~30 segundos
4. **Total:** 30-45 segundos

### Configurar Auto-Refresh

1. Abrir dashboard
2. Click en reloj (arriba derecha)
3. Seleccionar "5s" o "10s"
4. Los paneles se actualizarán automáticamente

### Time Range

**Importante:** El time range debe incluir el momento de los errores

- **Recomendado:** "Last 5 minutes" o "Last 15 minutes"
- **No usar:** "Last 24 hours" si acabas de generar errores
- **Ajustar:** Click en time range (arriba derecha)

## 🔍 Troubleshooting

### Panel muestra "No data"

**Causa 1: Errores muy antiguos**
```powershell
# Solución: Generar errores nuevos
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 0
```

**Causa 2: Time range incorrecto**
```
# Solución: Cambiar a "Last 5 minutes"
```

**Causa 3: No se ha esperado suficiente**
```powershell
# Solución: Esperar 30-45 segundos
Start-Sleep -Seconds 45
```

### Panel muestra "-∞" o "NaN"

**Causa:** Query con división por cero

**Solución:** Ya corregido en Error Budget panel

### Errores no aparecen en Prometheus

```powershell
# Verificar que demo-app esté corriendo
docker-compose ps demo-app

# Verificar endpoint
curl http://localhost:3000/health

# Generar errores y verificar
.\generate-test-errors.ps1 -ErrorCount 5 -DelaySeconds 0

# Verificar en Prometheus
curl "http://localhost:9090/api/v1/query?query=http_server_duration_milliseconds_count{http_status_code=~\"[45]..\"}"
```

## 📊 Queries Útiles

### En Prometheus

```promql
# Ver todos los errores
http_server_duration_milliseconds_count{http_status_code=~"[45].."}

# Tasa de errores 4xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"4.."}[5m]))

# Tasa de errores 5xx
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m]))

# Porcentaje de errores
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"[45].."}[5m])) / sum(rate(http_server_duration_milliseconds_count[5m])) * 100
```

### En Tempo Explore

```traceql
# Todos los traces con errores
{status=error}

# Traces con errores de un servicio
{.service.name="demo-app" && status=error}

# Traces con errores lentos
{status=error && duration > 100ms}
```

## 🎓 Escenario de Demo Completo

```powershell
# 1. Mostrar sistema saludable
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5
# Ver dashboards: Error Rate = 0%, Success Rate = 100%

# 2. Introducir errores
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5 -ErrorRatePercent 15
# Ver dashboards: Error Rate sube, Success Rate baja, Budget se consume

# 3. Esperar 45 segundos para ver métricas
Start-Sleep -Seconds 45

# 4. Analizar en dashboards
# - Application Performance: Ver error rate breakdown
# - SLI/SLO: Ver impacto en SLO y budget

# 5. Ver traces con errores
.\open-tempo-explore.bat
# Query: {status=error}

# 6. Recuperación
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
# Ver dashboards: Error Rate baja, Success Rate sube
```

## ✅ Checklist de Verificación

- [ ] Generar errores recientes (últimos 5 minutos)
- [ ] Esperar 30-45 segundos
- [ ] Refrescar dashboard (Ctrl+F5)
- [ ] Verificar time range (Last 5 minutes)
- [ ] Configurar auto-refresh (5s o 10s)
- [ ] Ver Error Rate Breakdown
- [ ] Ver Response Status Code Distribution
- [ ] Ver Error Budget Remaining
- [ ] Ver traces en Explore

---

**Fecha:** 5 de octubre de 2025
**Estado:** ✅ Paneles corregidos
**Cambios:** Error Budget query mejorada
**Recomendación:** Usar generate-mixed-traffic.ps1 para demos
