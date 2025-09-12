import 'package:easy_localization/easy_localization.dart';

extension DateTimeExtension on String {
  String toLocalTime() {
    DateTime utcDateTime = DateTime.parse(this);
    DateTime localDateTime = utcDateTime.toLocal();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(localDateTime);
  }
}
