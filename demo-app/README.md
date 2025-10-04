# Demo Application with OpenTelemetry

A Node.js Express application instrumented with OpenTelemetry for the AIOps & SRE Observability Platform.

## Features

- **Express REST API** with sample endpoints for users and products
- **OpenTelemetry Auto-Instrumentation** for automatic metrics and traces
- **Custom Metrics** for business operations
- **Custom Spans** with attributes and events for detailed tracing
- **Error Simulation** endpoints for testing observability
- **Health Checks** for container orchestration

## Endpoints

### Health Checks
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint

### API Endpoints
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID

### Error Simulation
- `GET /api/error/500` - Simulate 500 error
- `GET /api/error/timeout` - Simulate slow endpoint
- `GET /api/error/exception` - Simulate unhandled exception

## Custom Metrics

- `business.requests.total` - Counter for business requests
- `business.operation.duration` - Histogram for operation duration
- `business.active_users` - UpDownCounter for active users
- `business.product.inventory` - Observable gauge for product inventory

## Custom Spans

Each API endpoint creates custom spans with:
- Operation type attributes
- Business context (user ID, product ID, etc.)
- Events for key operations
- Error recording for failures

## Running Locally

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

## Environment Variables

- `PORT` - Server port (default: 3000)
- `OTEL_EXPORTER_OTLP_ENDPOINT` - OpenTelemetry Collector endpoint
- `OTEL_SERVICE_NAME` - Service name for telemetry
- `NODE_ENV` - Environment (development/production)

## Docker

```bash
# Build image
docker build -t demo-app .

# Run container
docker run -p 3000:3000 \
  -e OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317 \
  -e OTEL_SERVICE_NAME=demo-app \
  demo-app
```

## OpenTelemetry Configuration

The application uses:
- **Auto-instrumentation** for HTTP and Express
- **OTLP gRPC exporter** for traces and metrics
- **Periodic metric export** every 10 seconds
- **Resource attributes** for service identification
