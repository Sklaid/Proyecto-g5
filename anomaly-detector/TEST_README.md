# Anomaly Detector Unit Tests

This document describes the comprehensive unit tests for the anomaly detection logic.

## Test Coverage

The test suite covers all critical aspects of the anomaly detection system as specified in task 7.7:

### 1. Holt-Winters Algorithm Tests (`TestHoltWintersAlgorithm`)

Tests the core machine learning algorithm with various data patterns:

- **test_fit_holt_winters_with_seasonal_pattern**: Verifies the algorithm can fit seasonal patterns (daily cycles)
- **test_fit_holt_winters_with_trend**: Verifies the algorithm can fit data with upward/downward trends
- **test_fit_holt_winters_with_constant_values**: Tests graceful handling of constant values (returns None)
- **test_fit_holt_winters_with_insufficient_data**: Tests handling of datasets too small for modeling

### 2. Deviation Calculation Tests (`TestDeviationCalculation`)

Tests the accuracy of deviation calculations:

- **test_calculate_prediction_and_deviation_normal**: Tests deviation calculation with normal values
- **test_calculate_prediction_and_deviation_anomaly**: Tests deviation calculation with anomalous values
- **test_deviation_calculation_accuracy**: Verifies mathematical accuracy of deviation calculations

### 3. Alert Generation Tests (`TestAlertGeneration`)

Tests alert generation with various scenarios:

- **test_classify_anomaly_below_threshold**: Tests classification when deviation is below threshold (no anomaly)
- **test_classify_anomaly_above_threshold**: Tests classification when deviation exceeds threshold (anomaly detected)
- **test_classify_anomaly_severity_levels**: Tests correct assignment of severity levels (low, medium, high, critical)
- **test_alert_payload_format**: Verifies alert payload structure and content
- **test_alert_webhook_success**: Tests successful webhook delivery
- **test_alert_webhook_failure**: Tests handling of webhook failures
- **test_alert_webhook_timeout**: Tests handling of webhook timeouts

### 4. Graceful Degradation Tests (`TestGracefulDegradation`)

Tests system behavior with insufficient data:

- **test_fallback_detection_with_insufficient_data**: Tests fallback to statistical methods when Holt-Winters fails
- **test_fetch_historical_metrics_insufficient_data**: Tests handling when too few data points are available
- **test_fetch_historical_metrics_no_data**: Tests handling when no historical data exists
- **test_detect_anomaly_with_fallback**: Tests complete detection pipeline using fallback method
- **test_detect_anomaly_handles_none_current_value**: Tests graceful handling of missing current values

### 5. Prometheus Client Tests (`TestPrometheusClient`)

Tests Prometheus connectivity:

- **test_health_check_success**: Tests successful Prometheus health check
- **test_health_check_failure**: Tests handling of Prometheus unavailability

### 6. End-to-End Scenario Tests (`TestEndToEndScenarios`)

Tests complete workflows:

- **test_normal_operation_no_anomaly**: Tests normal operation with no anomalies detected
- **test_spike_detection**: Tests detection of sudden metric spikes
- **test_complete_alert_pipeline**: Tests complete pipeline from detection to alert delivery

## Running the Tests

### Prerequisites

Install required dependencies:

```bash
pip install -r requirements.txt
```

### Run All Tests

```bash
python -m pytest test_anomaly_detector.py -v
```

### Run Specific Test Class

```bash
python -m pytest test_anomaly_detector.py::TestHoltWintersAlgorithm -v
```

### Run with Coverage

```bash
python -m pytest test_anomaly_detector.py --cov=anomaly_detector --cov=alert_manager --cov=prometheus_client
```

## Test Results

All 24 tests pass successfully, covering:

✅ Holt-Winters algorithm with known data patterns (4 tests)
✅ Deviation calculation accuracy (3 tests)
✅ Alert generation with various scenarios (7 tests)
✅ Graceful degradation with insufficient data (5 tests)
✅ Prometheus client functionality (2 tests)
✅ End-to-end scenarios (3 tests)

## Requirements Mapping

These tests verify the following requirements from the spec:

- **Requirement 6.1**: Anomaly detection using Holt-Winters algorithm
- **Requirement 6.2**: Deviation calculation and anomaly classification
- **Requirement 6.3**: Alert generation with context and severity

## Notes

- Tests use mocking to isolate components and avoid external dependencies
- Random seeds are set where needed for reproducibility
- Tests verify both happy paths and error conditions
- Graceful degradation is thoroughly tested to ensure system reliability
