const fs = require('fs/promises');
const path = require('path');
const mongoose = require('mongoose');
const { connect, disconnect } = require('./db');
const { logError } = require('../src/log');

async function dump(name) {
  return mongoose.connection.collection(name).find({}).sort({ updatedAt: 1 }).toArray();
}

async function main() {
  await connect();
  try {
    const dir = path.join(__dirname, '..', 'backups');
    await fs.mkdir(dir, { recursive: true });
    const stamp = new Date().toISOString().replace(/[:.]/g, '-');
    const inbound = await dump('inboundreceipts');
    const outbound = await dump('outboundshipments');
    const inboundFile = path.join(dir, `inboundreceipts-${stamp}.json`);
    const outboundFile = path.join(dir, `outboundshipments-${stamp}.json`);
    await fs.writeFile(inboundFile, JSON.stringify(inbound, null, 2));
    await fs.writeFile(outboundFile, JSON.stringify(outbound, null, 2));
    console.log(`Wrote ${inbound.length} inbound receipts to ${inboundFile}`);
    console.log(`Wrote ${outbound.length} outbound shipments to ${outboundFile}`);
  } finally {
    await disconnect();
  }
}

if (require.main === module) {
  main().catch((err) => {
    logError('Backup failed.', err);
    process.exit(1);
  });
}
