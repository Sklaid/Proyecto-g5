# AIOps Platform Helm Chart

Helm chart para desplegar la plataforma completa de AIOps y SRE Observability en Kubernetes.

## TL;DR

```bash
# Agregar el repositorio (si está publicado)
helm repo add aiops-platform https://sklaid.github.io/Proyecto-g5

# Instalar el chart
helm install my-aiops aiops-platform/aiops-platform

# O instalar desde el directorio local
helm install my-aiops ./helm/aiops-platform
```

## Introducción

Este chart despliega una plataforma completa de observabilidad que incluye:

- **Demo Application:** Aplicación instrumentada con OpenTelemetry
- **OpenTelemetry Collector:** Recopilación de métricas y trazas
- **Prometheus:** Almacenamiento de métricas
- **Tempo:** Almacenamiento de trazas distribuidas
- **Grafana:** Visualización y dashboards
- **Anomaly Detector:** Detección de anomalías con ML

## Prerequisites

- Kubernetes 1.24+
- Helm 3.8+
- PV provisioner support (para almacenamiento persistente)
- Metrics Server (para HPA)

## Installing the Chart

### Instalación Básica

```bash
helm install my-aiops ./helm/aiops-platform \
  --namespace observability \
  --create-namespace
```

### Instalación para Desarrollo

```bash
helm install my-aiops ./helm/aiops-platform \
  --namespace observability-dev \
  --create-namespace \
  --values ./helm/aiops-platform/values-dev.yaml
```

### Instalación para Producción

```bash
# Crear secret para Grafana
kubectl create secret generic grafana-admin \
  --from-literal=username=admin \
  --from-literal=password=<strong-password> \
  -n observability-prod

# Instalar chart
helm install my-aiops ./helm/aiops-platform \
  --namespace observability-prod \
  --create-namespace \
  --values ./helm/aiops-platform/values-prod.yaml
```

## Uninstalling the Chart

```bash
helm uninstall my-aiops -n observability
```

## Configuration

### Parámetros Principales

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Namespace para el deployment | `observability` |
| `global.environment` | Entorno (development/production) | `production` |

### Demo Application

| Parameter | Description | Default |
|-----------|-------------|---------|
| `demoApp.enabled` | Habilitar demo app | `true` |
| `demoApp.replicaCount` | Número de replicas | `2` |
| `demoApp.image.repository` | Repositorio de imagen | `ghcr.io/sklaid/proyecto-g5/demo-app` |
| `demoApp.image.tag` | Tag de imagen | `latest` |
| `demoApp.resources.requests.cpu` | CPU request | `100m` |
| `demoApp.resources.requests.memory` | Memory request | `128Mi` |
| `demoApp.autoscaling.enabled` | Habilitar HPA | `true` |
| `demoApp.autoscaling.minReplicas` | Min replicas para HPA | `2` |
| `demoApp.autoscaling.maxReplicas` | Max replicas para HPA | `10` |

### Prometheus

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prometheus.enabled` | Habilitar Prometheus | `true` |
| `prometheus.persistence.enabled` | Habilitar persistencia | `true` |
| `prometheus.persistence.size` | Tamaño del PVC | `10Gi` |
| `prometheus.retention` | Retention period | `15d` |
| `prometheus.resources.requests.cpu` | CPU request | `500m` |
| `prometheus.resources.requests.memory` | Memory request | `2Gi` |

### Tempo

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tempo.enabled` | Habilitar Tempo | `true` |
| `tempo.persistence.enabled` | Habilitar persistencia | `true` |
| `tempo.persistence.size` | Tamaño del PVC | `10Gi` |
| `tempo.resources.requests.cpu` | CPU request | `500m` |
| `tempo.resources.requests.memory` | Memory request | `1Gi` |

### Grafana

| Parameter | Description | Default |
|-----------|-------------|---------|
| `grafana.enabled` | Habilitar Grafana | `true` |
| `grafana.service.type` | Tipo de servicio | `LoadBalancer` |
| `grafana.persistence.enabled` | Habilitar persistencia | `true` |
| `grafana.persistence.size` | Tamaño del PVC | `2Gi` |
| `grafana.admin.user` | Usuario admin | `admin` |
| `grafana.admin.password` | Password admin | `admin` |
| `grafana.admin.existingSecret` | Secret existente para credenciales | `""` |

### Resource Quota

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resourceQuota.enabled` | Habilitar ResourceQuota | `true` |
| `resourceQuota.hard.requests.cpu` | CPU requests limit | `10` |
| `resourceQuota.hard.requests.memory` | Memory requests limit | `20Gi` |

## Examples

### Ejemplo 1: Desarrollo Local

```bash
helm install dev-aiops ./helm/aiops-platform \
  --namespace observability-dev \
  --create-namespace \
  --set global.environment=development \
  --set demoApp.replicaCount=1 \
  --set demoApp.autoscaling.enabled=false \
  --set grafana.service.type=ClusterIP \
  --values ./helm/aiops-platform/values-dev.yaml
```

### Ejemplo 2: Producción con Valores Personalizados

```bash
helm install prod-aiops ./helm/aiops-platform \
  --namespace observability-prod \
  --create-namespace \
  --set demoApp.replicaCount=5 \
  --set prometheus.retention=30d \
  --set prometheus.persistence.size=50Gi \
  --values ./helm/aiops-platform/values-prod.yaml
```

### Ejemplo 3: Actualizar Release

```bash
helm upgrade prod-aiops ./helm/aiops-platform \
  --namespace observability-prod \
  --set demoApp.image.tag=v1.2.0 \
  --reuse-values
```

### Ejemplo 4: Dry Run

```bash
helm install my-aiops ./helm/aiops-platform \
  --namespace observability \
  --dry-run --debug
```

## Accessing Services

### Grafana

```bash
# Si es LoadBalancer
kubectl get svc my-aiops-grafana -n observability

# Si es ClusterIP (port-forward)
kubectl port-forward svc/my-aiops-grafana 3000:3000 -n observability
```

Acceder a: http://localhost:3000

### Prometheus

```bash
kubectl port-forward svc/my-aiops-prometheus 9090:9090 -n observability
```

Acceder a: http://localhost:9090

### Tempo

```bash
kubectl port-forward svc/my-aiops-tempo 3200:3200 -n observability
```

Acceder a: http://localhost:3200

## Monitoring

### Ver Estado

```bash
# Pods
kubectl get pods -n observability

# Services
kubectl get svc -n observability

# PVCs
kubectl get pvc -n observability

# HPA
kubectl get hpa -n observability
```

### Ver Logs

```bash
# Demo app
kubectl logs -f deployment/my-aiops-demo-app -n observability

# Prometheus
kubectl logs -f statefulset/my-aiops-prometheus -n observability

# Todos los pods
kubectl logs -f -l app.kubernetes.io/instance=my-aiops -n observability
```

## Troubleshooting

### Pods no inician

```bash
kubectl describe pod <pod-name> -n observability
kubectl logs <pod-name> -n observability
```

### PVC no se crea

```bash
kubectl get pvc -n observability
kubectl describe pvc <pvc-name> -n observability
kubectl get storageclass
```

### HPA no escala

```bash
kubectl describe hpa my-aiops-demo-app -n observability
kubectl top pods -n observability
kubectl get deployment metrics-server -n kube-system
```

## Upgrading

### Actualizar a Nueva Versión

```bash
helm upgrade my-aiops ./helm/aiops-platform \
  --namespace observability \
  --reuse-values
```

### Rollback

```bash
# Ver historial
helm history my-aiops -n observability

# Rollback a versión anterior
helm rollback my-aiops -n observability

# Rollback a versión específica
helm rollback my-aiops 2 -n observability
```

## Values Files

El chart incluye tres archivos de valores:

- **values.yaml:** Valores por defecto (producción)
- **values-dev.yaml:** Valores optimizados para desarrollo
- **values-prod.yaml:** Valores optimizados para producción

## Contributing

Para contribuir al chart:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Haz tus cambios
4. Ejecuta `helm lint ./helm/aiops-platform`
5. Crea un Pull Request

## License

MIT

## Support

Para soporte, abre un issue en: https://github.com/Sklaid/Proyecto-g5/issues
