/// Formatage des données en français, sans dépendance supplémentaire.
class Formatters {
  Formatters._();

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  /// `2024-03-12` → `12 mars 2024`
  static String date(DateTime? date) =>
      date == null ? 'Date inconnue' : '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `135` → `2 h 15 min`
  static String runtime(int? minutes) {
    if (minutes == null || minutes <= 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
  }

  /// `7.456` → `7.5`
  static String rating(double value) => value.toStringAsFixed(1);
}
