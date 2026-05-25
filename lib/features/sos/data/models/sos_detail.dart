// lib/features/sos/data/models/sos_detail.dart

enum SosStatus { none, active, resolved }

class SosDetail {
  const SosDetail({
    required this.sosId,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.note,
  });

  final int sosId;
  final SosStatus status;
  final String createdAt;
  final String? resolvedAt;
  final String? note;

  factory SosDetail.fromJson(Map<String, dynamic> json) {
    SosStatus parseStatus(dynamic raw) {
      switch (raw?.toString()) {
        case 'active':
          return SosStatus.active;
        case 'resolved':
          return SosStatus.resolved;
        default:
          return SosStatus.none;
      }
    }

    return SosDetail(
      sosId: (json['sos_id'] ?? json['id'] ?? 0) as int,
      status: parseStatus(json['status']),
      createdAt: (json['created_at'] ?? json['time'] ?? '') as String,
      resolvedAt: json['resolved_at'] as String?,
      note: json['note'] as String?,
    );
  }
}
