const { test } = require('node:test');
const assert = require('node:assert/strict');
const { splitRecords } = require('../scripts/import');

test('import accepts list, sync, and backup shapes', () => {
  const list = splitRecords({
    items: [
      { itemName: 'Wheat', category: 'Grain', supplier: 'Ahmed' },
      { product: 'Wheat', type: 'Giza 171' },
    ],
  });
  assert.equal(list.inbound.length, 1);
  assert.equal(list.outbound.length, 1);

  const sync = splitRecords({
    inbound: [{ itemName: 'Wheat' }],
    outbound: [{ product: 'Wheat' }],
    serverTime: '2026-01-01T00:00:00.000Z',
  });
  assert.equal(sync.inbound.length, 1);
  assert.equal(sync.outbound.length, 1);

  const backup = splitRecords([{ product: 'Seeds', type: 'raw', unit: 'bag' }]);
  assert.equal(backup.outbound.length, 1);
  assert.equal(backup.inbound.length, 0);
});
