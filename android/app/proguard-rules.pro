# Captus ProGuard / R8 rules

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase / Realtime
-keep class io.github.jan.supabase.** { *; }

# Keep model classes used by JSON serialisation
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# OkHttp / Dio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# Speech to text
-keep class com.codeheadlabs.google.speechtotext.** { *; }
