const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
require('dotenv').config();

const app = express();

// Middleware
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", 'https://fonts.googleapis.com'],
        fontSrc: ["'self'", 'https://fonts.gstatic.com'],
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: ["'self'"],
      },
    },
  })
);
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/properties', require('./routes/properties'));
app.use('/api/photos', require('./routes/photos'));
app.use('/api/admin', require('./routes/admin'));

app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin/index.html'));
});

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Student Nest API is running' });
});

// Database connection
require('./config/db');
const { startListingExpiryJob } = require('./services/listingExpiryService');
const { ensureAdminLogsTable } = require('./services/adminLogService');
const { ensureAdminAccessLevels } = require('./services/adminAccessService');

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  ensureAdminLogsTable().catch((err) => {
    console.error('Failed to prepare admin logs table:', err);
  });
  ensureAdminAccessLevels().catch((err) => {
    console.error('Failed to prepare admin access levels:', err);
  });
  startListingExpiryJob();
});

module.exports = app;
