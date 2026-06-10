# Gson (de)serializes these model classes by reflecting on field names; R8 must not rename or
# strip them, or the JSON stops mapping and the widget reads an empty trip (release-only bug).
-keep class io.github.ludvigcarlsen.retur.** { *; }
-keepattributes Signature, *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
