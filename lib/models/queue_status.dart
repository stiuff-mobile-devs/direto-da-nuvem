import 'package:hive/hive.dart';

part 'hive/queue_status.g.dart';

@HiveType(typeId: 6)
enum QueueStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}

QueueStatus queueStatusFromMap(String status) {
  switch (status) {
    case "pending":
      return QueueStatus.pending;
    case "approved":
      return QueueStatus.approved;
    case "rejected":
      return QueueStatus.rejected;
    default:
      return QueueStatus.pending;
  }
}

String queueStatusToMap(QueueStatus status) {
  switch (status) {
    case QueueStatus.pending:
      return "pending";
    case QueueStatus.approved:
      return "approved";
    case QueueStatus.rejected:
      return "rejected";
  }
}