class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final String? description;
  final String? fileUrl;
  final String? coverImageUrl;
  final String studyYear;
  final String studyAddress;
  final int downloads;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    this.description,
    this.fileUrl,
    this.coverImageUrl,
    required this.studyYear,
    required this.studyAddress,
    this.downloads = 0,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      studyYear: json['study_year'] as String? ?? '',
      studyAddress: json['study_address'] as String? ?? '',
      downloads: json['downloads'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subject': subject,
      'description': description,
      'file_url': fileUrl,
      'cover_image_url': coverImageUrl,
      'study_year': studyYear,
      'study_address': studyAddress,
      'downloads': downloads,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
