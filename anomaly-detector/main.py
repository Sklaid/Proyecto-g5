import logging
import sys
import time
from datetime import datetime
from config import Config

# Configure logging
logging.basicConfig(
    level=getattr(logging, Config.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

def run_detection_cycle(prom_client, detector, alert_manager):
    """
    Run a single detection cycle for all monitored metrics
    
    Args:
        prom_client: PrometheusQueryClient instance
        detector: AnomalyDetector instance
        alert_manager: AlertManager instance
    """
    logger.info("=" * 60)
    logger.info(f"Starting detection cycle at {datetime.now().isoformat()}")
    logger.info("=" * 60)
    
    anomalies_detected = 0
    alerts_sent = 0
    
    for metric in Config.METRICS_TO_MONITOR:
        try:
            logger.info(f"Analyzing metric: {metric}")
            
            # Detect anomalies
            result = detector.detect_anomaly(
                prom_client=prom_client,
                metric_name=metric,
                days=Config.HISTORICAL_DAYS
            )
            
            if result is None:
                logger.warning(f"Could not analyze {metric}, skipping")
                continue
            
            # Check if anomaly was detected
            if result.get('is_anomaly', False):
                anomalies_detected += 1
                logger.warning(f"Anomaly detected in {metric}")
                
                # Generate and send alert
                success = alert_manager.generate_and_send_alert(result)
                if success:
                    alerts_sent += 1
            else:
                logger.info(f"No anomaly detected in {metric}")
                
        except Exception as e:
            logger.error(f"Error analyzing {metric}: {e}", exc_info=True)
            continue
    
    logger.info("=" * 60)
    logger.info(
        f"Detection cycle completed: "
        f"{anomalies_detected} anomalies detected, "
        f"{alerts_sent} alerts sent"
    )
    logger.info("=" * 60)

def main():
    """Main entry point for the anomaly detector service"""
    logger.info("=" * 60)
    logger.info("Starting Anomaly Detector Service")
    logger.info("=" * 60)
    logger.info(f"Prometheus URL: {Config.PROMETHEUS_URL}")
    logger.info(f"Check interval: {Config.CHECK_INTERVAL_MINUTES} minutes")
    logger.info(f"Historical data window: {Config.HISTORICAL_DAYS} days")
    logger.info(f"Anomaly threshold: {Config.ANOMALY_THRESHOLD} standard deviations")
    logger.info(f"Metrics to monitor: {', '.join(Config.METRICS_TO_MONITOR)}")
    logger.info("=" * 60)
    
    # Import here to avoid circular dependencies
    from prometheus_client import PrometheusQueryClient
    from anomaly_detector import AnomalyDetector
    from alert_manager import AlertManager
    
    # Initialize components with retry logic
    max_retries = 5
    retry_delay = 10  # seconds
    
    for attempt in range(1, max_retries + 1):
        try:
            logger.info(f"Initialization attempt {attempt}/{max_retries}")
            
            # Initialize Prometheus client
            prom_client = PrometheusQueryClient(Config.PROMETHEUS_URL)
            
            # Perform health check
            if not prom_client.health_check():
                raise ConnectionError("Prometheus health check failed")
            
            logger.info("Successfully connected to Prometheus")
            break
            
        except Exception as e:
            logger.error(f"Initialization failed: {e}")
            
            if attempt < max_retries:
                logger.info(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                logger.error("Max retries reached. Exiting.")
                sys.exit(1)
    
    # Initialize anomaly detector
    detector = AnomalyDetector(
        threshold=Config.ANOMALY_THRESHOLD,
        min_data_points=100
    )
    
    # Initialize alert manager
    alert_manager = AlertManager(webhook_url=Config.ALERT_WEBHOOK_URL)
    
    logger.info("All components initialized successfully")
    logger.info("Starting detection loop...")
    
    # Main detection loop
    check_interval_seconds = Config.CHECK_INTERVAL_MINUTES * 60
    
    while True:
        try:
            # Run detection cycle
            run_detection_cycle(prom_client, detector, alert_manager)
            
            # Wait for next cycle
            logger.info(f"Waiting {Config.CHECK_INTERVAL_MINUTES} minutes until next check...")
            time.sleep(check_interval_seconds)
            
        except KeyboardInterrupt:
            logger.info("Received shutdown signal, exiting gracefully...")
            break
        except Exception as e:
            logger.error(f"Error in main loop: {e}", exc_info=True)
            logger.info(f"Retrying in {retry_delay} seconds...")
            time.sleep(retry_delay)
            
            # Verify Prometheus is still reachable
            try:
                if not prom_client.health_check():
                    logger.error("Lost connection to Prometheus, attempting to reconnect...")
                    prom_client = PrometheusQueryClient(Config.PROMETHEUS_URL)
            except Exception as reconnect_error:
                logger.error(f"Reconnection failed: {reconnect_error}")
    
    logger.info("Anomaly Detector Service stopped")

if __name__ == "__main__":
    main()
