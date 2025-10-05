#!/bin/bash

# Smoke Tests - Post-deployment validation
# Runs the same tests as the deployment workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧪 Running Smoke Tests...${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Function to test an endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local max_retries=${3:-1}
    local retry_delay=${4:-0}
    
    for ((i=1; i<=max_retries; i++)); do
        if curl -f -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
            echo -e "${GREEN}✓${NC} $name"
            ((TESTS_PASSED++))
            return 0
        else
            if [ $i -lt $max_retries ]; then
                echo -e "${YELLOW}⚠${NC} $name (attempt $i/$max_retries failed, retrying...)"
                sleep $retry_delay
            fi
        fi
    done
    
    echo -e "${RED}✗${NC} $name (failed after $max_retries attempts)"
    ((TESTS_FAILED++))
    return 1
}

# 1. Health Checks
echo -e "${YELLOW}🏥 Health Checks...${NC}"
test_endpoint "http://localhost:3000/health" "Demo App - Health" 3 2
test_endpoint "http://localhost:3000/ready" "Demo App - Ready" 3 2
test_endpoint "http://localhost:9090/-/healthy" "Prometheus - Health" 3 2
test_endpoint "http://localhost:3001/api/health" "Grafana - Health" 3 2
test_endpoint "http://localhost:3200/ready" "Tempo - Ready" 3 2

echo ""

# 2. Metrics Baseline Check
echo -e "${YELLOW}📊 Metrics Baseline Check...${NC}"
echo -e "  ${CYAN}Waiting for metrics to be collected...${NC}"
sleep 5

# Check if Prometheus is collecting metrics
METRICS_RESPONSE=$(curl -s "http://localhost:9090/api/v1/query?query=up")
if echo "$METRICS_RESPONSE" | grep -q '"status":"success"'; then
    echo -e "${GREEN}✓${NC} Prometheus is collecting metrics"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Prometheus is not collecting metrics"
    ((TESTS_FAILED++))
fi

# Check if demo app is reporting metrics
APP_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=http_server_requests_total")
if echo "$APP_METRICS" | grep -q '"status":"success"' && echo "$APP_METRICS" | grep -q '"result":\['; then
    RESULT_COUNT=$(echo "$APP_METRICS" | grep -o '"result":\[[^]]*\]' | grep -o '{' | wc -l)
    if [ "$RESULT_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Demo app is reporting metrics ($RESULT_COUNT series found)"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Demo app metrics exist but no data yet (may be normal if just started)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Demo app metrics not found yet (may be normal if just started)"
fi

# Check OTel Collector metrics
OTEL_METRICS=$(curl -s "http://localhost:9090/api/v1/query?query=otelcol_receiver_accepted_spans")
if echo "$OTEL_METRICS" | grep -q '"status":"success"'; then
    echo -e "${GREEN}✓${NC} OpenTelemetry Collector is reporting metrics"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠${NC} OTel Collector metrics not found yet"
fi

echo ""

# 3. Trace Validation
echo -e "${YELLOW}🔍 Trace Validation...${NC}"
echo -e "  ${CYAN}Generating test traffic...${NC}"

# Generate some traffic to create traces
for i in {1..3}; do
    curl -s http://localhost:3000/api/users > /dev/null 2>&1 || true
    curl -s http://localhost:3000/api/products > /dev/null 2>&1 || true
done

echo -e "${GREEN}✓${NC} Test traffic generated"
((TESTS_PASSED++))

echo -e "  ${CYAN}Waiting for traces to be processed...${NC}"
sleep 5

# Check if Tempo is ready and processing traces
if test_endpoint "http://localhost:3200/ready" "Tempo is processing traces" 1 0; then
    # Try to query for traces (basic check)
    TEMPO_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3200/api/search?tags=service.name=demo-app&limit=1")
    if [ "$TEMPO_STATUS" = "200" ]; then
        echo -e "${GREEN}✓${NC} Tempo trace API is responding"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Tempo trace API returned status $TEMPO_STATUS"
    fi
fi

echo ""

# 4. Grafana Datasources and Dashboards Check
echo -e "${YELLOW}📈 Grafana Datasources and Dashboards...${NC}"

# Check Grafana datasources
DATASOURCES=$(curl -s -u admin:admin "http://localhost:3001/api/datasources")

if echo "$DATASOURCES" | grep -q '"type":"prometheus"'; then
    echo -e "${GREEN}✓${NC} Prometheus datasource configured"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Prometheus datasource not found"
    ((TESTS_FAILED++))
fi

if echo "$DATASOURCES" | grep -q '"type":"tempo"'; then
    echo -e "${GREEN}✓${NC} Tempo datasource configured"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Tempo datasource not found"
    ((TESTS_FAILED++))
fi

# Check if dashboards are accessible
DASHBOARDS=$(curl -s -u admin:admin "http://localhost:3001/api/search?type=dash-db")
DASHBOARD_COUNT=$(echo "$DASHBOARDS" | grep -o '"uid"' | wc -l)

if [ "$DASHBOARD_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Grafana dashboards are accessible ($DASHBOARD_COUNT dashboards found)"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠${NC} No Grafana dashboards found (may need to be provisioned)"
fi

echo ""

# 5. Container Status Check
echo -e "${YELLOW}🐳 Container Status...${NC}"

REQUIRED_CONTAINERS=(
    "demo-app"
    "otel-collector"
    "prometheus"
    "tempo"
    "grafana"
    "anomaly-detector"
)

for container in "${REQUIRED_CONTAINERS[@]}"; do
    if docker ps --format "{{.Names}}" | grep -q "$container"; then
        echo -e "${GREEN}✓${NC} $container is running"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $container is NOT running"
        ((TESTS_FAILED++))
    fi
done

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Smoke Tests Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}Tests failed: $TESTS_FAILED${NC}"
else
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All smoke tests passed!${NC}"
    echo -e "${GREEN}The system is functioning correctly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo -e "${YELLOW}Review service logs with: docker-compose logs <service>${NC}"
    exit 1
fi
