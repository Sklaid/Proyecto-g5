# 🚀 Guía Rápida - Grafana Dashboards

## 📋 Requisitos Previos

Asegúrate de que todos los servicios estén corriendo:

```bash
docker-compose ps
```

Deberías ver estos servicios como "healthy":
- ✅ demo-app
- ✅ prometheus
- ✅ tempo
- ✅ grafana

## 🌐 Acceso a Grafana

### URL
```
http://localhost:3001
```

### Credenciales
- **Usuario**: `admin`
- **Contraseña**: `admin`

## 📊 Dashboards Disponibles

### 1. SLI/SLO Dashboard
**Ruta**: Dashboards → Browse → "SLI/SLO Dashboard"

**Qué verás**:
- 📈 Latencia P95 y P99
- ❌ Error rate con umbrales SLO
- 💰 Error budget restante
- 🔥 Burn rate actual
- 📉 Proyección de error budget

**Cuándo usarlo**: Para monitorear la salud general del servicio según SLOs

---

### 2. Application Performance Dashboard
**Ruta**: Dashboards → Browse → "Application Performance Dashboard"

**Qué verás**:
- 📊 Histogramas de duración de requests
- 🚀 Throughput por endpoint
- ⚠️ Desglose de errores por código HTTP
- 💻 Uso de CPU y memoria

**Cuándo usarlo**: Para analizar el rendimiento y recursos de la aplicación

---

### 3. Distributed Tracing Dashboard
**Ruta**: Dashboards → Browse → "Distributed Tracing Dashboard"

**Qué verás**:
- 🔍 Búsqueda de trazas
- 🕸️ Grafo de dependencias entre servicios
- ⏱️ Latencia por servicio (P50, P95, P99)
- 🚨 Trazas con errores destacadas
- 📦 Volumen de trazas

**Cuándo usarlo**: Para investigar problemas de latencia y errores específicos

## 🎯 Generar Tráfico para Visualizar Datos

Si los dashboards están vacíos, necesitas generar tráfico:

### Opción 1: Script Automático (Windows)
```bash
generate-traffic.bat
```

### Opción 2: Comandos Manuales

#### Requests Normales:
```bash
# Usuarios
curl http://localhost:3000/api/users
curl http://localhost:3000/api/users/1

# Productos
curl http://localhost:3000/api/products
curl http://localhost:3000/api/products/1
```

#### Generar Errores:
```bash
# Error 500
curl http://localhost:3000/api/error/500

# Excepción
curl http://localhost:3000/api/error/exception

# Timeout (tarda 5 segundos)
curl http://localhost:3000/api/error/timeout
```

#### Generar Tráfico Continuo (PowerShell):
```powershell
# Ejecutar en PowerShell
1..50 | ForEach-Object {
    Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "http://localhost:3000/api/products" -UseBasicParsing | Out-Null
    Start-Sleep -Milliseconds 500
}
```

## 🔍 Explorar Datos

### Ver Métricas en Prometheus
```
http://localhost:9090
```

**Queries útiles**:
```promql
# Request rate
rate(http_server_requests_total[5m])

# Latencia P95
histogram_quantile(0.95, rate(http_server_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_server_requests_total{status_code=~"5.."}[5m])
```

### Ver Trazas en Tempo
En Grafana:
1. Ve a **Explore** (icono de brújula)
2. Selecciona datasource **Tempo**
3. Usa el query builder o TraceQL:
   ```
   {status=error}
   ```

## 🚨 Ver Alertas

### Alertas Configuradas
**Ruta**: Alerting → Alert rules

Verás 6 alertas activas:
1. ✅ High Error Budget Burn Rate (Critical)
2. ✅ High Latency P95 Exceeding SLI (High)
3. ✅ High Error Rate Above 1% (Critical)
4. ✅ Service Down (Critical)
5. ✅ High Memory Usage (Warning)
6. ✅ High CPU Usage (Warning)

### Forzar Alertas para Pruebas

#### Alerta de Error Rate:
```bash
# Generar muchos errores (>1%)
for /L %i in (1,1,100) do curl http://localhost:3000/api/error/500
```

#### Alerta de Latencia:
```bash
# Generar requests lentos
for /L %i in (1,1,50) do curl http://localhost:3000/api/error/timeout
```

#### Alerta de Service Down:
```bash
# Detener la aplicación
docker-compose stop demo-app

# Esperar 1-2 minutos, luego reiniciar
docker-compose start demo-app
```

## 📱 Navegación Rápida en Grafana

### Atajos de Teclado:
- `Ctrl + K` (o `Cmd + K`): Búsqueda rápida
- `d + d`: Ir a dashboards
- `e`: Ir a Explore
- `a`: Ir a Alerting
- `?`: Ver todos los atajos

### Menú Principal:
```
☰ (Hamburguesa)
├── Dashboards
│   ├── Browse (ver todos los dashboards)
│   └── New (crear nuevo)
├── Explore (explorar datos)
├── Alerting
│   ├── Alert rules
│   ├── Contact points
│   └── Notification policies
└── Configuration
    └── Data sources
```

## 🔧 Troubleshooting

### Dashboard vacío o sin datos

**Problema**: No aparecen métricas en los dashboards

**Soluciones**:
1. Verifica que los servicios estén corriendo:
   ```bash
   docker-compose ps
   ```

2. Genera tráfico a la aplicación:
   ```bash
   generate-traffic.bat
   ```

3. Verifica que Prometheus esté recibiendo métricas:
   ```
   http://localhost:9090/targets
   ```
   Todos los targets deben estar "UP"

4. Espera 30-60 segundos para que las métricas se procesen

### Datasource no conectado

**Problema**: Error "Data source not found"

**Solución**:
1. Ve a Configuration → Data sources
2. Verifica que Prometheus y Tempo estén configurados
3. Haz clic en "Test" para verificar conexión
4. Si falla, reinicia Grafana:
   ```bash
   docker-compose restart grafana
   ```

### No aparecen trazas

**Problema**: El dashboard de tracing está vacío

**Solución**:
1. Verifica que Tempo esté corriendo:
   ```bash
   docker logs tempo
   ```

2. Genera tráfico a la aplicación

3. Ve a Explore → Tempo y busca trazas recientes

4. Verifica la configuración del OTel Collector:
   ```bash
   docker logs otel-collector
   ```

## 📚 Recursos Adicionales

- **Documentación de Alertas**: `grafana/ALERTING_CONFIGURATION.md`
- **Estado del Despliegue**: `DEPLOYMENT_STATUS.md`
- **Resumen de Tarea 6**: `grafana/TASK_6_COMPLETION_SUMMARY.md`

## ✅ Checklist de Verificación

Antes de explorar los dashboards, verifica:

- [ ] Todos los servicios están corriendo (`docker-compose ps`)
- [ ] Puedes acceder a Grafana (http://localhost:3001)
- [ ] Has generado tráfico a la aplicación
- [ ] Los datasources están conectados (Configuration → Data sources)
- [ ] Esperaste 30-60 segundos para que se procesen las métricas

## 🎉 ¡Listo!

Ahora puedes explorar los dashboards y ver las métricas de tu aplicación en tiempo real.

**Próximos pasos**:
1. Explora cada dashboard
2. Genera diferentes tipos de tráfico
3. Observa cómo cambian las métricas
4. Prueba las alertas
5. Investiga trazas específicas

¡Disfruta monitoreando tu aplicación! 🚀
