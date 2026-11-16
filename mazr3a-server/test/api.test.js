const { before, after, test } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const request = require('supertest');

process.env.NODE_ENV = 'test';
process.env.API_KEY = 'test-api-key-0123456789abcdef';

const app = require('../src/app');
const Inbound = require('../src/models/inbound');
const Outbound = require('../src/models/outbound');

const KEY = process.env.API_KEY;
let mongo;

function authed(req) {
  return req.set('x-api-key', KEY);
}

function inboundBody(overrides = {}) {
  return {
    clientId: crypto.randomUUID(),
    date: '2026-10-09T10:00:00.000Z',
    itemName: 'Wheat',
    category: 'Grain',
    type: 'Giza 171',
    quantity: 2,
    unit: 'kg',
    unitPrice: 10.5,
    supplier: 'Ahmed',
    paymentType: 'cash',
    ...overrides,
  };
}

function outboundBody(overrides = {}) {
  return {
    clientId: crypto.randomUUID(),
    date: '2026-10-10T10:00:00.000Z',
    product: 'Wheat',
    type: 'Giza 171',
    unit: 'kg',
    quantity: 1,
    unitPrice: 15,
    ...overrides,
  };
}

async function clear() {
  await Inbound.deleteMany({});
  await Outbound.deleteMany({});
}

before(async () => {
  mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri());
  await Promise.all([Inbound.init(), Outbound.init()]);
}, { timeout: 180000 });

after(async () => {
  if (mongoose.connection.readyState !== 0) await mongoose.disconnect();
  if (mongo) await mongo.stop();
});

test('mazr3a api', { timeout: 180000 }, async (t) => {
  await t.test('health is open and reports ok', async () => {
    const res = await request(app).get('/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
  });

  await t.test('missing or wrong api key is 401', async () => {
    const missing = await request(app).get('/api/v1/inbound');
    assert.equal(missing.status, 401);
    assert.equal(missing.body.code, 'UNAUTHORIZED');

    const wrong = await request(app).get('/api/v1/dashboard/summary').set('x-api-key', 'not-the-key');
    assert.equal(wrong.status, 401);
    assert.equal(wrong.body.code, 'UNAUTHORIZED');
  });

  await t.test('validation rejects bad bodies and queries', async () => {
    const badUuid = await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ clientId: 'nope' }));
    assert.equal(badUuid.status, 400);
    assert.equal(badUuid.body.code, 'VALIDATION_ERROR');
    assert.ok(Array.isArray(badUuid.body.details));

    const negative = await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ quantity: -1 }));
    assert.equal(negative.status, 400);

    const absurd = await authed(request(app).post('/api/v1/outbound')).send(outboundBody({ unitPrice: 1e13 }));
    assert.equal(absurd.status, 400);

    const badDate = await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ date: 'yesterday' }));
    assert.equal(badDate.status, 400);

    const missingName = await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ itemName: '   ' }));
    assert.equal(missingName.status, 400);

    const badLimit = await authed(request(app).get('/api/v1/inbound')).query({ limit: 0 });
    assert.equal(badLimit.status, 400);

    const badSince = await authed(request(app).get('/api/v1/sync/changes')).query({ since: 'not-a-date' });
    assert.equal(badSince.status, 400);
    assert.equal(badSince.body.code, 'VALIDATION_ERROR');
  });

  await t.test('server calculates total and ignores the client value', async () => {
    const res = await authed(request(app).post('/api/v1/inbound')).send(
      inboundBody({ itemName: '  Wheat  ', quantity: 2, unitPrice: 10.5, total: 1 })
    );
    assert.equal(res.status, 201);
    assert.equal(res.body.itemName, 'Wheat');
    assert.equal(res.body.total, 21);
    assert.equal(res.body.amount, undefined);
    assert.equal(res.body.deletedAt, null);
  });

  await t.test('legacy amount is accepted as quantity and not stored', async () => {
    const body = inboundBody({ quantity: undefined, amount: 4, unitPrice: 2.5 });
    delete body.quantity;
    const res = await authed(request(app).post('/api/v1/inbound')).send(body);
    assert.equal(res.status, 201);
    assert.equal(res.body.quantity, 4);
    assert.equal(res.body.total, 10);
    assert.equal(res.body.amount, undefined);
  });

  await t.test('creating the same clientId twice keeps one record', async () => {
    const body = inboundBody();
    const first = await authed(request(app).post('/api/v1/inbound')).send(body);
    const second = await authed(request(app).post('/api/v1/inbound')).send({ ...body, quantity: 99, unitPrice: 99 });
    assert.equal(first.status, 201);
    assert.equal(second.status, 200);
    assert.equal(second.body.clientId, body.clientId);
    assert.equal(second.body.quantity, body.quantity);
    assert.equal(second.body._id, first.body._id);
    assert.equal(await Inbound.countDocuments({ clientId: body.clientId }), 1);
  });

  await t.test('outbound defaults paymentType to cash and field to empty', async () => {
    const res = await authed(request(app).post('/api/v1/outbound')).send(outboundBody());
    assert.equal(res.status, 201);
    assert.equal(res.body.paymentType, 'cash');
    assert.equal(res.body.field, '');
    assert.equal(res.body.total, 15);
  });

  await t.test('soft delete hides the record, keeps a tombstone, and a later create does not restore it', async () => {
    await clear();
    const body = inboundBody();
    const created = await authed(request(app).post('/api/v1/inbound')).send(body);
    assert.equal(created.status, 201);

    const removed = await authed(request(app).delete(`/api/v1/inbound/${body.clientId}`));
    assert.equal(removed.status, 200);
    assert.deepEqual(removed.body, { ok: true });

    const again = await authed(request(app).delete(`/api/v1/inbound/${body.clientId}`));
    assert.equal(again.status, 200);

    const unknown = await authed(request(app).delete(`/api/v1/outbound/${crypto.randomUUID()}`));
    assert.equal(unknown.status, 200);
    assert.deepEqual(unknown.body, { ok: true });

    const list = await authed(request(app).get('/api/v1/inbound'));
    assert.equal(list.body.total, 0);
    assert.equal(list.body.items.length, 0);

    const sync = await authed(request(app).get('/api/v1/sync/changes'));
    const tombstone = sync.body.inbound.find((row) => row.clientId === body.clientId);
    assert.ok(tombstone);
    assert.equal(typeof tombstone.deletedAt, 'string');

    const replay = await authed(request(app).post('/api/v1/inbound')).send(body);
    assert.equal(replay.status, 200);
    assert.equal(typeof replay.body.deletedAt, 'string');
    const afterList = await authed(request(app).get('/api/v1/inbound'));
    assert.equal(afterList.body.total, 0);
  });

  await t.test('sync cursor and pagination', async () => {
    await clear();
    const ids = [];
    for (let i = 0; i < 5; i += 1) {
      const body = inboundBody({ date: `2026-01-0${i + 1}T00:00:00.000Z` });
      const res = await authed(request(app).post('/api/v1/inbound')).send(body);
      assert.equal(res.status, 201);
      ids.push(body.clientId);
      await Inbound.collection.updateOne(
        { clientId: body.clientId },
        { $set: { updatedAt: new Date(Date.UTC(2026, 0, i + 1)) } }
      );
    }
    const old = inboundBody();
    await authed(request(app).post('/api/v1/inbound')).send(old);
    await Inbound.collection.updateOne(
      { clientId: old.clientId },
      { $set: { updatedAt: new Date('2020-01-01T00:00:00.000Z') } }
    );

    const cursor = await authed(request(app).get('/api/v1/sync/changes')).query({
      since: '2020-06-01T00:00:00.000Z',
      until: '2020-12-01T00:00:00.000Z',
    });
    assert.equal(cursor.status, 200);
    assert.equal(cursor.body.hasMore, false);
    assert.deepEqual(cursor.body.inbound, []);

    const first = await authed(request(app).get('/api/v1/sync/changes')).query({
      since: '2025-12-31T00:00:00.000Z',
      until: '2026-01-06T00:00:00.000Z',
      limit: 2,
    });
    assert.equal(first.status, 200);
    assert.equal(first.body.hasMore, true);
    assert.equal(first.body.inbound.length, 2);
    assert.equal(first.body.inbound[0].clientId, ids[0]);
    assert.equal(first.body.inbound[1].clientId, ids[1]);
    assert.equal(first.body.nextSince, '2026-01-02T00:00:00.000Z');
    assert.match(first.body.serverTime, /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);

    const second = await authed(request(app).get('/api/v1/sync/changes')).query({
      since: first.body.nextSince,
      until: '2026-01-06T00:00:00.000Z',
      limit: 2,
    });
    assert.equal(second.body.hasMore, true);
    assert.deepEqual(
      second.body.inbound.map((row) => row.clientId),
      [ids[2], ids[3]]
    );

    const third = await authed(request(app).get('/api/v1/sync/changes')).query({
      since: second.body.nextSince,
      until: '2026-01-06T00:00:00.000Z',
      limit: 2,
    });
    assert.equal(third.body.hasMore, false);
    assert.equal(third.body.nextSince, undefined);
    assert.deepEqual(
      third.body.inbound.map((row) => row.clientId),
      [ids[4]]
    );
    assert.ok(!third.body.inbound.some((row) => row.clientId === old.clientId));
  });

  await t.test('dashboard summary counts active inbound cash and deferred only', async () => {
    await clear();
    await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ quantity: 10, unitPrice: 10, paymentType: 'cash' }));
    await authed(request(app).post('/api/v1/inbound')).send(inboundBody({ quantity: 5, unitPrice: 10, paymentType: 'cash' }));
    await authed(request(app).post('/api/v1/inbound')).send(
      inboundBody({ quantity: 5, unitPrice: 5, paymentType: 'deferred' })
    );
    const removed = inboundBody({ quantity: 1, unitPrice: 999, paymentType: 'cash' });
    await authed(request(app).post('/api/v1/inbound')).send(removed);
    await authed(request(app).delete(`/api/v1/inbound/${removed.clientId}`));
    await authed(request(app).post('/api/v1/outbound')).send(outboundBody({ quantity: 4, unitPrice: 10 }));

    const res = await authed(request(app).get('/api/v1/dashboard/summary'));
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, {
      totalInboundValue: 175,
      inboundCount: 3,
      totalOutboundValue: 40,
      outboundCount: 1,
      cashCount: 2,
      deferredCount: 1,
      netInventoryValue: 135,
    });
  });

  await t.test('inventory groups Arabic variants and keeps negative stock', async () => {
    await clear();
    await authed(request(app).post('/api/v1/inbound')).send(
      inboundBody({
        itemName: 'اسمدة',
        category: 'مدخلات',
        type: 'NPK',
        unit: 'kg',
        quantity: 10,
        unitPrice: 5,
        date: '2026-01-01T00:00:00.000Z',
      })
    );
    await authed(request(app).post('/api/v1/inbound')).send(
      inboundBody({
        itemName: 'أسمدة',
        category: 'مدخلات',
        type: 'NPK',
        unit: 'kg',
        quantity: 10,
        unitPrice: 15,
        date: '2026-02-01T00:00:00.000Z',
      })
    );
    await authed(request(app).post('/api/v1/outbound')).send(
      outboundBody({
        product: 'اسمدة',
        type: 'NPK',
        unit: 'kg',
        quantity: 30,
        unitPrice: 20,
      })
    );
    await authed(request(app).post('/api/v1/outbound')).send(
      outboundBody({
        product: 'Seeds',
        type: 'raw',
        unit: 'bag',
        quantity: 4,
        unitPrice: 8,
      })
    );

    const res = await authed(request(app).get('/api/v1/inventory'));
    assert.equal(res.status, 200);
    const fertilizer = res.body.items.find((item) => item.totalIn === 20);
    assert.ok(fertilizer);
    assert.equal(fertilizer.product, 'أسمدة');
    assert.equal(fertilizer.type, 'NPK');
    assert.equal(fertilizer.unit, 'kg');
    assert.equal(fertilizer.totalOut, 30);
    assert.equal(fertilizer.inStock, -10);
    assert.equal(fertilizer.lastPrice, 15);
    assert.equal(fertilizer.avgPrice, 10);
    assert.equal(fertilizer.stockValue, 0);

    const seeds = res.body.items.find((item) => item.product === 'Seeds');
    assert.ok(seeds);
    assert.equal(seeds.totalIn, 0);
    assert.equal(seeds.totalOut, 4);
    assert.equal(seeds.inStock, -4);
    assert.equal(seeds.lastPrice, 0);
    assert.equal(seeds.avgPrice, 0);
    assert.equal(seeds.stockValue, 0);

    for (let i = 1; i < res.body.items.length; i += 1) {
      assert.ok(res.body.items[i - 1].product.localeCompare(res.body.items[i].product) <= 0);
    }
  });

  await t.test('unknown routes are 404', async () => {
    const res = await authed(request(app).get('/api/v1/missing'));
    assert.equal(res.status, 404);
    assert.equal(res.body.code, 'NOT_FOUND');
  });

  await t.test('health reports db_unavailable when mongoose is disconnected', async () => {
    await mongoose.disconnect();
    const res = await request(app).get('/health');
    assert.equal(res.status, 503);
    assert.equal(res.body.status, 'db_unavailable');
  });
});
