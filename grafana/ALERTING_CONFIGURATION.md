# Grafana Alerting Configuration

This document describes the alerting rules configured for the AIOps & SRE Observability Platform.

## Overview

The alerting system is configured using Grafana's unified alerting with provisioning files. Alerts are organized into two main groups:

1. **SLO Alerts** - Service Level Objective related alerts
2. **Infrastructure Alerts** - System health and resource alerts

## Alert Rules

### SLO Alerts

#### 1. High Error Budget Burn Rate
- **UID**: `high-burn-rate`
- **Severity**: Critical
- **Condition**: Error rate > 1% for both 1h and 5m windows
- **For**: 5 minutes
- **Description**: Detects when the error budget is being consumed at a high rate, indicating potential service degradation.
- **Requirements**: 4.3, 6.3, 8.3

**Query Logic**:
```promql
# 1-hour window
(sum(rate(http_server_requests_total{status_code=~"5.."}[1h])) / sum(rate(http_server_requests_total[1h]))) > 0.01

# 5-minute window
(sum(rate(http_server_requests_total{status_code=~"5.."}[5m])) / sum(rate(http_server_requests_total[5m]))) > 0.01
```

This implements a multi-window burn rate alert following Google SRE best practices.

#### 2. High Latency P95 Exceeding SLI
- **UID**: `high-latency-p95`
- **Severity**: High
- **Condition**: P95 latency > 200ms
- **For**: 5 minutes
- **Description**: Alerts when the 95th percentile latency exceeds the defined SLI threshold.
- **Requirements**: 4.2, 4.3

**Query Logic**:
```promql
histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket[5m]))) * 1000 > 200
```

#### 3. High Error Rate Above 1%
- **UID**: `high-error-rate`
- **Severity**: Critical
- **Condition**: Error rate (4xx + 5xx) > 1%
- **For**: 2 minutes
- **Description**: Immediate alert when error rate exceeds 1%, requiring urgent investigation.
- **Requirements**: 4.3, 6.3

**Query Logic**:
```promql
(sum(rate(http_server_requests_total{status_code=~"[45].."}[5m])) / sum(rate(http_server_requests_total[5m]))) * 100 > 1
```

#### 4. Anomaly Detected by ML Model
- **UID**: `anomaly-detected`
- **Severity**: High
- **Condition**: `anomaly_detected{confidence="high"} == 1`
- **For**: 1 minute
- **Description**: Triggered when the ML-based anomaly detector identifies unusual patterns in metrics.
- **Requirements**: 6.3, 8.3

**Note**: This alert expects the anomaly detector service to expose a metric `anomaly_detected` with labels for metric name, deviation, and confidence level.

### Infrastructure Alerts

#### 5. Service Down
- **UID**: `service-down`
- **Severity**: Critical
- **Condition**: `up{job="demo-app"} == 0`
- **For**: 1 minute
- **Description**: Alerts when the demo application is not responding to health checks.

#### 6. High Memory Usage
- **UID**: `high-memory-usage`
- **Severity**: Warning
- **Condition**: Memory usage > 400MB
- **For**: 5 minutes
- **Description**: Warns when memory usage exceeds threshold, indicating potential memory leak or resource constraint.

**Query Logic**:
```promql
(process_memory_usage_bytes / 1024 / 1024) > 400
```

#### 7. High CPU Usage
- **UID**: `high-cpu-usage`
- **Severity**: Warning
- **Condition**: CPU usage > 80%
- **For**: 5 minutes
- **Description**: Warns when CPU usage is consistently high, indicating potential performance bottleneck.

**Query Logic**:
```promql
process_cpu_usage * 100 > 80
```

## Notification Configuration

### Contact Points

**Webhook Notifications**:
- **Name**: `webhook-notifications`
- **Type**: Webhook
- **URL**: `http://localhost:8080/webhook`
- **Method**: POST

This is configured for testing purposes. In production, you should configure:
- PagerDuty for critical alerts
- Slack for team notifications
- Email for non-urgent alerts

### Notification Policies

The notification policy is configured with the following routing:

1. **Critical Alerts** (severity=critical):
   - Group wait: 10 seconds
   - Repeat interval: 1 hour
   
2. **High Severity Alerts** (severity=high):
   - Group wait: 30 seconds
   - Repeat interval: 2 hours

3. **Default**:
   - Group wait: 30 seconds
   - Group interval: 5 minutes
   - Repeat interval: 4 hours

Alerts are grouped by:
- `alertname`
- `service`

## Customization

### Adjusting Thresholds

To adjust alert thresholds, edit `grafana/provisioning/alerting/rules.yml`:

1. **Latency threshold**: Change `> 200` in the `high-latency-p95` rule
2. **Error rate threshold**: Change `> 1` in the `high-error-rate` rule
3. **Resource thresholds**: Modify values in infrastructure alerts

### Adding New Contact Points

Edit `grafana/provisioning/alerting/alerting.yml` to add new contact points:

```yaml
contactPoints:
  - orgId: 1
    name: slack-notifications
    receivers:
      - uid: slack-receiver
        type: slack
        settings:
          url: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
          text: "{{ .CommonAnnotations.summary }}"
```

### Adding New Alert Rules

Add new rules to `grafana/provisioning/alerting/rules.yml` under the appropriate group:

```yaml
- uid: your-alert-uid
  title: Your Alert Title
  condition: A
  data:
    - refId: A
      relativeTimeRange:
        from: 600
        to: 0
      datasourceUid: prometheus
      model:
        expr: your_promql_query
        refId: A
  noDataState: NoData
  execErrState: Alerting
  for: 5m
  annotations:
    description: "Your alert description"
    summary: "Your alert summary"
  labels:
    severity: high
    team: sre
```

## Testing Alerts

### Manual Testing

1. **Test High Error Rate**:
   ```bash
   # Generate errors
   for i in {1..100}; do curl http://localhost:3000/api/error; done
   ```

2. **Test High Latency**:
   ```bash
   # Generate slow requests
   for i in {1..50}; do curl http://localhost:3000/api/slow; done
   ```

3. **Test Service Down**:
   ```bash
   # Stop the demo app
   docker-compose stop demo-app
   ```

### Viewing Alerts

1. Open Grafana: http://localhost:3001
2. Navigate to **Alerting** → **Alert rules**
3. View firing alerts in **Alerting** → **Alert groups**
4. Check notification history in **Alerting** → **Contact points**

## Troubleshooting

### Alerts Not Firing

1. Check Prometheus is scraping metrics:
   ```bash
   curl http://localhost:9090/api/v1/query?query=up
   ```

2. Verify alert rule syntax in Grafana UI:
   - Go to **Alerting** → **Alert rules**
   - Click on the alert rule
   - Check for evaluation errors

3. Check Grafana logs:
   ```bash
   docker-compose logs grafana
   ```

### Notifications Not Sending

1. Verify contact point configuration:
   - Go to **Alerting** → **Contact points**
   - Test the contact point using the "Test" button

2. Check notification policy routing:
   - Go to **Alerting** → **Notification policies**
   - Verify the alert matches the routing rules

3. Check webhook endpoint is accessible:
   ```bash
   curl -X POST http://localhost:8080/webhook -d '{"test": "data"}'
   ```

## Best Practices

1. **Use Multi-Window Burn Rate Alerts**: Combine short and long windows to balance sensitivity and precision
2. **Set Appropriate For Durations**: Avoid alert fatigue by requiring conditions to persist
3. **Include Context in Annotations**: Add relevant information to help with investigation
4. **Use Severity Labels**: Properly categorize alerts for routing and prioritization
5. **Test Regularly**: Periodically test alerts to ensure they work as expected
6. **Document Runbooks**: Link to runbooks in alert annotations for faster resolution

## References

- [Grafana Unified Alerting Documentation](https://grafana.com/docs/grafana/latest/alerting/)
- [Google SRE Book - Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [Prometheus Alerting Best Practices](https://prometheus.io/docs/practices/alerting/)
