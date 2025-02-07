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

# Keep Play Core SplitInstall classes to prevent R8 from removing them (if using dynamic features)
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; }

# Prevent removal of main methods
-keepclassmembers class * {
    public static void main(java.lang.String[]);
}

# Disable obfuscation for specific methods or classes (optional)
-dontobfuscate
