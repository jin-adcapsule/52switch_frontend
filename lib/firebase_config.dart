// lib/firebase_config.dart

import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:convert'; // For JSON parsing
import 'env_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // The dynamically generated file

class FirebaseConfig {
  // Method to load Firebase configuration dynamically
  static Future<void> loadFirebaseConfig() async {
    // Initialize Firebase with the dynamically generated DefaultFirebaseOptions
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized with DefaultFirebaseOptions.');
    
    if (EnvConfig.useEmulator){  // Initialize Firebase Emulator if required
      FirebaseAuth.instance.useAuthEmulator(EnvConfig.hostAddress, EnvConfig.emulatorPort);
      }
    // Check if Firebase config for Android or iOS is available through environment variables
    if (Platform.isAndroid) {
      await _loadGoogleServicesJsonFromEnv();
    } else if (Platform.isIOS) {
      await _loadGoogleServiceInfoPlist();
    }
  }

  // Load `google-services.json` for Android from environment variable
  static Future<void> _loadGoogleServicesJsonFromEnv() async {
    // Retrieve the Google Services JSON content from environment variable
    String googleServicesJson = const String.fromEnvironment('GOOGLE_SERVICES_JSON_DEV');
    if (googleServicesJson.isNotEmpty) {
      print('Using GOOGLE_SERVICES_JSON from environment variable for Firebase configuration.');
      // You can parse and apply the configuration if needed, or simply initialize Firebase
      Map<String, dynamic> googleServices = jsonDecode(googleServicesJson);
      print('google-services.json: $googleServices'); // Print or process the JSON as needed
    } else {
      print('GOOGLE_SERVICES_JSON_DEV environment variable not found.');
    }
  }

  /// Load `GoogleService-Info.plist` for iOS (placed in ios/Runner/)
  static Future<void> _loadGoogleServiceInfoPlist() async {
    try {
      // Read the contents of the GoogleService-Info.plist for iOS
      String googleServiceInfoPlist = await File('ios/Runner/GoogleService-Info.plist').readAsString();
      if (googleServiceInfoPlist.isNotEmpty) {
        print('Using GoogleService-Info.plist for Firebase configuration.');
        // Process the Plist content if necessary
        print('GoogleService-Info.plist: $googleServiceInfoPlist');
      } else {
        print('GoogleService-Info.plist not found.');
      }
    } catch (e) {
      print('Error loading GoogleService-Info.plist: $e');
    }
  }
}
