# Application Performance Dashboard

## Overview

The Application Performance Dashboard provides comprehensive monitoring of application performance metrics for the AIOps & SRE Observability Platform. This dashboard is automatically provisioned when Grafana starts and is available in the "AIOps & SRE" folder.

## Dashboard Panels

### 1. Request Duration Histogram (by Percentile)
- **Type**: Time series
- **Metrics**: P50, P90, P95, P99 latency percentiles
- **Breakdown**: By HTTP endpoint
- **Purpose**: Visualize request latency distribution across different percentiles to identify performance bottlenecks

### 2. Request Duration Distribution by Endpoint
- **Type**: Pie chart
- **Metrics**: Total request duration by endpoint
- **Purpose**: Identify which endpoints consume the most processing time

### 3. Throughput by Endpoint
- **Type**: Stacked time series
- **Metrics**: Requests per second by endpoint
- **Purpose**: Monitor traffic patterns and identify high-traffic endpoints

### 4. Top 10 Endpoints by Request Rate
- **Type**: Bar gauge
- **Metrics**: Current request rate for top 10 endpoints
- **Purpose**: Quick identification of most active endpoints

### 5. Error Rate Breakdown by Status Code
- **Type**: Stacked time series
- **Metrics**: Error rate percentage by HTTP status code (4xx, 5xx)
- **Thresholds**: 
  - Green: < 1%
  - Yellow: 1-5%
  - Red: > 5%
- **Purpose**: Monitor error rates and identify error patterns

### 6. Response Status Code Distribution
- **Type**: Donut chart
- **Metrics**: Distribution of 2xx, 3xx, 4xx, 5xx responses
- **Purpose**: Overall health snapshot of HTTP responses

### 7. CPU Utilization
- **Type**: Time series
- **Metrics**: CPU usage percentage
- **Thresholds**:
  - Green: < 70%
  - Yellow: 70-90%
  - Red: > 90%
- **Purpose**: Monitor CPU resource consumption

### 8. Memory Utilization
- **Type**: Time series
- **Metrics**: 
  - RSS (Resident Set Size)
  - Heap Used
  - Heap Total
- **Thresholds**:
  - Green: < 400MB
  - Yellow: 400-500MB
  - Red: > 500MB
- **Purpose**: Monitor memory usage and detect potential memory leaks

### 9. Current CPU Usage
- **Type**: Gauge
- **Metrics**: Current CPU usage percentage
- **Purpose**: At-a-glance CPU status

### 10. Current Heap Usage
- **Type**: Gauge
- **Metrics**: Current heap usage percentage
- **Thresholds**:
  - Green: < 70%
  - Yellow: 70-85%
  - Red: > 85%
- **Purpose**: At-a-glance memory status

### 11. Total Request Rate
- **Type**: Stat
- **Metrics**: Total requests per second across all endpoints
- **Purpose**: Overall system throughput indicator

## Metrics Used

The dashboard relies on the following Prometheus metrics exported by the demo application via OpenTelemetry:

- `http_server_request_duration_seconds_bucket`: Histogram of request durations
- `http_server_request_duration_seconds_sum`: Sum of request durations
- `http_server_requests_total`: Total count of HTTP requests
- `process_cpu_seconds_total`: CPU time consumed by the process
- `process_resident_memory_bytes`: Resident memory size
- `nodejs_heap_size_used_bytes`: Node.js heap memory used
- `nodejs_heap_size_total_bytes`: Node.js total heap size

## Requirements Addressed

This dashboard addresses the following requirements from the spec:

- **Requirement 5.1**: Detección inteligente de anomalías - Provides baseline metrics for anomaly detection
- **Requirement 5.2**: Visualización de métricas - Comprehensive visualization of application performance

## Access

Once the stack is running with `docker-compose up`, access the dashboard at:

**URL**: http://localhost:3001/d/app-performance-dashboard/application-performance-dashboard

**Default Credentials**:
- Username: `admin`
- Password: `admin`

## Refresh Rate

The dashboard automatically refreshes every 30 seconds to provide near real-time monitoring.

## Time Range

Default time range is the last 6 hours, but this can be adjusted using the time picker in the top-right corner of Grafana.

## Alerts

This dashboard is designed to work in conjunction with the alerting rules defined in Prometheus. Key metrics to watch:

- **Latency**: P95 should be < 200ms for good user experience
- **Error Rate**: Should be < 1% for production systems
- **CPU Usage**: Should typically stay below 70% for healthy operation
- **Memory Usage**: Monitor heap usage to detect memory leaks

## Related Dashboards

- **SLI/SLO Dashboard**: For service level monitoring and error budget tracking
- **Distributed Tracing Dashboard**: For detailed trace analysis (to be implemented)
