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
    // Initialize Firebase with the default options from the google-services.json (Android) or GoogleService-Info.plist (iOS)
    await Firebase.initializeApp();
    LoggerConfig()
      .logger
      .i("Firebase initialized with default file.");

    if (EnvConfig.useEmulator) {
      // Initialize Firebase Emulator if required
      FirebaseAuth.instance
          .useAuthEmulator(EnvConfig.hostAddress, EnvConfig.emulatorPort);
    }
  }
}
