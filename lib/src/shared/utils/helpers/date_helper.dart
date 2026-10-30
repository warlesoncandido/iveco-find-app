class DateHelper {
  static String formatDate(String date) {
    if (date.isEmpty) return '';
    final splitted = date.split('/');
    return '${splitted[2]}-${splitted[1].padLeft(2, '0')}-${splitted[0].padLeft(2, '0')}';
  }

  static String now() {
    final dateNow = DateTime.now();

    final month = dateNow.month.toString().padLeft(2, '0');
    final day = dateNow.day.toString().padLeft(2, '0');

    return '${dateNow.year}/$month/$day';
  }
}
