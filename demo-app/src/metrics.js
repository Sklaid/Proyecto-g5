const { metrics } = require('@opentelemetry/api');

// Get meter
const meter = metrics.getMeter('demo-app-metrics', '1.0.0');

// Custom metrics
const requestCounter = meter.createCounter('business.requests.total', {
  description: 'Total number of business requests',
});

const operationDuration = meter.createHistogram('business.operation.duration', {
  description: 'Duration of business operations in milliseconds',
  unit: 'ms',
});

const activeUsers = meter.createUpDownCounter('business.active_users', {
  description: 'Number of active users',
});

const productInventory = meter.createObservableGauge('business.product.inventory', {
  description: 'Current product inventory levels',
});

// Track product inventory
let products = [
  { id: 1, name: 'Laptop', stock: 50 },
  { id: 2, name: 'Mouse', stock: 200 },
  { id: 3, name: 'Keyboard', stock: 150 }
];

productInventory.addCallback((observableResult) => {
  products.forEach(product => {
    observableResult.observe(product.stock, { 
      product_id: product.id.toString(),
      product_name: product.name 
    });
  });
});

module.exports = {
  requestCounter,
  operationDuration,
  activeUsers,
  products,
};
