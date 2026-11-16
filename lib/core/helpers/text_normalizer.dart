/// Helper for text normalization across inventory grouping and search.
///
/// Trims, collapses multiple whitespaces, lowercases Latin letters,
/// removes Arabic tashkeel (diacritics) and tatweel (kashida),
/// and unifies Arabic variants (أ إ آ ٱ -> ا, ى -> ي, ة -> ه).
String normalizeText(String input) {
  var s = input.trim();
  if (s.isEmpty) return '';

  // 1. Collapse multiple spaces into a single space
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  // 2. Lowercase Latin characters
  s = s.toLowerCase();

  // 3. Remove tatweel (\u0640)
  s = s.replaceAll('\u0640', '');

  // 4. Remove Arabic tashkeel / harakat (\u064B through \u065F, \u0670)
  s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

  // 5. Unify Alef variants (أ, إ, آ, ٱ -> ا)
  s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

  // 6. Unify Alef Maksura to Yaa (ى -> ي)
  s = s.replaceAll('ى', 'ي');

  // 7. Unify Taa Marbuta to Haa (ة -> ه)
  s = s.replaceAll('ة', 'ه');

  return s;
}

/// Generates a composite grouping key for warehouse inventory items
/// based on normalized product name, type, and unit.
String generateInventoryGroupKey({
  required String product,
  required String type,
  required String unit,
}) {
  final normP = normalizeText(product);
  final normT = normalizeText(type);
  final normU = normalizeText(unit);
  return '$normP|$normT|$normU';
}
