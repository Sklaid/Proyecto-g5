# AIOps & SRE Observability Platform

A comprehensive observability and AIOps platform that combines modern instrumentation with OpenTelemetry, SLI/SLO-based monitoring, and intelligent anomaly detection to reduce Mean Time To Recovery (MTTR).

## Overview

This platform provides end-to-end observability for distributed applications by integrating:

- **OpenTelemetry Instrumentation**: Standardized collection of metrics and distributed traces
- **Metrics Storage**: Prometheus for time-series metrics with 15-day retention
- **Trace Storage**: Tempo for distributed tracing
- **Visualization**: Grafana dashboards for SLIs, SLOs, error budgets, and application performance
- **Intelligent Alerting**: SLO-driven alerts and ML-based anomaly detection
- **CI/CD Integration**: Automated build, test, and deployment pipeline

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

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB of available RAM
- Ports 3000, 3001, 4317, 4318, 8889, 9090, 3200 available

### Local Deployment with Docker Compose

1. Clone the repository:
```bash
git clone <repository-url>
cd aiops-sre-observability
```

2. Start all services:
```bash
docker-compose up -d
```

3. Verify all services are running:
```bash
docker-compose ps
```

4. Access the services:
- **Demo Application**: http://localhost:3000
- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Tempo**: http://localhost:3200

### Accessing Grafana Dashboards

1. Open Grafana at http://localhost:3001
2. Login with credentials: `admin` / `admin`
3. Navigate to Dashboards to view:
   - SLI/SLO Dashboard
   - Application Performance Dashboard
   - Distributed Tracing Dashboard

## Project Structure

```
.
├── demo-app/              # Node.js demo application
├── otel-collector/        # OpenTelemetry Collector configuration
├── prometheus/            # Prometheus configuration and rules
├── tempo/                 # Tempo configuration
├── grafana/               # Grafana provisioning (datasources & dashboards)
├── anomaly-detector/      # Python ML-based anomaly detection service
├── docker-compose.yml     # Docker Compose orchestration
└── README.md             # This file
```

## Key Features

### SLI/SLO Monitoring
- Track latency percentiles (P95, P99)
- Monitor error rates and availability
- Calculate error budgets in real-time
- Visualize burn rates and projections

### Distributed Tracing
- End-to-end request tracing
- Service dependency mapping
- Latency breakdown analysis
- Error trace highlighting

### Intelligent Anomaly Detection
- ML-based pattern recognition
- Automatic anomaly alerts
- Confidence scoring
- Reduced false positives

### SLO-Driven Alerting
- Multi-window multi-burn-rate alerts
- Error budget consumption alerts
- Latency threshold alerts
- Anomaly detection alerts

## Development

### Running Tests
```bash
# Demo app tests
cd demo-app
npm test

# Anomaly detector tests
cd anomaly-detector
python -m pytest
```

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

## Kubernetes Deployment

For production deployments on Kubernetes, see the `k8s/` directory for:
- Helm charts
- Kustomize overlays
- Resource configurations

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

## Troubleshooting

### Services not starting
```bash
# Check service status
docker-compose ps

# View logs for errors
docker-compose logs <service-name>

# Restart specific service
docker-compose restart <service-name>
```

### No metrics in Grafana
1. Verify Prometheus is scraping: http://localhost:9090/targets
2. Check OTel Collector logs: `docker-compose logs otel-collector`
3. Verify demo app is sending data: `docker-compose logs demo-app`

### No traces in Tempo
1. Check Tempo is receiving data: `docker-compose logs tempo`
2. Verify OTel Collector trace pipeline: `docker-compose logs otel-collector`
3. Generate traffic to demo app: `curl http://localhost:3000/api/users`

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
