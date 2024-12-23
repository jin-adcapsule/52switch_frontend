//navigate to MyInfoScreen after a successful login. You can use the Navigator.pushReplacement to change the screen.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/local_notification_service.dart';
import 'services/notification_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import "firebase_config.dart";

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  
  // Initialize Firebase
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await FirebaseConfig.loadFirebaseConfig();
  /*
  if (EnvConfig.useEmulator) {
    final String host = Platform.isIOS
        ? EnvConfig.emulatorHostIOS
        : EnvConfig.emulatorHostAndroid;
    FirebaseAuth.instance.useAuthEmulator(host, EnvConfig.emulatorPort);
  }
  */
  // Initialize Local Notifications
  LocalNotificationService.initialize();
  // Listen for foreground & background notifications with requesting permission
  NotificationHandler.initialize();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        locale: const Locale('ko', 'KR'), // Set default language to Korean
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('ko', 'KR'), // Korean
        ],
        home: LoginScreen(),// Initial screen is LoginScreen
        routes: {
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}
