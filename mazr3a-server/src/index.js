require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./app');
const { logError } = require('./log');

const { MONGODB_URI, API_KEY } = process.env;
const parsedPort = Number(process.env.PORT);
const PORT = Number.isInteger(parsedPort) && parsedPort > 0 ? parsedPort : 3000;

if (!MONGODB_URI || !API_KEY || String(API_KEY).length < 24) {
  console.error(
    'Refusing to start: MONGODB_URI is required and API_KEY must be at least 24 characters. See .env.example.'
  );
  process.exit(1);
}

let server;
let shuttingDown = false;

function shutdown(signal) {
  if (shuttingDown) return;
  shuttingDown = true;
  console.log(`Received ${signal}, shutting down`);
  const closeServer = () =>
    new Promise((resolve) => {
      if (!server) return resolve();
      server.close(() => resolve());
    });
  closeServer()
    .then(() => mongoose.connection.close())
    .then(() => process.exit(0))
    .catch((err) => {
      logError('Shutdown failed.', err);
      process.exit(1);
    });
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

mongoose
  .connect(MONGODB_URI, { serverSelectionTimeoutMS: 10000 })
  .then(() => {
    console.log('Connected to MongoDB');
    server = app.listen(PORT, () => console.log(`API listening on port ${PORT}`));
  })
  .catch((err) => {
    logError('Could not connect to MongoDB.', err);
    process.exit(1);
  });
