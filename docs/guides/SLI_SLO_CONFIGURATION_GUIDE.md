# SLI/SLO Configuration Guide

A comprehensive guide to defining, configuring, and managing Service Level Indicators (SLIs) and Service Level Objectives (SLOs) in the AIOps & SRE Observability Platform.

## 📋 Table of Contents

- [Understanding SLIs and SLOs](#understanding-slis-and-slos)
- [Defining Custom SLIs](#defining-custom-slis)
- [Configuring SLO Targets](#configuring-slo-targets)
- [Error Budget Calculations](#error-budget-calculations)
- [Burn Rate Alerting Strategy](#burn-rate-alerting-strategy)
- [Practical Examples](#practical-examples)
- [Best Practices](#best-practices)

---

## 🎯 Understanding SLIs and SLOs

### What is an SLI?

**Service Level Indicator (SLI)** is a quantitative measure of a service's behavior.

**Examples:**
- Request latency (P95, P99)
- Error rate (% of failed requests)
- Availability (% of successful requests)
- Throughput (requests per second)

**Key characteristics:**
- Measurable
- Meaningful to users
- Based on actual service behavior
- Collected automatically

### What is an SLO?

**Service Level Objective (SLO)** is a target value or range for an SLI.

**Examples:**
- "99.9% of requests should complete successfully"
- "95% of requests should complete in under 200ms"
- "Error rate should be below 1%"

**Key characteristics:**
- Specific target (e.g., 99.9%)
- Time window (e.g., 30 days)
- Based on user expectations
- Drives operational decisions

### The Relationship

```
SLI: What we measure
SLO: What we promise
SLA: What we're contractually obligated to deliver

Example:
SLI: Request success rate = 99.95%
SLO: Success rate > 99.9%
SLA: Success rate > 99.5% (with penalties if breached)
```

---

## 🔧 Defining Custom SLIs

### Step 1: Identify What Matters to Users

**Questions to ask:**
- What makes users happy with the service?
- What causes user complaints?
- What metrics correlate with user satisfaction?

**Common user-centric SLIs:**
- **Latency:** How fast does the service respond?
- **Availability:** Is the service accessible?
- **Correctness:** Does the service return correct results?
- **Throughput:** Can the service handle the load?

### Step 2: Choose Measurement Method

#### Latency SLI

**Option A: Percentile-based**
```yaml
sli:
  name: "API Latency P95"
  metric: "http_server_duration_milliseconds"
  aggregation: "histogram_quantile"
  percentile: 0.95
  threshold: 200  # milliseconds
```

**Prometheus query:**
```promql
histogram_quantile(0.95, 
  sum(rate(http_server_duration_milliseconds_bucket[5m])) 
  by (le, service_name, http_route)
)
```

**Option B: Threshold-based**
```yaml
sli:
  name: "Fast Requests"
  metric: "http_server_duration_milliseconds"
  threshold: 200  # milliseconds
  aggregation: "percentage_below_threshold"
```

**Prometheus query:**
```promql
sum(rate(http_server_duration_milliseconds_bucket{le="200"}[5m])) 
/ 
sum(rate(http_server_duration_milliseconds_count[5m]))
* 100
```

#### Availability SLI

**Success rate (recommended):**
```yaml
sli:
  name: "Request Success Rate"
  metric: "http_server_duration_milliseconds_count"
  success_criteria: "http_status_code !~ '5..'"
  aggregation: "success_ratio"
```

**Prometheus query:**
```promql
(
  sum(rate(http_server_duration_milliseconds_count[5m])) 
  - 
  sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m]))
) 
/ 
sum(rate(http_server_duration_milliseconds_count[5m]))
* 100
```

#### Error Rate SLI

**Error percentage:**
```yaml
sli:
  name: "Error Rate"
  metric: "http_server_duration_milliseconds_count"
  error_criteria: "http_status_code =~ '[45]..'"
  aggregation: "error_ratio"
```

**Prometheus query:**
```promql
sum(rate(http_server_duration_milliseconds_count{http_status_code=~"[45].."}[5m])) 
/ 
sum(rate(http_server_duration_milliseconds_count[5m]))
* 100
```

### Step 3: Implement SLI Collection

#### In Prometheus Recording Rules

The platform includes pre-configured recording rules in `prometheus/rules/sli_recording_rules.yml`:

```yaml
groups:
  - name: sli_latency_rules
    interval: 30s
    rules:
      # Latency P95 SLI
      - record: sli:http_request_duration_seconds:p95
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_server_request_duration_milliseconds_bucket[5m]))
            by (le, service_name, http_route)
          )
        labels:
          sli_type: "latency"
          percentile: "p95"
      
      # Latency P99 SLI
      - record: sli:http_request_duration_seconds:p99
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_server_request_duration_milliseconds_bucket[5m]))
            by (le, service_name, http_route)
          )
        labels:
          sli_type: "latency"
          percentile: "p99"
  
  - name: sli_error_rate_rules
    interval: 30s
    rules:
      # Success rate SLI
      - record: sli:http_requests:success_rate_percent
        expr: |
          (
            sum(rate(http_server_requests_total{http_status_code!~"4..|5.."}[5m]))
            by (service_name, http_route)
            /
            sum(rate(http_server_requests_total[5m]))
            by (service_name, http_route)
          ) * 100
        labels:
          sli_type: "availability"
      
      # Error rate SLI
      - record: sli:http_requests:error_rate_percent
        expr: |
          (
            sum(rate(http_server_requests_total{http_status_code=~"4..|5.."}[5m]))
            by (service_name, http_route)
            /
            sum(rate(http_server_requests_total[5m]))
            by (service_name, http_route)
          ) * 100
        labels:
          sli_type: "availability"
      
      # 5xx error rate (server errors only)
      - record: sli:http_requests:5xx_error_rate_percent
        expr: |
          (
            sum(rate(http_server_requests_total{http_status_code=~"5.."}[5m]))
            by (service_name, http_route)
            /
            sum(rate(http_server_requests_total[5m]))
            by (service_name, http_route)
          ) * 100
        labels:
          sli_type: "availability"
          error_type: "server"
  
  - name: sli_request_rate_rules
    interval: 30s
    rules:
      # Request rate (throughput) SLI
      - record: sli:http_requests_per_second:by_service
        expr: |
          sum(rate(http_server_requests_total[5m]))
          by (service_name)
        labels:
          sli_type: "throughput"
```

#### Reload Prometheus Configuration

```bash
# Docker Compose
docker-compose restart prometheus

# Kubernetes
kubectl rollout restart statefulset prometheus -n observability
```

#### Verify Recording Rules

```bash
# Check Prometheus UI
# Navigate to: http://localhost:9090/rules

# Query recorded SLIs
curl 'http://localhost:9090/api/v1/query?query=sli:http_requests:success_rate_percent'
curl 'http://localhost:9090/api/v1/query?query=sli:http_request_duration_seconds:p95'
curl 'http://localhost:9090/api/v1/query?query=sli:error_budget:burn_rate_1h'
```

---

## 🎯 Configuring SLO Targets

### Step 1: Determine Appropriate SLO Targets

**Factors to consider:**
- User expectations
- Current performance baseline
- Business requirements
- Cost of achieving higher reliability

**Common SLO targets:**

| Service Type | Availability SLO | Latency SLO (P95) |
|--------------|------------------|-------------------|
| Critical user-facing | 99.95% | <100ms |
| Standard user-facing | 99.9% | <200ms |
| Internal API | 99.5% | <500ms |
| Batch processing | 99% | <5s |

**Downtime allowed per SLO:**

| SLO | Downtime per 30 days | Downtime per year |
|-----|----------------------|-------------------|
| 99.99% | 4.3 minutes | 52.6 minutes |
| 99.95% | 21.6 minutes | 4.4 hours |
| 99.9% | 43.2 minutes | 8.8 hours |
| 99.5% | 3.6 hours | 1.8 days |
| 99% | 7.2 hours | 3.7 days |

### Step 2: Define SLO in Configuration

#### Create SLO Configuration File

Create file: `prometheus/slo-config.yaml`

```yaml
slos:
  - name: "API Availability"
    description: "Percentage of successful API requests"
    sli:
      metric: "sli:http_request:success_rate"
      service: "demo-app"
    target: 99.9  # 99.9% success rate
    window: 30d   # 30-day rolling window
    
  - name: "API Latency P95"
    description: "95th percentile request latency"
    sli:
      metric: "sli:http_request_duration:p95"
      service: "demo-app"
    target: 200   # 200ms
    window: 30d
    
  - name: "API Latency P99"
    description: "99th percentile request latency"
    sli:
      metric: "sli:http_request_duration:p99"
      service: "demo-app"
    target: 500   # 500ms
    window: 30d
    
  - name: "Error Rate"
    description: "Percentage of failed requests"
    sli:
      metric: "sli:http_request:error_rate"
      service: "demo-app"
    target: 1.0   # <1% error rate
    window: 30d
    comparison: "less_than"  # Target is maximum, not minimum
```

### Step 3: Visualize SLO in Grafana

#### Update Dashboard JSON

Edit: `grafana/provisioning/dashboards/json/sli-slo-dashboard.json`

**Add SLO target line to latency panel:**
```json
{
  "targets": [
    {
      "expr": "sli:http_request_duration:p95",
      "legendFormat": "P95 Latency"
    },
    {
      "expr": "200",
      "legendFormat": "SLO Target (200ms)",
      "refId": "SLO_Target"
    }
  ],
  "thresholds": {
    "mode": "absolute",
    "steps": [
      {"color": "green", "value": null},
      {"color": "red", "value": 200}
    ]
  }
}
```

**Add SLO gauge for success rate:**
```json
{
  "type": "gauge",
  "targets": [
    {
      "expr": "sli:http_request:success_rate"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "thresholds": {
        "steps": [
          {"color": "red", "value": 0},
          {"color": "yellow", "value": 99},
          {"color": "green", "value": 99.9}
        ]
      },
      "max": 100,
      "min": 99
    }
  }
}
```

---

## 💰 Error Budget Calculations

### Understanding Error Budget

**Error budget** is the amount of unreliability you can tolerate while still meeting your SLO.

**Formula:**
```
Error Budget = (1 - SLO Target) × Total Events

Example with 99.9% SLO:
Error Budget = (1 - 0.999) × Total Requests
Error Budget = 0.001 × Total Requests
Error Budget = 0.1% of requests
```

### Calculating Error Budget

#### For Availability SLO

**Given:**
- SLO: 99.9% success rate
- Time window: 30 days
- Total requests: 1,000,000

**Calculation:**
```
Error Budget = (1 - 0.999) × 1,000,000
Error Budget = 0.001 × 1,000,000
Error Budget = 1,000 errors allowed

If 300 errors occurred:
Consumed = 300 errors (30%)
Remaining = 700 errors (70%)
```

**Prometheus query:**
```promql
# Total error budget (30 days)
sum(increase(http_server_duration_milliseconds_count[30d])) 
by (service_name) 
* 0.001

# Consumed error budget
sum(increase(http_server_duration_milliseconds_count{http_status_code=~"5.."}[30d])) 
by (service_name)

# Remaining error budget
(
  sum(increase(http_server_duration_milliseconds_count[30d])) 
  by (service_name) 
  * 0.001
)
-
sum(increase(http_server_duration_milliseconds_count{http_status_code=~"5.."}[30d])) 
by (service_name)

# Error budget remaining percentage
(
  1 - (
    sum(increase(http_server_duration_milliseconds_count{http_status_code=~"5.."}[30d])) 
    by (service_name)
    /
    (
      sum(increase(http_server_duration_milliseconds_count[30d])) 
      by (service_name) 
      * 0.001
    )
  )
) * 100
```

#### For Latency SLO

**Given:**
- SLO: 99.9% of requests < 200ms
- Time window: 30 days
- Total requests: 1,000,000

**Calculation:**
```
Error Budget = 0.1% of requests can be slow
Error Budget = 1,000 slow requests allowed

If 250 requests > 200ms:
Consumed = 250 slow requests (25%)
Remaining = 750 slow requests (75%)
```

**Prometheus query:**
```promql
# Requests exceeding latency SLO
sum(increase(http_server_duration_milliseconds_count[30d])) 
by (service_name)
-
sum(increase(http_server_duration_milliseconds_bucket{le="200"}[30d])) 
by (service_name)
```

### Error Budget Policy

**Define what happens at different budget levels:**

```yaml
error_budget_policy:
  - budget_remaining: ">50%"
    actions:
      - "Normal operations"
      - "Deploy changes freely"
      - "Experiment with new features"
    
  - budget_remaining: "20-50%"
    actions:
      - "Deploy with caution"
      - "Increase monitoring"
      - "Review recent changes"
    
  - budget_remaining: "10-20%"
    actions:
      - "Freeze non-critical deployments"
      - "Focus on reliability"
      - "Incident review required"
    
  - budget_remaining: "<10%"
    actions:
      - "Freeze all deployments"
      - "Emergency fixes only"
      - "Incident response mode"
      - "Executive notification"
```

---

## 🔥 Burn Rate Alerting Strategy

### Understanding Burn Rate

**Burn rate** measures how fast you're consuming your error budget.

**Formula:**
```
Burn Rate = (Errors in Window / Window Duration) / (Error Budget / SLO Window)

1x = Normal consumption (budget lasts full SLO window)
2x = Budget consumed twice as fast (lasts half the time)
10x = Budget consumed 10x faster (lasts 1/10th the time)
```

### Multi-Window Multi-Burn-Rate Alerts

**Google SRE recommended approach:**

Use multiple time windows to balance:
- **Precision:** Avoid false positives
- **Recall:** Catch real issues quickly

**Alert configuration:**

```yaml
alerts:
  # Page-worthy: Budget exhausted in < 2 days
  - name: "Critical Burn Rate"
    severity: "critical"
    long_window: 1h
    long_burn_rate: 14.4
    short_window: 5m
    short_burn_rate: 14.4
    action: "Page on-call engineer"
    
  # Ticket-worthy: Budget exhausted in < 5 days
  - name: "High Burn Rate"
    severity: "warning"
    long_window: 6h
    long_burn_rate: 6
    short_window: 30m
    short_burn_rate: 6
    action: "Create incident ticket"
```

**Why two windows?**
- **Long window:** Confirms sustained issue (not just a blip)
- **Short window:** Ensures issue is still happening (not resolved)

### Implementing Burn Rate Alerts

#### Prometheus Alert Rules

The platform includes pre-configured alert rules in `prometheus/rules/slo_alert_rules.yml`:

```yaml
groups:
  - name: slo_burn_rate_alerts
    interval: 1m
    rules:
      # Critical: Fast burn rate (exhausts error budget in < 2 days)
      # Alert if burn rate > 14.4x for 1 hour AND > 14.4x for 5 minutes
      - alert: ErrorBudgetBurnRateCritical
        expr: |
          (
            sli:error_budget:burn_rate_1h > 14.4
            and
            sli:error_budget:burn_rate_1h offset 5m > 14.4
          )
        for: 2m
        labels:
          severity: critical
          slo_type: availability
          alert_type: burn_rate
        annotations:
          summary: "Critical error budget burn rate for {{ $labels.service_name }}"
          description: "Error budget is being consumed at {{ $value | humanize }}x the acceptable rate. At this rate, the monthly budget will be exhausted in less than 2 days."
          runbook_url: "https://sre.google/workbook/alerting-on-slos/"
          dashboard_url: "http://localhost:3001/d/slo-dashboard"
      
      # High: Moderate burn rate (exhausts error budget in < 1 week)
      # Alert if burn rate > 6x for 6 hours AND > 6x for 30 minutes
      - alert: ErrorBudgetBurnRateHigh
        expr: |
          (
            sli:error_budget:burn_rate_6h > 6
            and
            sli:error_budget:burn_rate_6h offset 30m > 6
          )
        for: 15m
        labels:
          severity: high
          slo_type: availability
          alert_type: burn_rate
        annotations:
          summary: "High error budget burn rate for {{ $labels.service_name }}"
          description: "Error budget is being consumed at {{ $value | humanize }}x the acceptable rate. At this rate, the monthly budget will be exhausted in less than 1 week."
          runbook_url: "https://sre.google/workbook/alerting-on-slos/"
      
      # Warning: Slow burn rate (exhausts error budget in < 1 month)
      # Alert if burn rate > 3x for 24 hours AND > 3x for 2 hours
      - alert: ErrorBudgetBurnRateWarning
        expr: |
          (
            sli:error_budget:burn_rate_24h > 3
            and
            sli:error_budget:burn_rate_24h offset 2h > 3
          )
        for: 1h
        labels:
          severity: warning
          slo_type: availability
          alert_type: burn_rate
        annotations:
          summary: "Elevated error budget burn rate for {{ $labels.service_name }}"
          description: "Error budget is being consumed at {{ $value | humanize }}x the acceptable rate. Monitor closely."

  - name: slo_latency_alerts
    interval: 1m
    rules:
      # Latency P95 exceeds SLI threshold
      - alert: LatencyP95ExceedsThreshold
        expr: sli:http_request_duration_seconds:p95 > 0.2
        for: 5m
        labels:
          severity: high
          slo_type: latency
          alert_type: threshold
        annotations:
          summary: "P95 latency exceeds 200ms for {{ $labels.service_name }}{{ $labels.http_route }}"
          description: "P95 latency is {{ $value | humanize }}s (threshold: 200ms). This may impact user experience."
          current_value: "{{ $value | humanize }}s"
          threshold: "200ms"
      
      # Latency P99 exceeds critical threshold
      - alert: LatencyP99Critical
        expr: sli:http_request_duration_seconds:p99 > 0.5
        for: 5m
        labels:
          severity: critical
          slo_type: latency
          alert_type: threshold
        annotations:
          summary: "P99 latency critically high for {{ $labels.service_name }}{{ $labels.http_route }}"
          description: "P99 latency is {{ $value | humanize }}s (threshold: 500ms). Immediate investigation required."
          current_value: "{{ $value | humanize }}s"
          threshold: "500ms"

  - name: slo_error_rate_alerts
    interval: 1m
    rules:
      # Error rate exceeds 1%
      - alert: ErrorRateHigh
        expr: sli:http_requests:error_rate_percent > 1
        for: 5m
        labels:
          severity: high
          slo_type: availability
          alert_type: error_rate
        annotations:
          summary: "Error rate exceeds 1% for {{ $labels.service_name }}{{ $labels.http_route }}"
          description: "Current error rate is {{ $value | humanize }}% (threshold: 1%). Investigate immediately."
          current_value: "{{ $value | humanize }}%"
          threshold: "1%"
```

### Burn Rate Calculation Examples

**Example 1: Normal operation**
```
SLO: 99.9% (0.1% error budget)
Current error rate: 0.05%
Burn rate: 0.05% / 0.1% = 0.5x

Interpretation: Consuming budget at half the normal rate
Budget will last: 30 days × 2 = 60 days
Action: None, healthy operation
```

**Example 2: Elevated errors**
```
SLO: 99.9% (0.1% error budget)
Current error rate: 0.6%
Burn rate: 0.6% / 0.1% = 6x

Interpretation: Consuming budget 6x faster
Budget will last: 30 days / 6 = 5 days
Action: Investigate, create ticket
```

**Example 3: Critical incident**
```
SLO: 99.9% (0.1% error budget)
Current error rate: 2%
Burn rate: 2% / 0.1% = 20x

Interpretation: Consuming budget 20x faster
Budget will last: 30 days / 20 = 1.5 days
Action: Page on-call, immediate response
```

---

## 📚 Practical Examples

### Example 1: E-commerce API

**Service:** Product catalog API

**SLIs:**
```yaml
slis:
  - name: "Product Search Latency P95"
    metric: "http_server_duration_milliseconds"
    filter: "http_route='/api/products/search'"
    percentile: 0.95
    
  - name: "Product API Availability"
    metric: "http_server_duration_milliseconds_count"
    filter: "http_route=~'/api/products.*'"
    success_criteria: "http_status_code !~ '5..'"
```

**SLOs:**
```yaml
slos:
  - sli: "Product Search Latency P95"
    target: 300ms
    rationale: "Users expect fast search results"
    
  - sli: "Product API Availability"
    target: 99.95%
    rationale: "Critical for checkout flow"
```

**Error Budget:**
```
99.95% SLO = 0.05% error budget
For 10M requests/month: 5,000 errors allowed
```

### Example 2: Payment Processing Service

**Service:** Payment gateway

**SLIs:**
```yaml
slis:
  - name: "Payment Success Rate"
    metric: "payment_transactions_total"
    success_criteria: "status='success'"
    
  - name: "Payment Processing Time P99"
    metric: "payment_duration_seconds"
    percentile: 0.99
```

**SLOs:**
```yaml
slos:
  - sli: "Payment Success Rate"
    target: 99.99%
    rationale: "Payment failures directly impact revenue"
    
  - sli: "Payment Processing Time P99"
    target: 2s
    rationale: "Users abandon slow checkouts"
```

**Error Budget:**
```
99.99% SLO = 0.01% error budget
For 1M transactions/month: 100 failed payments allowed
```

### Example 3: Background Job Processor

**Service:** Email notification service

**SLIs:**
```yaml
slis:
  - name: "Email Delivery Success Rate"
    metric: "email_jobs_total"
    success_criteria: "status='delivered'"
    
  - name: "Email Processing Time P95"
    metric: "email_processing_duration_seconds"
    percentile: 0.95
```

**SLOs:**
```yaml
slos:
  - sli: "Email Delivery Success Rate"
    target: 99.5%
    rationale: "Some failures acceptable for non-critical emails"
    
  - sli: "Email Processing Time P95"
    target: 60s
    rationale: "Users don't expect instant email delivery"
```

**Error Budget:**
```
99.5% SLO = 0.5% error budget
For 100K emails/day: 500 failed deliveries allowed
```

---

## ✅ Best Practices

### 1. Start Simple

**Don't:**
- Define 20 SLIs on day one
- Set unrealistic targets (99.999%)
- Measure everything

**Do:**
- Start with 2-3 critical SLIs
- Base targets on current performance + 10%
- Focus on user-facing metrics

### 2. Iterate Based on Data

**Process:**
1. Set initial SLO based on baseline
2. Monitor for 30 days
3. Analyze if target is too strict or too loose
4. Adjust target
5. Repeat

**Example:**
```
Month 1: Set 99.9% SLO, achieved 99.95%
Month 2: Increase to 99.95% SLO
Month 3: Achieved 99.93%, target appropriate
```

### 3. Align with Business Needs

**Questions:**
- What's the cost of downtime?
- What's the cost of achieving higher reliability?
- What do competitors offer?
- What do users expect?

**Example:**
```
Free tier: 99% SLO (acceptable for free users)
Paid tier: 99.9% SLO (expected for paying customers)
Enterprise: 99.95% SLO (contractual obligation)
```

### 4. Use Error Budget for Decision Making

**Scenarios:**

**High budget remaining (>50%):**
- ✅ Deploy new features
- ✅ Experiment with changes
- ✅ Planned maintenance

**Medium budget (20-50%):**
- ⚠️  Deploy with caution
- ⚠️  Increase testing
- ⚠️  Monitor closely

**Low budget (<20%):**
- 🔴 Freeze deployments
- 🔴 Focus on reliability
- 🔴 Fix known issues

### 5. Document Everything

**What to document:**
- SLI definitions and rationale
- SLO targets and why they were chosen
- Error budget policy
- Alert thresholds and escalation
- Historical SLO performance

**Example documentation:**
```markdown
## SLO: API Availability

**Target:** 99.9% success rate over 30 days

**Rationale:** 
- User research shows 99.9% meets expectations
- Current baseline is 99.95%
- Allows for planned maintenance windows

**Error Budget:** 0.1% of requests (≈43 minutes downtime/month)

**Alerts:**
- Critical: Burn rate >14.4x (page on-call)
- Warning: Burn rate >6x (create ticket)

**Last Review:** 2025-09-01
**Next Review:** 2025-12-01
```

### 6. Review and Adjust Regularly

**Quarterly SLO review:**
- Analyze SLO performance
- Review error budget consumption
- Adjust targets if needed
- Update alert thresholds
- Document changes

**Questions to ask:**
- Are we meeting our SLOs?
- Are the SLOs still relevant?
- Do we need new SLIs?
- Are alerts actionable?

---

## 🚀 Quick Start: Using the Pre-Configured SLI/SLO System

The platform comes with a fully configured SLI/SLO monitoring system. Here's how to use it:

### 1. Start the Platform

```bash
# Using Docker Compose
docker-compose up -d

# Wait for all services to be healthy
docker-compose ps
```

### 2. Access Grafana

```bash
# Open Grafana in your browser
start http://localhost:3001

# Or use the convenience script
open-grafana.bat
```

**Default credentials:**
- Username: `admin`
- Password: `admin`

### 3. View the SLI/SLO Dashboard

1. Navigate to **Dashboards** → **Browse**
2. Select **SLI/SLO Dashboard**
3. The dashboard displays:
   - Request latency (P95/P99)
   - Success rate gauge
   - Error budget remaining
   - Error rate trends
   - Burn rate analysis
   - Throughput metrics

### 4. Generate Test Traffic

```bash
# Generate normal traffic
generate-traffic.bat

# Generate traffic with errors
generate-test-errors.bat

# Generate continuous mixed traffic
powershell -ExecutionPolicy Bypass -File generate-mixed-traffic.ps1
```

### 5. Monitor SLO Compliance

Watch the dashboard to see:
- **Green zones**: SLOs are being met
- **Yellow zones**: Approaching SLO thresholds
- **Red zones**: SLO breach in progress

### 6. Test Alerting

To test the burn rate alerting:

```bash
# Generate high error rate to trigger alerts
generate-test-errors.ps1

# Check Grafana Alerting
# Navigate to: Alerting → Alert rules
```

### 7. Verify Prometheus Rules

```bash
# Check recording rules are active
curl http://localhost:9090/api/v1/rules | jq '.data.groups[] | select(.name | contains("sli"))'

# Query specific SLI metrics
curl 'http://localhost:9090/api/v1/query?query=sli:http_requests:success_rate_percent'
curl 'http://localhost:9090/api/v1/query?query=sli:error_budget:burn_rate_1h'
```

---

## 📊 Understanding the Dashboard Panels

### Panel 1: Request Latency (P95/P99)
- **What it shows**: Response time percentiles
- **SLO target**: P95 < 200ms
- **Action if red**: Investigate slow endpoints, check database queries, review resource utilization

### Panel 2: Success Rate Gauge
- **What it shows**: Percentage of successful requests (non-5xx)
- **SLO target**: 99.9%
- **Action if red**: Check application logs, review recent deployments, investigate error patterns

### Panel 3: Error Budget Remaining
- **What it shows**: Percentage of error budget left for the 30-day window
- **Interpretation**:
  - >80%: Healthy, can deploy freely
  - 50-80%: Normal operations
  - 20-50%: Deploy with caution
  - <20%: Freeze deployments, focus on reliability

### Panel 4: Error Rate
- **What it shows**: Percentage of failed requests over time
- **SLO target**: <1%
- **Action if red**: Immediate investigation required

### Panel 5: Error Budget Burn Rate
- **What it shows**: How fast error budget is being consumed
- **Critical thresholds**:
  - >14.4x: Budget exhausted in <2 days (page on-call)
  - >6x: Budget exhausted in <1 week (create ticket)
  - >3x: Budget exhausted in <1 month (monitor closely)

### Panel 6: Current Burn Rate (1h Window)
- **What it shows**: Real-time burn rate
- **Use case**: Quick assessment of current system health

### Panel 7: Error Budget (30d Window)
- **What it shows**: Total, consumed, and remaining error budget
- **Use case**: Trend analysis and capacity planning

### Panel 8: Error Budget Remaining %
- **What it shows**: Percentage of error budget remaining
- **Use case**: Quick status check

### Panel 9: Latency SLO Compliance
- **What it shows**: Percentage of requests meeting latency SLO
- **SLO target**: 99.9%
- **Action if red**: Performance optimization needed

### Panel 10: Request Rate (Throughput)
- **What it shows**: Requests per second
- **Use case**: Capacity planning, anomaly detection

---

## 🔧 Customizing SLO Targets

To adjust SLO targets for your specific needs:

### 1. Update Recording Rules

Edit `prometheus/rules/sli_recording_rules.yml`:

```yaml
# Change error budget calculation (currently 99.9% = 0.001 error budget)
# For 99.95% SLO, use 0.0005
# For 99.5% SLO, use 0.005

- record: sli:error_budget:burn_rate_1h
  expr: |
    (
      sum(rate(http_server_requests_total{http_status_code=~"5.."}[1h]))
      by (service_name)
      /
      sum(rate(http_server_requests_total[1h]))
      by (service_name)
    ) / 0.001  # <-- Change this value
```

### 2. Update Alert Thresholds

Edit `prometheus/rules/slo_alert_rules.yml`:

```yaml
# Adjust latency threshold (currently 200ms)
- alert: LatencyP95ExceedsThreshold
  expr: sli:http_request_duration_seconds:p95 > 0.2  # <-- Change to 0.3 for 300ms
  
# Adjust error rate threshold (currently 1%)
- alert: ErrorRateHigh
  expr: sli:http_requests:error_rate_percent > 1  # <-- Change to 0.5 for 0.5%
```

### 3. Update Dashboard Thresholds

Edit `grafana/provisioning/dashboards/json/sli-slo-dashboard.json`:

```json
{
  "thresholds": {
    "mode": "absolute",
    "steps": [
      {"color": "green", "value": null},
      {"color": "yellow", "value": 99},
      {"color": "red", "value": 99.9}  // <-- Adjust these values
    ]
  }
}
```

### 4. Reload Configuration

```bash
# Restart Prometheus to load new rules
docker-compose restart prometheus

# Restart Grafana to load updated dashboards
docker-compose restart grafana

# Or use the convenience script
restart-grafana.bat
```

---

## 🔗 Additional Resources

- [Google SRE Book - SLOs](https://sre.google/sre-book/service-level-objectives/)
- [Google SRE Workbook - SLO Engineering](https://sre.google/workbook/implementing-slos/)
- [Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)
- [Multi-Window Multi-Burn-Rate Alerts](https://sre.google/workbook/alerting-on-slos/)

### Platform-Specific Documentation

- [Quick Start Guide](QUICK_START.md)
- [Dashboard Interpretation Guide](DASHBOARD_INTERPRETATION_GUIDE.md)
- [Grafana Quick Start](GRAFANA_QUICK_START.md)
- [Usage Examples](USAGE_EXAMPLES.md)

---

**Last Updated:** October 5, 2025
**Version:** 1.1.0
