//-ignored credential or environment dependant data


class EnvConfig {
  // Get the host address for the platform
  static String get hostAddress => const String.fromEnvironment('HOST_ADDRESS', defaultValue: 'localhost');

  // Get the port number for the platform
  static int get serverPort => const int.fromEnvironment('SERVER_PORT', defaultValue: 8080);

  // Check if we should use the emulator
  static bool get useEmulator => const bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  // Get the emulator port if needed
  static int get emulatorPort => const int.fromEnvironment('EMULATOR_PORT', defaultValue: 9099);
  /*
  static const bool useEmulator = true; // Set to true to use emulator
  static const String hostAddress= '10.0.0.176'; // host for both server and emulator
  static const int emulatorPort = 9099; // Auth Emulator Port
  static const int serverPort = 8080; // Auth Emulator Port


  static const String apiUrl = 'http://10.0.0.176:8080/graphql';//apiurl from ipv4 address 10.0.0.185 // 172.30.1.37
  static const String apiWebSocketUrl = "ws://10.0.0.176:8080/graphql"; // Add this


  static const String emulatorHostIOS = '10.0.0.176';//'127.0.0.1';//'localhost'; // iOS uses localhostipconeee
  static const String emulatorHostAndroid = '10.0.0.176'; // Android uses 10.0.2.2
    */
  // Get the API URL (constructed dynamically)
  static String get apiUrl => 'http://$hostAddress:$serverPort/graphql';



}
