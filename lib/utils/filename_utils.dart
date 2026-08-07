// lib/utils/filename_utils.dart
//
// Utility for sanitizing string input (like contact full names, which may contain
// Malayalam, Hindi, English, Unicode scripts, spaces, or symbols) into safe,
// valid filenames for Android, iOS, Windows, macOS, and Linux filesystems.

/// Sanitizes [input] for use as a filesystem filename.
///
/// Preserves non-ASCII Unicode characters (such as Malayalam script U+0D00..U+0D7F),
/// Latin characters, numbers, spaces, hyphens, and underscores, while replacing
/// OS-reserved invalid characters (`/ \ : * ? " < > |` and control characters `\x00-\x1F`)
/// with an underscore.
///
/// If [input] is empty or resolves to only invalid characters, returns [fallback].
String sanitizeFileName(String input, {String fallback = 'contact'}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return fallback;

  // Replace OS-reserved file path characters with an underscore
  String sanitized = trimmed.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), '_');

  // Replace multiple consecutive underscores with a single underscore
  sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');

  // Trim leading/trailing dots, spaces, or underscores that can be problematic on OS filesystems
  sanitized = sanitized.replaceAll(RegExp(r'^[._\s]+|[._\s]+$'), '');

  return sanitized.isEmpty ? fallback : sanitized;
}
