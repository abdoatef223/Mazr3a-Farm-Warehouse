const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const mongoose = require('mongoose');

const { requireApiKey } = require('./auth');
const { inboundSchema, outboundSchema } = require('./validation');
const Inbound = require('./models/inbound');
const Outbound = require('./models/outbound');
const { createRecordsRouter } = require('./routes/records');
const syncRouter = require('./routes/sync');
const dashboardRouter = require('./routes/dashboard');
const inventoryRouter = require('./routes/inventory');
const { logError } = require('./log');

const httpLog = morgan('tiny');

const app = express();
app.set('trust proxy', 1);
app.use(helmet());
app.use(cors());
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'test') return next();
  return httpLog(req, res, next);
});
app.use(express.json({ limit: '200kb' }));
app.use(
  rateLimit({
    windowMs: 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false,
    handler(req, res) {
      res.status(429).json({ message: 'Too many requests', code: 'RATE_LIMITED' });
    },
  })
);

app.get('/health', (req, res) => {
  const dbReady = mongoose.connection.readyState === 1;
  res.status(dbReady ? 200 : 503).json({ status: dbReady ? 'ok' : 'db_unavailable' });
});

const api = express.Router();
api.use(requireApiKey);
api.use('/inbound', createRecordsRouter(Inbound, inboundSchema));
api.use('/outbound', createRecordsRouter(Outbound, outboundSchema));
api.use('/sync', syncRouter);
api.use('/dashboard', dashboardRouter);
api.use('/inventory', inventoryRouter);
app.use('/api/v1', api);

app.use((req, res) => res.status(404).json({ message: 'Not found', code: 'NOT_FOUND' }));

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (res.headersSent) return next(err);
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ message: 'Invalid JSON body', code: 'BAD_JSON' });
  }
  if (err.type === 'entity.too.large') {
    return res.status(413).json({ message: 'Request body too large', code: 'PAYLOAD_TOO_LARGE' });
  }
  logError('Request failed.', err);
  return res.status(500).json({ message: 'Internal server error', code: 'SERVER_ERROR' });
});

module.exports = app;
