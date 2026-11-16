/// Normalizes a picked file path to ensure it is a valid, clean Windows/cross-platform
/// `.xlsx` file path with proper extension, sanitized characters, and trimmed whitespace.
String normalizeExcelFilePath(
  String rawPath, {
  String defaultBaseName = 'mazr3a-export',
}) {
  final trimmed = rawPath.trim();
  if (trimmed.isEmpty) {
    return '$defaultBaseName.xlsx';
  }

  String dir = '';
  String fileName = trimmed;

  final hasAbsoluteDir = RegExp(r'^([a-zA-Z]:[/\\]|[/\\])').hasMatch(trimmed);
  final separatorIndex = trimmed.lastIndexOf(RegExp(r'[/\\]'));

  if (hasAbsoluteDir && separatorIndex != -1) {
    dir = trimmed.substring(0, separatorIndex + 1);
    fileName = trimmed.substring(separatorIndex + 1);
  } else if (!hasAbsoluteDir && separatorIndex != -1) {
    final beforeSep = trimmed.substring(0, separatorIndex);
    // If the portion before the separator contains invalid file name characters (< > : " | ? *),
    // then the entire input is an unsanitized file name containing slashes.
    if (RegExp(r'[<>:"|?*]').hasMatch(beforeSep)) {
      dir = '';
      fileName = trimmed;
    } else {
      dir = trimmed.substring(0, separatorIndex + 1);
      fileName = trimmed.substring(separatorIndex + 1);
    }
  }

  // 1. Trim name
  fileName = fileName.trim();

  // 2. Sanitize invalid Windows file name characters (< > : " / \ | ? *)
  fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

  // 3. Remove trailing dots or spaces
  fileName = fileName.replaceAll(RegExp(r'[\. ]+$'), '');

  // If empty after sanitization, fallback to default name
  if (fileName.isEmpty) {
    fileName = defaultBaseName;
  }

  // 4. Normalize extension to .xlsx
  if (fileName.toLowerCase().endsWith('.xlsx')) {
    // Preserve base name and ensure lower-case extension
    fileName = '${fileName.substring(0, fileName.length - 5)}.xlsx';
  } else {
    // If user typed a different extension such as .xls, .txt, etc., replace it
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex > 0) {
      fileName = '${fileName.substring(0, lastDotIndex)}.xlsx';
    } else {
      fileName = '$fileName.xlsx';
    }
  }

  return '$dir$fileName';
}
