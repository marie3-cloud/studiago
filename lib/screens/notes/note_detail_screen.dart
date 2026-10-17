import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_service.dart';
import '../../models/note_model.dart';
import '../../utils/theme.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _supabase = SupabaseService();
  NoteModel? _note;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final note = await _supabase.getNoteById(widget.noteId);
    if (mounted) {
      setState(() {
        _note = note;
        _loading = false;
      });
    }
  }

  Future<void> _openFile() async {
    if (_note?.fileUrl == null) return;
    final uri = Uri.parse(_note!.fileUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _supabase.incrementDownloads(_note!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio appunti')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Appunti non trovati'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_note!.coverImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _note!.coverImageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      if (_note!.coverImageUrl != null)
                        const SizedBox(height: 20),
                      Text(
                        _note!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(_note!.subject),
                            backgroundColor:
                                AppTheme.secondary.withOpacity(0.12),
                            labelStyle: const TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Chip(label: Text(_note!.studyYear)),
                          Chip(label: Text(_note!.studyAddress)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: _note!.authorAvatar != null
                                ? NetworkImage(_note!.authorAvatar!)
                                : null,
                            child: _note!.authorAvatar == null
                                ? const Icon(Icons.person, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _note!.authorName ?? 'Utente',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                DateFormat('dd MMMM yyyy', 'it')
                                    .format(_note!.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_note!.description != null &&
                          _note!.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Descrizione',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _note!.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_note!.fileUrl != null)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _openFile,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Scarica / Apri file'),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          '${_note!.downloads} download',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
