/// Shared by Settings → Data ("storage used") and Documents (per-file size,
/// total quota) — moved here rather than duplicated once a second feature
/// needed it (CLAUDE.md rule 4: features don't import features).
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
