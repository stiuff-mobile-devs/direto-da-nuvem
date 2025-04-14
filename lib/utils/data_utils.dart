extension DateTimeUtils on DateTime {
  String get formattedDate {
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
  }

  String get formattedTime {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}