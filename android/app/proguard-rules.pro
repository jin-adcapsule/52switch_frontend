# Keep Firebase Authentication and FCM classes
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Firebase Core
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter-related rules
-keep class io.flutter.** { *; }

# Keep Firebase reflection-based fields (for database or Firestore if used)
-keepclassmembers class * {
    @com.google.firebase.database.IgnoreExtraProperties <fields>;
}
-keepclassmembers class * {
    @com.google.firebase.firestore.IgnoreExtraProperties <fields>;
}

# Keep Play Core classes to prevent R8 from removing them (if using dynamic features)
-keep class com.google.android.play.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }

# Prevent removal of main methods
-keepclassmembers class * {
    public static void main(java.lang.String[]);
}

# Disable obfuscation for specific methods or classes (optional)
-dontobfuscate
