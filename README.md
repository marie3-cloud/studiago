# StudiaGo

App Flutter Web (PWA) per studenti: appunti, richieste di aiuto, chat e profilo personalizzato per anno di studio e indirizzo.

## Caratteristiche

- Autenticazione completa con Supabase (Login / Registrazione)
- Registrazione obbligatoriamente con Anno di studio e Indirizzo scolastico/universitario
- Home con feed personalizzato in base a anno + indirizzo
- Appunti: carica, visualizza, scarica (PDF, immagini, ecc.)
- Richieste di aiuto: pubblica richieste, rispondi, contatta in privato
- Chat private con supporto messaggi testuali e infrastruttura per vocali
- Profilo modificabile (nome, bio, anno, indirizzo, avatar)
- PWA installabile su smartphone e desktop
- 100% Flutter Web – nessun plugin solo-nativo

## Setup rapido

### 1. Configura Supabase

1. Crea un progetto su supabase.com
2. Vai su SQL Editor e incolla tutto il contenuto di supabase_schema.sql
3. Vai su Storage e crea 3 bucket: notes (public), avatars (public), voice-messages (private)
4. Copia Project URL e anon key da Settings → API

### 2. Configura le chiavi

Apri lib/utils/constants.dart e sostituisci:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Esegui in locale

```bash
flutter pub get
flutter run -d chrome
```

### 4. Build PWA per Vercel

```bash
flutter build web --release --base-href /
```

La cartella build/web e pronta per essere deployata su Vercel.

## Struttura progetto

```
lib/
  main.dart
  models/          # User, Note, Request, Chat
  providers/       # AuthProvider
  screens/
    auth/          # Login, Register
    home/
    notes/         # Lista, dettaglio, upload
    search/        # Richieste e ricerca
    chat/          # Conversazioni e chat
    profile/       # Profilo e modifica
  services/        # SupabaseService
  utils/           # constants, theme, router
web/
  index.html       # PWA-ready
  manifest.json
  icons/
```

## Pacchetti utilizzati (tutti web-compatible)

- supabase_flutter
- go_router
- provider
- google_fonts
- file_picker
- image_picker
- url_launcher
- cached_network_image
- intl
- uuid

## Note sui messaggi vocali

L'infrastruttura (bucket + upload + modello messaggio) e completa.
Su Flutter Web la registrazione audio richiede MediaRecorder via JS interop.
E presente un placeholder informativo: puoi integrare facilmente un package o interop quando necessario.
