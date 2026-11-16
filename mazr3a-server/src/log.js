function logError(prefix, err) {
  let msg = err instanceof Error ? err.message : String(err || '');
  msg = msg.replace(/mongodb(?:\+srv)?:\/\/\S+/gi, 'mongodb://[redacted]');
  console.error(prefix, msg);
}

module.exports = { logError };
