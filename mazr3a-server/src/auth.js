const crypto = require('crypto');

function requireApiKey(req, res, next) {
  const expected = process.env.API_KEY || '';
  const provided = String(req.get('x-api-key') || '');
  const a = Buffer.from(provided);
  const b = Buffer.from(expected);
  const ok = a.length === b.length && crypto.timingSafeEqual(a, b);
  if (!ok) {
    return res.status(401).json({ message: 'Invalid or missing API key', code: 'UNAUTHORIZED' });
  }
  return next();
}

module.exports = { requireApiKey };
