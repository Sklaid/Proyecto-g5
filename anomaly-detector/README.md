# Anomaly Detector Service

Machine learning-based anomaly detection service for monitoring application metrics using Holt-Winters exponential smoothing.

## Overview

This service continuously monitors key metrics from Prometheus and uses the Holt-Winters algorithm to detect anomalies based on historical patterns. When anomalies are detected, it generates alerts with context and severity information.

## Features

- **Holt-Winters Algorithm**: Uses exponential smoothing to predict expected values based on trends and seasonality
- **Automatic Fallback**: Falls back to statistical methods if insufficient data for Holt-Winters
- **Configurable Thresholds**: Adjustable sensitivity for anomaly detection
- **Alert Generation**: Sends formatted alerts to Grafana/Alertmanager
- **Graceful Degradation**: Handles missing data and connection issues
- **Retry Logic**: Automatic reconnection to Prometheus on failures

## Configuration

Configure the service using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PROMETHEUS_URL` | `http://prometheus:9090` | Prometheus server URL |
| `CHECK_INTERVAL_MINUTES` | `5` | Minutes between detection cycles |
| `HISTORICAL_DAYS` | `7` | Days of historical data for training |
| `ANOMALY_THRESHOLD` | `2.5` | Standard deviations for anomaly classification |
| `ALERT_WEBHOOK_URL` | `http://grafana:3000/api/alerts` | Webhook URL for alerts |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |

## Monitored Metrics

The service monitors these metrics by default:

- `http_server_request_duration_seconds` - Request latency
- `http_server_requests_total` - Request rate
- `http_server_errors_total` - Error rate

## How It Works

1. **Data Collection**: Fetches historical metrics from Prometheus (default: 7 days)
2. **Model Training**: Fits Holt-Winters model to capture trends and seasonality
3. **Prediction**: Generates expected values for current time period
4. **Deviation Calculation**: Compares actual vs. predicted values
5. **Classification**: Determines if deviation exceeds threshold
6. **Alert Generation**: Sends alerts for detected anomalies

## Anomaly Severity Levels

- **Critical**: Deviation > 5.0 standard deviations
- **High**: Deviation > 3.75 standard deviations
- **Medium**: Deviation > 2.5 standard deviations
- **Low**: Deviation < 2.5 standard deviations

## Running Locally

### With Docker Compose

```bash
docker-compose up anomaly-detector
```

### Standalone

```bash
cd anomaly-detector
pip install -r requirements.txt
python main.py
```

## Development

### Project Structure

```
anomaly-detector/
├── main.py                 # Main entry point with detection loop
├── config.py              # Configuration management
├── prometheus_client.py   # Prometheus query client
├── anomaly_detector.py    # Holt-Winters detection algorithm
├── alert_manager.py       # Alert generation and notification
├── requirements.txt       # Python dependencies
├── Dockerfile            # Container image definition
└── README.md             # This file
```

### Dependencies

- `prometheus-api-client`: Query Prometheus metrics
- `statsmodels`: Holt-Winters exponential smoothing
- `scikit-learn`: Machine learning utilities
- `numpy`: Numerical computations
- `requests`: HTTP client for webhooks

## Logs

The service logs all detection activities:

```
2025-10-04 10:30:00 - INFO - Starting detection cycle
2025-10-04 10:30:05 - INFO - Analyzing metric: http_server_request_duration_seconds
2025-10-04 10:30:10 - WARNING - Anomaly detected in http_server_request_duration_seconds
2025-10-04 10:30:10 - ERROR - ANOMALY DETECTED | Service: demo-app | Metric: http_server_request_duration_seconds | Severity: high | Actual: 450.00 | Expected: 150.00 | Deviation: 3.50 std
2025-10-04 10:30:11 - INFO - Alert generated and sent for http_server_request_duration_seconds
```

## Troubleshooting

### Service won't start

- Check Prometheus is running and accessible
- Verify `PROMETHEUS_URL` is correct
- Check logs for connection errors

### No anomalies detected

- Ensure metrics are being collected in Prometheus
- Check if there's sufficient historical data (minimum 100 data points)
- Adjust `ANOMALY_THRESHOLD` if too sensitive/insensitive

### Alerts not being sent

- Verify `ALERT_WEBHOOK_URL` is correct
- Check Grafana is running and accessible
- Review logs for webhook errors

## Future Enhancements

- Support for additional ML algorithms (Prophet, LSTM)
- Correlation analysis between multiple metrics
- Automatic threshold tuning
- Alert deduplication and grouping
- Integration with incident management systems
