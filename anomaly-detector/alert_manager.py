import logging
import json
import requests
from typing import Dict, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class AlertManager:
    """Manages alert generation and notification"""
    
    def __init__(self, webhook_url: str):
        """
        Initialize alert manager
        
        Args:
            webhook_url: URL to send alert webhooks
        """
        self.webhook_url = webhook_url
        logger.info(f"Initialized AlertManager with webhook URL: {webhook_url}")
    
    def format_alert_payload(
        self,
        anomaly_result: Dict,
        service_name: str = 'demo-app'
    ) -> Dict:
        """
        Format anomaly detection result into alert payload
        
        Args:
            anomaly_result: Result from anomaly detection
            service_name: Name of the service being monitored
            
        Returns:
            Formatted alert payload
        """
        # Extract key information
        metric = anomaly_result.get('metric', 'unknown')
        actual_value = anomaly_result.get('actual_value', 0)
        expected_value = anomaly_result.get('expected_value', 0)
        deviation = anomaly_result.get('deviation', 0)
        deviation_std = anomaly_result.get('deviation_std', 0)
        severity = anomaly_result.get('severity', 'medium')
        confidence = anomaly_result.get('confidence', 0)
        timestamp = anomaly_result.get('timestamp', datetime.now().isoformat())
        
        # Build alert title
        title = f"Anomaly Detected: {metric}"
        
        # Build alert description
        description = (
            f"An anomaly has been detected in metric '{metric}' for service '{service_name}'.\n\n"
            f"**Details:**\n"
            f"- Expected Value: {expected_value:.2f}\n"
            f"- Actual Value: {actual_value:.2f}\n"
            f"- Deviation: {deviation:.2f} ({deviation_std:.2f} standard deviations)\n"
            f"- Severity: {severity}\n"
            f"- Confidence: {confidence:.2%}\n"
            f"- Timestamp: {timestamp}\n\n"
            f"**Context:**\n"
            f"The current value deviates significantly from the predicted value based on "
            f"historical patterns. This may indicate a performance degradation or anomalous behavior."
        )
        
        # Build alert payload (Grafana-compatible format)
        payload = {
            'title': title,
            'message': description,
            'severity': severity,
            'tags': {
                'service': service_name,
                'metric': metric,
                'anomaly_type': 'ml_detection',
                'source': 'anomaly_detector'
            },
            'annotations': {
                'expected_value': str(expected_value),
                'actual_value': str(actual_value),
                'deviation': str(deviation),
                'deviation_std': str(deviation_std),
                'confidence': str(confidence),
                'timestamp': timestamp
            },
            'state': 'alerting',
            'evalMatches': [
                {
                    'metric': metric,
                    'value': actual_value,
                    'tags': {
                        'service': service_name
                    }
                }
            ]
        }
        
        logger.debug(f"Formatted alert payload for {metric}")
        return payload
    
    def send_webhook(self, payload: Dict) -> bool:
        """
        Send alert webhook to configured endpoint
        
        Args:
            payload: Alert payload to send
            
        Returns:
            True if webhook was sent successfully, False otherwise
        """
        try:
            logger.info(f"Sending alert webhook to {self.webhook_url}")
            
            response = requests.post(
                self.webhook_url,
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code in [200, 201, 202]:
                logger.info(f"Alert webhook sent successfully: {response.status_code}")
                return True
            else:
                logger.warning(
                    f"Alert webhook returned non-success status: {response.status_code} - {response.text}"
                )
                return False
                
        except requests.exceptions.Timeout:
            logger.error("Alert webhook timed out")
            return False
        except requests.exceptions.ConnectionError as e:
            logger.error(f"Alert webhook connection error: {e}")
            return False
        except Exception as e:
            logger.error(f"Error sending alert webhook: {e}")
            return False
    
    def log_anomaly(self, anomaly_result: Dict, service_name: str = 'demo-app'):
        """
        Log detected anomaly with full context
        
        Args:
            anomaly_result: Result from anomaly detection
            service_name: Name of the service being monitored
        """
        metric = anomaly_result.get('metric', 'unknown')
        severity = anomaly_result.get('severity', 'medium')
        actual_value = anomaly_result.get('actual_value', 0)
        expected_value = anomaly_result.get('expected_value', 0)
        deviation_std = anomaly_result.get('deviation_std', 0)
        
        log_message = (
            f"ANOMALY DETECTED | "
            f"Service: {service_name} | "
            f"Metric: {metric} | "
            f"Severity: {severity} | "
            f"Actual: {actual_value:.2f} | "
            f"Expected: {expected_value:.2f} | "
            f"Deviation: {deviation_std:.2f} std"
        )
        
        # Log at appropriate level based on severity
        if severity == 'critical':
            logger.critical(log_message)
        elif severity == 'high':
            logger.error(log_message)
        elif severity == 'medium':
            logger.warning(log_message)
        else:
            logger.info(log_message)
    
    def generate_and_send_alert(
        self,
        anomaly_result: Dict,
        service_name: str = 'demo-app'
    ) -> bool:
        """
        Complete alert generation and notification pipeline
        
        Args:
            anomaly_result: Result from anomaly detection
            service_name: Name of the service being monitored
            
        Returns:
            True if alert was sent successfully, False otherwise
        """
        # Log the anomaly
        self.log_anomaly(anomaly_result, service_name)
        
        # Format alert payload
        payload = self.format_alert_payload(anomaly_result, service_name)
        
        # Send webhook
        success = self.send_webhook(payload)
        
        if success:
            logger.info(f"Alert generated and sent for {anomaly_result.get('metric')}")
        else:
            logger.error(f"Failed to send alert for {anomaly_result.get('metric')}")
        
        return success
