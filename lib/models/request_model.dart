class RequestModel {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final String description;
  final String studyYear;
  final String studyAddress;
  final String status; // open, closed
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;
  final int repliesCount;

  RequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.description,
    required this.studyYear,
    required this.studyAddress,
    this.status = 'open',
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.repliesCount = 0,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      studyYear: json['study_year'] as String? ?? '',
      studyAddress: json['study_address'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      repliesCount: json['replies_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'subject': subject,
      'description': description,
      'study_year': studyYear,
      'study_address': studyAddress,
      'status': status,
    };
  }
}

class RequestReplyModel {
  final String id;
  final String requestId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;

  RequestReplyModel({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
  });

  factory RequestReplyModel.fromJson(Map<String, dynamic> json) {
    return RequestReplyModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
    );
  }
}
