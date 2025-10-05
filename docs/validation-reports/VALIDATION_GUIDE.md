# Guía de Validación - AIOps Platform

## 🎯 Objetivo

Validar que toda la implementación funcional está operativa y funcionando correctamente.

---

## ✅ Checklist de Validación

### Fase 1: Deployment ✅

- [ ] **1.1** Docker y Docker Compose instalados
  ```bash
  docker --version
  docker-compose --version
  ```

- [ ] **1.2** Servicios levantados
  ```bash
  docker-compose up -d
  ```

- [ ] **1.3** Todos los contenedores corriendo
  ```bash
  docker-compose ps
  # Esperado: 6 servicios "Up"
  ```

- [ ] **1.4** Sin errores en logs
  ```bash
  docker-compose logs | grep -i error
  # Esperado: Sin errores críticos
  ```

### Fase 2: Health Checks ✅

- [ ] **2.1** Demo App Health
  ```bash
  curl http://localhost:3000/health
  # Esperado: {"status":"ok"}
  ```

- [ ] **2.2** Demo App Ready
  ```bash
  curl http://localhost:3000/ready
  # Esperado: {"status":"ready"}
  ```

- [ ] **2.3** Prometheus Health
  ```bash
  curl http://localhost:9090/-/healthy
  # Esperado: Prometheus is Healthy
  ```

- [ ] **2.4** Grafana Health
  ```bash
  curl http://localhost:3001/api/health
  # Esperado: {"database":"ok"}
  ```

- [ ] **2.5** Tempo Ready
  ```bash
  curl http://localhost:3200/ready
  # Esperado: ready
  ```

### Fase 3: Telemetry Pipeline ✅

- [ ] **3.1** Generar tráfico
  ```bash
  .\generate-traffic.bat
  # O manualmente:
  curl http://localhost:3000/api/users
  curl http://localhost:3000/api/products
  ```

- [ ] **3.2** Verificar métricas en Prometheus
  ```bash
  # Abrir: http://localhost:9090
  # Query: up
  # Esperado: Ver todos los targets "up"
  ```

- [ ] **3.3** Verificar métricas de la app
  ```bash
  # Query en Prometheus: http_server_requests_total
  # Esperado: Ver métricas de la demo app
  ```

- [ ] **3.4** Verificar trazas en Tempo
  ```bash
  # Abrir Grafana: http://localhost:3001
  # Ir a Explore > Tempo
  # Buscar trazas del servicio "demo-app"
  # Esperado: Ver trazas con spans
  ```

### Fase 4: Grafana Dashboards ✅

- [ ] **4.1** Acceder a Grafana
  ```
  URL: http://localhost:3001
  User: admin
  Pass: admin
  ```

- [ ] **4.2** Verificar Datasources
  ```
  Grafana > Configuration > Data Sources
  Esperado:
  - Prometheus (default) ✅
  - Tempo ✅
  ```

- [ ] **4.3** Verificar Dashboards
  ```
  Grafana > Dashboards
  Esperado:
  - SLI/SLO Dashboard ✅
  - Application Performance ✅
  - Distributed Tracing ✅
  ```

- [ ] **4.4** Dashboard muestra datos
  ```
  Abrir SLI/SLO Dashboard
  Esperado:
  - Request Rate > 0
  - Latency P95/P99 visible
  - Error Rate calculado
  ```

### Fase 5: Anomaly Detection ✅

- [ ] **5.1** Anomaly Detector corriendo
  ```bash
  docker-compose logs anomaly-detector
  # Esperado: Sin errores, logs de inicialización
  ```

- [ ] **5.2** Detector consultando Prometheus
  ```bash
  docker-compose logs anomaly-detector | grep -i prometheus
  # Esperado: Logs de queries a Prometheus
  ```

- [ ] **5.3** Generar anomalía (opcional)
  ```bash
  # Generar spike de latencia
  for i in {1..1000}; do curl http://localhost:3000/api/slow; done
  
  # Esperar 5 minutos
  # Verificar logs del detector
  docker-compose logs anomaly-detector | grep -i anomaly
  ```

### Fase 6: CI/CD Pipeline ✅

- [ ] **6.1** Workflow configurado
  ```bash
  # Verificar archivo existe
  ls .github/workflows/main-pipeline.yml
  ```

- [ ] **6.2** Imágenes Docker construidas
  ```bash
  docker images | grep demo-app
  docker images | grep anomaly-detector
  ```

- [ ] **6.3** Pipeline ejecutado (si hay push a GitHub)
  ```
  GitHub > Actions > Main CI/CD Pipeline
  Esperado:
  - Run Tests ✅
  - Build Docker Images ✅
  - Deploy to Staging ✅
  ```

### Fase 7: Smoke Tests ✅

- [ ] **7.1** Ejecutar smoke tests
  ```bash
  # Windows
  .\scripts\smoke-tests.ps1
  
  # Linux/Mac
  ./scripts/smoke-tests.sh
  ```

- [ ] **7.2** Todos los tests pasan
  ```
  Esperado:
  ✓ Health Checks (5/5)
  ✓ Metrics Baseline (2/2)
  ✓ Trace Validation (2/2)
  ✓ Grafana Datasources (2/2)
  ✓ Container Status (6/6)
  
  Total: 17/17 tests passed ✅
  ```

### Fase 8: Kubernetes Manifests ✅

- [ ] **8.1** Manifiestos base creados
  ```bash
  ls k8s/base/
  # Esperado: 12 archivos .yaml
  ```

- [ ] **8.2** Overlays creados
  ```bash
  ls k8s/overlays/dev/
  ls k8s/overlays/prod/
  ```

- [ ] **8.3** Helm chart creado
  ```bash
  ls helm/aiops-platform/
  # Esperado: Chart.yaml, values.yaml, templates/
  ```

- [ ] **8.4** Validar sintaxis (opcional)
  ```bash
  # Kustomize
  kubectl kustomize k8s/base
  
  # Helm
  helm lint helm/aiops-platform
  ```

---

## 📊 Resultados Esperados

### ✅ Todos los Checks Pasan

```
Fase 1: Deployment          ✅ 4/4
Fase 2: Health Checks       ✅ 5/5
Fase 3: Telemetry Pipeline  ✅ 4/4
Fase 4: Grafana Dashboards  ✅ 4/4
Fase 5: Anomaly Detection   ✅ 3/3
Fase 6: CI/CD Pipeline      ✅ 3/3
Fase 7: Smoke Tests         ✅ 2/2
Fase 8: Kubernetes          ✅ 4/4

TOTAL: 29/29 ✅ (100%)
```

---

## 🎯 Validación Rápida (5 minutos)

Si tienes poco tiempo, ejecuta esto:

```bash
# 1. Levantar servicios
docker-compose up -d

# 2. Esperar 60 segundos
timeout /t 60

# 3. Ejecutar smoke tests
.\scripts\smoke-tests.ps1

# 4. Abrir Grafana
start http://localhost:3001

# 5. Generar tráfico
.\generate-traffic.bat
```

**Si todo pasa:** ✅ Implementación funcional validada

---

## 🐛 Troubleshooting

### Problema: Servicios no inician

**Solución:**
```bash
# Ver logs
docker-compose logs

# Reiniciar
docker-compose restart

# Rebuild si es necesario
docker-compose down
docker-compose build
docker-compose up -d
```

### Problema: No hay métricas en Prometheus

**Solución:**
```bash
# Verificar targets
# Abrir: http://localhost:9090/targets
# Todos deben estar "UP"

# Generar tráfico
.\generate-traffic.bat

# Esperar 30 segundos
timeout /t 30

# Verificar query: up
```

### Problema: No hay trazas en Tempo

**Solución:**
```bash
# Verificar OTel Collector
docker-compose logs otel-collector | grep -i trace

# Generar más tráfico
for i in {1..50}; do curl http://localhost:3000/api/users; done

# Esperar procesamiento
timeout /t 15

# Buscar en Grafana > Explore > Tempo
```

### Problema: Dashboards vacíos

**Solución:**
```bash
# 1. Verificar datasources
# Grafana > Configuration > Data Sources
# Test connection para Prometheus y Tempo

# 2. Generar datos
.\generate-traffic.bat

# 3. Esperar 1 minuto
timeout /t 60

# 4. Refrescar dashboard
```

---

## 📈 Métricas de Éxito

### Mínimo Aceptable
- ✅ 80% de checks pasan
- ✅ Servicios principales funcionan (Grafana, Prometheus, Demo App)
- ✅ Al menos 1 dashboard muestra datos

### Óptimo
- ✅ 100% de checks pasan
- ✅ Todos los servicios funcionan
- ✅ Todos los dashboards muestran datos
- ✅ Smoke tests pasan completamente
- ✅ CI/CD pipeline ejecuta exitosamente

---

## 🎉 Validación Completa

Si todos los checks pasan:

```
╔════════════════════════════════════════╗
║  ✅ IMPLEMENTACIÓN FUNCIONAL VALIDADA  ║
║                                        ║
║  Todos los componentes operativos:    ║
║  • Demo App con OpenTelemetry     ✅  ║
║  • Prometheus (métricas)          ✅  ║
║  • Tempo (trazas)                 ✅  ║
║  • Grafana (dashboards)           ✅  ║
║  • Anomaly Detector               ✅  ║
║  • CI/CD Pipeline                 ✅  ║
║  • Kubernetes Manifests           ✅  ║
║                                        ║
║  Sistema listo para producción! 🚀    ║
╚════════════════════════════════════════╝
```

---

**Próximos pasos:**
1. Explorar dashboards en Grafana
2. Experimentar con anomaly detection
3. Probar deployment en Kubernetes
4. Configurar alertas personalizadas

**¡Felicidades!** 🎊
