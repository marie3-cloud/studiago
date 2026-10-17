import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();

  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.client.auth.currentSession;
      if (session != null) {
        _user = await _supabase.getCurrentProfile();
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    }

    _supabase.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _user = await _supabase.getCurrentProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
      }
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studyYear,
    required String studyAddress,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studyYear: studyYear,
        studyAddress: studyAddress,
      );

      if (response.user != null) {
        _user = await _supabase.getCurrentProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Registrazione fallita';
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.signIn(email: email, password: password);
      if (response.user != null) {
        _user = await _supabase.getCurrentProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Login fallito';
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _supabase.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    _user = await _supabase.getCurrentProfile();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? studyYear,
    String? studyAddress,
    String? avatarUrl,
  }) async {
    await _supabase.updateProfile(
      fullName: fullName,
      bio: bio,
      studyYear: studyYear,
      studyAddress: studyAddress,
      avatarUrl: avatarUrl,
    );
    await refreshProfile();
  }
}
