// lib/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:convert'; // For JSON parsing
import 'env_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConfig {
  // Method to load Firebase configuration dynamically
  static Future<void> loadFirebaseConfig() async {
    // Check if the environment variable FIREBASE_OPTIONS_DART_DEV exists
    String firebaseOptionsCode = const String.fromEnvironment('FIREBASE_OPTIONS_DART_DEV');
    
    if (firebaseOptionsCode.isNotEmpty) {
      print('Using Firebase options from environment variable.');
      // Dynamically generate the FirebaseOptions object based on the passed code
      FirebaseOptions options = _generateFirebaseOptions(firebaseOptionsCode);
      // Initialize Firebase with the generated options
      await _initializeFirebaseWithOptions(options);
    }
    if (EnvConfig.useEmulator){  // Initialize Firebase Emulator if required
      FirebaseAuth.instance.useAuthEmulator(EnvConfig.hostAddress, EnvConfig.emulatorPort);
      }
    // Check if Firebase config for Android or iOS is available through environment variables
    if (Platform.isAndroid) {
      await _loadGoogleServicesJsonFromEnv();
    } else if (Platform.isIOS) {
      await _loadGoogleServiceInfoPlistFromEnv();
    }
  }
// Generate FirebaseOptions from the Dart code string
  static FirebaseOptions _generateFirebaseOptions(String code) {
    final RegExp regex = RegExp(r"(\w+):\s*'([^']+)'");
    final matches = regex.allMatches(code);

    final Map<String, String> parsedOptions = {};
    for (final match in matches) {
      parsedOptions[match.group(1)!] = match.group(2)!;
    }
    print(parsedOptions);
    // Create and return FirebaseOptions from parsed data
    return FirebaseOptions(
      apiKey: parsedOptions['apiKey']!,
      authDomain: parsedOptions['authDomain']!,
      projectId: parsedOptions['projectId']!,
      storageBucket: parsedOptions['storageBucket']!,
      messagingSenderId: parsedOptions['messagingSenderId']!,
      appId: parsedOptions['appId']!,
      measurementId: parsedOptions['measurementId']!,
    );
  }

  // Initialize Firebase with options (for web or custom configurations)
  static Future<void> _initializeFirebaseWithOptions(FirebaseOptions options) async {
    // Firebase initialization logic for custom configurations goes here
    await Firebase.initializeApp(options: options);
    print('Firebase initialized with custom options: $options');
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

  // Load `GoogleService-Info.plist` for iOS from environment variable
  static Future<void> _loadGoogleServiceInfoPlistFromEnv() async {
    // Retrieve the Google Service Info plist content from environment variable
    String googleServiceInfoPlist = const String.fromEnvironment('GOOGLESERVICE_INFO_PLIST_DEV');
    if (googleServiceInfoPlist.isNotEmpty) {
      print('Using GOOGLE_SERVICE_INFO_PLIST from environment variable for Firebase configuration.');
      // The Plist file is an XML format, so if needed, you can parse it here
      print('GoogleService-Info.plist: $googleServiceInfoPlist');
    } else {
      print('GOOGLE_SERVICE_INFO_PLIST_DEV environment variable not found.');
    }
  }
}
