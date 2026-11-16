const mongoose = require('mongoose');

const outboundSchema = new mongoose.Schema(
  {
    clientId: { type: String, required: true, unique: true },
    date: { type: Date, required: true },
    product: { type: String, required: true, trim: true, maxlength: 200 },
    type: { type: String, required: true, trim: true, maxlength: 200 },
    field: { type: String, trim: true, maxlength: 100, default: '' },
    unit: { type: String, required: true, trim: true, maxlength: 200 },
    quantity: { type: Number, required: true, min: 0 },
    unitPrice: { type: Number, required: true, min: 0 },
    paymentType: { type: String, required: true, enum: ['cash', 'deferred'], default: 'cash' },
    total: { type: Number, required: true, min: 0 },
    deletedAt: { type: Date, default: null },
  },
  { timestamps: true, versionKey: false }
);

outboundSchema.index({ date: -1 });
outboundSchema.index({ updatedAt: 1 });
outboundSchema.index({ product: 1, type: 1, unit: 1 });

module.exports = mongoose.model('OutboundShipment', outboundSchema);
