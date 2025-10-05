import logging
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import requests
from prometheus_api_client import PrometheusConnect

logger = logging.getLogger(__name__)

class PrometheusQueryClient:
    """Client for querying Prometheus metrics"""
    
    def __init__(self, prometheus_url: str):
        """
        Initialize Prometheus client
        
        Args:
            prometheus_url: URL of the Prometheus server
        """
        self.prometheus_url = prometheus_url
        self.client = PrometheusConnect(url=prometheus_url, disable_ssl=True)
        logger.info(f"Initialized Prometheus client for {prometheus_url}")
    
    def query_range(
        self,
        query: str,
        start_time: datetime,
        end_time: datetime,
        step: str = '1m'
    ) -> Optional[List[Dict]]:
        """
        Query Prometheus for a range of time
        
        Args:
            query: PromQL query string
            start_time: Start time for the query
            end_time: End time for the query
            step: Query resolution step
            
        Returns:
            List of metric data points or None if query fails
        """
        try:
            result = self.client.custom_query_range(
                query=query,
                start_time=start_time,
                end_time=end_time,
                step=step
            )
            
            if not result:
                logger.warning(f"No data returned for query: {query}")
                return None
            
            logger.debug(f"Query returned {len(result)} series")
            return result
            
        except Exception as e:
            logger.error(f"Error querying Prometheus: {e}")
            return None
    
    def get_metric_history(
        self,
        metric_name: str,
        days: int = 7,
        aggregation: str = 'avg'
    ) -> Optional[List[tuple]]:
        """
        Get historical data for a specific metric
        
        Args:
            metric_name: Name of the metric to query
            days: Number of days of historical data
            aggregation: Aggregation function (avg, max, min, sum)
            
        Returns:
            List of (timestamp, value) tuples or None if query fails
        """
        end_time = datetime.now()
        start_time = end_time - timedelta(days=days)
        
        # Build PromQL query with aggregation
        query = f'{aggregation}({metric_name})'
        
        result = self.query_range(
            query=query,
            start_time=start_time,
            end_time=end_time,
            step='5m'
        )
        
        if not result:
            return None
        
        # Extract time series data
        time_series = []
        for series in result:
            values = series.get('values', [])
            for timestamp, value in values:
                try:
                    time_series.append((timestamp, float(value)))
                except (ValueError, TypeError) as e:
                    logger.warning(f"Invalid value in series: {e}")
                    continue
        
        if not time_series:
            logger.warning(f"No valid data points for metric: {metric_name}")
            return None
        
        # Sort by timestamp
        time_series.sort(key=lambda x: x[0])
        
        logger.info(f"Retrieved {len(time_series)} data points for {metric_name}")
        return time_series
    
    def get_current_value(self, metric_name: str, aggregation: str = 'avg') -> Optional[float]:
        """
        Get the current value of a metric
        
        Args:
            metric_name: Name of the metric to query
            aggregation: Aggregation function (avg, max, min, sum)
            
        Returns:
            Current metric value or None if query fails
        """
        query = f'{aggregation}({metric_name})'
        
        try:
            result = self.client.custom_query(query=query)
            
            if not result:
                logger.warning(f"No current data for metric: {metric_name}")
                return None
            
            # Get the first result value
            value = float(result[0]['value'][1])
            logger.debug(f"Current value for {metric_name}: {value}")
            return value
            
        except Exception as e:
            logger.error(f"Error getting current value: {e}")
            return None
    
    def health_check(self) -> bool:
        """
        Check if Prometheus is reachable
        
        Returns:
            True if Prometheus is healthy, False otherwise
        """
        try:
            response = requests.get(f"{self.prometheus_url}/-/healthy", timeout=5)
            is_healthy = response.status_code == 200
            
            if is_healthy:
                logger.debug("Prometheus health check passed")
            else:
                logger.warning(f"Prometheus health check failed: {response.status_code}")
            
            return is_healthy
            
        except Exception as e:
            logger.error(f"Prometheus health check error: {e}")
            return False
