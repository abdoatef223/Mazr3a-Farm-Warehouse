const express = require('express');
const Inbound = require('../models/inbound');
const Outbound = require('../models/outbound');
const { parseSyncQuery, sendValidationError } = require('../validation');
const { toPublic } = require('../present');

const router = express.Router();

function timeOf(value) {
  return new Date(value).getTime();
}

function mergeRows(inbound, outbound) {
  const rows = [
    ...inbound.map((doc) => ({ kind: 'inbound', doc })),
    ...outbound.map((doc) => ({ kind: 'outbound', doc })),
  ];
  rows.sort((a, b) => {
    const byTime = timeOf(a.doc.updatedAt) - timeOf(b.doc.updatedAt);
    if (byTime !== 0) return byTime;
    const byKind = a.kind.localeCompare(b.kind);
    if (byKind !== 0) return byKind;
    return String(a.doc.clientId).localeCompare(String(b.doc.clientId));
  });
  return rows;
}

function takePage(rows, limit) {
  if (rows.length <= limit) return { page: rows, hasMore: false, expandTie: false };
  const boundary = timeOf(rows[limit].doc.updatedAt);
  if (timeOf(rows[limit - 1].doc.updatedAt) !== boundary) {
    return { page: rows.slice(0, limit), hasMore: true, expandTie: false };
  }
  let cut = limit;
  while (cut > 0 && timeOf(rows[cut - 1].doc.updatedAt) === boundary) cut -= 1;
  if (cut === 0) {
    return { page: [], hasMore: true, expandTie: true, tieAt: rows[0].doc.updatedAt };
  }
  return { page: rows.slice(0, cut), hasMore: true, expandTie: false };
}

router.get('/changes', async (req, res, next) => {
  const parsed = parseSyncQuery(req.query);
  if (!parsed.success) return sendValidationError(res, parsed.error);

  const serverTime = new Date();
  const { limit } = parsed.data;
  const since = parsed.data.since ? new Date(parsed.data.since) : null;
  const until = parsed.data.until ? new Date(parsed.data.until) : null;

  const range = {};
  if (since) range.$gt = since;
  if (until) range.$lte = until;
  const filter = Object.keys(range).length ? { updatedAt: range } : {};

  try {
    const cap = limit + 1;
    const [inboundDocs, outboundDocs] = await Promise.all([
      Inbound.find(filter).sort({ updatedAt: 1, clientId: 1 }).limit(cap).lean(),
      Outbound.find(filter).sort({ updatedAt: 1, clientId: 1 }).limit(cap).lean(),
    ]);
    const fetchedAll = inboundDocs.length <= limit && outboundDocs.length <= limit;
    const rows = mergeRows(inboundDocs, outboundDocs);
    const decision = takePage(rows, limit);
    let page = decision.page;
    let hasMore = decision.hasMore;

    if (decision.expandTie) {
      const ts = new Date(decision.tieAt);
      const newer = { $gt: ts };
      if (until) newer.$lte = until;
      const [allIn, allOut, newerIn, newerOut] = await Promise.all([
        Inbound.find({ ...filter, updatedAt: ts }).lean(),
        Outbound.find({ ...filter, updatedAt: ts }).lean(),
        Inbound.countDocuments({ updatedAt: newer }),
        Outbound.countDocuments({ updatedAt: newer }),
      ]);
      page = mergeRows(allIn, allOut);
      hasMore = newerIn + newerOut > 0;
    } else if (!fetchedAll && page.length === rows.length) {
      hasMore = true;
    }

    const body = {
      inbound: page.filter((row) => row.kind === 'inbound').map((row) => toPublic(row.doc)),
      outbound: page.filter((row) => row.kind === 'outbound').map((row) => toPublic(row.doc)),
      serverTime: serverTime.toISOString(),
      hasMore,
    };
    if (hasMore && page.length) {
      body.nextSince = new Date(page[page.length - 1].doc.updatedAt).toISOString();
    }
    return res.json(body);
  } catch (e) {
    return next(e);
  }
});

module.exports = router;
