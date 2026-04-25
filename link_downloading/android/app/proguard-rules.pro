# ─── Flutter ProGuard Rules ──────────────────────────────
# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep Hive generated classes
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Suppress warnings for common Flutter dependencies
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**

# Keep R8 from stripping Gson/JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
