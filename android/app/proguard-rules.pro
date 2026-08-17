# ProGuard / R8 rules for the release build.
#
# google_mlkit_text_recognition (business card scanner) compiles against all five
# ML Kit script recognizers, but this app only bundles the Latin one — see
# BusinessCardScanService. R8 therefore reports the other four option classes as
# missing and fails the release build. They are never reached at runtime because
# nothing asks for a non-Latin script, so warning about them is safe to silence.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
