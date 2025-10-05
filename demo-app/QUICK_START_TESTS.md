# Quick Start - Integration Tests

## Run Tests (Windows)

```cmd
run-integration-tests.bat
```

## Run Tests (Linux/Mac)

```bash
chmod +x run-integration-tests.sh
./run-integration-tests.sh
```

## Manual Testing

### 1. Start services
```bash
# Windows (Docker Desktop)
docker compose up -d

# OR if using standalone docker-compose
docker-compose up -d
```

### 2. Wait for services (30 seconds)
```bash
# Windows
timeout /t 30

# Linux/Mac
sleep 30
```

### 3. Run tests
```bash
cd demo-app
npm run test:integration
```

## What the tests verify

✅ Collector receives OTLP metrics from demo app  
✅ Collector receives OTLP traces from demo app  
✅ Metrics are exported in Prometheus format  
✅ Application metrics appear in Prometheus  
✅ Custom business metrics are exported  
✅ Traces are forwarded to Tempo  
✅ Trace context is preserved  
✅ Error traces are handled correctly  
✅ Complete end-to-end pipeline works  

## Service URLs

- Demo App: http://localhost:3000
- Collector Metrics: http://localhost:8889/metrics
- Prometheus: http://localhost:9090
- Tempo: http://localhost:3200

## Troubleshooting

**Tests timeout?**
- Check services are running: `docker compose ps`
- Check logs: `docker compose logs otel-collector`

**No metrics found?**
- Verify Prometheus targets: http://localhost:9090/targets
- Check collector config: `type otel-collector\otel-collector-config.yaml` (Windows) or `cat otel-collector/otel-collector-config.yaml` (Linux/Mac)

**No traces found?**
- Check Tempo is ready: http://localhost:3200/ready
- Verify collector is forwarding: `docker compose logs otel-collector`

**Note:** If `docker compose` doesn't work, try `docker-compose` (with hyphen) for older Docker installations.
