/**
 * Same grouping rules as the Flutter `normalizeText` helper:
 * trim, collapse spaces, lowercase Latin letters, drop tatweel and tashkeel,
 * then أ إ آ ٱ -> ا, ى -> ي, ة -> ه.
 */
function normalizeText(input) {
  let s = String(input ?? '').trim();
  if (!s) return '';
  s = s.replace(/\s+/g, ' ').toLowerCase();
  s = s.replace(/\u0640/g, '');
  s = s.replace(/[\u064B-\u065F\u0670]/g, '');
  s = s.replace(/[أإآٱ]/g, 'ا');
  s = s.replace(/ى/g, 'ي');
  s = s.replace(/ة/g, 'ه');
  return s;
}

function inventoryGroupKey(product, type, unit) {
  return [normalizeText(product), normalizeText(type), normalizeText(unit)].join('|');
}

module.exports = { normalizeText, inventoryGroupKey };
