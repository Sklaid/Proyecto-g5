# Arquitectura y Diagramas de la Solución

## 📋 Índice

1. [Arquitectura de Alto Nivel](#arquitectura-de-alto-nivel)
2. [Flujo de Datos](#flujo-de-datos)
3. [Arquitectura de Despliegue](#arquitectura-de-despliegue)
4. [Arquitectura Kubernetes](#arquitectura-kubernetes)
5. [Pipeline CI/CD](#pipeline-cicd)
6. [Componentes y Repositorios](#componentes-y-repositorios)

---

## 🏗️ Arquitectura de Alto Nivel

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLATAFORMA AIOPS & SRE                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│ Application     │
│ Layer           │
├─────────────────┤
│  Demo App       │ ──┐
│  (Node.js)      │   │ Métricas y Trazas (OTLP)
└─────────────────┘   │
                      ▼
              ┌──────────────────┐
              │ Collection Layer │
              ├──────────────────┤
              │ OTel Collector   │
              └──────────────────┘
                   │         │
        Métricas   │         │    Trazas
                   ▼         ▼
            ┌──────────┐  ┌──────────┐
            │ Storage  │  │ Storage  │
            │  Layer   │  │  Layer   │
            ├──────────┤  ├──────────┤
            │Prometheus│  │  Tempo   │
            └──────────┘  └──────────┘
                   │         │
                   └────┬────┘
                        ▼
                 ┌─────────────┐
                 │Visualization│
                 │   Layer     │
                 ├─────────────┤
                 │   Grafana   │ ◄── Dashboards y Alertas
                 └─────────────┘
                        ▲
                        │ Alertas de Anomalías
                 ┌─────────────┐
                 │  Analysis   │
                 │   Layer     │
                 ├─────────────┤
                 │  Detector   │
                 │  Anomalías  │
                 └─────────────┘
```

### Capas de la Arquitectura

| Capa | Componente | Tecnología | Propósito |
|------|------------|------------|-----------|
| **Application** | Demo App | Node.js + Express | Aplicación instrumentada que genera telemetría |
| **Collection** | OTel Collector | OpenTelemetry | Recopilación y enrutamiento de telemetría |
| **Storage** | Prometheus | Prometheus | Almacenamiento de métricas de series temporales |
| **Storage** | Tempo | Grafana Tempo | Almacenamiento de trazas distribuidas |
| **Visualization** | Grafana | Grafana | Dashboards, visualización y alertas |
| **Analysis** | Anomaly Detector | Python + ML | Detección de anomalías con ML |
| **CI/CD** | GitHub Actions | GitHub Actions | Pipeline de integración y despliegue |

---

## 🔄 Flujo de Datos

### Flujo de Telemetría Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUJO DE TELEMETRÍA                         │
└─────────────────────────────────────────────────────────────────┘

1. GENERACIÓN
   ┌──────────────┐
   │  Demo App    │
   │              │
   │ • HTTP APIs  │
   │ • Métricas   │
   │ • Trazas     │
   └──────┬───────┘
          │
          │ OpenTelemetry SDK
          │ (OTLP gRPC/HTTP)
          ▼
2. RECOPILACIÓN
   ┌──────────────────┐
   │ OTel Collector   │
   │                  │
   │ Receivers:       │
   │ • OTLP gRPC      │ :4317
   │ • OTLP HTTP      │ :4318
   │                  │
   │ Processors:      │
   │ • Batch          │
   │ • Memory Limiter │
   │                  │
   │ Exporters:       │
   │ • Prometheus     │ :8889
   │ • OTLP (Tempo)   │
   └────┬─────────┬───┘
        │         │
        │         │
3. ALMACENAMIENTO
        │         │
        ▼         ▼
   ┌─────────┐ ┌─────────┐
   │Prometheus│ │  Tempo  │
   │         │ │         │
   │ Métricas│ │ Trazas  │
   │ :9090   │ │ :3200   │
   └────┬────┘ └────┬────┘
        │           │
        │           │
4. ANÁLISIS
        │           │
        ├───────────┴──────┐
        │                  │
        ▼                  ▼
   ┌─────────┐      ┌──────────┐
   │Anomaly  │      │ Grafana  │
   │Detector │      │          │
   │         │      │ Queries  │
   │ ML      │──────│ Dashboards│
   │ Python  │      │ Alertas  │
   └─────────┘      │ :3001    │
                    └──────────┘
                         │
                         │
5. VISUALIZACIÓN Y ALERTAS
                         │
                         ▼
                    ┌─────────┐
                    │ Usuario │
                    │   SRE   │
                    └─────────┘
```

### Protocolos y Puertos

| Componente | Puerto | Protocolo | Propósito |
|------------|--------|-----------|-----------|
| Demo App | 3000 | HTTP | API endpoints |
| OTel Collector | 4317 | gRPC | OTLP receiver |
| OTel Collector | 4318 | HTTP | OTLP receiver |
| OTel Collector | 8889 | HTTP | Prometheus exporter |
| Prometheus | 9090 | HTTP | Metrics storage & query |
| Tempo | 3200 | HTTP | Trace storage & query |
| Grafana | 3001 | HTTP | Dashboards & UI |

---

## 🐳 Arquitectura de Despliegue

### Docker Compose (Desarrollo Local)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOCKER COMPOSE STACK                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    observability-network                         │
│                         (bridge)                                 │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ demo-app     │  │otel-collector│  │ prometheus   │         │
│  │              │  │              │  │              │         │
│  │ Node.js      │  │ Collector    │  │ TSDB         │         │
│  │ :3000        │  │ :4317/:4318  │  │ :9090        │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ tempo        │  │ grafana      │  │ anomaly-     │         │
│  │              │  │              │  │ detector     │         │
│  │ Traces       │  │ Dashboards   │  │ ML Service   │         │
│  │ :3200        │  │ :3001        │  │ Python       │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    PERSISTENT VOLUMES                            │
├─────────────────────────────────────────────────────────────────┤
│  • prometheus-data  → /prometheus                               │
│  • tempo-data       → /var/tempo                                │
│  • grafana-data     → /var/lib/grafana                          │
└─────────────────────────────────────────────────────────────────┘
```

### Estructura de Archivos

```
Proyecto-g5/
├── docker-compose.yml          # Orquestación de servicios
├── demo-app/
│   ├── Dockerfile             # Imagen Node.js
│   └── src/                   # Código fuente
├── otel-collector/
│   └── otel-collector-config.yaml
├── prometheus/
│   ├── prometheus.yml         # Configuración
│   └── rules/                 # Reglas de alerta
├── tempo/
│   └── tempo.yaml            # Configuración
├── grafana/
│   └── provisioning/
│       ├── datasources/      # Prometheus, Tempo
│       ├── dashboards/       # Dashboards JSON
│       └── alerting/         # Reglas de alerta
└── anomaly-detector/
    ├── Dockerfile            # Imagen Python
    └── *.py                  # Código ML
```

---

## ☸️ Arquitectura Kubernetes

### Diagrama de Despliegue K8s

```
┌─────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                            │
│                      Namespace: observability                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         DEPLOYMENTS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ demo-app         │  │ otel-collector   │                    │
│  │                  │  │                  │                    │
│  │ Replicas: 3      │  │ Replicas: 2      │                    │
│  │ HPA: 2-10        │  │                  │                    │
│  │                  │  │                  │                    │
│  │ Resources:       │  │ Resources:       │                    │
│  │ • CPU: 100m-500m │  │ • CPU: 200m-1    │                    │
│  │ • Mem: 128Mi-512Mi│ │ • Mem: 256Mi-512Mi│                   │
│  └──────────────────┘  └──────────────────┘                    │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ grafana          │  │ anomaly-detector │                    │
│  │                  │  │                  │                    │
│  │ Replicas: 1      │  │ Replicas: 1      │                    │
│  │ LoadBalancer     │  │                  │                    │
│  │                  │  │                  │                    │
│  │ Resources:       │  │ Resources:       │                    │
│  │ • CPU: 100m-500m │  │ • CPU: 100m-500m │                    │
│  │ • Mem: 256Mi-512Mi│ │ • Mem: 256Mi-512Mi│                   │
│  └──────────────────┘  └──────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        STATEFULSETS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ prometheus       │  │ tempo            │                    │
│  │                  │  │                  │                    │
│  │ Replicas: 1      │  │ Replicas: 1      │                    │
│  │                  │  │                  │                    │
│  │ PVC: 50Gi        │  │ PVC: 100Gi       │                    │
│  │                  │  │                  │                    │
│  │ Resources:       │  │ Resources:       │                    │
│  │ • CPU: 500m-2    │  │ • CPU: 500m-1    │                    │
│  │ • Mem: 2Gi-4Gi   │  │ • Mem: 1Gi-2Gi   │                    │
│  └──────────────────┘  └──────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          SERVICES                                │
├─────────────────────────────────────────────────────────────────┤
│  • demo-app          → ClusterIP                                │
│  • otel-collector    → ClusterIP                                │
│  • prometheus        → ClusterIP                                │
│  • tempo             → ClusterIP                                │
│  • grafana           → LoadBalancer (External IP)               │
│  • anomaly-detector  → ClusterIP                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        CONFIGMAPS                                │
├─────────────────────────────────────────────────────────────────┤
│  • otel-collector-config                                        │
│  • prometheus-config                                            │
│  • tempo-config                                                 │
│  • grafana-datasources                                          │
│  • grafana-dashboards                                           │
└─────────────────────────────────────────────────────────────────┘
```

### Opciones de Despliegue K8s

#### Opción 1: Helm Chart
```bash
helm install aiops-platform ./helm/aiops-platform \
  --namespace observability \
  --create-namespace \
  --values helm/aiops-platform/values-prod.yaml
```

#### Opción 2: Kustomize
```bash
kubectl apply -k k8s/overlays/prod
```

---

## 🔄 Pipeline CI/CD

### Diagrama del Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS PIPELINE                       │
└─────────────────────────────────────────────────────────────────┘

┌──────────┐
│   Push   │
│ to main/ │
│  develop │
└────┬─────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────┐
│                         STAGE 1: TEST                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Checkout     │→ │ Setup Node   │→ │ Run Tests    │         │
│  │ Code         │  │ Setup Python │  │ • Unit       │         │
│  └──────────────┘  └──────────────┘  │ • Linters    │         │
│                                       │ • Coverage   │         │
│                                       └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                        STAGE 2: BUILD                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ Build Docker     │  │ Build Docker     │                    │
│  │ demo-app         │  │ anomaly-detector │                    │
│  │                  │  │                  │                    │
│  │ • Tag: latest    │  │ • Tag: latest    │                    │
│  │ • Tag: SHA       │  │ • Tag: SHA       │                    │
│  └────────┬─────────┘  └────────┬─────────┘                    │
│           │                     │                               │
│           └──────────┬──────────┘                               │
│                      ▼                                           │
│           ┌──────────────────┐                                  │
│           │ Push to Registry │                                  │
│           │ (ghcr.io)        │                                  │
│           └──────────────────┘                                  │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                       STAGE 3: DEPLOY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐                                           │
│  │ Deploy to        │                                           │
│  │ Staging          │                                           │
│  │                  │                                           │
│  │ • docker-compose │                                           │
│  │ • Wait for ready │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │ Run Smoke Tests  │                                           │
│  │                  │                                           │
│  │ • Health checks  │                                           │
│  │ • Metrics test   │                                           │
│  │ • Traces test    │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │ Manual Approval  │ (if main branch)                          │
│  │ for Production   │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │ Deploy to        │                                           │
│  │ Production       │                                           │
│  │                  │                                           │
│  │ • K8s/Helm       │                                           │
│  │ • Verify         │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌──────────┐
                    │ Success! │
                    └──────────┘
```

### Workflow File
**Ubicación:** `.github/workflows/main-pipeline.yml`

---

## 📦 Componentes y Repositorios

### Estructura de Repositorio

```
github.com/Sklaid/Proyecto-g5
│
├── demo-app/                    # Aplicación Node.js
│   ├── src/
│   │   ├── index.js            # Servidor Express
│   │   ├── tracing.js          # Config OpenTelemetry
│   │   └── metrics.js          # Métricas custom
│   ├── Dockerfile
│   └── package.json
│
├── otel-collector/              # OpenTelemetry Collector
│   └── otel-collector-config.yaml
│
├── prometheus/                  # Prometheus
│   ├── prometheus.yml
│   └── rules/
│       ├── recording-rules.yml
│       └── slo-alerts.yml
│
├── tempo/                       # Grafana Tempo
│   └── tempo.yaml
│
├── grafana/                     # Grafana
│   └── provisioning/
│       ├── datasources/
│       ├── dashboards/
│       └── alerting/
│
├── anomaly-detector/            # Detector de Anomalías
│   ├── anomaly_detector.py
│   ├── prometheus_client.py
│   ├── main.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── k8s/                         # Kubernetes
│   ├── base/
│   └── overlays/
│       ├── dev/
│       └── prod/
│
├── helm/                        # Helm Charts
│   └── aiops-platform/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
├── .github/workflows/           # CI/CD
│   └── main-pipeline.yml
│
├── docs/                        # Documentación
│   ├── validation-reports/
│   ├── guides/
│   ├── summaries/
│   └── ci-cd/
│
├── scripts/                     # Scripts
│   ├── validation/
│   ├── traffic-generation/
│   └── utilities/
│
├── docker-compose.yml           # Orquestación local
└── README.md                    # Documentación principal
```

### Mapa de Componentes

| Componente | Directorio | Lenguaje | Imagen Docker | Puerto |
|------------|-----------|----------|---------------|--------|
| Demo App | `demo-app/` | Node.js | `ghcr.io/sklaid/proyecto-g5/demo-app` | 3000 |
| OTel Collector | `otel-collector/` | Go | `otel/opentelemetry-collector-contrib` | 4317, 4318 |
| Prometheus | `prometheus/` | Go | `prom/prometheus` | 9090 |
| Tempo | `tempo/` | Go | `grafana/tempo` | 3200 |
| Grafana | `grafana/` | Go | `grafana/grafana` | 3001 |
| Anomaly Detector | `anomaly-detector/` | Python | `ghcr.io/sklaid/proyecto-g5/anomaly-detector` | - |

---

## 📚 Documentos de Referencia

### Documentación de Diseño
- **Documento Principal:** `.kiro/specs/aiops-sre-observability/design.md`
- **Documento de Requisitos:** `.kiro/specs/aiops-sre-observability/requirements.md`
- **Plan de Tareas:** `.kiro/specs/aiops-sre-observability/tasks.md`

### Documentación de Validación
- **Índice de Validación:** `docs/validation-reports/VALIDATION_INDEX.md`
- **Reportes Task 11:** `docs/validation-reports/TASK_11.*_VALIDATION_REPORT.md`

### Guías de Usuario
- **Quick Start:** `docs/guides/QUICK_START.md`
- **Grafana Quick Start:** `docs/guides/GRAFANA_QUICK_START.md`
- **SLI/SLO Configuration:** `docs/guides/SLI_SLO_CONFIGURATION_GUIDE.md`

### Documentación CI/CD
- **Índice CI/CD:** `docs/ci-cd/CI-CD-DOCS-INDEX.md`
- **Implementación CI/CD:** `docs/ci-cd/CI-CD-IMPLEMENTATION.md`

---

## 🔗 Enlaces Rápidos

- **README Principal:** [README.md](README.md)
- **Índice de Documentación:** [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- **Repositorio GitHub:** https://github.com/Sklaid/Proyecto-g5
- **GitHub Actions:** https://github.com/Sklaid/Proyecto-g5/actions

---

**Última actualización:** 2025-10-05
**Versión:** 1.0.0
