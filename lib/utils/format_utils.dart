import 'package:intl/intl.dart';

/// Formatting helpers used across screens.
class FormatUtils {
  FormatUtils._();

  static String time(DateTime dt) => DateFormat('h:mm a').format(dt);

  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, h:mm a').format(dt);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String distance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
