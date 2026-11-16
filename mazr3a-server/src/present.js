function toPublic(doc) {
  if (!doc) return doc;
  const obj = typeof doc.toObject === 'function' ? doc.toObject({ versionKey: false }) : { ...doc };
  delete obj.__v;
  return obj;
}

module.exports = { toPublic };
