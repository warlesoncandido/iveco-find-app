import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(String date) {
    if (date.isEmpty) return '';
    final splitted = date.split('/');
    return '${splitted[2]}-${splitted[1].padLeft(2, '0')}-${splitted[0].padLeft(2, '0')}';
  }

  /// `yyyy-MM-dd` (API) → `dd/MM/yyyy`.
  static String toBr(String date) {
    if (date.isEmpty) return '';
    final splitted = date.split('-');
    return '${splitted[2]}/${splitted[1]}/${splitted[0]}';
  }

  /// Valida uma data `dd/MM/yyyy` digitada.
  static bool isValidBr(String date) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(date);
    if (match == null) return false;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final parsed = DateTime(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  static String todayBr() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  static String now() {
    final dateNow = DateTime.now();

    final month = dateNow.month.toString().padLeft(2, '0');
    final day = dateNow.day.toString().padLeft(2, '0');

    return '${dateNow.year}/$month/$day';
  }
}
