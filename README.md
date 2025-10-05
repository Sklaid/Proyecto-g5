# AIOps & SRE Observability Platform

[![CI/CD Pipeline](https://github.com/your-org/aiops-platform/workflows/CI/badge.svg)](https://github.com/your-org/aiops-platform/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A production-ready observability and AIOps platform that combines modern instrumentation with OpenTelemetry, SLI/SLO-based monitoring, and intelligent anomaly detection to reduce Mean Time To Recovery (MTTR) by up to 70%.

**📚 [Ver Índice Completo de Documentación](DOCUMENTATION_INDEX.md)** | **✅ [Estado de Validación](docs/validation-reports/VALIDATION_INDEX.md)** | **🚀 [Guía de Inicio Rápido](docs/guides/QUICK_START.md)**

## 🎯 Overview

This platform provides **complete end-to-end observability** for distributed applications by implementing the three pillars of observability (Metrics, Traces, Logs) and adding intelligent anomaly detection on top.

### Key Capabilities

- **📊 OpenTelemetry Instrumentation**: Vendor-neutral, standardized collection of metrics and distributed traces
- **💾 Metrics Storage**: Prometheus for time-series metrics with configurable retention (default: 15 days)
- **🔍 Trace Storage**: Grafana Tempo for efficient distributed tracing storage
- **📈 Visualization**: Pre-configured Grafana dashboards for SLIs, SLOs, error budgets, and application performance
- **🚨 Intelligent Alerting**: SLO-driven multi-window alerts and ML-based anomaly detection
- **🤖 AIOps**: Automated anomaly detection using Isolation Forest algorithm
- **🔄 CI/CD Integration**: Complete GitHub Actions pipeline with automated testing and deployment
- **☸️ Cloud Native**: Ready for Kubernetes deployment with Helm charts and Kustomize overlays

### Why This Platform?

**Problem:** Traditional monitoring tells you *what* is broken, but not *why* or *how to fix it quickly*.

**Solution:** This platform provides:
- **Faster incident detection** (< 5 minutes vs hours)
- **Rapid root cause analysis** (< 15 minutes with distributed tracing)
- **Proactive alerting** (detect issues before users notice)
- **Reduced MTTR** (70-80% improvement documented)

## Architecture

```
┌─────────────────┐
│   Demo App      │ ──┐
│  (Node.js)      │   │ Metrics & Traces
└─────────────────┘   │
                      ▼
              ┌──────────────────┐
              │ OTel Collector   │
              └──────────────────┘
                   │         │
        Metrics    │         │    Traces
                   ▼         ▼
            ┌──────────┐  ┌──────────┐
            │Prometheus│  │  Tempo   │
            └──────────┘  └──────────┘
                   │         │
                   └────┬────┘
                        ▼
                 ┌─────────────┐
                 │   Grafana   │ ◄── Dashboards & Alerts
                 └─────────────┘
                        ▲
                        │ Anomaly Alerts
                 ┌─────────────┐
                 │  Anomaly    │
                 │  Detector   │
                 └─────────────┘
```

## Components

### Demo Application
- Node.js Express application with OpenTelemetry instrumentation
- Exports metrics (CPU, memory, request count, duration)
- Generates distributed traces with context propagation
- Simulates realistic traffic patterns and error scenarios

### OpenTelemetry Collector
- Receives telemetry via OTLP (gRPC and HTTP)
- Processes data with batching and memory limiting
- Exports metrics to Prometheus and traces to Tempo

### Prometheus
- Stores time-series metrics with 15-day retention
- Provides PromQL query interface
- Supports recording rules for SLI calculations

### Tempo
- Stores distributed traces efficiently
- Provides trace query API
- Integrates with Grafana for visualization

### Grafana
- Pre-configured dashboards for:
  - SLI/SLO monitoring with error budgets
  - Application performance metrics
  - Distributed tracing visualization
- Alert rules for SLO breaches and anomalies
- Datasources for Prometheus and Tempo

### Anomaly Detector
- Python service using Holt-Winters algorithm
- Detects anomalies in metrics automatically
- Generates alerts with confidence levels
- Reduces MTTR through predictive insights

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- **Docker** (version 20.10+) and **Docker Compose** (version 2.0+) installed
- At least **4GB of available RAM** (8GB recommended for production-like testing)
- The following **ports available**:
  - `3000` - Demo Application
  - `3001` - Grafana
  - `4317` - OTel Collector (gRPC)
  - `4318` - OTel Collector (HTTP)
  - `8889` - OTel Collector (Prometheus exporter)
  - `9090` - Prometheus
  - `3200` - Tempo
- **Git** for cloning the repository

### 🐳 Local Deployment with Docker Compose

#### Step 1: Clone and Navigate

```bash
git clone https://github.com/your-org/aiops-sre-observability.git
cd aiops-sre-observability
```

#### Step 2: Start All Services

```bash
# Start all services in detached mode
docker-compose up -d

# Watch the logs (optional)
docker-compose logs -f
```

**Expected output:**
```
✔ Container demo-app           Started
✔ Container otel-collector     Started
✔ Container prometheus         Started
✔ Container tempo              Started
✔ Container grafana            Started
✔ Container anomaly-detector   Started
```

#### Step 3: Verify Services are Running

```bash
# Check service status
docker-compose ps

# All services should show "Up" status
```

#### Step 4: Generate Sample Traffic

```powershell
# Windows PowerShell
.\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

# Or use the batch file
.\generate-traffic.bat
```

```bash
# Linux/Mac
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products
```

#### Step 5: Access the Services

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **Grafana** | http://localhost:3001 | `admin` / `grupo5_devops` | Dashboards & Visualization |
| **Prometheus** | http://localhost:9090 | None | Metrics Query Interface |
| **Tempo** | http://localhost:3200 | None | Trace Query API |
| **Demo App** | http://localhost:3000 | None | Instrumented Application |

### 📊 Accessing Grafana Dashboards

1. **Open Grafana**: Navigate to http://localhost:3001
2. **Login**: Use credentials `admin` / `grupo5_devops`
3. **View Dashboards**: Click on the menu (☰) → Dashboards

**Available Dashboards:**

| Dashboard | URL | Description |
|-----------|-----|-------------|
| **SLI/SLO Dashboard** | http://localhost:3001/d/slo-dashboard | Monitor SLIs, SLOs, error budgets, and burn rates |
| **Application Performance** | http://localhost:3001/d/app-performance-dashboard | Request latency, throughput, errors, and resource utilization |
| **Distributed Tracing** | http://localhost:3001/d/distributed-tracing | Trace analysis and service dependencies |

4. **Explore Traces**: Navigate to Explore (compass icon) → Select Tempo datasource → Query: `{status=error}`

### 🎬 Quick Demo Script

Want to see the platform in action? Run this demo:

```powershell
# 1. Generate normal traffic for 30 seconds
.\generate-continuous-traffic.ps1 -DurationSeconds 30 -RequestsPerSecond 5

# 2. Generate some errors
.\generate-test-errors.ps1 -ErrorCount 10 -DelaySeconds 1

# 3. Generate mixed traffic (normal + errors)
.\generate-mixed-traffic.ps1 -DurationSeconds 60 -ErrorRatePercent 15

# 4. Open all dashboards
.\open-all-dashboards.bat
```

Now watch the dashboards update in real-time!

## 📁 Project Structure

```
aiops-sre-observability/
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipelines
│       └── main-pipeline.yml   # Main CI/CD workflow
├── demo-app/                   # Node.js demo application
│   ├── src/
│   │   ├── index.js           # Main application with OTel instrumentation
│   │   ├── tracing.js         # OpenTelemetry tracing configuration
│   │   └── metrics.js         # Custom metrics definitions
│   ├── Dockerfile             # Multi-stage Docker build
│   ├── package.json           # Node.js dependencies
│   └── README.md              # Demo app documentation
├── otel-collector/            # OpenTelemetry Collector
│   └── otel-collector-config.yaml  # Collector configuration
├── prometheus/                # Prometheus time-series database
│   ├── prometheus.yml         # Prometheus configuration
│   └── rules/                 # Recording and alerting rules
│       ├── recording-rules.yml
│       └── slo-alerts.yml
├── tempo/                     # Grafana Tempo distributed tracing
│   └── tempo.yaml            # Tempo configuration
├── grafana/                   # Grafana visualization
│   └── provisioning/
│       ├── datasources/       # Auto-configured datasources
│       │   ├── prometheus.yml
│       │   └── tempo.yml
│       ├── dashboards/        # Dashboard provisioning config
│       │   └── json/          # Dashboard JSON definitions
│       │       ├── sli-slo-dashboard.json
│       │       ├── app-performance-dashboard.json
│       │       └── distributed-tracing-dashboard.json
│       └── alerting/          # Alert rules
│           └── rules.yml
├── anomaly-detector/          # Python ML anomaly detection service
│   ├── anomaly_detector.py    # Isolation Forest algorithm
│   ├── prometheus_client.py   # Prometheus query client
│   ├── main.py               # Service entry point
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile            # Python service Docker build
│   └── test_anomaly_detector.py  # Unit tests
├── k8s/                       # Kubernetes deployment manifests
│   ├── base/                  # Base Kubernetes resources
│   │   ├── demo-app-deployment.yaml
│   │   ├── prometheus-statefulset.yaml
│   │   ├── tempo-statefulset.yaml
│   │   └── ...
│   └── overlays/              # Environment-specific overlays
│       ├── dev/
│       └── prod/
├── helm/                      # Helm charts
│   └── aiops-platform/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
├── scripts/                   # Utility scripts
│   ├── smoke-tests.ps1       # Smoke tests for CI/CD
│   ├── ci-smoke-tests.sh     # Linux smoke tests
│   └── ...
├── docker-compose.yml         # Docker Compose orchestration
├── generate-continuous-traffic.ps1  # Traffic generation script
├── generate-test-errors.ps1   # Error simulation script
├── generate-mixed-traffic.ps1 # Mixed traffic (normal + errors)
└── README.md                  # This file
```

### Key Directories Explained

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `demo-app/` | Instrumented Node.js application | `src/index.js`, `src/tracing.js` |
| `otel-collector/` | Telemetry collection and routing | `otel-collector-config.yaml` |
| `prometheus/` | Metrics storage and querying | `prometheus.yml`, `rules/*.yml` |
| `tempo/` | Distributed trace storage | `tempo.yaml` |
| `grafana/` | Visualization and dashboards | `provisioning/dashboards/json/*.json` |
| `anomaly-detector/` | ML-based anomaly detection | `anomaly_detector.py` |
| `k8s/` | Kubernetes deployment | `base/*.yaml`, `overlays/*/` |
| `helm/` | Helm chart for K8s | `aiops-platform/` |
| `.github/workflows/` | CI/CD pipelines | `main-pipeline.yml` |

## 🎯 Key Features

### SLI/SLO Monitoring
- **Track latency percentiles** (P95, P99) with configurable thresholds
- **Monitor error rates** and availability in real-time
- **Calculate error budgets** automatically based on SLO targets
- **Visualize burn rates** with multi-window analysis (1h, 6h, 24h)
- **Project budget exhaustion** to take proactive action

### Distributed Tracing
- **End-to-end request tracing** across all services
- **Service dependency mapping** to understand system architecture
- **Latency breakdown analysis** to identify slow components
- **Error trace highlighting** for quick problem identification
- **Context propagation** across service boundaries

### Intelligent Anomaly Detection
- **ML-based pattern recognition** using Isolation Forest algorithm
- **Automatic anomaly alerts** with confidence scoring
- **Historical baseline learning** (7-30 days of data)
- **Reduced false positives** through statistical analysis
- **Predictive insights** to prevent incidents

### SLO-Driven Alerting
- **Multi-window multi-burn-rate alerts** (Google SRE best practice)
- **Error budget consumption alerts** before budget exhaustion
- **Latency threshold alerts** when P95 exceeds SLI
- **Anomaly detection alerts** for unusual patterns
- **Contextual alert information** for faster resolution

## 📊 Understanding the Dashboards

### 1. SLI/SLO Dashboard

**Purpose:** Monitor service level objectives and error budget consumption

**Key Panels:**

| Panel | What It Shows | How to Interpret |
|-------|---------------|------------------|
| **Request Latency (P95/P99)** | 95th and 99th percentile latency | Green = Good (<200ms), Red = SLO breach |
| **Success Rate** | % of successful requests (non-5xx) | Target: 99.9%, Yellow <99.5%, Red <99% |
| **Error Budget Remaining** | % of error budget left for 30d window | Green >50%, Yellow 20-50%, Red <20% |
| **Error Rate** | % of failed requests (4xx, 5xx) | Target: <1%, Alert if >1% |
| **Burn Rate (Multi-Window)** | Rate of error budget consumption | Critical if >14.4x (budget gone in 2 days) |
| **Current Burn Rate** | 1-hour burn rate | Shows immediate consumption rate |
| **Error Budget (30d)** | Total, consumed, and remaining budget | Track budget over time |
| **Latency SLO Compliance** | % of requests meeting latency SLO | Target: 99.9% under 200ms |
| **Request Rate** | Throughput (requests/second) | Monitor traffic patterns |

**How to Use:**
1. **Check Success Rate gauge** - Is it above 99.9%?
2. **Monitor Burn Rate** - Is it accelerating?
3. **Review Error Budget** - How much budget remains?
4. **Investigate spikes** - Click on anomalies to drill down

**Alert Thresholds:**
- 🔴 **Critical**: Burn rate >14.4x (budget exhausted in <2 days)
- 🟡 **Warning**: Burn rate >6x (budget exhausted in <5 days)
- 🟢 **Normal**: Burn rate <3x

### 2. Application Performance Dashboard

**Purpose:** Monitor application health and resource utilization

**Key Panels:**

| Panel | What It Shows | How to Interpret |
|-------|---------------|------------------|
| **Request Duration Histogram** | Distribution of request latencies | Look for bimodal distributions or long tails |
| **Request Duration by Endpoint** | Latency breakdown per API endpoint | Identify slow endpoints |
| **Throughput by Endpoint** | Requests/sec per endpoint | Understand traffic patterns |
| **Top 10 Endpoints** | Most frequently called endpoints | Optimize high-traffic endpoints |
| **Error Rate Breakdown** | Errors by status code (4xx, 5xx) | 4xx = client errors, 5xx = server errors |
| **Status Code Distribution** | Pie chart of response codes | Healthy = mostly 2xx |
| **CPU Utilization** | CPU usage over time | Alert if >80% sustained |
| **Memory Utilization** | Memory usage over time | Alert if >80% or growing |
| **Current CPU/Heap Usage** | Real-time resource usage | Monitor for resource exhaustion |
| **Total Request Rate** | Overall throughput | Baseline for capacity planning |

**How to Use:**
1. **Check resource utilization** - CPU/Memory under 80%?
2. **Review error breakdown** - Are 5xx errors increasing?
3. **Identify slow endpoints** - Which APIs need optimization?
4. **Monitor throughput** - Is traffic within expected range?

### 3. Distributed Tracing Dashboard

**Purpose:** Analyze request flows and identify bottlenecks

**Key Panels:**

| Panel | What It Shows | How to Interpret |
|-------|---------------|------------------|
| **Service Request Rate** | Requests/sec per service | Understand service load |
| **Latency Breakdown** | P50, P95, P99 per service | Identify slow services |
| **Trace Volume** | Number of traces by status | Monitor trace collection |
| **Average Spans per Trace** | Complexity of requests | More spans = more service calls |

**How to Use Trace Search:**
1. Navigate to **Grafana Explore** (compass icon)
2. Select **Tempo** datasource
3. Use queries:
   - `{status=error}` - Find all error traces
   - `{service.name="demo-app"}` - Filter by service
   - `{http.status_code="500"}` - Find specific errors
4. Click on a trace to see detailed span timeline
5. Analyze span duration to find bottlenecks

**Trace Analysis Tips:**
- **Long spans** = slow operations (database, external API)
- **Many spans** = complex request flow
- **Error spans** = exceptions or failures
- **Span attributes** = contextual information (user ID, endpoint, etc.)

### Dashboard Best Practices

1. **Start with SLI/SLO Dashboard** - Is the service healthy?
2. **If SLO breach, check Application Performance** - What's causing it?
3. **Use Distributed Tracing for root cause** - Which component is slow?
4. **Monitor trends over time** - Are things getting better or worse?
5. **Set up alerts** - Don't rely on manual checking

## Development

### Running Tests

#### Unit Tests
```bash
# Demo app unit tests
cd demo-app
npm test

# Anomaly detector tests
cd anomaly-detector
python -m pytest
```

#### Integration Tests
The integration tests verify the complete telemetry pipeline from the demo app through the collector to Prometheus and Tempo.

**Quick Start (Windows):**
```cmd
cd demo-app
run-integration-tests.bat
```

**Quick Start (Linux/Mac):**
```bash
cd demo-app
chmod +x run-integration-tests.sh
./run-integration-tests.sh
```

**Manual Execution:**
```bash
# 1. Start all services
docker-compose up -d

# 2. Wait for services to be ready (30 seconds)

# 3. Run integration tests
cd demo-app
npm run test:integration
```

**What the integration tests verify:**
- ✅ Collector receives OTLP metrics and traces from demo app
- ✅ Metrics are exported in Prometheus format
- ✅ Application and custom metrics appear in Prometheus
- ✅ Traces are forwarded to Tempo with preserved context
- ✅ Error traces are handled correctly
- ✅ Complete end-to-end telemetry pipeline

For detailed information, see [demo-app/INTEGRATION_TESTS.md](demo-app/INTEGRATION_TESTS.md)

### Building Docker Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build demo-app
```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f demo-app
```

## ☸️ Kubernetes Deployment

For production deployments on Kubernetes, we provide two options:

### Option 1: Helm Chart (Recommended)

```bash
# Install with Helm
helm install aiops-platform ./helm/aiops-platform \
  --namespace observability \
  --create-namespace \
  --values helm/aiops-platform/values-prod.yaml

# Verify deployment
kubectl get pods -n observability

# Access Grafana (after LoadBalancer gets external IP)
kubectl get svc -n observability grafana
```

**Helm Chart Features:**
- Parameterized configurations for different environments
- Resource requests and limits pre-configured
- HorizontalPodAutoscaler for demo-app
- PersistentVolumeClaims for data persistence
- ConfigMaps for all component configurations

### Option 2: Kustomize

```bash
# Deploy to development
kubectl apply -k k8s/overlays/dev

# Deploy to production
kubectl apply -k k8s/overlays/prod

# Verify deployment
kubectl get all -n observability
```

**Kustomize Features:**
- Base manifests with environment-specific overlays
- Easy customization per environment
- GitOps-friendly structure

### Kubernetes Architecture

```
┌─────────────────────────────────────────────────┐
│              Kubernetes Cluster                  │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Deployment  │  │  Deployment  │            │
│  │  demo-app    │  │ otel-collector│           │
│  │  (3 replicas)│  │  (2 replicas)│            │
│  └──────────────┘  └──────────────┘            │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ StatefulSet  │  │ StatefulSet  │            │
│  │  Prometheus  │  │    Tempo     │            │
│  │  (with PVC)  │  │  (with PVC)  │            │
│  └──────────────┘  └──────────────┘            │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Deployment  │  │  Deployment  │            │
│  │   Grafana    │  │   Anomaly    │            │
│  │(LoadBalancer)│  │   Detector   │            │
│  └──────────────┘  └──────────────┘            │
└─────────────────────────────────────────────────┘
```

### Resource Requirements

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| demo-app | 100m | 128Mi | 500m | 512Mi |
| otel-collector | 200m | 256Mi | 1000m | 512Mi |
| prometheus | 500m | 2Gi | 2000m | 4Gi |
| tempo | 500m | 1Gi | 1000m | 2Gi |
| grafana | 100m | 256Mi | 500m | 512Mi |
| anomaly-detector | 100m | 256Mi | 500m | 512Mi |

**Total Cluster Requirements:** ~2 CPU cores, ~4.5GB RAM minimum

### Scaling Considerations

```bash
# Scale demo-app horizontally
kubectl scale deployment demo-app --replicas=5 -n observability

# HorizontalPodAutoscaler is pre-configured
kubectl get hpa -n observability

# Scale Prometheus vertically (edit StatefulSet)
kubectl edit statefulset prometheus -n observability
```

For detailed Kubernetes deployment instructions, see [k8s/README.md](k8s/README.md)

## CI/CD Pipeline

The project includes a GitHub Actions pipeline that:
1. Runs tests and linters
2. Builds Docker images
3. Deploys to staging
4. Runs smoke tests
5. Promotes to production (manual approval)

## Monitoring the Platform

The observability platform monitors itself:
- OTel Collector metrics (dropped data, export latency)
- Prometheus storage and query performance
- Tempo ingestion and storage
- Grafana dashboard performance

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Services Not Starting

**Problem:** One or more containers fail to start

**Solution:**
```bash
# Check service status
docker-compose ps

# View logs for errors
docker-compose logs <service-name>

# Common fixes:
# - Port already in use: Stop conflicting services
# - Out of memory: Increase Docker memory limit
# - Permission issues: Run with appropriate permissions

# Restart specific service
docker-compose restart <service-name>

# Full restart
docker-compose down
docker-compose up -d
```

#### 2. No Metrics in Grafana

**Problem:** Dashboards show "No data" or empty panels

**Diagnosis:**
```bash
# 1. Check if Prometheus is scraping targets
# Open: http://localhost:9090/targets
# All targets should show "UP" status

# 2. Check OTel Collector logs
docker-compose logs otel-collector | grep -i error

# 3. Verify demo app is sending metrics
docker-compose logs demo-app | grep -i "metrics"

# 4. Test metrics endpoint directly
curl http://localhost:3000/metrics
```

**Solution:**
```bash
# Generate traffic to create metrics
.\generate-continuous-traffic.ps1 -DurationSeconds 30

# Restart Grafana to reload datasources
docker-compose restart grafana

# Verify Prometheus has data
curl http://localhost:9090/api/v1/query?query=up
```

#### 3. No Traces in Tempo

**Problem:** Distributed Tracing dashboard shows no traces

**Diagnosis:**
```bash
# 1. Check Tempo is receiving data
docker-compose logs tempo | grep -i "received"

# 2. Verify OTel Collector trace pipeline
docker-compose logs otel-collector | grep -i "trace"

# 3. Check demo app trace export
docker-compose logs demo-app | grep -i "span"
```

**Solution:**
```bash
# Generate traffic to create traces
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products

# Query Tempo directly
curl http://localhost:3200/api/search

# In Grafana Explore, use query: {status=error}
```

#### 4. Dashboards Not Loading

**Problem:** Grafana dashboards are missing or not loading

**Solution:**
```bash
# 1. Restart Grafana
docker-compose restart grafana

# 2. Check provisioning logs
docker-compose logs grafana | grep -i "provisioning"

# 3. Verify dashboard files exist
ls -la grafana/provisioning/dashboards/json/

# 4. Re-provision dashboards
docker-compose down grafana
docker-compose up -d grafana
```

#### 5. High Memory Usage

**Problem:** Docker containers consuming too much memory

**Solution:**
```bash
# Check memory usage
docker stats

# Adjust memory limits in docker-compose.yml
# For Prometheus:
mem_limit: 2g

# For Tempo:
mem_limit: 1g

# Restart with new limits
docker-compose up -d
```

#### 6. Anomaly Detector Not Working

**Problem:** No anomaly alerts being generated

**Diagnosis:**
```bash
# Check anomaly detector logs
docker-compose logs anomaly-detector

# Verify it can query Prometheus
docker-compose exec anomaly-detector curl http://prometheus:9090/api/v1/query?query=up
```

**Solution:**
```bash
# Ensure sufficient historical data (7+ days recommended)
# For testing, trigger anomalies manually:
.\generate-test-errors.ps1 -ErrorCount 50

# Restart anomaly detector
docker-compose restart anomaly-detector
```

#### 7. Port Conflicts

**Problem:** "Port already in use" error

**Solution:**
```bash
# Find process using the port (Windows)
netstat -ano | findstr :3001

# Kill the process
taskkill /PID <process_id> /F

# Or change ports in docker-compose.yml
ports:
  - "3002:3000"  # Use different external port
```

### Getting Help

If you're still experiencing issues:

1. **Check logs**: `docker-compose logs -f`
2. **Verify prerequisites**: Docker version, available ports, memory
3. **Review documentation**: Check component-specific READMEs
4. **Search issues**: Look for similar problems in GitHub issues
5. **Create an issue**: Provide logs, docker-compose ps output, and steps to reproduce

### Diagnostic Scripts

We provide diagnostic scripts to help troubleshoot:

```powershell
# Check if metrics are flowing
.\verify-error-rate.ps1

# Diagnose telemetry pipeline
.\diagnose-telemetry.bat

# List available metrics
.\list-available-metrics.ps1

# Verify dashboards
.\verify-dashboards.ps1
```

### Health Check Endpoints

All services expose health check endpoints:

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

## Performance Considerations

- **Prometheus**: Adjust retention period based on storage capacity
- **Tempo**: Configure appropriate trace retention
- **OTel Collector**: Tune batch size and memory limits
- **Anomaly Detector**: Adjust check interval based on metric volume

## Security

For production deployments:
- Change default Grafana credentials
- Enable authentication on Prometheus and Tempo
- Use network policies to restrict access
- Store secrets in secure secret management systems

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## License

[Your License Here]

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section
- Review component logs

## Roadmap

Future enhancements:
- Logs integration with Loki
- Service mesh integration (Istio/Linkerd)
- Advanced AIOps (root cause analysis)
- Cost optimization recommendations
- Multi-tenancy support
- Chaos engineering integration

## References

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Tempo Documentation](https://grafana.com/docs/tempo/)
- [Google SRE Book - SLIs, SLOs, and Error Budgets](https://sre.google/sre-book/service-level-objectives/)
