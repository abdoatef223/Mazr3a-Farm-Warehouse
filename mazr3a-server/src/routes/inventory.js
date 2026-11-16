const express = require('express');
const Inbound = require('../models/inbound');
const Outbound = require('../models/outbound');
const { inventoryGroupKey } = require('../normalize');
const { round2, roundQty } = require('../validation');

const router = express.Router();

function isNewer(record, previous) {
  if (!previous) return true;
  const byDate = new Date(record.date) - new Date(previous.date);
  if (byDate !== 0) return byDate > 0;
  return new Date(record.updatedAt) - new Date(previous.updatedAt) > 0;
}

router.get('/', async (req, res, next) => {
  try {
    const active = { deletedAt: null };
    const [inbound, outbound] = await Promise.all([
      Inbound.find(active).lean(),
      Outbound.find(active).lean(),
    ]);

    const groups = new Map();
    const ensure = (name, type, unit) => {
      const key = inventoryGroupKey(name, type, unit);
      let group = groups.get(key);
      if (!group) {
        group = {
          product: name,
          type,
          unit,
          totalIn: 0,
          totalOut: 0,
          totalInValue: 0,
          lastPrice: 0,
          latestIn: null,
          latestOut: null,
        };
        groups.set(key, group);
      }
      return group;
    };

    for (const rec of inbound) {
      const group = ensure(rec.itemName, rec.type, rec.unit);
      group.totalIn += rec.quantity;
      group.totalInValue += rec.total;
      if (isNewer(rec, group.latestIn)) {
        group.latestIn = rec;
        group.product = rec.itemName;
        group.type = rec.type;
        group.unit = rec.unit;
        group.lastPrice = rec.unitPrice;
      }
    }

    for (const rec of outbound) {
      const group = ensure(rec.product, rec.type, rec.unit);
      group.totalOut += rec.quantity;
      if (!group.latestIn && isNewer(rec, group.latestOut)) {
        group.latestOut = rec;
        group.product = rec.product;
        group.type = rec.type;
        group.unit = rec.unit;
      }
    }

    const items = [...groups.values()].map((group) => {
      const totalIn = roundQty(group.totalIn);
      const totalOut = roundQty(group.totalOut);
      const inStock = roundQty(totalIn - totalOut);
      const avgPrice = totalIn > 0 ? round2(group.totalInValue / totalIn) : 0;
      return {
        product: group.product,
        type: group.type,
        unit: group.unit,
        totalIn,
        totalOut,
        inStock,
        lastPrice: round2(group.lastPrice || 0),
        avgPrice,
        stockValue: round2(Math.max(inStock, 0) * avgPrice),
      };
    });

    items.sort(
      (a, b) => a.product.localeCompare(b.product) || a.type.localeCompare(b.type) || a.unit.localeCompare(b.unit)
    );
    res.json({ items });
  } catch (e) {
    next(e);
  }
});

module.exports = router;
