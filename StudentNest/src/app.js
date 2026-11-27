require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');

if (!process.env.JWT_SECRET) {
  // Without a secret every token is signed/verified with `undefined`; refuse to start.
  console.error('JWT_SECRET is not set. Refusing to start.');
  process.exit(1);
}

const { prepareDatabase } = require('./services/schemaService');
const { startListingExpiryJob } = require('./services/listingExpiryService');

const PUBLIC_DIR = path.join(__dirname, '../public');
const ADMIN_INDEX = path.join(PUBLIC_DIR, 'admin/index.html');

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
app.use(express.urlencoded({ extended: false }));
app.use(express.static(PUBLIC_DIR));

// API routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/properties', require('./routes/properties'));
app.use('/api/photos', require('./routes/photos'));
app.use('/api/admin', require('./routes/admin'));

app.use('/api', (req, res) => {
  res.status(404).json({ message: 'Endpoint not found' });
});

// Admin dashboard (static single page)
app.get('/admin', (req, res) => res.sendFile(ADMIN_INDEX));
app.post('/admin', (req, res) => res.sendFile(ADMIN_INDEX));

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Student Nest API is running' });
});

// Last-resort error handler: never leak stack traces or internals to clients.
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ message: status < 500 ? err.message : 'Server error' });
});

const start = async () => {
  try {
    await prepareDatabase();
  } catch (err) {
    // Keep serving (e.g. the health check) even if a migration fails; it is logged for follow-up.
    console.error('Failed to prepare database:', err);
  }

  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    startListingExpiryJob();
  });
};

if (require.main === module) {
  start();
}

module.exports = app;
