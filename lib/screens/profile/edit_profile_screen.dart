import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _supabase = SupabaseService();

  String? _studyYear;
  String? _studyAddress;
  PlatformFile? _avatarFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.fullName ?? '';
      _bioCtrl.text = user.bio ?? '';
      _studyYear = user.studyYear;
      _studyAddress = user.studyAddress;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _avatarFile = result.files.first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? avatarUrl;
      if (_avatarFile != null && _avatarFile!.bytes != null) {
        avatarUrl = await _supabase.uploadAvatar(
          Uint8List.fromList(_avatarFile!.bytes!),
          _avatarFile!.name,
        );
      }

      await context.read<AuthProvider>().updateProfile(
            fullName: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            studyYear: _studyYear,
            studyAddress: _studyAddress,
            avatarUrl: avatarUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilo aggiornato!'),
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
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifica profilo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primary.withOpacity(0.12),
                        backgroundImage: _avatarFile != null &&
                                _avatarFile!.bytes != null
                            ? MemoryImage(
                                Uint8List.fromList(_avatarFile!.bytes!))
                            : (user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                    as ImageProvider
                                : null),
                        child: (_avatarFile == null &&
                                user?.avatarUrl == null)
                            ? const Icon(Icons.person,
                                size: 48, color: AppTheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tocca per cambiare foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Inserisci il nome' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _studyYear,
                  decoration: const InputDecoration(
                    labelText: 'Anno di studio',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: AppConstants.studyYears
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (v) => setState(() => _studyYear = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _studyAddress,
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  isExpanded: true,
                  items: AppConstants.studyAddresses
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _studyAddress = v),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio (opzionale)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salva modifiche'),
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
