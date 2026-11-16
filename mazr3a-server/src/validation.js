const { z } = require('zod');

const text = (max) => z.string().trim().min(1).max(max);

function numeric(val) {
  if (typeof val === 'string') {
    const trimmed = val.trim();
    if (trimmed === '') return val;
    return Number(trimmed);
  }
  return val;
}

const money = z.preprocess(numeric, z.number().finite().min(0).max(1e12));
const paymentType = z.enum(['cash', 'deferred']);
const isoQueryDate = z
  .string()
  .trim()
  .min(1)
  .refine((value) => !Number.isNaN(Date.parse(value)), { message: 'Invalid date' });

function withQuantityFallback(schema) {
  return z.preprocess((val) => {
    if (!val || typeof val !== 'object' || Array.isArray(val)) return val;
    const copy = { ...val };
    const quantityMissing = copy.quantity === undefined || copy.quantity === null || copy.quantity === '';
    if (quantityMissing && copy.amount !== undefined) copy.quantity = copy.amount;
    delete copy.amount;
    delete copy.total;
    return copy;
  }, schema);
}

const inboundSchema = withQuantityFallback(
  z.object({
    clientId: z.string().uuid(),
    date: z.coerce.date(),
    itemName: text(200),
    category: text(200),
    type: text(200),
    quantity: money,
    unit: text(200),
    unitPrice: money,
    supplier: text(200),
    paymentType,
  })
);

const outboundSchema = withQuantityFallback(
  z.object({
    clientId: z.string().uuid(),
    date: z.coerce.date(),
    product: text(200),
    type: text(200),
    field: z.preprocess((v) => (v === undefined || v === null ? '' : v), z.string().trim().max(100)),
    unit: text(200),
    quantity: money,
    unitPrice: money,
    paymentType: paymentType.default('cash'),
  })
);

const listQuerySchema = z.object({
  limit: z.preprocess(numeric, z.number().int().min(1).max(500)),
  page: z.preprocess(numeric, z.number().int().min(1).max(1_000_000)),
});

const syncQuerySchema = z.object({
  limit: z.preprocess(numeric, z.number().int().min(1).max(5000)),
  since: isoQueryDate.optional(),
  until: isoQueryDate.optional(),
});

function parseListQuery(query) {
  return listQuerySchema.safeParse({
    limit: query.limit === undefined ? 10 : query.limit,
    page: query.page === undefined ? 1 : query.page,
  });
}

function parseSyncQuery(query) {
  const input = { limit: query.limit === undefined ? 1000 : query.limit };
  if (query.since !== undefined) input.since = query.since;
  if (query.until !== undefined) input.until = query.until;
  return syncQuerySchema.safeParse(input);
}

function sendValidationError(res, error) {
  return res.status(400).json({
    message: 'Validation failed',
    code: 'VALIDATION_ERROR',
    details: error.issues.map((issue) => ({
      field: issue.path.length ? issue.path.join('.') : 'body',
      message: issue.message,
    })),
  });
}

function roundTo(n, places) {
  const factor = 10 ** places;
  return Math.round((n + Number.EPSILON) * factor) / factor;
}

const round2 = (n) => roundTo(n, 2);
const roundQty = (n) => roundTo(n, 6);
const calcTotal = (quantity, unitPrice) => round2(quantity * unitPrice);

module.exports = {
  inboundSchema,
  outboundSchema,
  parseListQuery,
  parseSyncQuery,
  sendValidationError,
  round2,
  roundQty,
  calcTotal,
};
