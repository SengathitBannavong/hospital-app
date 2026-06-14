/// The user's currently-borrowed asset, persisted locally.
///
/// The backend exposes no "my bookings" endpoint and no `booked_by` on assets,
/// so the only way to remember which wheelchair this user holds (and to offer a
/// path back to release it) is to store the [book_asset] result on the device.
class ActiveBooking {
  const ActiveBooking({required this.assetId, this.bookingId});

  final String assetId;
  final int? bookingId;

  factory ActiveBooking.fromJson(Map<String, dynamic> json) {
    return ActiveBooking(
      assetId: json['asset_id']?.toString() ?? '',
      bookingId: _parseInt(json['booking_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'asset_id': assetId,
    if (bookingId != null) 'booking_id': bookingId,
  };

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
