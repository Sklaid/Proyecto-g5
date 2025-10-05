#!/bin/bash

# Integration test runner script
# This script starts the services, runs the tests, and cleans up

set -e

echo "🚀 Starting OpenTelemetry Collector Integration Tests"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose not found. Please install Docker Compose.${NC}"
    exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.."

echo -e "${YELLOW}📦 Starting services with Docker Compose...${NC}"
docker-compose up -d

echo -e "${YELLOW}⏳ Waiting for services to be healthy (30 seconds)...${NC}"
sleep 30

# Check service health
echo -e "${YELLOW}🔍 Checking service health...${NC}"
docker-compose ps

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}❌ Some services are not running. Check docker-compose logs.${NC}"
    docker-compose logs
    exit 1
fi

echo -e "${GREEN}✅ All services are running${NC}"

# Run integration tests
echo -e "${YELLOW}🧪 Running integration tests...${NC}"
cd demo-app

if npm run test:integration; then
    echo -e "${GREEN}✅ Integration tests passed!${NC}"
    TEST_RESULT=0
else
    echo -e "${RED}❌ Integration tests failed!${NC}"
    TEST_RESULT=1
fi

# Show logs if tests failed
if [ $TEST_RESULT -ne 0 ]; then
    echo -e "${YELLOW}📋 Showing service logs...${NC}"
    cd ..
    docker-compose logs --tail=50 otel-collector
    docker-compose logs --tail=50 demo-app
fi

# Cleanup (optional - comment out if you want to keep services running)
# echo -e "${YELLOW}🧹 Cleaning up...${NC}"
# cd ..
# docker-compose down

echo "=================================================="
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Integration tests completed successfully!${NC}"
else
    echo -e "${RED}❌ Integration tests failed. Check logs above.${NC}"
fi

exit $TEST_RESULT
