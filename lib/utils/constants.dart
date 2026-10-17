/// Configurazione centralizzata di StudiaGo
/// Sostituisci i placeholder con le tue chiavi reali di Supabase
class AppConstants {
  // ========== SUPABASE ==========
  static const String supabaseUrl = 'https://trcmljmurtwmfhwjbias.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_DFYoVs0xVon4bxZZPIYY9Q_SA2rRiWr';

  // ========== STORAGE BUCKETS ==========
  static const String notesBucket = 'notes';
  static const String avatarsBucket = 'avatars';
  static const String voiceMessagesBucket = 'voice-messages';

  // ========== APP INFO ==========
  static const String appName = 'StudiaGo';
  static const String appVersion = '1.0.0';

  // ========== ANNI DI STUDIO ==========
  static const List<String> studyYears = [
    '1° anno',
    '2° anno',
    '3° anno',
    '4° anno',
    '5° anno',
    'Università - 1° anno',
    'Università - 2° anno',
    'Università - 3° anno',
    'Università - Magistrale',
    'Altro',
  ];

  // ========== INDIRIZZI SCOLASTICI / UNIVERSITARI ==========
  static const List<String> studyAddresses = [
    'Liceo Scientifico',
    'Liceo Classico',
    'Liceo Linguistico',
    'Liceo delle Scienze Umane',
    'Istituto Tecnico - Informatica',
    'Istituto Tecnico - Economia',
    'Istituto Tecnico - Meccanica',
    'Istituto Professionale',
    'Università - Informatica',
    'Università - Economia',
    'Università - Ingegneria',
    'Università - Medicina',
    'Università - Giurisprudenza',
    'Università - Lettere',
    'Università - Scienze',
    'Altro',
  ];

  // ========== MATERIE COMUNI ==========
  static const List<String> subjects = [
    'Matematica',
    'Fisica',
    'Chimica',
    'Biologia',
    'Informatica',
    'Italiano',
    'Storia',
    'Filosofia',
    'Inglese',
    'Economia',
    'Diritto',
    'Geografia',
    'Arte',
    'Educazione Fisica',
    'Altro',
  ];
}
