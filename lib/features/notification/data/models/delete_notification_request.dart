class DeleteNotificationRequest {
  const DeleteNotificationRequest({required this.notificationIds});

  final List<String> notificationIds;

  Map<String, dynamic> toJson() {
    return {'notificationIds': notificationIds};
  }
}
