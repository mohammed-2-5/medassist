# ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-dontwarn com.google.mlkit.**

# Flutter Local Notifications - CRITICAL for notifications to work
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# WorkManager - CRITICAL for background tasks
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-dontwarn androidx.work.impl.**

# Timezone data - CRITICAL for scheduled notifications
-keep class net.danlew.android.joda.** { *; }
-keep class org.joda.time.** { *; }
-dontwarn org.joda.**

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Notification payload and actions
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep entry points for notification callbacks
-keep class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Prevent optimization of notification scheduled tasks
-keepclassmembers class * {
    @androidx.work.* *;
}

# Keep notification action handlers
-keep @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Google Play Core (Split Install) - Not used but referenced by Flutter
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Apache Tika (OCR library dependencies)
-dontwarn javax.xml.stream.XMLStreamException
-dontwarn org.apache.tika.**

# Keep OCR text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.vision.** { *; }