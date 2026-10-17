class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String studyYear;
  final String studyAddress;
  final String? bio;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.studyYear,
    required this.studyAddress,
    this.bio,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      studyYear: json['study_year'] as String? ?? '',
      studyAddress: json['study_address'] as String? ?? '',
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'study_year': studyYear,
      'study_address': studyAddress,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? studyYear,
    String? studyAddress,
    String? bio,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studyYear: studyYear ?? this.studyYear,
      studyAddress: studyAddress ?? this.studyAddress,
      bio: bio ?? this.bio,
      createdAt: createdAt,
    );
  }
}
