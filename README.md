# Plataforma de Observabilidad AIOps & SRE

[![Pipeline CI/CD](https://github.com/Sklaid/aiops-platform/workflows/CI/badge.svg)](https://github.com/Sklaid/aiops-platform/actions)
[![Licencia](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Una plataforma de observabilidad y AIOps lista para producción que combina instrumentación moderna con OpenTelemetry, monitoreo basado en SLI/SLO y detección inteligente de anomalías para reducir el Tiempo Medio de Recuperación (MTTR) hasta en un 70%.

**📚 [Ver Índice Completo de Documentación](DOCUMENTATION_INDEX.md)** | **✅ [Estado de Validación](docs/validation-reports/VALIDATION_INDEX.md)** | **🚀 [Guía de Inicio Rápido](docs/guides/QUICK_START.md)**

## 🎯 Descripción General

Esta plataforma proporciona **observabilidad completa de extremo a extremo** para aplicaciones distribuidas implementando los tres pilares de la observabilidad (Métricas, Trazas, Logs) y agregando detección inteligente de anomalías.

### Capacidades Clave

- **📊 Instrumentación OpenTelemetry**: Recopilación estandarizada y neutral de métricas y trazas distribuidas
- **💾 Almacenamiento de Métricas**: Prometheus para métricas de series temporales con retención configurable (predeterminado: 15 días)
- **🔍 Almacenamiento de Trazas**: Grafana Tempo para almacenamiento eficiente de trazas distribuidas
- **📈 Visualización**: Dashboards preconfigurados de Grafana para SLIs, SLOs, presupuestos de error y rendimiento de aplicaciones
- **🚨 Alertas Inteligentes**: Alertas multi-ventana basadas en SLO y detección de anomalías basada en ML
- **🤖 AIOps**: Detección automática de anomalías usando algoritmo Isolation Forest
- **🔄 Integración CI/CD**: Pipeline completo de GitHub Actions con pruebas y despliegue automatizados
- **☸️ Cloud Native**: Listo para despliegue en Kubernetes con Helm charts y overlays de Kustomize

### ¿Por Qué Esta Plataforma?

**Problema:** El monitoreo tradicional te dice *qué* está roto, pero no *por qué* o *cómo arreglarlo rápidamente*.

**Solución:** Esta plataforma proporciona:
- **Detección más rápida de incidentes** (< 5 minutos vs horas)
- **Análisis rápido de causa raíz** (< 15 minutos con trazas distribuidas)
- **Alertas proactivas** (detecta problemas antes de que los usuarios los noten)
- **MTTR reducido** (mejora del 70-80% documentada)

## Arquitectura

```
┌─────────────────┐
│   Demo App      │ ──┐
│  (Node.js)      │   │ Métricas y Trazas
└─────────────────┘   │
                      ▼
              ┌──────────────────┐
              │ OTel Collector   │
              └──────────────────┘
                   │         │
        Métricas   │         │    Trazas
                   ▼         ▼
            ┌──────────┐  ┌──────────┐
            │Prometheus│  │  Tempo   │
            └──────────┘  └──────────┘
                   │         │
                   └────┬────┘
                        ▼
                 ┌─────────────┐
                 │   Grafana   │ ◄── Dashboards y Alertas
                 └─────────────┘
                        ▲
                        │ Alertas de Anomalías
                 ┌─────────────┐
                 │  Detector   │
                 │  Anomalías  │
                 └─────────────┘
```

## Componentes

### Aplicación Demo
- Aplicación Node.js Express con instrumentación OpenTelemetry
- Exporta métricas (CPU, memoria, conteo de solicitudes, duración)
- Genera trazas distribuidas con propagación de contexto
- Simula patrones de tráfico realistas y escenarios de error

### OpenTelemetry Collector
- Recibe telemetría vía OTLP (gRPC y HTTP)
- Procesa datos con batching y limitación de memoria
- Exporta métricas a Prometheus y trazas a Tempo

### Prometheus
- Almacena métricas de series temporales con retención de 15 días
- Proporciona interfaz de consulta PromQL
- Soporta reglas de grabación para cálculos de SLI

### Tempo
- Almacena trazas distribuidas eficientemente
- Proporciona API de consulta de trazas
- Se integra con Grafana para visualización

### Grafana
- Dashboards preconfigurados para:
  - Monitoreo SLI/SLO con presupuestos de error
  - Métricas de rendimiento de aplicaciones
  - Visualización de trazas distribuidas
- Reglas de alerta para violaciones de SLO y anomalías
- Datasources para Prometheus y Tempo

### Detector de Anomalías
- Servicio Python usando algoritmo Holt-Winters
- Detecta anomalías en métricas automáticamente
- Genera alertas con niveles de confianza
- Reduce MTTR a través de insights predictivos

## 🚀 Inicio Rápido

### Prerrequisitos

Antes de comenzar, asegúrate de tener:

- **Docker** (versión 20.10+) y **Docker Compose** (versión 2.0+) instalados
- Al menos **4GB de RAM disponible** (8GB recomendado para pruebas similares a producción)
- Los siguientes **puertos disponibles**:
  - `3000` - Aplicación Demo
  - `3001` - Grafana
  - `4317` - OTel Collector (gRPC)
  - `4318` - OTel Collector (HTTP)
  - `8889` - OTel Collector (exportador Prometheus)
  - `9090` - Prometheus
  - `3200` - Tempo
- **Git** para clonar el repositorio

### 🐳 Despliegue Local con Docker Compose

#### Paso 1: Clonar y Navegar

```bash
git clone https://github.com/Sklaid/aiops-sre-observability.git
cd aiops-sre-observability
```

#### Paso 2: Iniciar Todos los Servicios

```bash
# Iniciar todos los servicios en modo desacoplado
docker-compose up -d

# Ver los logs (opcional)
docker-compose logs -f
```

**Salida esperada:**
```
✔ Container demo-app           Started
✔ Container otel-collector     Started
✔ Container prometheus         Started
✔ Container tempo              Started
✔ Container grafana            Started
✔ Container anomaly-detector   Started
```

#### Paso 3: Verificar que los Servicios Están Ejecutándose

```bash
# Verificar estado de servicios
docker-compose ps

# Todos los servicios deben mostrar estado "Up"
```

#### Paso 4: Generar Tráfico de Muestra

```powershell
# Windows PowerShell
.\scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# O usar el archivo batch
.\scripts\traffic-generation\generate-traffic.bat
```

```bash
# Linux/Mac
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products
```

#### Paso 5: Acceder a los Servicios

| Servicio | URL | Credenciales | Propósito |
|---------|-----|-------------|---------|
| **Grafana** | http://localhost:3001 | `admin` / `grupo5_devops` | Dashboards y Visualización |
| **Prometheus** | http://localhost:9090 | Ninguna | Interfaz de Consulta de Métricas |
| **Tempo** | http://localhost:3200 | Ninguna | API de Consulta de Trazas |
| **Demo App** | http://localhost:3000 | Ninguna | Aplicación Instrumentada |

### 📊 Accediendo a los Dashboards de Grafana

1. **Abrir Grafana**: Navegar a http://localhost:3001
2. **Iniciar Sesión**: Usar credenciales `admin` / `grupo5_devops`
3. **Ver Dashboards**: Hacer clic en el menú (☰) → Dashboards

**Dashboards Disponibles:**

| Dashboard | URL | Descripción |
|-----------|-----|-------------|
| **Dashboard SLI/SLO** | http://localhost:3001/d/slo-dashboard | Monitorear SLIs, SLOs, presupuestos de error y tasas de consumo |
| **Rendimiento de Aplicación** | http://localhost:3001/d/app-performance-dashboard | Latencia de solicitudes, throughput, errores y utilización de recursos |
| **Trazas Distribuidas** | http://localhost:3001/d/distributed-tracing | Análisis de trazas y dependencias de servicios |

4. **Explorar Trazas**: Navegar a Explore (ícono de brújula) → Seleccionar datasource Tempo → Query: `{status=error}`

### 🎬 Script de Demo Rápido

¿Quieres ver la plataforma en acción? Ejecuta esta demo:

```powershell
# 1. Generar tráfico normal por 30 segundos
.\scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5

# 2. Generar algunos errores
.\scripts\traffic-generation\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1

# 3. Generar tráfico mixto (normal + errores)
.\scripts\traffic-generation\generate-mixed-traffic.ps1 -DurationSeconds 60 -ErrorRatePercent 15

# 4. Abrir todos los dashboards
.\scripts\utilities\open-all-dashboards.bat
```

¡Ahora observa cómo los dashboards se actualizan en tiempo real!

## 📁 Estructura del Proyecto

```
aiops-sre-observability/
├── .github/
│   └── workflows/              # Pipelines CI/CD de GitHub Actions
│       └── main-pipeline.yml   # Workflow principal de CI/CD
├── demo-app/                   # Aplicación demo Node.js
│   ├── src/
│   │   ├── index.js           # Aplicación principal con instrumentación OTel
│   │   ├── tracing.js         # Configuración de tracing OpenTelemetry
│   │   └── metrics.js         # Definiciones de métricas personalizadas
│   ├── Dockerfile             # Build Docker multi-etapa
│   ├── package.json           # Dependencias Node.js
│   └── README.md              # Documentación de la app demo
├── otel-collector/            # OpenTelemetry Collector
│   └── otel-collector-config.yaml  # Configuración del Collector
├── prometheus/                # Base de datos de series temporales Prometheus
│   ├── prometheus.yml         # Configuración de Prometheus
│   └── rules/                 # Reglas de grabación y alertas
│       ├── recording-rules.yml
│       └── slo-alerts.yml
├── tempo/                     # Trazas distribuidas Grafana Tempo
│   └── tempo.yaml            # Configuración de Tempo
├── grafana/                   # Visualización Grafana
│   └── provisioning/
│       ├── datasources/       # Datasources autoconfigurados
│       │   ├── prometheus.yml
│       │   └── tempo.yml
│       ├── dashboards/        # Configuración de provisioning de dashboards
│       │   └── json/          # Definiciones JSON de dashboards
│       │       ├── sli-slo-dashboard.json
│       │       ├── app-performance-dashboard.json
│       │       └── distributed-tracing-dashboard.json
│       └── alerting/          # Reglas de alerta
│           └── rules.yml
├── anomaly-detector/          # Servicio Python de detección de anomalías ML
│   ├── anomaly_detector.py    # Algoritmo Isolation Forest
│   ├── prometheus_client.py   # Cliente de consulta Prometheus
│   ├── main.py               # Punto de entrada del servicio
│   ├── requirements.txt      # Dependencias Python
│   ├── Dockerfile            # Build Docker del servicio Python
│   └── test_anomaly_detector.py  # Pruebas unitarias
├── k8s/                       # Manifiestos de despliegue Kubernetes
│   ├── base/                  # Recursos base de Kubernetes
│   │   ├── demo-app-deployment.yaml
│   │   ├── prometheus-statefulset.yaml
│   │   ├── tempo-statefulset.yaml
│   │   └── ...
│   └── overlays/              # Overlays específicos por entorno
│       ├── dev/
│       └── prod/
├── helm/                      # Charts Helm
│   └── aiops-platform/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
├── scripts/                   # Scripts de utilidad
│   ├── validation/            # Scripts de validación
│   ├── traffic-generation/    # Scripts de generación de tráfico
│   └── utilities/             # Scripts de utilidades
├── docs/                      # Documentación
│   ├── validation-reports/    # Reportes de validación
│   ├── guides/                # Guías de usuario
│   ├── summaries/             # Resúmenes técnicos
│   └── ci-cd/                 # Documentación CI/CD
├── docker-compose.yml         # Orquestación Docker Compose
└── README.md                  # Este archivo
```

### Directorios Clave Explicados

| Directorio | Propósito | Archivos Clave |
|-----------|---------|-----------|
| `demo-app/` | Aplicación Node.js instrumentada | `src/index.js`, `src/tracing.js` |
| `otel-collector/` | Recopilación y enrutamiento de telemetría | `otel-collector-config.yaml` |
| `prometheus/` | Almacenamiento y consulta de métricas | `prometheus.yml`, `rules/*.yml` |
| `tempo/` | Almacenamiento de trazas distribuidas | `tempo.yaml` |
| `grafana/` | Visualización y dashboards | `provisioning/dashboards/json/*.json` |
| `anomaly-detector/` | Detección de anomalías basada en ML | `anomaly_detector.py` |
| `k8s/` | Despliegue Kubernetes | `base/*.yaml`, `overlays/*/` |
| `helm/` | Chart Helm para K8s | `aiops-platform/` |
| `.github/workflows/` | Pipelines CI/CD | `main-pipeline.yml` |
| `docs/` | Documentación completa | `validation-reports/`, `guides/` |
| `scripts/` | Scripts de utilidad | `validation/`, `traffic-generation/`, `utilities/` |

## 🎯 Características Clave

### Monitoreo SLI/SLO
- **Seguimiento de percentiles de latencia** (P95, P99) con umbrales configurables
- **Monitoreo de tasas de error** y disponibilidad en tiempo real
- **Cálculo automático de presupuestos de error** basado en objetivos SLO
- **Visualización de tasas de consumo** con análisis multi-ventana (1h, 6h, 24h)
- **Proyección de agotamiento de presupuesto** para tomar acción proactiva

### Trazas Distribuidas
- **Trazado de solicitudes de extremo a extremo** a través de todos los servicios
- **Mapeo de dependencias de servicios** para entender la arquitectura del sistema
- **Análisis de desglose de latencia** para identificar componentes lentos
- **Resaltado de trazas de error** para identificación rápida de problemas
- **Propagación de contexto** a través de límites de servicios

### Detección Inteligente de Anomalías
- **Reconocimiento de patrones basado en ML** usando algoritmo Isolation Forest
- **Alertas automáticas de anomalías** con puntuación de confianza
- **Aprendizaje de línea base histórica** (7-30 días de datos)
- **Reducción de falsos positivos** a través de análisis estadístico
- **Insights predictivos** para prevenir incidentes

### Alertas Basadas en SLO
- **Alertas multi-ventana multi-tasa-de-consumo** (mejor práctica de Google SRE)
- **Alertas de consumo de presupuesto de error** antes del agotamiento del presupuesto
- **Alertas de umbral de latencia** cuando P95 excede SLI
- **Alertas de detección de anomalías** para patrones inusuales
- **Información contextual de alertas** para resolución más rápida

## 📊 Entendiendo los Dashboards

### 1. Dashboard SLI/SLO

**Propósito:** Monitorear objetivos de nivel de servicio y consumo de presupuesto de error

**Paneles Clave:**

| Panel | Qué Muestra | Cómo Interpretar |
|-------|---------------|------------------|
| **Latencia de Solicitud (P95/P99)** | Latencia percentil 95 y 99 | Verde = Bueno (<200ms), Rojo = Violación SLO |
| **Tasa de Éxito** | % de solicitudes exitosas (no-5xx) | Objetivo: 99.9%, Amarillo <99.5%, Rojo <99% |
| **Presupuesto de Error Restante** | % de presupuesto de error restante para ventana de 30d | Verde >50%, Amarillo 20-50%, Rojo <20% |
| **Tasa de Error** | % de solicitudes fallidas (4xx, 5xx) | Objetivo: <1%, Alerta si >1% |
| **Tasa de Consumo (Multi-Ventana)** | Tasa de consumo de presupuesto de error | Crítico si >14.4x (presupuesto agotado en 2 días) |
| **Tasa de Consumo Actual** | Tasa de consumo de 1 hora | Muestra tasa de consumo inmediata |
| **Presupuesto de Error (30d)** | Total, consumido y restante | Seguir presupuesto a lo largo del tiempo |
| **Cumplimiento SLO de Latencia** | % de solicitudes que cumplen SLO de latencia | Objetivo: 99.9% bajo 200ms |
| **Tasa de Solicitudes** | Throughput (solicitudes/segundo) | Monitorear patrones de tráfico |

**Cómo Usar:**
1. **Verificar medidor de Tasa de Éxito** - ¿Está por encima del 99.9%?
2. **Monitorear Tasa de Consumo** - ¿Se está acelerando?
3. **Revisar Presupuesto de Error** - ¿Cuánto presupuesto queda?
4. **Investigar picos** - Hacer clic en anomalías para profundizar

**Umbrales de Alerta:**
- 🔴 **Crítico**: Tasa de consumo >14.4x (presupuesto agotado en <2 días)
- 🟡 **Advertencia**: Tasa de consumo >6x (presupuesto agotado en <5 días)
- 🟢 **Normal**: Tasa de consumo <3x

### 2. Dashboard de Rendimiento de Aplicación

**Propósito:** Monitorear salud de aplicación y utilización de recursos

**Paneles Clave:**

| Panel | Qué Muestra | Cómo Interpretar |
|-------|---------------|------------------|
| **Histograma de Duración de Solicitud** | Distribución de latencias de solicitud | Buscar distribuciones bimodales o colas largas |
| **Duración de Solicitud por Endpoint** | Desglose de latencia por endpoint API | Identificar endpoints lentos |
| **Throughput por Endpoint** | Solicitudes/seg por endpoint | Entender patrones de tráfico |
| **Top 10 Endpoints** | Endpoints más frecuentemente llamados | Optimizar endpoints de alto tráfico |
| **Desglose de Tasa de Error** | Errores por código de estado (4xx, 5xx) | 4xx = errores de cliente, 5xx = errores de servidor |
| **Distribución de Código de Estado** | Gráfico circular de códigos de respuesta | Saludable = mayormente 2xx |
| **Utilización de CPU** | Uso de CPU a lo largo del tiempo | Alerta si >80% sostenido |
| **Utilización de Memoria** | Uso de memoria a lo largo del tiempo | Alerta si >80% o creciendo |
| **Uso Actual de CPU/Heap** | Uso de recursos en tiempo real | Monitorear agotamiento de recursos |
| **Tasa Total de Solicitudes** | Throughput general | Línea base para planificación de capacidad |

**Cómo Usar:**
1. **Verificar utilización de recursos** - ¿CPU/Memoria bajo 80%?
2. **Revisar desglose de errores** - ¿Están aumentando los errores 5xx?
3. **Identificar endpoints lentos** - ¿Qué APIs necesitan optimización?
4. **Monitorear throughput** - ¿El tráfico está dentro del rango esperado?

### 3. Dashboard de Trazas Distribuidas

**Propósito:** Analizar flujos de solicitudes e identificar cuellos de botella

**Paneles Clave:**

| Panel | Qué Muestra | Cómo Interpretar |
|-------|---------------|------------------|
| **Tasa de Solicitud de Servicio** | Solicitudes/seg por servicio | Entender carga de servicio |
| **Desglose de Latencia** | P50, P95, P99 por servicio | Identificar servicios lentos |
| **Volumen de Trazas** | Número de trazas por estado | Monitorear recopilación de trazas |
| **Promedio de Spans por Traza** | Complejidad de solicitudes | Más spans = más llamadas de servicio |

**Cómo Usar Búsqueda de Trazas:**
1. Navegar a **Grafana Explore** (ícono de brújula)
2. Seleccionar datasource **Tempo**
3. Usar consultas:
   - `{status=error}` - Encontrar todas las trazas de error
   - `{service.name="demo-app"}` - Filtrar por servicio
   - `{http.status_code="500"}` - Encontrar errores específicos
4. Hacer clic en una traza para ver línea de tiempo detallada de spans
5. Analizar duración de span para encontrar cuellos de botella

**Consejos de Análisis de Trazas:**
- **Spans largos** = operaciones lentas (base de datos, API externa)
- **Muchos spans** = flujo de solicitud complejo
- **Spans de error** = excepciones o fallos
- **Atributos de span** = información contextual (ID de usuario, endpoint, etc.)

### Mejores Prácticas de Dashboards

1. **Comenzar con Dashboard SLI/SLO** - ¿El servicio está saludable?
2. **Si hay violación de SLO, verificar Rendimiento de Aplicación** - ¿Qué lo está causando?
3. **Usar Trazas Distribuidas para causa raíz** - ¿Qué componente es lento?
4. **Monitorear tendencias a lo largo del tiempo** - ¿Las cosas están mejorando o empeorando?
5. **Configurar alertas** - No depender de verificación manual

## Desarrollo

### Ejecutar Pruebas

#### Pruebas Unitarias
```bash
# Pruebas unitarias de la app demo
cd demo-app
npm test

# Pruebas del detector de anomalías
cd anomaly-detector
python -m pytest
```

#### Pruebas de Integración
Las pruebas de integración verifican el pipeline completo de telemetría desde la app demo a través del collector hasta Prometheus y Tempo.

**Inicio Rápido (Windows):**
```cmd
cd demo-app
run-integration-tests.bat
```

**Inicio Rápido (Linux/Mac):**
```bash
cd demo-app
chmod +x run-integration-tests.sh
./run-integration-tests.sh
```

**Ejecución Manual:**
```bash
# 1. Iniciar todos los servicios
docker-compose up -d

# 2. Esperar a que los servicios estén listos (30 segundos)

# 3. Ejecutar pruebas de integración
cd demo-app
npm run test:integration
```

**Lo que verifican las pruebas de integración:**
- ✅ El Collector recibe métricas y trazas OTLP de la app demo
- ✅ Las métricas se exportan en formato Prometheus
- ✅ Las métricas de aplicación y personalizadas aparecen en Prometheus
- ✅ Las trazas se reenvían a Tempo con contexto preservado
- ✅ Las trazas de error se manejan correctamente
- ✅ Pipeline completo de telemetría de extremo a extremo

Para información detallada, ver [demo-app/INTEGRATION_TESTS.md](demo-app/INTEGRATION_TESTS.md)

### Construir Imágenes Docker
```bash
# Construir todas las imágenes
docker-compose build

# Construir servicio específico
docker-compose build demo-app
```

### Ver Logs
```bash
# Todos los servicios
docker-compose logs -f

# Servicio específico
docker-compose logs -f demo-app
```

## ☸️ Despliegue en Kubernetes

Para despliegues de producción en Kubernetes, proporcionamos dos opciones:

### Opción 1: Helm Chart (Recomendado)

```bash
# Instalar con Helm
helm install aiops-platform ./helm/aiops-platform \
  --namespace observability \
  --create-namespace \
  --values helm/aiops-platform/values-prod.yaml

# Verificar despliegue
kubectl get pods -n observability

# Acceder a Grafana (después de que LoadBalancer obtenga IP externa)
kubectl get svc -n observability grafana
```

**Características del Helm Chart:**
- Configuraciones parametrizadas para diferentes entornos
- Requests y límites de recursos preconfigurados
- HorizontalPodAutoscaler para demo-app
- PersistentVolumeClaims para persistencia de datos
- ConfigMaps para todas las configuraciones de componentes

### Opción 2: Kustomize

```bash
# Desplegar a desarrollo
kubectl apply -k k8s/overlays/dev

# Desplegar a producción
kubectl apply -k k8s/overlays/prod

# Verificar despliegue
kubectl get all -n observability
```

**Características de Kustomize:**
- Manifiestos base con overlays específicos por entorno
- Fácil personalización por entorno
- Estructura amigable con GitOps

### Arquitectura Kubernetes

```
┌─────────────────────────────────────────────────┐
│              Cluster Kubernetes                  │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Deployment  │  │  Deployment  │            │
│  │  demo-app    │  │ otel-collector│           │
│  │  (3 réplicas)│  │  (2 réplicas)│            │
│  └──────────────┘  └──────────────┘            │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ StatefulSet  │  │ StatefulSet  │            │
│  │  Prometheus  │  │    Tempo     │            │
│  │  (con PVC)   │  │  (con PVC)   │            │
│  └──────────────┘  └──────────────┘            │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Deployment  │  │  Deployment  │            │
│  │   Grafana    │  │   Detector   │            │
│  │(LoadBalancer)│  │   Anomalías  │            │
│  └──────────────┘  └──────────────┘            │
└─────────────────────────────────────────────────┘
```

### Requisitos de Recursos

| Componente | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| demo-app | 100m | 128Mi | 500m | 512Mi |
| otel-collector | 200m | 256Mi | 1000m | 512Mi |
| prometheus | 500m | 2Gi | 2000m | 4Gi |
| tempo | 500m | 1Gi | 1000m | 2Gi |
| grafana | 100m | 256Mi | 500m | 512Mi |
| anomaly-detector | 100m | 256Mi | 500m | 512Mi |

**Requisitos Totales del Cluster:** ~2 núcleos CPU, ~4.5GB RAM mínimo

### Consideraciones de Escalado

```bash
# Escalar demo-app horizontalmente
kubectl scale deployment demo-app --replicas=5 -n observability

# HorizontalPodAutoscaler está preconfigurado
kubectl get hpa -n observability

# Escalar Prometheus verticalmente (editar StatefulSet)
kubectl edit statefulset prometheus -n observability
```

Para instrucciones detalladas de despliegue en Kubernetes, ver [k8s/README.md](k8s/README.md)

## Pipeline CI/CD

El proyecto incluye un pipeline de GitHub Actions que:
1. Ejecuta pruebas y linters
2. Construye imágenes Docker
3. Despliega a staging
4. Ejecuta smoke tests
5. Promueve a producción (aprobación manual)

Para más información, ver [docs/ci-cd/CI-CD-DOCS-INDEX.md](docs/ci-cd/CI-CD-DOCS-INDEX.md)

## Monitoreo de la Plataforma

La plataforma de observabilidad se monitorea a sí misma:
- Métricas del OTel Collector (datos descartados, latencia de exportación)
- Almacenamiento y rendimiento de consultas de Prometheus
- Ingesta y almacenamiento de Tempo
- Rendimiento de dashboards de Grafana

## 🔧 Solución de Problemas

### Problemas Comunes y Soluciones

#### 1. Servicios No Inician

**Problema:** Uno o más contenedores fallan al iniciar

**Solución:**
```bash
# Verificar estado de servicios
docker-compose ps

# Ver logs para errores
docker-compose logs <nombre-servicio>

# Correcciones comunes:
# - Puerto ya en uso: Detener servicios en conflicto
# - Sin memoria: Aumentar límite de memoria de Docker
# - Problemas de permisos: Ejecutar con permisos apropiados

# Reiniciar servicio específico
docker-compose restart <nombre-servicio>

# Reinicio completo
docker-compose down
docker-compose up -d
```

#### 2. Sin Métricas en Grafana

**Problema:** Los dashboards muestran "Sin datos" o paneles vacíos

**Diagnóstico:**
```bash
# 1. Verificar si Prometheus está scrapeando targets
# Abrir: http://localhost:9090/targets
# Todos los targets deben mostrar estado "UP"

# 2. Verificar logs del OTel Collector
docker-compose logs otel-collector | grep -i error

# 3. Verificar que la app demo está enviando métricas
docker-compose logs demo-app | grep -i "metrics"

# 4. Probar endpoint de métricas directamente
curl http://localhost:3000/metrics
```

**Solución:**
```bash
# Generar tráfico para crear métricas
.\scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 30

# Reiniciar Grafana para recargar datasources
docker-compose restart grafana

# Verificar que Prometheus tiene datos
curl http://localhost:9090/api/v1/query?query=up
```

#### 3. Sin Trazas en Tempo

**Problema:** El dashboard de Trazas Distribuidas no muestra trazas

**Diagnóstico:**
```bash
# 1. Verificar que Tempo está recibiendo datos
docker-compose logs tempo | grep -i "received"

# 2. Verificar pipeline de trazas del OTel Collector
docker-compose logs otel-collector | grep -i "trace"

# 3. Verificar exportación de trazas de la app demo
docker-compose logs demo-app | grep -i "span"
```

**Solución:**
```bash
# Generar tráfico para crear trazas
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products

# Consultar Tempo directamente
curl http://localhost:3200/api/search

# En Grafana Explore, usar consulta: {status=error}
```

#### 4. Dashboards No Cargan

**Problema:** Los dashboards de Grafana faltan o no cargan

**Solución:**
```bash
# 1. Reiniciar Grafana
docker-compose restart grafana

# 2. Verificar logs de provisioning
docker-compose logs grafana | grep -i "provisioning"

# 3. Verificar que existen archivos de dashboard
ls -la grafana/provisioning/dashboards/json/

# 4. Re-provisionar dashboards
docker-compose down grafana
docker-compose up -d grafana
```

#### 5. Alto Uso de Memoria

**Problema:** Los contenedores Docker consumen demasiada memoria

**Solución:**
```bash
# Verificar uso de memoria
docker stats

# Ajustar límites de memoria en docker-compose.yml
# Para Prometheus:
mem_limit: 2g

# Para Tempo:
mem_limit: 1g

# Reiniciar con nuevos límites
docker-compose up -d
```

#### 6. Detector de Anomalías No Funciona

**Problema:** No se generan alertas de anomalías

**Diagnóstico:**
```bash
# Verificar logs del detector de anomalías
docker-compose logs anomaly-detector

# Verificar que puede consultar Prometheus
docker-compose exec anomaly-detector curl http://prometheus:9090/api/v1/query?query=up
```

**Solución:**
```bash
# Asegurar datos históricos suficientes (7+ días recomendado)
# Para pruebas, disparar anomalías manualmente:
.\scripts\traffic-generation\generate-test-errors.ps1 -ErrorCount 50

# Reiniciar detector de anomalías
docker-compose restart anomaly-detector
```

#### 7. Conflictos de Puertos

**Problema:** Error "Puerto ya en uso"

**Solución:**
```bash
# Encontrar proceso usando el puerto (Windows)
netstat -ano | findstr :3001

# Matar el proceso
taskkill /PID <process_id> /F

# O cambiar puertos en docker-compose.yml
ports:
  - "3002:3000"  # Usar puerto externo diferente
```

### Obtener Ayuda

Si aún experimentas problemas:

1. **Verificar logs**: `docker-compose logs -f`
2. **Verificar prerrequisitos**: Versión de Docker, puertos disponibles, memoria
3. **Revisar documentación**: Verificar READMEs específicos de componentes
4. **Buscar issues**: Buscar problemas similares en GitHub issues
5. **Crear un issue**: Proporcionar logs, salida de docker-compose ps y pasos para reproducir

### Scripts de Diagnóstico

Proporcionamos scripts de diagnóstico para ayudar a solucionar problemas:

```powershell
# Verificar si las métricas están fluyendo
.\scripts\utilities\verify-error-rate.ps1

# Diagnosticar pipeline de telemetría
.\scripts\utilities\diagnose-telemetry.bat

# Listar métricas disponibles
.\scripts\utilities\list-available-metrics.ps1

# Verificar dashboards
.\scripts\utilities\verify-dashboards.ps1
```

### Endpoints de Health Check

Todos los servicios exponen endpoints de health check:

```bash
# Demo App
curl http://localhost:3000/health
curl http://localhost:3000/ready

# Prometheus
curl http://localhost:9090/-/healthy

# Tempo
curl http://localhost:3200/ready

# Grafana
curl http://localhost:3001/api/health
```

## Consideraciones de Rendimiento

- **Prometheus**: Ajustar período de retención basado en capacidad de almacenamiento
- **Tempo**: Configurar retención de trazas apropiada
- **OTel Collector**: Ajustar tamaño de batch y límites de memoria
- **Detector de Anomalías**: Ajustar intervalo de verificación basado en volumen de métricas

## Seguridad

Para despliegues de producción:
- Cambiar credenciales predeterminadas de Grafana
- Habilitar autenticación en Prometheus y Tempo
- Usar políticas de red para restringir acceso
- Almacenar secretos en sistemas seguros de gestión de secretos

## Contribuir

¡Las contribuciones son bienvenidas! Por favor:
1. Hacer fork del repositorio
2. Crear una rama de feature
3. Hacer cambios con pruebas
4. Enviar un pull request

## Licencia

[Tu Licencia Aquí]

## Soporte

Para problemas y preguntas:
- Abrir un issue en GitHub
- Verificar la sección de solución de problemas
- Revisar logs de componentes

## Hoja de Ruta

Mejoras futuras:
- Integración de logs con Loki
- Integración con service mesh (Istio/Linkerd)
- AIOps avanzado (análisis de causa raíz)
- Recomendaciones de optimización de costos
- Soporte multi-tenancy
- Integración con chaos engineering

## Referencias

- [Documentación OpenTelemetry](https://opentelemetry.io/docs/)
- [Documentación Prometheus](https://prometheus.io/docs/)
- [Documentación Grafana Tempo](https://grafana.com/docs/tempo/)
- [Libro Google SRE - SLIs, SLOs y Presupuestos de Error](https://sre.google/sre-book/service-level-objectives/)

---

## 📚 Documentación Adicional

Para más información detallada, consulta:

- **[Índice de Documentación](DOCUMENTATION_INDEX.md)** - Índice completo de toda la documentación
- **[Reportes de Validación](docs/validation-reports/VALIDATION_INDEX.md)** - Validaciones completas del sistema
- **[Guías de Usuario](docs/guides/)** - Guías detalladas de uso y configuración
- **[Documentación CI/CD](docs/ci-cd/CI-CD-DOCS-INDEX.md)** - Información del pipeline CI/CD
- **[Resúmenes Técnicos](docs/summaries/)** - Resúmenes de tareas y correcciones

---

**¿Preguntas? Consulta el [Índice de Documentación](DOCUMENTATION_INDEX.md) para encontrar la información que necesitas.**
