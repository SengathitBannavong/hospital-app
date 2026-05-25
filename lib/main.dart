import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/firebase_notification_service.dart';
import 'firebase_options.dart';

const _enableFirebase = bool.fromEnvironment('ENABLE_FIREBASE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Missing .env file\n');
  }

  if (_enableFirebase) {
    await _initializeFirebase();
  } else {
    debugPrint('Firebase disabled. Use ENABLE_FIREBASE=true to enable it.');
  }

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initializeFirebase() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options.apiKey.isEmpty) {
    debugPrint('Firebase skipped: missing API key dart-define.');
    return;
  }

  try {
    await Firebase.initializeApp(options: options);
    await FirebaseNotificationService.instance.initialize();
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }
}
