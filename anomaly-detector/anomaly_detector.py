import logging
import numpy as np
from typing import List, Tuple, Optional, Dict
from datetime import datetime
from sklearn.preprocessing import StandardScaler
from statsmodels.tsa.holtwinters import ExponentialSmoothing

logger = logging.getLogger(__name__)

class AnomalyDetector:
    """Anomaly detection using Holt-Winters exponential smoothing"""
    
    def __init__(self, threshold: float = 2.5, min_data_points: int = 100):
        """
        Initialize anomaly detector
        
        Args:
            threshold: Number of standard deviations for anomaly classification
            min_data_points: Minimum number of data points required for detection
        """
        self.threshold = threshold
        self.min_data_points = min_data_points
        logger.info(f"Initialized AnomalyDetector with threshold={threshold}")
    
    def fetch_historical_metrics(
        self,
        prom_client,
        metric_name: str,
        days: int = 7
    ) -> Optional[List[Tuple[float, float]]]:
        """
        Fetch historical metrics from Prometheus
        
        Args:
            prom_client: PrometheusQueryClient instance
            metric_name: Name of the metric to fetch
            days: Number of days of historical data
            
        Returns:
            List of (timestamp, value) tuples or None if insufficient data
        """
        logger.info(f"Fetching {days} days of historical data for {metric_name}")
        
        time_series = prom_client.get_metric_history(
            metric_name=metric_name,
            days=days,
            aggregation='avg'
        )
        
        if not time_series:
            logger.warning(f"No historical data available for {metric_name}")
            return None
        
        if len(time_series) < self.min_data_points:
            logger.warning(
                f"Insufficient data points for {metric_name}: "
                f"{len(time_series)} < {self.min_data_points}"
            )
            return None
        
        logger.info(f"Retrieved {len(time_series)} data points for {metric_name}")
        return time_series
    
    def fit_holt_winters(
        self,
        time_series: List[Tuple[float, float]],
        seasonal_periods: int = 288  # 24 hours with 5-minute intervals
    ) -> Optional[ExponentialSmoothing]:
        """
        Fit Holt-Winters model to time series data
        
        Args:
            time_series: List of (timestamp, value) tuples
            seasonal_periods: Number of periods in a seasonal cycle
            
        Returns:
            Fitted ExponentialSmoothing model or None if fitting fails
        """
        try:
            # Extract values
            values = np.array([v for _, v in time_series])
            
            # Check for constant values
            if np.std(values) == 0:
                logger.warning("Time series has constant values, cannot fit model")
                return None
            
            # Fit Holt-Winters model
            # Use additive model for simplicity
            model = ExponentialSmoothing(
                values,
                seasonal_periods=min(seasonal_periods, len(values) // 2),
                trend='add',
                seasonal='add',
                initialization_method='estimated'
            )
            
            fitted_model = model.fit(optimized=True)
            logger.info("Successfully fitted Holt-Winters model")
            return fitted_model
            
        except Exception as e:
            logger.error(f"Error fitting Holt-Winters model: {e}")
            return None
    
    def calculate_prediction_and_deviation(
        self,
        fitted_model: ExponentialSmoothing,
        actual_value: float,
        forecast_steps: int = 1
    ) -> Tuple[float, float, float]:
        """
        Calculate prediction and deviation from actual value
        
        Args:
            fitted_model: Fitted Holt-Winters model
            actual_value: Current actual value
            forecast_steps: Number of steps to forecast
            
        Returns:
            Tuple of (predicted_value, deviation, deviation_std)
        """
        try:
            # Generate forecast
            forecast = fitted_model.forecast(steps=forecast_steps)
            predicted_value = forecast[0]
            
            # Calculate residuals from fitted values
            residuals = fitted_model.resid
            residual_std = np.std(residuals)
            
            # Calculate deviation
            deviation = abs(actual_value - predicted_value)
            
            # Normalize deviation by standard deviation
            if residual_std > 0:
                deviation_std = deviation / residual_std
            else:
                deviation_std = 0
            
            logger.debug(
                f"Prediction: {predicted_value:.2f}, "
                f"Actual: {actual_value:.2f}, "
                f"Deviation: {deviation:.2f} ({deviation_std:.2f} std)"
            )
            
            return predicted_value, deviation, deviation_std
            
        except Exception as e:
            logger.error(f"Error calculating prediction: {e}")
            return 0.0, 0.0, 0.0
    
    def classify_anomaly(
        self,
        deviation_std: float,
        confidence_level: float = 0.95
    ) -> Tuple[bool, str, float]:
        """
        Classify whether a deviation is an anomaly
        
        Args:
            deviation_std: Deviation in standard deviations
            confidence_level: Confidence level for classification
            
        Returns:
            Tuple of (is_anomaly, severity, confidence)
        """
        is_anomaly = deviation_std > self.threshold
        
        # Determine severity
        if deviation_std > self.threshold * 2:
            severity = 'critical'
        elif deviation_std > self.threshold * 1.5:
            severity = 'high'
        elif deviation_std > self.threshold:
            severity = 'medium'
        else:
            severity = 'low'
        
        # Calculate confidence (simple approach)
        confidence = min(confidence_level, deviation_std / (self.threshold * 2))
        
        if is_anomaly:
            logger.info(
                f"Anomaly detected: deviation={deviation_std:.2f} std, "
                f"severity={severity}, confidence={confidence:.2f}"
            )
        
        return is_anomaly, severity, confidence
    
    def detect_anomaly(
        self,
        prom_client,
        metric_name: str,
        days: int = 7
    ) -> Optional[Dict]:
        """
        Complete anomaly detection pipeline for a metric
        
        Args:
            prom_client: PrometheusQueryClient instance
            metric_name: Name of the metric to analyze
            days: Number of days of historical data
            
        Returns:
            Dictionary with anomaly detection results or None if detection fails
        """
        logger.info(f"Starting anomaly detection for {metric_name}")
        
        # Step 1: Fetch historical data
        time_series = self.fetch_historical_metrics(prom_client, metric_name, days)
        if not time_series:
            return None
        
        # Step 2: Fit Holt-Winters model
        fitted_model = self.fit_holt_winters(time_series)
        if not fitted_model:
            logger.warning(f"Could not fit model for {metric_name}, using fallback")
            return self._fallback_detection(prom_client, metric_name, time_series)
        
        # Step 3: Get current value
        current_value = prom_client.get_current_value(metric_name, aggregation='avg')
        if current_value is None:
            logger.warning(f"Could not get current value for {metric_name}")
            return None
        
        # Step 4: Calculate prediction and deviation
        predicted_value, deviation, deviation_std = self.calculate_prediction_and_deviation(
            fitted_model, current_value
        )
        
        # Step 5: Classify anomaly
        is_anomaly, severity, confidence = self.classify_anomaly(deviation_std)
        
        # Build result
        result = {
            'timestamp': datetime.now().isoformat(),
            'metric': metric_name,
            'expected_value': float(predicted_value),
            'actual_value': float(current_value),
            'deviation': float(deviation),
            'deviation_std': float(deviation_std),
            'is_anomaly': is_anomaly,
            'severity': severity,
            'confidence': float(confidence),
            'threshold': self.threshold
        }
        
        logger.info(f"Anomaly detection completed for {metric_name}: is_anomaly={is_anomaly}")
        return result
    
    def _fallback_detection(
        self,
        prom_client,
        metric_name: str,
        time_series: List[Tuple[float, float]]
    ) -> Optional[Dict]:
        """
        Fallback detection using simple statistical methods
        
        Args:
            prom_client: PrometheusQueryClient instance
            metric_name: Name of the metric
            time_series: Historical time series data
            
        Returns:
            Dictionary with anomaly detection results
        """
        logger.info(f"Using fallback detection for {metric_name}")
        
        # Calculate mean and std from historical data
        values = np.array([v for _, v in time_series])
        mean_value = np.mean(values)
        std_value = np.std(values)
        
        # Get current value
        current_value = prom_client.get_current_value(metric_name, aggregation='avg')
        if current_value is None:
            return None
        
        # Calculate deviation
        deviation = abs(current_value - mean_value)
        deviation_std = deviation / std_value if std_value > 0 else 0
        
        # Classify
        is_anomaly, severity, confidence = self.classify_anomaly(deviation_std)
        
        return {
            'timestamp': datetime.now().isoformat(),
            'metric': metric_name,
            'expected_value': float(mean_value),
            'actual_value': float(current_value),
            'deviation': float(deviation),
            'deviation_std': float(deviation_std),
            'is_anomaly': is_anomaly,
            'severity': severity,
            'confidence': float(confidence),
            'threshold': self.threshold,
            'method': 'fallback'
        }
