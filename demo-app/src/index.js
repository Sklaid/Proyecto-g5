const express = require('express');
const { trace, context, SpanStatusCode } = require('@opentelemetry/api');
const { requestCounter, operationDuration, activeUsers } = require('./metrics');
const promClient = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Configure prom-client to collect default Node.js metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ 
  register,
  prefix: 'nodejs_',
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
  eventLoopMonitoringPrecision: 10
});

// Get tracer
const tracer = trace.getTracer('demo-app-tracer', '1.0.0');

// Middleware
app.use(express.json());

// In-memory data stores
const users = [
  { id: 1, name: 'Alice Johnson', email: 'alice@example.com' },
  { id: 2, name: 'Bob Smith', email: 'bob@example.com' },
  { id: 3, name: 'Charlie Brown', email: 'charlie@example.com' }
];

const products = [
  { id: 1, name: 'Laptop', price: 999.99, stock: 50 },
  { id: 2, name: 'Mouse', price: 29.99, stock: 200 },
  { id: 3, name: 'Keyboard', price: 79.99, stock: 150 }
];

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready', timestamp: new Date().toISOString() });
});

// API endpoints - Users
app.get('/api/users', (req, res) => {
  const span = tracer.startSpan('fetch_users_operation');
  const startTime = Date.now();
  
  // Add span attributes
  span.setAttribute('operation.type', 'database_query');
  span.setAttribute('user.count', users.length);
  
  // Record custom metric
  requestCounter.add(1, { endpoint: '/api/users', method: 'GET' });
  
  // Simulate some processing time
  setTimeout(() => {
    const duration = Date.now() - startTime;
    
    // Record operation duration
    operationDuration.record(duration, { operation: 'fetch_users' });
    
    // Add span event
    span.addEvent('users_fetched', { count: users.length });
    
    span.setStatus({ code: SpanStatusCode.OK });
    span.end();
    
    res.json({ users, count: users.length });
  }, Math.random() * 100);
});

app.get('/api/users/:id', (req, res) => {
  const span = tracer.startSpan('fetch_user_by_id');
  const userId = parseInt(req.params.id);
  
  span.setAttribute('user.id', userId);
  requestCounter.add(1, { endpoint: '/api/users/:id', method: 'GET' });
  
  const user = users.find(u => u.id === userId);
  
  if (!user) {
    span.setStatus({ code: SpanStatusCode.ERROR, message: 'User not found' });
    span.end();
    return res.status(404).json({ error: 'User not found' });
  }
  
  span.addEvent('user_found', { user_id: userId });
  span.setStatus({ code: SpanStatusCode.OK });
  span.end();
  
  res.json(user);
});

// API endpoints - Products
app.get('/api/products', (req, res) => {
  const span = tracer.startSpan('fetch_products_operation');
  const startTime = Date.now();
  
  span.setAttribute('operation.type', 'inventory_query');
  span.setAttribute('product.count', products.length);
  
  requestCounter.add(1, { endpoint: '/api/products', method: 'GET' });
  
  // Simulate some processing time
  setTimeout(() => {
    const duration = Date.now() - startTime;
    operationDuration.record(duration, { operation: 'fetch_products' });
    
    span.addEvent('products_fetched', { count: products.length });
    span.setStatus({ code: SpanStatusCode.OK });
    span.end();
    
    res.json({ products, count: products.length });
  }, Math.random() * 100);
});

app.get('/api/products/:id', (req, res) => {
  const span = tracer.startSpan('fetch_product_by_id');
  const productId = parseInt(req.params.id);
  
  span.setAttribute('product.id', productId);
  requestCounter.add(1, { endpoint: '/api/products/:id', method: 'GET' });
  
  const product = products.find(p => p.id === productId);
  
  if (!product) {
    span.setStatus({ code: SpanStatusCode.ERROR, message: 'Product not found' });
    span.end();
    return res.status(404).json({ error: 'Product not found' });
  }
  
  span.addEvent('product_found', { product_id: productId, stock: product.stock });
  span.setStatus({ code: SpanStatusCode.OK });
  span.end();
  
  res.json(product);
});

// Error simulation endpoints
app.get('/api/error/500', (req, res) => {
  const span = tracer.startSpan('error_500_simulation');
  span.setAttribute('error.type', 'simulated_500');
  span.setStatus({ code: SpanStatusCode.ERROR, message: 'Simulated 500 error' });
  span.end();
  
  requestCounter.add(1, { endpoint: '/api/error/500', method: 'GET', status: '500' });
  res.status(500).json({ error: 'Internal server error simulation' });
});

app.get('/api/error/timeout', (req, res) => {
  // Simulate a slow endpoint that times out
  setTimeout(() => {
    res.status(200).json({ message: 'This took too long' });
  }, 5000);
});

app.get('/api/error/exception', (req, res, next) => {
  const span = tracer.startSpan('exception_simulation');
  span.setAttribute('error.type', 'simulated_exception');
  
  // Simulate an unhandled exception
  const error = new Error('Simulated exception for testing');
  error.code = 'SIMULATED_ERROR';
  
  span.recordException(error);
  span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
  span.end();
  
  requestCounter.add(1, { endpoint: '/api/error/exception', method: 'GET', status: 'error' });
  next(error);
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  
  const span = trace.getActiveSpan();
  if (span) {
    span.recordException(err);
    span.setStatus({ code: SpanStatusCode.ERROR, message: err.message });
  }
  
  res.status(500).json({ 
    error: err.message,
    code: err.code || 'INTERNAL_ERROR'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server only if not in test mode
if (process.env.NODE_ENV !== 'test') {
  const server = app.listen(PORT, () => {
    console.log(`Demo app listening on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`Ready check: http://localhost:${PORT}/ready`);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
    });
  });
}

module.exports = app;