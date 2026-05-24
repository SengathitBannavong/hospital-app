// lib/main.dart  ← REPLACE your existing main.dart with this

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/firebase_notification_service.dart';
import 'firebase_options.dart'; // ← uncomment after running flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Missing .env file\n');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ← uncomment after flutterfire configure
  );

  // Initialize notification service (background handler must be registered early)
  await FirebaseNotificationService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}