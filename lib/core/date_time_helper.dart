import 'package:intl/intl.dart';

class DateTimeHelper {
  static String getRecordFormatDate() {
    DateTime now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.format(now);
  }

  static double getWorkingHours(String date) {
    DateTime startDate = DateTime.parse(date);
    DateTime now = DateTime.now();

    Duration difference = now.difference(startDate);
    double minutes = difference.inMinutes.toDouble();

    return minutes / 60.0;
  }
}
