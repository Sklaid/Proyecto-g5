const request = require('supertest');
const app = require('./index');

describe('Health Check Endpoints', () => {
  describe('GET /health', () => {
    it('should return 200 status with healthy status', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(new Date(response.body.timestamp)).toBeInstanceOf(Date);
    });
  });

  describe('GET /ready', () => {
    it('should return 200 status with ready status', async () => {
      const response = await request(app).get('/ready');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'ready');
      expect(response.body).toHaveProperty('timestamp');
      expect(new Date(response.body.timestamp)).toBeInstanceOf(Date);
    });
  });
});

describe('User API Endpoints', () => {
  describe('GET /api/users', () => {
    it('should return 200 status with list of users', async () => {
      const response = await request(app).get('/api/users');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('users');
      expect(response.body).toHaveProperty('count');
      expect(Array.isArray(response.body.users)).toBe(true);
      expect(response.body.count).toBe(response.body.users.length);
    });

    it('should return users with correct structure', async () => {
      const response = await request(app).get('/api/users');
      
      expect(response.status).toBe(200);
      const users = response.body.users;
      
      if (users.length > 0) {
        expect(users[0]).toHaveProperty('id');
        expect(users[0]).toHaveProperty('name');
        expect(users[0]).toHaveProperty('email');
      }
    });

    it('should return JSON content type', async () => {
      const response = await request(app).get('/api/users');
      
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toMatch(/json/);
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return 200 status with user when valid id is provided', async () => {
      const response = await request(app).get('/api/users/1');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('id', 1);
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('email');
    });

    it('should return 404 status when user not found', async () => {
      const response = await request(app).get('/api/users/999');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'User not found');
    });

    it('should return 404 for invalid user id', async () => {
      const response = await request(app).get('/api/users/0');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });
});

describe('Product API Endpoints', () => {
  describe('GET /api/products', () => {
    it('should return 200 status with list of products', async () => {
      const response = await request(app).get('/api/products');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('products');
      expect(response.body).toHaveProperty('count');
      expect(Array.isArray(response.body.products)).toBe(true);
      expect(response.body.count).toBe(response.body.products.length);
    });

    it('should return products with correct structure', async () => {
      const response = await request(app).get('/api/products');
      
      expect(response.status).toBe(200);
      const products = response.body.products;
      
      if (products.length > 0) {
        expect(products[0]).toHaveProperty('id');
        expect(products[0]).toHaveProperty('name');
        expect(products[0]).toHaveProperty('price');
        expect(products[0]).toHaveProperty('stock');
      }
    });

    it('should return JSON content type', async () => {
      const response = await request(app).get('/api/products');
      
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toMatch(/json/);
    });
  });

  describe('GET /api/products/:id', () => {
    it('should return 200 status with product when valid id is provided', async () => {
      const response = await request(app).get('/api/products/1');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('id', 1);
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('price');
      expect(response.body).toHaveProperty('stock');
    });

    it('should return 404 status when product not found', async () => {
      const response = await request(app).get('/api/products/999');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Product not found');
    });

    it('should return 404 for invalid product id', async () => {
      const response = await request(app).get('/api/products/0');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });
});

describe('Error Simulation Endpoints', () => {
  describe('GET /api/error/500', () => {
    it('should return 500 status with error message', async () => {
      const response = await request(app).get('/api/error/500');
      
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error', 'Internal server error simulation');
    });
  });

  describe('GET /api/error/exception', () => {
    it('should return 500 status when exception is thrown', async () => {
      const response = await request(app).get('/api/error/exception');
      
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error');
      expect(response.body).toHaveProperty('code');
    });

    it('should return error with SIMULATED_ERROR code', async () => {
      const response = await request(app).get('/api/error/exception');
      
      expect(response.status).toBe(500);
      expect(response.body.code).toBe('SIMULATED_ERROR');
    });
  });
});

describe('Edge Cases and Error Handling', () => {
  describe('404 Not Found', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app).get('/api/nonexistent');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Route not found');
    });

    it('should return 404 for invalid API paths', async () => {
      const response = await request(app).get('/invalid/path');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('Invalid Input Handling', () => {
    it('should handle non-numeric user id gracefully', async () => {
      const response = await request(app).get('/api/users/abc');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });

    it('should handle non-numeric product id gracefully', async () => {
      const response = await request(app).get('/api/products/xyz');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });

    it('should handle negative user id', async () => {
      const response = await request(app).get('/api/users/-1');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });

    it('should handle negative product id', async () => {
      const response = await request(app).get('/api/products/-1');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('Response Format Validation', () => {
    it('should always return JSON for API endpoints', async () => {
      const endpoints = [
        '/api/users',
        '/api/products',
        '/api/users/1',
        '/api/products/1',
        '/api/error/500'
      ];

      for (const endpoint of endpoints) {
        const response = await request(app).get(endpoint);
        expect(response.headers['content-type']).toMatch(/json/);
      }
    });

    it('should return valid JSON even for error responses', async () => {
      const response = await request(app).get('/api/users/999');
      
      expect(response.status).toBe(404);
      expect(() => JSON.parse(JSON.stringify(response.body))).not.toThrow();
    });
  });

  describe('Concurrent Requests', () => {
    it('should handle multiple concurrent requests to /api/users', async () => {
      const requests = Array(5).fill(null).map(() => 
        request(app).get('/api/users')
      );
      
      const responses = await Promise.all(requests);
      
      responses.forEach(response => {
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('users');
      });
    });

    it('should handle mixed concurrent requests', async () => {
      const requests = [
        request(app).get('/api/users'),
        request(app).get('/api/products'),
        request(app).get('/api/users/1'),
        request(app).get('/api/products/1'),
        request(app).get('/health')
      ];
      
      const responses = await Promise.all(requests);
      
      responses.forEach(response => {
        expect(response.status).toBe(200);
      });
    });
  });
});
