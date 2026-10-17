import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/request_model.dart';
import '../../utils/theme.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _supabase = SupabaseService();
  final _replyCtrl = TextEditingController();
  RequestModel? _request;
  List<RequestReplyModel> _replies = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Carica richiesta (semplificato: usiamo getRequests e filtriamo)
      final user = context.read<AuthProvider>().user;
      final all = await _supabase.getRequests(
        studyYear: user?.studyYear,
        studyAddress: user?.studyAddress,
      );
      final matches = all.where((r) => r.id == widget.requestId).toList();
      final req = matches.isEmpty ? null : matches.first;
      final replies = await _supabase.getRequestReplies(widget.requestId);
      if (mounted) {
        setState(() {
          _request = req;
          _replies = replies;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendReply() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await _supabase.addRequestReply(
        requestId: widget.requestId,
        content: _replyCtrl.text.trim(),
      );
      _replyCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _contactPrivately() async {
    if (_request == null) return;
    final currentId = context.read<AuthProvider>().user?.id;
    if (currentId == _request!.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non puoi contattare te stesso')),
      );
      return;
    }
    try {
      final convId =
          await _supabase.getOrCreateConversation(_request!.userId);
      if (mounted) {
        context.push(
          '/chat/$convId?name=${Uri.encodeComponent(_request!.authorName ?? "Utente")}&userId=${_request!.userId}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Richiesta')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
              ? const Center(child: Text('Richiesta non trovata'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _request!.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(_request!.subject),
                                  backgroundColor:
                                      AppTheme.secondary.withOpacity(0.12),
                                  labelStyle: const TextStyle(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Chip(label: Text(_request!.studyYear)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage:
                                      _request!.authorAvatar != null
                                          ? NetworkImage(
                                              _request!.authorAvatar!)
                                          : null,
                                  child: _request!.authorAvatar == null
                                      ? const Icon(Icons.person, size: 18)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _request!.authorName ?? 'Utente',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(_request!.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (currentUserId != _request!.userId)
                                  OutlinedButton.icon(
                                    onPressed: _contactPrivately,
                                    icon: const Icon(Icons.chat, size: 18),
                                    label: const Text('Contatta'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _request!.description,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              'Risposte (${_replies.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_replies.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Nessuna risposta ancora. Sii il primo ad aiutare!',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            else
                              ..._replies.map((r) => _ReplyTile(reply: r)),
                          ],
                        ),
                      ),
                    ),
                    // Reply input
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Scrivi una risposta...',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                maxLines: 2,
                                minLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _sending ? null : _sendReply,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final RequestReplyModel reply;

  const _ReplyTile({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: reply.authorAvatar != null
                ? NetworkImage(reply.authorAvatar!)
                : null,
            child: reply.authorAvatar == null
                ? const Icon(Icons.person, size: 16)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.authorName ?? 'Utente',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd/MM HH:mm').format(reply.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(reply.content, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
