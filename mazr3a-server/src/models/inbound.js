const mongoose = require('mongoose');

const inboundSchema = new mongoose.Schema(
  {
    clientId: { type: String, required: true, unique: true },
    date: { type: Date, required: true },
    itemName: { type: String, required: true, trim: true, maxlength: 200 },
    category: { type: String, required: true, trim: true, maxlength: 200 },
    type: { type: String, required: true, trim: true, maxlength: 200 },
    quantity: { type: Number, required: true, min: 0 },
    unit: { type: String, required: true, trim: true, maxlength: 200 },
    unitPrice: { type: Number, required: true, min: 0 },
    supplier: { type: String, required: true, trim: true, maxlength: 200 },
    paymentType: { type: String, required: true, enum: ['cash', 'deferred'] },
    total: { type: Number, required: true, min: 0 },
    deletedAt: { type: Date, default: null },
  },
  { timestamps: true, versionKey: false }
);

inboundSchema.index({ date: -1 });
inboundSchema.index({ updatedAt: 1 });
inboundSchema.index({ itemName: 1, type: 1, unit: 1 });

module.exports = mongoose.model('InboundReceipt', inboundSchema);
