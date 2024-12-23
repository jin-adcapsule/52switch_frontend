// lib/firebase_config.dart
import 'package:logger/logger.dart';

class LoggerConfig {
// Singleton pattern for the Logger
  static final LoggerConfig _instance = LoggerConfig._internal();
  final Logger logger;

  factory LoggerConfig() {
    return _instance;
  }

  LoggerConfig._internal() : logger = Logger(); // Private constructor
}