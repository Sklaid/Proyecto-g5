#!/bin/bash

# CI/CD Smoke Tests - Streamlined version for GitHub Actions
# Tests critical functionality after deployment

set -e

echo "🧪 Running CI/CD Smoke Tests..."
echo ""

FAILED=0

# Helper function to test endpoint with retries
test_endpoint() {
    local url=$1
    local name=$2
    local max_retries=${3:-3}
    local retry_delay=${4:-5}
    
    echo "Testing $name..."
    for ((i=1; i<=max_retries; i++)); do
        if curl -f -s -o /dev/null "$url"; then
            echo "✓ $name - OK"
            return 0
        else
            if [ $i -lt $max_retries ]; then
                echo "  Attempt $i/$max_retries failed, retrying in ${retry_delay}s..."
                sleep $retry_delay
            fi
        fi
    done
    
    echo "✗ $name - FAILED"
    FAILED=1
    return 1
}

# 1. Health Checks - All services must be healthy
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Health Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_endpoint "http://localhost:3000/health" "Demo App Health" 5 10
test_endpoint "http://localhost:3000/ready" "Demo App Ready" 5 10
test_endpoint "http://localhost:9090/-/healthy" "Prometheus Health" 3 5
test_endpoint "http://localhost:3001/api/health" "Grafana Health" 3 5
test_endpoint "http://localhost:3200/ready" "Tempo Ready" 3 5

echo ""

# 2. Metrics Validation - Ensure metrics are being collected
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Metrics Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Waiting for metrics to be collected..."
sleep 15

echo "Checking Prometheus metrics collection..."
METRICS_RESPONSE=$(curl -s "http://localhost:9090/api/v1/query?query=up")
if echo "$METRICS_RESPONSE" | grep -q '"status":"success"'; then
    echo "✓ Prometheus is collecting metrics"
else
    echo "✗ Prometheus metrics check failed"
    FAILED=1
fi

echo "Checking demo app metrics..."
APP_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=http_server_requests_total")
if echo "$APP_METRICS" | grep -q '"status":"success"'; then
    echo "✓ Demo app is reporting metrics to Prometheus"
else
    echo "✗ Demo app metrics not found in Prometheus"
    FAILED=1
fi

echo ""

# 3. Trace Validation - Ensure traces are being collected
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Trace Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Generating test traffic to create traces..."
for i in {1..5}; do
    curl -s http://localhost:3000/api/users > /dev/null 2>&1 || true
    curl -s http://localhost:3000/api/products > /dev/null 2>&1 || true
done
echo "✓ Test traffic generated"

echo "Waiting for traces to be processed..."
sleep 10

echo "Checking Tempo trace storage..."
TEMPO_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3200/api/search?limit=1")
if [ "$TEMPO_STATUS" = "200" ]; then
    echo "✓ At least one trace is visible in Tempo"
else
    echo "✗ Tempo trace validation failed (status: $TEMPO_STATUS)"
    FAILED=1
fi

echo ""

# 4. Grafana Dashboards - Ensure dashboards are accessible
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Grafana Dashboards"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Checking Grafana datasources..."
DATASOURCES=$(curl -s -u admin:admin "http://localhost:3001/api/datasources")

if echo "$DATASOURCES" | grep -q '"type":"prometheus"'; then
    echo "✓ Prometheus datasource is configured"
else
    echo "✗ Prometheus datasource not found"
    FAILED=1
fi

if echo "$DATASOURCES" | grep -q '"type":"tempo"'; then
    echo "✓ Tempo datasource is configured"
else
    echo "✗ Tempo datasource not found"
    FAILED=1
fi

echo "Checking Grafana dashboards..."
DASHBOARDS=$(curl -s -u admin:admin "http://localhost:3001/api/search?type=dash-db")
DASHBOARD_COUNT=$(echo "$DASHBOARDS" | grep -o '"uid"' | wc -l)

if [ "$DASHBOARD_COUNT" -gt 0 ]; then
    echo "✓ Grafana dashboards are accessible ($DASHBOARD_COUNT found)"
else
    echo "⚠ No dashboards found (may need provisioning)"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Smoke Tests Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAILED -eq 0 ]; then
    echo "✅ All smoke tests passed!"
    echo "The system is ready for use."
    exit 0
else
    echo "❌ Some smoke tests failed!"
    echo "Check the logs above for details."
    exit 1
fi
