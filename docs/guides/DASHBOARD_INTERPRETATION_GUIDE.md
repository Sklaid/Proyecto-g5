# Dashboard Interpretation Guide

A comprehensive guide to understanding and interpreting the Grafana dashboards in the AIOps & SRE Observability Platform.

## 📊 Overview

This guide helps you:
- Understand what each dashboard panel shows
- Interpret metrics and visualizations
- Identify problems quickly
- Take appropriate action based on dashboard data

---

## 🎯 SLI/SLO Dashboard

**URL:** http://localhost:3001/d/slo-dashboard

**Purpose:** Monitor service level objectives, error budgets, and overall service health

### Panel 1: Request Latency (P95 / P99)

**What it shows:**
- 95th percentile latency (P95): 95% of requests complete within this time
- 99th percentile latency (P99): 99% of requests complete within this time

**How to read it:**
```
P95: 150ms  ✅ Good (under 200ms SLO)
P99: 250ms  ⚠️  Warning (some requests slow)
```

**Interpretation:**
- **Green line below 200ms:** Meeting SLO ✅
- **Yellow line 200-500ms:** Degraded performance ⚠️
- **Red line above 500ms:** Critical performance issue 🔴

**Action items:**
- **P95 > 200ms:** Investigate slow endpoints
- **P99 >> P95:** Check for outliers or slow operations
- **Increasing trend:** Capacity or performance issue

**Example scenarios:**
```
Scenario 1: P95=50ms, P99=80ms
✅ Excellent performance, well within SLO

Scenario 2: P95=180ms, P99=450ms
⚠️  Most requests OK, but some very slow
Action: Check distributed traces for slow requests

Scenario 3: P95=350ms, P99=800ms
🔴 SLO breach, immediate action required
Action: Check resource utilization, identify bottlenecks
```

### Panel 2: Success Rate (SLO: 99.9%)

**What it shows:**
- Percentage of successful requests (non-5xx errors)
- Gauge visualization with color-coded thresholds

**How to read it:**
```
99.95% ✅ Above SLO
99.50% ⚠️  Below SLO but acceptable
98.00% 🔴 Critical SLO breach
```

**Thresholds:**
- **Green (99.9-100%):** Meeting SLO
- **Yellow (99-99.9%):** Warning, approaching SLO
- **Red (<99%):** SLO breach

**Action items:**
- **<99.9%:** Check error rate panel for details
- **<99%:** Immediate investigation required
- **Declining trend:** Identify root cause quickly

### Panel 3: Error Budget Remaining (30d)

**What it shows:**
- Percentage of error budget remaining for 30-day window
- Based on 99.9% SLO (0.1% error budget)

**How to read it:**
```
Error Budget = (1 - 0.999) * Total Requests = 0.1% of requests

Example with 100,000 requests:
- Total budget: 100 errors allowed
- Consumed: 30 errors
- Remaining: 70 errors (70%)
```

**Interpretation:**
- **Green (>50%):** Healthy, plenty of budget
- **Yellow (20-50%):** Moderate consumption, monitor closely
- **Red (<20%):** Critical, budget nearly exhausted

**Action items:**
- **<50%:** Review recent incidents, identify patterns
- **<20%:** Freeze risky changes, focus on stability
- **0%:** SLO breached, incident response mode

**Budget management:**
```
High budget (>80%): Safe to deploy changes
Medium budget (50-80%): Deploy with caution
Low budget (20-50%): Only critical fixes
Critical (<20%): Freeze deployments
```

### Panel 4: Error Rate (Threshold: 1%)

**What it shows:**
- Percentage of failed requests (4xx and 5xx errors)
- Separate lines for total errors and 5xx errors

**How to read it:**
```
Total Error Rate: 0.5%  ✅ Below threshold
5xx Error Rate: 0.2%    ✅ Server errors low
```

**Interpretation:**
- **<1%:** Normal operation
- **1-5%:** Elevated errors, investigate
- **>5%:** Critical error rate

**Error types:**
- **4xx errors:** Client errors (bad requests, not found)
- **5xx errors:** Server errors (our fault, more serious)

**Action items:**
- **Spike in 4xx:** Check for API changes, client issues
- **Spike in 5xx:** Server problem, check logs and traces
- **Sustained high rate:** Systemic issue, incident response

### Panel 5: Error Budget Burn Rate (Multi-Window)

**What it shows:**
- Rate at which error budget is being consumed
- Multiple time windows: 1h, 6h, 24h

**How to read it:**
```
Burn Rate = (Errors in Window / Window Duration) / (Error Budget / SLO Window)

1x = Normal consumption (budget lasts 30 days)
6x = Budget exhausted in 5 days
14.4x = Budget exhausted in 2 days
```

**Interpretation:**
- **1-3x:** Normal consumption ✅
- **3-6x:** Elevated consumption ⚠️
- **6-14.4x:** High consumption, alert 🟡
- **>14.4x:** Critical consumption, alert 🔴

**Action items:**
- **>6x:** Investigate cause, prepare mitigation
- **>14.4x:** Immediate action, incident response
- **Increasing trend:** Problem getting worse

**Example:**
```
1h burn rate: 20x  🔴 Critical!
6h burn rate: 10x  🔴 Sustained issue
24h burn rate: 5x  ⚠️  Improving but still high

Interpretation: Recent critical issue, now improving
Action: Identify what changed in last 1-6 hours
```

### Panel 6: Current Burn Rate (1h Window)

**What it shows:**
- Real-time burn rate for last hour
- Bar gauge visualization

**How to read it:**
- Shows immediate consumption rate
- Most sensitive to recent changes
- Use for real-time monitoring

**Action items:**
- **Sudden spike:** Recent incident, investigate immediately
- **Sustained high:** Ongoing issue, needs resolution
- **Returning to normal:** Issue resolving

### Panel 7: Error Budget (30d Window)

**What it shows:**
- Three lines: Total budget, Consumed, Remaining
- Historical view of budget consumption

**How to read it:**
```
Total Budget: 100 errors (constant)
Consumed: 30 errors (increasing)
Remaining: 70 errors (decreasing)
```

**Interpretation:**
- **Flat consumed line:** No errors, healthy
- **Steep consumed line:** Rapid error accumulation
- **Remaining approaching zero:** Budget exhaustion

**Action items:**
- **Rapid consumption:** Identify and fix error source
- **Gradual consumption:** Normal, monitor trends
- **Budget replenishment:** Errors age out after 30 days

### Panel 8: Latency SLO Compliance

**What it shows:**
- Percentage of requests meeting latency SLO (<200ms)
- Gauge visualization

**How to read it:**
```
99.95% ✅ Excellent compliance
99.50% ⚠️  Some slow requests
98.00% 🔴 Many slow requests
```

**Action items:**
- **<99.9%:** Check Request Latency panel for details
- **Declining:** Performance degradation
- **Sudden drop:** Incident, check traces

### Panel 9: Request Rate (Throughput)

**What it shows:**
- Requests per second over time
- Indicates traffic patterns

**How to read it:**
```
5 req/s: Normal baseline
20 req/s: Traffic spike
0.5 req/s: Low traffic period
```

**Interpretation:**
- **Steady line:** Consistent traffic
- **Spikes:** Traffic bursts (expected or attack?)
- **Drops:** Service issue or low usage period

**Action items:**
- **Unexpected spike:** Check if legitimate or attack
- **Sudden drop:** Service may be down
- **Gradual increase:** Capacity planning needed

---

## 📈 Application Performance Dashboard

**URL:** http://localhost:3001/d/app-performance-dashboard

**Purpose:** Monitor application health, performance, and resource utilization

### Request Duration Histogram

**What it shows:**
- Distribution of request latencies
- P50, P90, P95, P99 percentiles

**How to read it:**
```
P50 (median): 50ms   - Half of requests faster
P90: 100ms           - 90% of requests faster
P95: 150ms           - 95% of requests faster
P99: 300ms           - 99% of requests faster
```

**Interpretation:**
- **Tight distribution:** Consistent performance
- **Long tail:** Some very slow requests
- **Bimodal:** Two distinct performance patterns

**Example patterns:**
```
Pattern 1: P50=50ms, P95=80ms, P99=100ms
✅ Excellent, consistent performance

Pattern 2: P50=50ms, P95=200ms, P99=2000ms
⚠️  Most requests fast, but some very slow
Action: Investigate P99 outliers

Pattern 3: P50=500ms, P95=800ms, P99=1200ms
🔴 All requests slow, systemic issue
Action: Check resource utilization, bottlenecks
```

### Throughput by Endpoint

**What it shows:**
- Requests per second for each API endpoint
- Identifies high-traffic endpoints

**How to read it:**
```
/api/users: 3 req/s      - High traffic
/api/products: 1 req/s   - Medium traffic
/api/admin: 0.1 req/s    - Low traffic
```

**Action items:**
- **Optimize high-traffic endpoints** for best impact
- **Monitor for unusual patterns** (sudden spikes)
- **Capacity planning** based on traffic trends

### Error Rate Breakdown by Status Code

**What it shows:**
- Errors separated by HTTP status code
- 4xx (client errors) vs 5xx (server errors)

**How to read it:**
```
200 OK: 95%        ✅ Successful
404 Not Found: 3%  ⚠️  Client errors
500 Error: 2%      🔴 Server errors
```

**Interpretation:**
- **High 404:** Missing resources, broken links
- **High 400:** Bad requests, validation errors
- **High 500:** Server problems, bugs
- **High 503:** Service overload or down

**Action items:**
- **4xx errors:** Check API documentation, client code
- **5xx errors:** Check server logs, traces, resources
- **Sudden increase:** Recent deployment issue?

### CPU Utilization

**What it shows:**
- CPU usage percentage over time
- Node.js process CPU consumption

**How to read it:**
```
<50%: Normal, healthy ✅
50-80%: Moderate load ⚠️
>80%: High load, may impact performance 🔴
>95%: Critical, CPU bound 🔴🔴
```

**Action items:**
- **>80% sustained:** Scale horizontally or optimize code
- **Spikes:** Identify CPU-intensive operations
- **Gradual increase:** Memory leak or growing load

### Memory Utilization

**What it shows:**
- Memory usage over time
- Heap and resident memory

**How to read it:**
```
<50%: Normal ✅
50-80%: Moderate ⚠️
>80%: High, risk of OOM 🔴
Increasing trend: Possible memory leak 🔴
```

**Action items:**
- **>80%:** Increase memory limit or optimize
- **Steady increase:** Memory leak, investigate
- **Sudden spike:** Large operation or data load

---

## 🔍 Distributed Tracing Dashboard

**URL:** http://localhost:3001/d/distributed-tracing

**Purpose:** Analyze request flows and identify bottlenecks

### Using Trace Search

**In Grafana Explore:**

1. **Navigate:** Click Explore icon (compass) → Select Tempo datasource

2. **Query examples:**
```
{status=error}                    # All error traces
{service.name="demo-app"}         # Traces from specific service
{http.status_code="500"}          # 500 errors only
{http.route="/api/users"}         # Specific endpoint
{http.method="POST"}              # POST requests only
```

3. **Analyze trace:**
- Click on a trace to see span timeline
- Identify long-running spans
- Check span attributes for context
- Look for error spans

### Reading a Trace

**Example trace structure:**
```
Trace ID: abc123def456
Duration: 250ms
Status: OK

├─ HTTP GET /api/users (250ms) [demo-app]
   ├─ fetch_users_operation (200ms)
   │  ├─ database_query (150ms) ⚠️  Slow!
   │  └─ cache_check (10ms)
   └─ response_serialization (40ms)
```

**What to look for:**

1. **Long spans:** Bottlenecks
   - Database queries >100ms
   - External API calls >500ms
   - File I/O operations

2. **Many spans:** Complex operations
   - N+1 query problems
   - Excessive service calls
   - Inefficient algorithms

3. **Error spans:** Failures
   - Exception details in span events
   - Error messages in attributes
   - Stack traces

4. **Span attributes:** Context
   - User ID, session ID
   - Request parameters
   - Database query details

### Trace Analysis Examples

**Example 1: Slow database query**
```
Trace duration: 500ms
├─ HTTP GET /api/users (500ms)
   └─ database_query (480ms) 🔴 Problem here!

Action: Optimize query, add index, use caching
```

**Example 2: N+1 query problem**
```
Trace duration: 2000ms
├─ HTTP GET /api/users (2000ms)
   ├─ fetch_users (100ms)
   ├─ fetch_user_details (50ms) x 20 🔴 N+1 problem!
   └─ ...

Action: Use batch query or JOIN
```

**Example 3: External API timeout**
```
Trace duration: 5000ms
├─ HTTP GET /api/products (5000ms)
   └─ external_api_call (4950ms) 🔴 Timeout!
      Status: ERROR
      Message: "Connection timeout"

Action: Increase timeout, add retry logic, use circuit breaker
```

---

## 🚨 Alert Interpretation

### Alert: High Error Budget Burn Rate

**What it means:**
- Error budget being consumed rapidly
- At current rate, budget will be exhausted soon

**Severity levels:**
```
Burn rate >14.4x: Critical (budget gone in 2 days)
Burn rate >6x: Warning (budget gone in 5 days)
```

**Action:**
1. Check Error Rate panel for spike
2. Review recent deployments or changes
3. Check traces for error patterns
4. Implement fix or rollback

### Alert: High Latency P95 Exceeding SLI

**What it means:**
- 95th percentile latency above 200ms threshold
- SLO at risk

**Action:**
1. Check Request Latency panel
2. Identify slow endpoints in Application Performance
3. Analyze traces for bottlenecks
4. Check resource utilization (CPU, memory)

### Alert: High Error Rate Above 1%

**What it means:**
- More than 1% of requests failing
- Immediate attention required

**Action:**
1. Check Error Rate Breakdown for error types
2. Review recent changes or deployments
3. Check server logs for exceptions
4. Analyze error traces in Tempo

### Alert: Service Down

**What it means:**
- Service health check failing
- Service may be unreachable

**Action:**
1. Check service status: `docker-compose ps`
2. View service logs: `docker-compose logs <service>`
3. Restart if needed: `docker-compose restart <service>`
4. Check resource availability (memory, disk)

---

## 📋 Quick Decision Matrix

### Based on Success Rate

| Success Rate | Status | Action |
|--------------|--------|--------|
| >99.9% | ✅ Healthy | Monitor, business as usual |
| 99-99.9% | ⚠️  Warning | Investigate, prepare mitigation |
| 95-99% | 🔴 Critical | Incident response, fix immediately |
| <95% | 🔴🔴 Emergency | All hands, major incident |

### Based on Error Budget

| Budget Remaining | Status | Action |
|------------------|--------|--------|
| >50% | ✅ Healthy | Safe to deploy changes |
| 20-50% | ⚠️  Caution | Deploy only critical fixes |
| 10-20% | 🔴 Critical | Freeze deployments, focus on stability |
| <10% | 🔴🔴 Emergency | Incident mode, no changes |

### Based on Burn Rate

| Burn Rate | Budget Lasts | Action |
|-----------|--------------|--------|
| 1-3x | 10-30 days | ✅ Normal |
| 3-6x | 5-10 days | ⚠️  Monitor closely |
| 6-14.4x | 2-5 days | 🔴 Investigate and fix |
| >14.4x | <2 days | 🔴🔴 Immediate action |

---

## 🎓 Best Practices

### Daily Monitoring Routine

1. **Morning check (5 minutes):**
   - Open SLI/SLO Dashboard
   - Check success rate gauge
   - Review error budget remaining
   - Scan for any alerts

2. **If issues detected (15 minutes):**
   - Check Application Performance Dashboard
   - Identify problematic endpoints
   - Review error rate breakdown
   - Analyze traces in Tempo

3. **Weekly review (30 minutes):**
   - Review error budget trends
   - Identify recurring issues
   - Plan optimizations
   - Update SLO targets if needed

### Incident Response Workflow

1. **Detect:** Alert fires or dashboard shows issue
2. **Assess:** Check SLI/SLO Dashboard for severity
3. **Investigate:** Use Application Performance and Traces
4. **Mitigate:** Fix issue or rollback
5. **Verify:** Confirm metrics returning to normal
6. **Document:** Record incident and learnings

### Dashboard Optimization Tips

1. **Set appropriate time ranges:**
   - Real-time monitoring: Last 15 minutes
   - Incident investigation: Last 1-6 hours
   - Trend analysis: Last 7-30 days

2. **Use dashboard variables:**
   - Filter by service, endpoint, or environment
   - Compare different time periods
   - Focus on specific metrics

3. **Create custom views:**
   - Save frequently used queries
   - Create team-specific dashboards
   - Set up TV displays for NOC

---

## 📚 Additional Resources

- [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - Scripts and examples
- [README.md](README.md) - Main documentation
- [TEMPO_TRACING_GUIDE.md](TEMPO_TRACING_GUIDE.md) - Tracing guide
- [Google SRE Book - SLOs](https://sre.google/sre-book/service-level-objectives/)

---

**Last Updated:** October 5, 2025
**Version:** 1.0.0
