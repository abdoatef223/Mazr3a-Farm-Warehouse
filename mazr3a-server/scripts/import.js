const fs = require('fs/promises');
const path = require('path');
const crypto = require('crypto');
const { connect, disconnect } = require('./db');
const { inboundSchema, outboundSchema, calcTotal } = require('../src/validation');
const Inbound = require('../src/models/inbound');
const Outbound = require('../src/models/outbound');
const { logError } = require('../src/log');

function splitMixed(records) {
  const inbound = [];
  const outbound = [];
  for (const record of records) {
    const outboundOnly =
      record &&
      typeof record === 'object' &&
      !Array.isArray(record) &&
      record.product != null &&
      record.itemName == null &&
      record.category == null &&
      record.supplier == null;
    if (outboundOnly) outbound.push(record);
    else inbound.push(record);
  }
  return { inbound, outbound };
}

function splitRecords(payload) {
  if (Array.isArray(payload)) return splitMixed(payload);
  if (!payload || typeof payload !== 'object') {
    throw new Error('JSON root must be an object or an array');
  }
  if (Array.isArray(payload.inbound) || Array.isArray(payload.outbound)) {
    return {
      inbound: Array.isArray(payload.inbound) ? payload.inbound : [],
      outbound: Array.isArray(payload.outbound) ? payload.outbound : [],
    };
  }
  if (Array.isArray(payload.items)) return splitMixed(payload.items);
  return splitMixed([payload]);
}

async function importMany(Model, schema, records) {
  let inserted = 0;
  let skipped = 0;
  let invalid = 0;
  for (const record of records) {
    if (!record || typeof record !== 'object' || Array.isArray(record)) {
      invalid += 1;
      continue;
    }
    const source = { ...record };
    if (!source.clientId) source.clientId = crypto.randomUUID();
    const parsed = schema.safeParse(source);
    if (!parsed.success) {
      invalid += 1;
      continue;
    }
    const data = parsed.data;
    data.total = calcTotal(data.quantity, data.unitPrice);
    if (record.deletedAt) {
      const deletedAt = new Date(record.deletedAt);
      if (Number.isNaN(deletedAt.getTime())) {
        invalid += 1;
        continue;
      }
      data.deletedAt = deletedAt;
    }
    const existing = await Model.findOne({ clientId: data.clientId }).select('clientId').lean();
    if (existing) {
      skipped += 1;
      continue;
    }
    try {
      await Model.create(data);
      inserted += 1;
    } catch (err) {
      if (err && err.code === 11000) skipped += 1;
      else throw err;
    }
  }
  return { inserted, skipped, invalid };
}

async function main() {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: npm run import -- <file.json>');
    process.exit(1);
  }
  const absolute = path.resolve(file);
  let payload;
  try {
    payload = JSON.parse(await fs.readFile(absolute, 'utf8'));
  } catch (err) {
    logError('Could not read JSON file.', err);
    process.exit(1);
  }

  let groups;
  try {
    groups = splitRecords(payload);
  } catch (err) {
    logError('Unrecognized JSON file.', err);
    process.exit(1);
  }

  await connect();
  try {
    const inbound = await importMany(Inbound, inboundSchema, groups.inbound);
    const outbound = await importMany(Outbound, outboundSchema, groups.outbound);
    console.log(`inserted: ${inbound.inserted + outbound.inserted}`);
    console.log(`skipped: ${inbound.skipped + outbound.skipped}`);
    console.log(`invalid: ${inbound.invalid + outbound.invalid}`);
  } finally {
    await disconnect();
  }
}

module.exports = { splitRecords };

if (require.main === module) {
  main().catch((err) => {
    logError('Import failed.', err);
    process.exit(1);
  });
}
