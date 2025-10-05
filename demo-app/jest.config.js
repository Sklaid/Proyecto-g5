module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/tracing.js',
    '!src/**/*.test.js'
  ],
  testMatch: [
    '**/__tests__/**/*.js',
    '**/?(*.)+(spec|test).js'
  ],
  testTimeout: 30000, // 30 seconds for integration tests that wait for Prometheus scrape (15s interval)
  verbose: true,
  setupFiles: ['<rootDir>/jest.setup.js']
};
