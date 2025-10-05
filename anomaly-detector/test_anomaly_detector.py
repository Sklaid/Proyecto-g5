"""
Unit tests for anomaly detection logic
Tests Holt-Winters algorithm, deviation calculation, alert generation, and graceful degradation
"""
import pytest
import numpy as np
from unittest.mock import Mock, MagicMock, patch
from datetime import datetime, timedelta
from anomaly_detector import AnomalyDetector
from alert_manager import AlertManager
from prometheus_client import PrometheusQueryClient


class TestHoltWintersAlgorithm:
    """Test Holt-Winters algorithm with known data patterns"""
    
    def test_fit_holt_winters_with_seasonal_pattern(self):
        """Test that Holt-Winters can fit a seasonal pattern"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Generate synthetic seasonal data (daily pattern)
        timestamps = list(range(288))  # 24 hours with 5-min intervals
        values = [50 + 20 * np.sin(2 * np.pi * t / 288) for t in timestamps]
        time_series = list(zip(timestamps, values))
        
        # Fit model
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=288)
        
        assert fitted_model is not None
        assert hasattr(fitted_model, 'forecast')
        assert hasattr(fitted_model, 'resid')
    
    def test_fit_holt_winters_with_trend(self):
        """Test that Holt-Winters can fit data with trend"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Generate data with upward trend
        timestamps = list(range(200))
        values = [10 + 0.5 * t + np.random.normal(0, 2) for t in timestamps]
        time_series = list(zip(timestamps, values))
        
        # Fit model
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=50)
        
        assert fitted_model is not None
    
    def test_fit_holt_winters_with_constant_values(self):
        """Test that Holt-Winters handles constant values gracefully"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Generate constant values
        timestamps = list(range(150))
        values = [100.0] * 150
        time_series = list(zip(timestamps, values))
        
        # Fit model - should return None for constant values
        fitted_model = detector.fit_holt_winters(time_series)
        
        assert fitted_model is None
    
    def test_fit_holt_winters_with_insufficient_data(self):
        """Test that Holt-Winters handles insufficient data"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Generate very small dataset
        timestamps = list(range(10))
        values = [50 + np.random.normal(0, 5) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        
        # Fit model with small data
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=5)
        
        # Should handle gracefully (may return None or a model)
        # The important thing is it doesn't crash
        assert fitted_model is None or hasattr(fitted_model, 'forecast')


class TestDeviationCalculation:
    """Test deviation calculation accuracy"""
    
    def test_calculate_prediction_and_deviation_normal(self):
        """Test deviation calculation with normal values"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create synthetic data and fit model
        timestamps = list(range(200))
        values = [50 + 10 * np.sin(2 * np.pi * t / 50) for t in timestamps]
        time_series = list(zip(timestamps, values))
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=50)
        
        assert fitted_model is not None
        
        # Test with value close to prediction
        actual_value = 52.0
        predicted, deviation, deviation_std = detector.calculate_prediction_and_deviation(
            fitted_model, actual_value
        )
        
        assert predicted > 0
        assert deviation >= 0
        assert deviation_std >= 0
    
    def test_calculate_prediction_and_deviation_anomaly(self):
        """Test deviation calculation with anomalous value"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create synthetic data
        timestamps = list(range(200))
        values = [50 + 5 * np.sin(2 * np.pi * t / 50) for t in timestamps]
        time_series = list(zip(timestamps, values))
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=50)
        
        assert fitted_model is not None
        
        # Test with anomalous value (far from expected)
        actual_value = 150.0  # Much higher than normal range
        predicted, deviation, deviation_std = detector.calculate_prediction_and_deviation(
            fitted_model, actual_value
        )
        
        assert predicted < actual_value
        assert deviation > 50  # Should be large deviation
        assert deviation_std > 2.5  # Should exceed threshold
    
    def test_deviation_calculation_accuracy(self):
        """Test that deviation is calculated correctly"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create predictable data
        timestamps = list(range(150))
        values = [100.0 + np.random.normal(0, 1) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        fitted_model = detector.fit_holt_winters(time_series, seasonal_periods=30)
        
        assert fitted_model is not None
        
        # Test deviation calculation
        actual_value = 110.0
        predicted, deviation, deviation_std = detector.calculate_prediction_and_deviation(
            fitted_model, actual_value
        )
        
        # Verify deviation is absolute difference
        assert abs(deviation - abs(actual_value - predicted)) < 0.01


class TestAlertGeneration:
    """Test alert generation with various scenarios"""
    
    def test_classify_anomaly_below_threshold(self):
        """Test classification when deviation is below threshold"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        deviation_std = 1.5  # Below threshold
        is_anomaly, severity, confidence = detector.classify_anomaly(deviation_std)
        
        assert is_anomaly is False
        assert severity == 'low'
    
    def test_classify_anomaly_above_threshold(self):
        """Test classification when deviation exceeds threshold"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        deviation_std = 3.0  # Above threshold
        is_anomaly, severity, confidence = detector.classify_anomaly(deviation_std)
        
        assert is_anomaly is True
        assert severity in ['medium', 'high', 'critical']
    
    def test_classify_anomaly_severity_levels(self):
        """Test that severity levels are assigned correctly"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Test medium severity
        is_anomaly, severity, _ = detector.classify_anomaly(2.6)
        assert is_anomaly is True
        assert severity == 'medium'
        
        # Test high severity
        is_anomaly, severity, _ = detector.classify_anomaly(4.0)
        assert is_anomaly is True
        assert severity == 'high'
        
        # Test critical severity
        is_anomaly, severity, _ = detector.classify_anomaly(6.0)
        assert is_anomaly is True
        assert severity == 'critical'
    
    def test_alert_payload_format(self):
        """Test that alert payload is formatted correctly"""
        alert_manager = AlertManager(webhook_url='http://test.com/webhook')
        
        anomaly_result = {
            'timestamp': '2025-10-03T10:30:00Z',
            'metric': 'http_request_duration_p95',
            'expected_value': 150.0,
            'actual_value': 450.0,
            'deviation': 300.0,
            'deviation_std': 5.0,
            'severity': 'high',
            'confidence': 0.95
        }
        
        payload = alert_manager.format_alert_payload(anomaly_result, 'demo-app')
        
        assert 'title' in payload
        assert 'message' in payload
        assert 'severity' in payload
        assert payload['severity'] == 'high'
        assert 'tags' in payload
        assert payload['tags']['service'] == 'demo-app'
        assert payload['tags']['metric'] == 'http_request_duration_p95'
    
    def test_alert_webhook_success(self):
        """Test successful webhook sending"""
        alert_manager = AlertManager(webhook_url='http://test.com/webhook')
        
        payload = {
            'title': 'Test Alert',
            'message': 'Test message',
            'severity': 'high'
        }
        
        with patch('requests.post') as mock_post:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_post.return_value = mock_response
            
            success = alert_manager.send_webhook(payload)
            
            assert success is True
            mock_post.assert_called_once()
    
    def test_alert_webhook_failure(self):
        """Test webhook failure handling"""
        alert_manager = AlertManager(webhook_url='http://test.com/webhook')
        
        payload = {'title': 'Test Alert'}
        
        with patch('requests.post') as mock_post:
            mock_response = Mock()
            mock_response.status_code = 500
            mock_response.text = 'Internal Server Error'
            mock_post.return_value = mock_response
            
            success = alert_manager.send_webhook(payload)
            
            assert success is False
    
    def test_alert_webhook_timeout(self):
        """Test webhook timeout handling"""
        alert_manager = AlertManager(webhook_url='http://test.com/webhook')
        
        payload = {'title': 'Test Alert'}
        
        with patch('requests.post') as mock_post:
            mock_post.side_effect = Exception('Timeout')
            
            success = alert_manager.send_webhook(payload)
            
            assert success is False


class TestGracefulDegradation:
    """Test graceful degradation with insufficient data"""
    
    def test_fallback_detection_with_insufficient_data(self):
        """Test that fallback detection works when Holt-Winters fails"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client
        mock_prom_client = Mock()
        
        # Small dataset that won't fit Holt-Winters well
        timestamps = list(range(50))
        values = [100.0 + np.random.normal(0, 5) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        
        mock_prom_client.get_current_value.return_value = 120.0
        
        # Call fallback detection
        result = detector._fallback_detection(mock_prom_client, 'test_metric', time_series)
        
        assert result is not None
        assert 'expected_value' in result
        assert 'actual_value' in result
        assert 'deviation' in result
        assert 'method' in result
        assert result['method'] == 'fallback'
    
    def test_fetch_historical_metrics_insufficient_data(self):
        """Test handling of insufficient historical data"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client with insufficient data
        mock_prom_client = Mock()
        mock_prom_client.get_metric_history.return_value = [(1, 50.0), (2, 51.0)]  # Only 2 points
        
        result = detector.fetch_historical_metrics(mock_prom_client, 'test_metric', days=7)
        
        assert result is None
    
    def test_fetch_historical_metrics_no_data(self):
        """Test handling when no historical data is available"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client with no data
        mock_prom_client = Mock()
        mock_prom_client.get_metric_history.return_value = None
        
        result = detector.fetch_historical_metrics(mock_prom_client, 'test_metric', days=7)
        
        assert result is None
    
    def test_detect_anomaly_with_fallback(self):
        """Test complete anomaly detection with fallback"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client
        mock_prom_client = Mock()
        
        # Provide data that will trigger fallback (constant values)
        timestamps = list(range(150))
        values = [100.0] * 150  # Constant values
        time_series = list(zip(timestamps, values))
        
        mock_prom_client.get_metric_history.return_value = time_series
        mock_prom_client.get_current_value.return_value = 150.0  # Anomalous value
        
        result = detector.detect_anomaly(mock_prom_client, 'test_metric', days=7)
        
        assert result is not None
        assert 'is_anomaly' in result
        assert 'method' in result
        assert result['method'] == 'fallback'
    
    def test_detect_anomaly_handles_none_current_value(self):
        """Test that detection handles None current value gracefully"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client
        mock_prom_client = Mock()
        
        timestamps = list(range(150))
        values = [100.0 + np.random.normal(0, 5) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        
        mock_prom_client.get_metric_history.return_value = time_series
        mock_prom_client.get_current_value.return_value = None  # No current value
        
        result = detector.detect_anomaly(mock_prom_client, 'test_metric', days=7)
        
        assert result is None


class TestPrometheusClient:
    """Test Prometheus client functionality"""
    
    def test_health_check_success(self):
        """Test successful Prometheus health check"""
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_get.return_value = mock_response
            
            client = PrometheusQueryClient('http://prometheus:9090')
            is_healthy = client.health_check()
            
            assert is_healthy is True
    
    def test_health_check_failure(self):
        """Test failed Prometheus health check"""
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 503
            mock_get.return_value = mock_response
            
            client = PrometheusQueryClient('http://prometheus:9090')
            is_healthy = client.health_check()
            
            assert is_healthy is False


class TestEndToEndScenarios:
    """Test complete end-to-end scenarios"""
    
    def test_normal_operation_no_anomaly(self):
        """Test normal operation where no anomaly is detected"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client
        mock_prom_client = Mock()
        
        # Normal data with clear pattern
        timestamps = list(range(200))
        np.random.seed(42)  # Set seed for reproducibility
        values = [100.0 + np.random.normal(0, 1) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        
        mock_prom_client.get_metric_history.return_value = time_series
        mock_prom_client.get_current_value.return_value = 100.5  # Very normal value
        
        result = detector.detect_anomaly(mock_prom_client, 'test_metric', days=7)
        
        assert result is not None
        # Check that deviation is low (may or may not be classified as anomaly depending on model)
        assert result['deviation_std'] < 5.0  # Reasonable deviation
    
    def test_spike_detection(self):
        """Test detection of sudden spike in metric"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        
        # Create mock Prometheus client
        mock_prom_client = Mock()
        
        # Normal data with clear pattern
        timestamps = list(range(200))
        np.random.seed(42)  # Set seed for reproducibility
        values = [100.0 + np.random.normal(0, 1) for _ in timestamps]
        time_series = list(zip(timestamps, values))
        
        mock_prom_client.get_metric_history.return_value = time_series
        mock_prom_client.get_current_value.return_value = 200.0  # Spike!
        
        result = detector.detect_anomaly(mock_prom_client, 'test_metric', days=7)
        
        assert result is not None
        # Check that there's a significant deviation
        assert result['deviation'] > 50.0  # Large deviation from normal
        assert result['deviation_std'] > 2.0  # Significant in terms of std deviations
    
    def test_complete_alert_pipeline(self):
        """Test complete pipeline from detection to alert"""
        detector = AnomalyDetector(threshold=2.5, min_data_points=100)
        alert_manager = AlertManager(webhook_url='http://test.com/webhook')
        
        # Create anomaly result
        anomaly_result = {
            'timestamp': datetime.now().isoformat(),
            'metric': 'http_request_duration_p95',
            'expected_value': 100.0,
            'actual_value': 300.0,
            'deviation': 200.0,
            'deviation_std': 5.0,
            'is_anomaly': True,
            'severity': 'high',
            'confidence': 0.95,
            'threshold': 2.5
        }
        
        with patch('requests.post') as mock_post:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_post.return_value = mock_response
            
            success = alert_manager.generate_and_send_alert(anomaly_result, 'demo-app')
            
            assert success is True
            mock_post.assert_called_once()


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
