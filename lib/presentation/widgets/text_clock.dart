import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting time

class TextClockWidget extends StatelessWidget {
  final double fontSize;
  final Color color;
  final bool isBold;

  const TextClockWidget({
    super.key,
    this.fontSize = 25,
    this.color = Colors.white,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final time = snapshot.data ?? DateTime.now();
        final formattedTime = DateFormat('HH:mm:ss').format(time); // 24-hour
        // final formattedTime = DateFormat('hh:mm:ss a').format(time); // 12-hour

        return Text(
          formattedTime,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        );
      },
    );
  }
}
