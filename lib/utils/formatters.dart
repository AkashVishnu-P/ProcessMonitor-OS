class Formatters {
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }

  static String formatSeconds(int seconds) {
    return '${seconds}s';
  }

  static String formatPercent(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
