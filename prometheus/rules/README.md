# Prometheus Recording and Alert Rules

This directory contains Prometheus recording rules and alert rules for SLI/SLO monitoring.

## Files

### sli_recording_rules.yml
Pre-calculated metrics for better dashboard performance and SLO tracking.

**Rule Groups:**
1. **sli_latency_rules** - Request duration percentiles (P50, P95, P99)
2. **sli_error_rate_rules** - Error rates and success rates
3. **sli_request_rate_rules** - Throughput and request aggregations
4. **sli_slo_calculations** - Error budget burn rates and SLO compliance
5. **sli_custom_metrics** - Custom business metrics
6. **sli_resource_utilization** - CPU and memory usage

### slo_alert_rules.yml
Alert rules based on SLO burn rates and threshold breaches.

**Alert Groups:**
1. **slo_burn_rate_alerts** - Multi-window multi-burn-rate alerts
2. **slo_latency_alerts** - Latency threshold and SLO compliance
3. **slo_error_rate_alerts** - Error rate thresholds
4. **slo_availability_alerts** - Success rate and service availability
5. **slo_throughput_alerts** - Request rate anomalies
6. **slo_resource_alerts** - Resource utilization warnings

## Recording Rules Explained

### Latency Percentiles

```promql
sli:http_request_duration_seconds:p95
```
Pre-calculated P95 latency from histogram buckets. Updated every 30 seconds.

### Error Rate

```promql
sli:http_requests:error_rate_percent
```
Percentage of requests with 4xx or 5xx status codes over 5-minute window.

### Burn Rate

```promql
sli:error_budget:burn_rate_1h
```
Rate at which error budget is being consumed. Value > 1 means budget is being consumed faster than acceptable.

**Burn Rate Thresholds:**
- **14.4x**: Budget exhausted in < 2 days (Critical)
- **6x**: Budget exhausted in < 1 week (High)
- **3x**: Budget exhausted in < 1 month (Warning)

## Alert Rules Explained

### Multi-Window Multi-Burn-Rate Alerting

Based on Google SRE best practices. Alerts fire when:
1. Short window shows high burn rate (fast detection)
2. Long window confirms sustained burn rate (reduces false positives)

**Example:**
```yaml
ErrorBudgetBurnRateCritical:
  - 1-hour burn rate > 14.4x
  - AND 5-minute burn rate > 14.4x
  - For at least 2 minutes
```

### Alert Severity Levels

- **Critical**: Immediate action required, service degradation likely
- **High**: Urgent attention needed, SLO breach imminent
- **Warning**: Monitor closely, investigate when possible

## Using These Rules

### In Grafana Dashboards

Query recording rules directly for faster dashboard loading:

```promql
# Instead of complex histogram_quantile query
sli:http_request_duration_seconds:p95{service_name="demo-app"}

# Instead of rate calculation
sli:http_requests:error_rate_percent{service_name="demo-app"}
```

### In Alert Manager

Alerts are automatically sent to Alert Manager (if configured). Configure notification channels in Grafana or Alert Manager.

### Querying Burn Rate

```promql
# Check current burn rate
sli:error_budget:burn_rate_1h{service_name="demo-app"}

# Value interpretation:
# 1.0 = consuming budget at expected rate
# 2.0 = consuming budget 2x faster than expected
# 14.4 = will exhaust monthly budget in 2 days
```

## SLO Targets

Current SLO targets (configurable):
- **Availability**: 99.9% (0.1% error budget)
- **Latency P95**: < 200ms
- **Latency P99**: < 500ms

## Customization

### Adjusting SLO Targets

Edit the recording rules to match your SLO targets:

```yaml
# For 99.95% SLO (0.05% error budget)
- record: sli:error_budget:burn_rate_1h
  expr: |
    (
      sum(rate(http_server_requests_total{http_status_code=~"5.."}[1h])) by (service_name)
      /
      sum(rate(http_server_requests_total[1h])) by (service_name)
    ) / 0.0005  # Changed from 0.001
```

### Adjusting Alert Thresholds

Edit alert rules to match your requirements:

```yaml
# Change latency threshold from 200ms to 300ms
- alert: LatencyP95ExceedsThreshold
  expr: sli:http_request_duration_seconds:p95 > 0.3  # Changed from 0.2
```

### Adding Custom Rules

Add new recording rules for custom metrics:

```yaml
- record: sli:my_custom_metric:rate
  expr: rate(my_custom_metric_total[5m])
  labels:
    sli_type: "custom"
```

## Validation

### Check Rule Syntax

```bash
# Validate rules file
promtool check rules prometheus/rules/sli_recording_rules.yml
promtool check rules prometheus/rules/slo_alert_rules.yml
```

### Test Rules

```bash
# Test recording rule
promtool test rules prometheus/rules/test_rules.yml
```

### View Active Rules

In Prometheus UI:
- Recording rules: http://localhost:9090/rules
- Alerts: http://localhost:9090/alerts

## Troubleshooting

### Rules Not Loading

1. Check Prometheus logs:
   ```bash
   docker compose logs prometheus
   ```

2. Verify rule file syntax:
   ```bash
   promtool check rules prometheus/rules/*.yml
   ```

3. Check prometheus.yml includes rule_files:
   ```yaml
   rule_files:
     - '/etc/prometheus/rules/*.yml'
   ```

### Recording Rules Not Appearing

1. Wait for evaluation interval (30s-1m)
2. Check Prometheus UI: http://localhost:9090/rules
3. Query the recording rule directly:
   ```promql
   sli:http_request_duration_seconds:p95
   ```

### Alerts Not Firing

1. Check alert conditions are met:
   ```promql
   # Query the alert expression directly
   sli:error_budget:burn_rate_1h > 14.4
   ```

2. Check alert state in Prometheus: http://localhost:9090/alerts
3. Verify Alert Manager is configured (if using)

## Performance Impact

Recording rules improve performance by:
- Pre-calculating complex queries
- Reducing dashboard load time
- Enabling faster alert evaluation

**Storage Impact:**
- Each recording rule creates a new time series
- Minimal storage overhead (< 1% of total metrics)

## Best Practices

1. **Use recording rules for**:
   - Complex queries used in multiple dashboards
   - Queries with high cardinality
   - SLI calculations

2. **Don't use recording rules for**:
   - Simple queries (e.g., `rate(metric[5m])`)
   - Rarely used metrics
   - Debugging queries

3. **Alert rule best practices**:
   - Use multi-window alerting to reduce false positives
   - Set appropriate `for` duration to avoid flapping
   - Include actionable information in annotations
   - Link to runbooks and dashboards

## References

- [Google SRE Workbook - Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Multi-Window Multi-Burn-Rate Alerts](https://sre.google/workbook/alerting-on-slos/#6-multiwindow-multi-burn-rate-alerts)

## Requirements Mapping

These rules satisfy:
- **Requirement 2.2**: Prometheus stores metrics with recording rules
- **Requirement 2.3**: SLI calculations for latency and error rate
- **Requirement 4.2**: Latency percentiles (P50, P95, P99)
- **Requirement 4.3**: Error rate and request rate calculations
- **Requirement 6.3**: Error budget and burn rate tracking
- **Requirement 8.3**: Alert generation for SLO breaches
