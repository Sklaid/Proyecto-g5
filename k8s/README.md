# Kubernetes Deployment Manifests

Este directorio contiene los manifiestos de Kubernetes para desplegar la plataforma AIOps y SRE Observability.

## 📁 Estructura

```
k8s/
├── base/                           # Manifiestos base
│   ├── namespace.yaml              # Namespace observability
│   ├── configmaps.yaml             # ConfigMaps para todos los servicios
│   ├── persistentvolumeclaims.yaml # PVCs para Prometheus, Tempo y Grafana
│   ├── demo-app-deployment.yaml    # Deployment de la aplicación demo
│   ├── otel-collector-deployment.yaml # Deployment del OTel Collector
│   ├── anomaly-detector-deployment.yaml # Deployment del detector de anomalías
│   ├── prometheus-statefulset.yaml # StatefulSet de Prometheus
│   ├── tempo-statefulset.yaml      # StatefulSet de Tempo
│   ├── grafana-deployment.yaml     # Deployment de Grafana
│   ├── hpa.yaml                    # HorizontalPodAutoscaler para demo-app
│   ├── resourcequota.yaml          # ResourceQuota y LimitRange
│   └── kustomization.yaml          # Kustomize base
│
├── overlays/
│   ├── dev/                        # Overlay para desarrollo
│   │   ├── kustomization.yaml
│   │   ├── demo-app-patch.yaml
│   │   └── resource-limits-patch.yaml
│   │
│   └── prod/                       # Overlay para producción
│       ├── kustomization.yaml
│       ├── demo-app-patch.yaml
│       ├── prometheus-patch.yaml
│       ├── tempo-patch.yaml
│       ├── grafana-patch.yaml
│       └── prometheus.yml
│
└── README.md                       # Este archivo
```

## 🚀 Despliegue

### Prerequisitos

1. **Kubernetes cluster** (v1.24+)
2. **kubectl** instalado y configurado
3. **kustomize** (incluido en kubectl 1.14+)
4. **Imágenes Docker** publicadas en GHCR

### Opción 1: Despliegue con Kustomize (Recomendado)

#### Desarrollo

```bash
# Aplicar manifiestos de desarrollo
kubectl apply -k k8s/overlays/dev

# Verificar despliegue
kubectl get pods -n observability-dev

# Ver logs
kubectl logs -f deployment/dev-demo-app -n observability-dev
```

#### Producción

```bash
# Crear secret para Grafana (producción)
kubectl create secret generic grafana-admin \
  --from-literal=username=admin \
  --from-literal=password=<strong-password> \
  -n observability-prod

# Aplicar manifiestos de producción
kubectl apply -k k8s/overlays/prod

# Verificar despliegue
kubectl get pods -n observability-prod
kubectl get svc -n observability-prod
```

### Opción 2: Despliegue Base

```bash
# Aplicar manifiestos base
kubectl apply -k k8s/base

# Verificar despliegue
kubectl get all -n observability
```

## 📊 Componentes Desplegados

### Aplicaciones

| Componente | Tipo | Replicas | Recursos (Request/Limit) |
|------------|------|----------|--------------------------|
| demo-app | Deployment | 2 (dev: 1, prod: 3) | 100m/500m CPU, 128Mi/512Mi RAM |
| otel-collector | Deployment | 1 | 200m/1000m CPU, 256Mi/1Gi RAM |
| anomaly-detector | Deployment | 1 | 100m/500m CPU, 256Mi/1Gi RAM |

### Almacenamiento

| Componente | Tipo | Replicas | Recursos (Request/Limit) | Storage |
|------------|------|----------|--------------------------|---------|
| prometheus | StatefulSet | 1 | 500m/2000m CPU, 2Gi/4Gi RAM | 10Gi |
| tempo | StatefulSet | 1 | 500m/1000m CPU, 1Gi/2Gi RAM | 10Gi |
| grafana | Deployment | 1 | 100m/500m CPU, 256Mi/1Gi RAM | 2Gi |

### Servicios

| Servicio | Tipo | Puerto | Descripción |
|----------|------|--------|-------------|
| demo-app | ClusterIP | 3000 | Aplicación demo |
| otel-collector | ClusterIP | 4317, 4318, 8889 | Collector OTLP y Prometheus |
| prometheus | ClusterIP | 9090 | Prometheus UI y API |
| tempo | ClusterIP | 3200, 4317, 4318 | Tempo UI y OTLP |
| grafana | LoadBalancer | 3000 | Grafana UI |
| anomaly-detector | ClusterIP | 8080 | Detector de anomalías |

## 🔧 Configuración

### HorizontalPodAutoscaler

El demo-app tiene configurado HPA:
- **Min replicas:** 2
- **Max replicas:** 10
- **Target CPU:** 70%
- **Target Memory:** 80%

```bash
# Ver estado del HPA
kubectl get hpa -n observability

# Describir HPA
kubectl describe hpa demo-app-hpa -n observability
```

### ResourceQuota

El namespace tiene límites de recursos:
- **CPU requests:** 10 cores
- **CPU limits:** 20 cores
- **Memory requests:** 20Gi
- **Memory limits:** 40Gi
- **PVCs:** 10
- **Pods:** 50

```bash
# Ver resource quota
kubectl get resourcequota -n observability

# Ver detalles
kubectl describe resourcequota observability-quota -n observability
```

## 🌐 Acceso a Servicios

### Grafana (LoadBalancer)

```bash
# Obtener IP externa
kubectl get svc grafana -n observability

# Port-forward (alternativa)
kubectl port-forward svc/grafana 3000:3000 -n observability
```

Acceder a: http://localhost:3000
- **Usuario:** admin
- **Contraseña:** admin (dev) o desde secret (prod)

### Prometheus

```bash
# Port-forward
kubectl port-forward svc/prometheus 9090:9090 -n observability
```

Acceder a: http://localhost:9090

### Tempo

```bash
# Port-forward
kubectl port-forward svc/tempo 3200:3200 -n observability
```

Acceder a: http://localhost:3200

### Demo App

```bash
# Port-forward
kubectl port-forward svc/demo-app 3000:3000 -n observability
```

Acceder a: http://localhost:3000

## 📈 Monitoreo

### Ver Logs

```bash
# Logs de demo-app
kubectl logs -f deployment/demo-app -n observability

# Logs de Prometheus
kubectl logs -f statefulset/prometheus -n observability

# Logs de todos los pods
kubectl logs -f -l app.kubernetes.io/part-of=aiops-platform -n observability
```

### Ver Métricas

```bash
# Uso de recursos por pod
kubectl top pods -n observability

# Uso de recursos por nodo
kubectl top nodes
```

### Ver Eventos

```bash
# Eventos del namespace
kubectl get events -n observability --sort-by='.lastTimestamp'
```

## 🔄 Actualización

### Actualizar Imágenes

```bash
# Editar kustomization.yaml y cambiar tags
# Luego aplicar cambios
kubectl apply -k k8s/overlays/prod

# O usar kubectl set image
kubectl set image deployment/demo-app \
  demo-app=ghcr.io/sklaid/proyecto-g5/demo-app:v1.2.0 \
  -n observability
```

### Rolling Update

```bash
# Ver estado del rollout
kubectl rollout status deployment/demo-app -n observability

# Ver historial
kubectl rollout history deployment/demo-app -n observability

# Rollback
kubectl rollout undo deployment/demo-app -n observability
```

## 🧹 Limpieza

### Eliminar Deployment

```bash
# Eliminar overlay específico
kubectl delete -k k8s/overlays/dev

# Eliminar base
kubectl delete -k k8s/base

# Eliminar namespace (elimina todo)
kubectl delete namespace observability
```

## 🐛 Troubleshooting

### Pods no inician

```bash
# Ver estado de pods
kubectl get pods -n observability

# Describir pod con problemas
kubectl describe pod <pod-name> -n observability

# Ver logs
kubectl logs <pod-name> -n observability
```

### PVC no se crea

```bash
# Ver PVCs
kubectl get pvc -n observability

# Describir PVC
kubectl describe pvc prometheus-data -n observability

# Ver PVs disponibles
kubectl get pv
```

### Servicio no accesible

```bash
# Ver servicios
kubectl get svc -n observability

# Describir servicio
kubectl describe svc grafana -n observability

# Ver endpoints
kubectl get endpoints -n observability
```

### HPA no escala

```bash
# Ver HPA
kubectl get hpa -n observability

# Describir HPA
kubectl describe hpa demo-app-hpa -n observability

# Verificar metrics-server
kubectl get deployment metrics-server -n kube-system
```

## 📚 Referencias

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)

## 🔐 Seguridad

### Secrets

Para producción, crear secrets para credenciales sensibles:

```bash
# Grafana admin
kubectl create secret generic grafana-admin \
  --from-literal=username=admin \
  --from-literal=password=<strong-password> \
  -n observability-prod

# Registry credentials (si es privado)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  -n observability-prod
```

### RBAC

Los manifiestos incluyen ServiceAccounts básicos. Para producción, configurar RBAC apropiado:

```bash
# Ver service accounts
kubectl get sa -n observability

# Ver roles y rolebindings
kubectl get role,rolebinding -n observability
```

## 💡 Mejores Prácticas

1. **Usar overlays** para diferentes entornos (dev, staging, prod)
2. **Configurar resource limits** para todos los contenedores
3. **Usar secrets** para credenciales sensibles
4. **Configurar health checks** (liveness y readiness probes)
5. **Implementar HPA** para componentes que necesitan escalar
6. **Usar PersistentVolumes** para datos que deben persistir
7. **Configurar monitoring** y alerting desde el inicio
8. **Documentar** cambios en configuración

---

**Última actualización:** 2025-10-04  
**Versión:** 1.0  
**Mantenido por:** DevOps Team
