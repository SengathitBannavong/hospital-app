class MarkNotificationReadRequest {
  const MarkNotificationReadRequest({required this.notificationId});

  final int notificationId;

  Map<String, dynamic> toJson() {
    return {'notif_id': notificationId};
  }
}
