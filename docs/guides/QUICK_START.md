# Quick Start - AIOps Platform

## 🚀 Inicio Rápido

### Opción 1: Script Automatizado (Recomendado)

```bash
# Windows
.\start-platform.bat

# Linux/Mac
chmod +x start-platform.sh
./start-platform.sh
```

### Opción 2: Manual

```bash
# 1. Levantar servicios
docker-compose up -d

# 2. Esperar 30-60 segundos
# Los servicios necesitan tiempo para inicializar

# 3. Verificar estado
docker-compose ps
```

---

## 📊 Verificar que Todo Funciona

### 1. Verificar Servicios

```bash
docker-compose ps
```

**Esperado:** Todos los servicios en estado "Up"

```
NAME                STATUS
demo-app            Up
otel-collector      Up
prometheus          Up
tempo               Up
grafana             Up
anomaly-detector    Up
```

### 2. Ejecutar Smoke Tests

```bash
# Windows PowerShell (Recomendado)
.\scripts\smoke-tests.ps1

# Windows CMD (Alternativa)
scripts\smoke-tests.bat

# Linux/Mac
./scripts/smoke-tests.sh
```

**⚠️ Importante:** Si estás en CMD y se abre el Bloc de Notas, usa `scripts\smoke-tests.bat` o cambia a PowerShell.

**Esperado:** Todos los tests pasan ✅

---

## 🌐 Acceder a los Servicios

### Grafana (Dashboard Principal)
- **URL:** http://localhost:3001
- **Usuario:** admin
- **Contraseña:** admin

**Dashboards disponibles:**
1. SLI/SLO Dashboard
2. Application Performance
3. Distributed Tracing

### Prometheus (Métricas)
- **URL:** http://localhost:9090
- Explorar métricas: `http_server_requests_total`

### Tempo (Trazas)
- **URL:** http://localhost:3200
- Ver trazas distribuidas

### Demo App (Aplicación)
- **URL:** http://localhost:3000
- **Health:** http://localhost:3000/health
- **API:** http://localhost:3000/api/users

---

## 🧪 Generar Tráfico de Prueba

### Opción 1: Script Automatizado

```bash
# Continuo
.\scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# Error
.\scripts\traffic-generation\generate-test-errors.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# Trafico mixto
.\scripts\traffic-generation\generate-mixed-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

```

### Opción 2: Manual

```bash
# Generar requests normales
for i in {1..100}; do curl http://localhost:3000/api/users; done

# Generar errores
for i in {1..10}; do curl http://localhost:3000/api/error; done
```

---

## 📈 Ver Métricas y Trazas

### URLs de Servicios
```
Demo App:       http://localhost:3000
Prometheus:     http://localhost:9090
Grafana:        http://localhost:3001
Tempo:          http://localhost:3200
```

### En Grafana

.\open-all-dashboards.bat

1. Abrir http://localhost:3001
2. Login: admin/admin
3. Ir a Dashboards
4. Seleccionar "SLI/SLO Dashboard"

**Deberías ver:**
- ✅ Request rate
- ✅ Latency P95/P99
- ✅ Error rate
- ✅ Error budget

### En Prometheus

1. Abrir http://localhost:9090
2. Ejecutar query: `rate(http_server_requests_total[5m])`
3. Ver gráfica de requests por segundo

### En Tempo

1. Abrir Grafana
2. Ir a Explore
3. Seleccionar datasource "Tempo"
4. Buscar trazas por servicio: `demo-app`

---

## 🔍 Troubleshooting

### Servicios no inician

```bash
# Ver logs
docker-compose logs

# Ver logs de servicio específico
docker-compose logs demo-app
docker-compose logs prometheus
```

### Puertos ocupados

```bash
# Verificar puertos en uso
netstat -ano | findstr :3000
netstat -ano | findstr :3001
netstat -ano | findstr :9090

# Cambiar puertos en docker-compose.yml si es necesario
```

### Reiniciar servicios

```bash
# Reiniciar todo
docker-compose restart

# Reiniciar servicio específico
docker-compose restart demo-app
```

### Limpiar y empezar de nuevo

```bash
# Detener y eliminar todo
docker-compose down -v

# Volver a iniciar
docker-compose up -d
```

---

## ✅ Checklist de Validación

- [ ] Todos los servicios están "Up"
- [ ] Smoke tests pasan
- [ ] Grafana es accesible (http://localhost:3001)
- [ ] Dashboards muestran datos
- [ ] Prometheus tiene métricas
- [ ] Tempo tiene trazas
- [ ] Demo app responde

---

## 🎯 Próximos Pasos

### 1. Explorar Dashboards
- Ver SLI/SLO Dashboard
- Analizar Application Performance
- Explorar Distributed Tracing

### 2. Probar Anomaly Detection
```bash
# Generar spike de latencia
for i in {1..1000}; do curl http://localhost:3000/api/slow; done
```

### 3. Configurar Alertas
- Ir a Grafana > Alerting
- Ver alertas configuradas
- Probar notificaciones

### 4. CI/CD
```bash
# Hacer cambio en código
git add .
git commit -m "test: validar CI/CD"
git push origin main

# Ver en GitHub Actions
```

---

## 📚 Documentación Adicional

- [Smoke Tests Guide](scripts/SMOKE_TESTS_README.md)
- [CI/CD Implementation](CI-CD-IMPLEMENTATION.md)
- [Kubernetes Deployment](k8s/README.md)
- [Helm Chart](helm/aiops-platform/README.md)

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker-compose logs`
2. Verifica el estado: `docker-compose ps`
3. Ejecuta smoke tests: `.\scripts\smoke-tests.ps1`
4. Consulta troubleshooting arriba

---

**¡Listo para empezar!** 🎉

Ejecuta `.\start-platform.bat` y en 2 minutos tendrás todo funcionando.
