import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuration for the anomaly detector service"""
    
    # Prometheus configuration
    PROMETHEUS_URL = os.getenv('PROMETHEUS_URL', 'http://prometheus:9090')
    
    # Detection configuration
    CHECK_INTERVAL_MINUTES = int(os.getenv('CHECK_INTERVAL_MINUTES', '5'))
    HISTORICAL_DAYS = int(os.getenv('HISTORICAL_DAYS', '7'))
    ANOMALY_THRESHOLD = float(os.getenv('ANOMALY_THRESHOLD', '2.5'))
    
    # Alert configuration
    ALERT_WEBHOOK_URL = os.getenv('ALERT_WEBHOOK_URL', 'http://grafana:3000/api/alerts')
    
    # Metrics to monitor
    METRICS_TO_MONITOR = [
        'http_server_request_duration_seconds',
        'http_server_requests_total',
        'http_server_errors_total'
    ]
    
    # Logging
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
