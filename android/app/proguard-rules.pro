# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.database.** { *; }
-dontwarn com.google.firebase.**

# Flutter-related rules
-keep class io.flutter.** { *; }

# Keep Firebase reflection-based fields (if needed)
-keepclassmembers class * {
    @com.google.firebase.database.IgnoreExtraProperties <fields>;
}
-keepclassmembers class * {
    @com.google.firebase.firestore.IgnoreExtraProperties <fields>;
}

# Keep any other necessary classes
# -keep class com.example.** { *; }

# Prevent removal of main methods
-keepclassmembers class * {
    public static void main(java.lang.String[]);
}

# Disable obfuscation for specific methods or classes
-dontobfuscate
# Keep Play Core classes to prevent R8 from removing them
-keep class com.google.android.play.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }