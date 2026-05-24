class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    required this.fullName,
    this.dob,
    this.gender,
    this.avatar,
  });

  final String fullName;
  final String? dob;
  final int? gender;
  final String? avatar;

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (avatar != null && avatar!.isNotEmpty) 'avatar': avatar,
    };
  }
}
