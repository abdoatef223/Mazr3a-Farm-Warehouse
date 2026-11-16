const express = require('express');
const Inbound = require('../models/inbound');
const Outbound = require('../models/outbound');
const { round2 } = require('../validation');

const router = express.Router();

router.get('/summary', async (req, res, next) => {
  try {
    const active = { $match: { deletedAt: null } };
    const [inb, outb, pay] = await Promise.all([
      Inbound.aggregate([active, { $group: { _id: null, value: { $sum: '$total' }, count: { $sum: 1 } } }]),
      Outbound.aggregate([active, { $group: { _id: null, value: { $sum: '$total' }, count: { $sum: 1 } } }]),
      Inbound.aggregate([active, { $group: { _id: '$paymentType', count: { $sum: 1 } } }]),
    ]);
    const totalInboundValue = round2(inb[0]?.value || 0);
    const totalOutboundValue = round2(outb[0]?.value || 0);
    const countOf = (k) => pay.find((p) => p._id === k)?.count || 0;
    res.json({
      totalInboundValue,
      inboundCount: inb[0]?.count || 0,
      totalOutboundValue,
      outboundCount: outb[0]?.count || 0,
      cashCount: countOf('cash'),
      deferredCount: countOf('deferred'),
      netInventoryValue: round2(totalInboundValue - totalOutboundValue),
    });
  } catch (e) {
    next(e);
  }
});

module.exports = router;
