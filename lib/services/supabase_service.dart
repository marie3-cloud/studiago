import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';
import '../models/request_model.dart';
import '../models/chat_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  // ==================== AUTH ====================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studyYear,
    required String studyAddress,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'study_year': studyYear,
        'study_address': studyAddress,
      },
    );

    if (response.user != null) {
      // Crea profilo nella tabella profiles
      await client.from('profiles').upsert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'study_year': studyYear,
        'study_address': studyAddress,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ==================== PROFILE ====================

  Future<UserModel?> getCurrentProfile() async {
    if (currentUserId == null) return null;
    final data = await client
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<UserModel?> getProfile(String userId) async {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? studyYear,
    String? studyAddress,
    String? avatarUrl,
  }) async {
    if (currentUserId == null) return;
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (studyYear != null) updates['study_year'] = studyYear;
    if (studyAddress != null) updates['study_address'] = studyAddress;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await client.from('profiles').update(updates).eq('id', currentUserId!);
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    if (currentUserId == null) return null;
    final path = '$currentUserId/$fileName';
    await client.storage.from(AppConstants.avatarsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from(AppConstants.avatarsBucket).getPublicUrl(path);
  }

  // ==================== NOTES ====================

  Future<List<NoteModel>> getNotes({
    String? studyYear,
    String? studyAddress,
    String? subject,
    String? search,
  }) async {
    var query = client.from('notes').select('''
      *,
      profiles:user_id (full_name, avatar_url)
    ''');

    if (studyYear != null && studyYear.isNotEmpty) {
      query = query.eq('study_year', studyYear);
    }
    if (studyAddress != null && studyAddress.isNotEmpty) {
      query = query.eq('study_address', studyAddress);
    }
    if (subject != null && subject.isNotEmpty) {
      query = query.eq('subject', subject);
    }
    if (search != null && search.isNotEmpty) {
      query = query.ilike('title', '%$search%');
    }

    final data = await query.order('created_at', ascending: false).limit(50);

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      final profile = map['profiles'] as Map<String, dynamic>?;
      map['author_name'] = profile?['full_name'];
      map['author_avatar'] = profile?['avatar_url'];
      return NoteModel.fromJson(map);
    }).toList();
  }

  Future<NoteModel?> getNoteById(String id) async {
    final data = await client.from('notes').select('''
      *,
      profiles:user_id (full_name, avatar_url)
    ''').eq('id', id).maybeSingle();
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data);
    final profile = map['profiles'] as Map<String, dynamic>?;
    map['author_name'] = profile?['full_name'];
    map['author_avatar'] = profile?['avatar_url'];
    return NoteModel.fromJson(map);
  }

  Future<NoteModel> createNote({
    required String title,
    required String subject,
    String? description,
    String? fileUrl,
    String? coverImageUrl,
    required String studyYear,
    required String studyAddress,
  }) async {
    final data = await client.from('notes').insert({
      'user_id': currentUserId,
      'title': title,
      'subject': subject,
      'description': description,
      'file_url': fileUrl,
      'cover_image_url': coverImageUrl,
      'study_year': studyYear,
      'study_address': studyAddress,
    }).select().single();
    return NoteModel.fromJson(data);
  }

  Future<String?> uploadNoteFile(Uint8List bytes, String fileName) async {
    if (currentUserId == null) return null;
    final path = '$currentUserId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage.from(AppConstants.notesBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from(AppConstants.notesBucket).getPublicUrl(path);
  }

  Future<void> incrementDownloads(String noteId) async {
    await client.rpc('increment_downloads', params: {'note_id': noteId});
  }

  // ==================== REQUESTS ====================

  Future<List<RequestModel>> getRequests({
    String? studyYear,
    String? studyAddress,
    String? subject,
  }) async {
    var query = client.from('requests').select('''
      *,
      profiles:user_id (full_name, avatar_url)
    ''');

    if (studyYear != null && studyYear.isNotEmpty) {
      query = query.eq('study_year', studyYear);
    }
    if (studyAddress != null && studyAddress.isNotEmpty) {
      query = query.eq('study_address', studyAddress);
    }
    if (subject != null && subject.isNotEmpty) {
      query = query.eq('subject', subject);
    }

    final data = await query.order('created_at', ascending: false).limit(50);

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      final profile = map['profiles'] as Map<String, dynamic>?;
      map['author_name'] = profile?['full_name'];
      map['author_avatar'] = profile?['avatar_url'];
      return RequestModel.fromJson(map);
    }).toList();
  }

  Future<RequestModel> createRequest({
    required String title,
    required String subject,
    required String description,
    required String studyYear,
    required String studyAddress,
  }) async {
    final data = await client.from('requests').insert({
      'user_id': currentUserId,
      'title': title,
      'subject': subject,
      'description': description,
      'study_year': studyYear,
      'study_address': studyAddress,
      'status': 'open',
    }).select().single();
    return RequestModel.fromJson(data);
  }

  Future<List<RequestReplyModel>> getRequestReplies(String requestId) async {
    final data = await client.from('request_replies').select('''
      *,
      profiles:user_id (full_name, avatar_url)
    ''').eq('request_id', requestId).order('created_at');

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      final profile = map['profiles'] as Map<String, dynamic>?;
      map['author_name'] = profile?['full_name'];
      map['author_avatar'] = profile?['avatar_url'];
      return RequestReplyModel.fromJson(map);
    }).toList();
  }

  Future<void> addRequestReply({
    required String requestId,
    required String content,
  }) async {
    await client.from('request_replies').insert({
      'request_id': requestId,
      'user_id': currentUserId,
      'content': content,
    });
  }

  // ==================== CHAT ====================

  Future<List<ConversationModel>> getConversations() async {
    if (currentUserId == null) return [];
    // Assumiamo una view o funzione che restituisce le conversazioni
    final data = await client.rpc('get_user_conversations', params: {
      'user_id': currentUserId,
    });

    return (data as List)
        .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> getOrCreateConversation(String otherUserId) async {
    // Cerca conversazione esistente
    final existing = await client
        .from('conversations')
        .select()
        .or('and(user1_id.eq.$currentUserId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$currentUserId)')
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Crea nuova
    final data = await client.from('conversations').insert({
      'user1_id': currentUserId,
      'user2_id': otherUserId,
    }).select().single();
    return data['id'] as String;
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');

    return (data as List)
        .map((e) => MessageModel.fromJson(
              Map<String, dynamic>.from(e),
              currentUserId ?? '',
            ))
        .toList();
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    await client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'content': content,
      'type': 'text',
    });
  }

  Future<String?> uploadVoiceMessage(Uint8List bytes, String fileName) async {
    if (currentUserId == null) return null;
    final path = '$currentUserId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage.from(AppConstants.voiceMessagesBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'audio/webm', upsert: true),
        );
    return client.storage
        .from(AppConstants.voiceMessagesBucket)
        .getPublicUrl(path);
  }

  Future<void> sendVoiceMessage({
    required String conversationId,
    required String voiceUrl,
    required int duration,
  }) async {
    await client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'voice_url': voiceUrl,
      'voice_duration': duration,
      'type': 'voice',
    });
  }

  // Realtime subscription helper
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(MessageModel) onMessage,
  ) {
    return client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final msg = MessageModel.fromJson(
              Map<String, dynamic>.from(payload.newRecord),
              currentUserId ?? '',
            );
            onMessage(msg);
          },
        )
        .subscribe();
  }
}
