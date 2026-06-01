# ─── Flutter ───────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─── App Models (JSON serialization — CRITICAL for release) ────────────────────
-keep class com.ejabatech.quickin.** { *; }
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve all fromJson / toJson methods and model fields
-keepclassmembers class **.ListingModel { *; }
-keepclassmembers class **.ListingImage { *; }
-keepclassmembers class **.WishlistModel { *; }
-keepclassmembers class **.HostModel { *; }
-keepclassmembers class **.PropertyTypeModel { *; }
-keepclassmembers class **.LifestyleModel { *; }

# ─── Networking ────────────────────────────────────────────────────────────────
# OkHttp (used by cached_network_image & dio)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ─── Image Loading ─────────────────────────────────────────────────────────────
# cached_network_image / flutter_cache_manager
-keep class com.baseflow.cachemanager.** { *; }
-dontwarn com.squareup.picasso.**

# ─── Supabase / Realtime ───────────────────────────────────────────────────────
-keep class io.github.jan.supabase.** { *; }
-dontwarn io.github.jan.supabase.**

# ─── Kotlin / Coroutines ───────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# ─── General Safety ────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
