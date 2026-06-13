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
      // avatar semantics (set_profile is a partial update):
      //   null  -> omit the field, leaving the stored avatar unchanged
      //   ""    -> send empty string; the backend treats it as "remove avatar"
      //   value -> set/replace the avatar
      if (avatar != null) 'avatar': avatar,
    };
  }
}
