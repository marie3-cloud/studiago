import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _supabase = SupabaseService();

  String? _subject;
  PlatformFile? _file;
  PlatformFile? _cover;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _file = result.files.first);
    }
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _cover = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una materia')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().user!;
      String? fileUrl;
      String? coverUrl;

      if (_file != null && _file!.bytes != null) {
        fileUrl = await _supabase.uploadNoteFile(
          Uint8List.fromList(_file!.bytes!),
          _file!.name,
        );
      }
      if (_cover != null && _cover!.bytes != null) {
        coverUrl = await _supabase.uploadNoteFile(
          Uint8List.fromList(_cover!.bytes!),
          'cover_${_cover!.name}',
        );
      }

      await _supabase.createNote(
        title: _titleCtrl.text.trim(),
        subject: _subject!,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        fileUrl: fileUrl,
        coverImageUrl: coverUrl,
        studyYear: user.studyYear,
        studyAddress: user.studyAddress,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appunti caricati con successo!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carica appunti')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titolo *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Inserisci un titolo' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Materia *',
                    prefixIcon: Icon(Icons.subject),
                  ),
                  items: AppConstants.subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _subject = v),
                  validator: (v) => v == null ? 'Seleziona materia' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione (opzionale)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                // File picker
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _file == null ? 'Seleziona file (PDF, DOC...)' : _file!.name,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickCover,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _cover == null
                        ? 'Immagine di copertina (opzionale)'
                        : _cover!.name,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pubblica appunti'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
