const express = require('express');
const { calcTotal, parseListQuery, sendValidationError } = require('../validation');
const { toPublic } = require('../present');

function createRecordsRouter(Model, schema) {
  const router = express.Router();

  router.get('/', async (req, res, next) => {
    const parsed = parseListQuery(req.query);
    if (!parsed.success) return sendValidationError(res, parsed.error);
    const { limit, page } = parsed.data;
    try {
      const filter = { deletedAt: null };
      const [items, total] = await Promise.all([
        Model.find(filter)
          .sort({ date: -1, createdAt: -1 })
          .skip((page - 1) * limit)
          .limit(limit)
          .lean(),
        Model.countDocuments(filter),
      ]);
      res.json({ items: items.map(toPublic), page, limit, total });
    } catch (e) {
      next(e);
    }
  });

  router.post('/', async (req, res, next) => {
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) return sendValidationError(res, parsed.error);
    const data = parsed.data;
    data.total = calcTotal(data.quantity, data.unitPrice);
    try {
      const existing = await Model.findOne({ clientId: data.clientId }).lean();
      if (existing) return res.status(200).json(toPublic(existing));
      try {
        const created = await Model.create(data);
        return res.status(201).json(toPublic(created));
      } catch (e) {
        if (e && e.code === 11000) {
          const again = await Model.findOne({ clientId: data.clientId }).lean();
          if (again) return res.status(200).json(toPublic(again));
        }
        throw e;
      }
    } catch (e) {
      return next(e);
    }
  });

  router.delete('/:clientId', async (req, res, next) => {
    try {
      await Model.updateOne(
        { clientId: req.params.clientId, deletedAt: null },
        { $set: { deletedAt: new Date() } },
        { timestamps: true }
      );
      res.status(200).json({ ok: true });
    } catch (e) {
      next(e);
    }
  });

  return router;
}

module.exports = { createRecordsRouter };
