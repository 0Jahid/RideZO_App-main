import 'package:flutter/material.dart';

class DateTimeUtils {
  static Future<void> selectDate(
    BuildContext context,
    TextEditingController dateController,
    VoidCallback onSelected,
  ) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2026),
    );
    if (picked != null && context.mounted) {
      dateController.text =
          "${picked.day.toString().padLeft(2, '0')} ${monthName(picked.month)} ${picked.year}";
      onSelected();
    }
  }

  static Future<void> selectTime(
    BuildContext context,
    TextEditingController dateController,
    TextEditingController timeController,
    VoidCallback onSelected,
  ) async {
    final now = DateTime.now().toUtc().add(Duration(hours: 6));
    final currentDate = DateTime(now.year, now.month, now.day);
    DateTime? selectedDate;
    if (dateController.text.isNotEmpty) {
      final dateParts = dateController.text.split(' ');
      final day = int.tryParse(dateParts[0]);
      final month = monthNumber(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      if (day != null && month != null && year != null) {
        selectedDate = DateTime(year, month, day);
      }
    }
    selectedDate ??= currentDate;

    TimeOfDay initialTime = TimeOfDay.fromDateTime(now);
    if (selectedDate.isAfter(currentDate)) {
      initialTime = TimeOfDay(hour: 0, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && context.mounted) {
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );
      if (selectedDate == currentDate && selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time cannot be in the past!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        timeController.text = picked.format(context);
        onSelected();
      }
    }
  }

  static int? monthNumber(String month) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[month];
  }

  static String monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
