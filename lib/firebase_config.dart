// lib/firebase_config.dart

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
//import 'dart:io';
//import 'dart:convert'; // For JSON parsing
import 'env_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger_config.dart';

class FirebaseConfig {
  // Method to load Firebase configuration dynamically
  static Future<void> loadFirebaseConfig() async {
    // Initialize Firebase with the dynamically generated DefaultFirebaseOptions
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
    FirebaseOptions firebaseOptions;

    print("firebase_options.dart not found, falling back to environment variables.");

    // Fallback to environment variables if `firebase_options.dart` is missing
    if (Platform.isAndroid) {
      firebaseOptions = FirebaseOptions(
        apiKey: const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
        appId: const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      );
    } else if (Platform.isIOS) {
      firebaseOptions = FirebaseOptions(
        apiKey: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
        appId: const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
        messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      );
    } else {
      throw UnsupportedError("Unsupported platform");
    }
      LoggerConfig()
      .logger
      .i("Firebase initialized with injected values.");
    

    await Firebase.initializeApp(options: firebaseOptions);

    if (EnvConfig.useEmulator) {
      // Initialize Firebase Emulator if required
      FirebaseAuth.instance
          .useAuthEmulator(EnvConfig.hostAddress, EnvConfig.emulatorPort);
    }
  }
}
