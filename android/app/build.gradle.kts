import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing secrets are loaded from `android/key.properties` (git-ignored;
// see android/key.properties.example). The file is absent on machines/CI without
// the production keystore, and the release build falls back to the debug key
// there so `flutter run --release` still works. rootProject is the `android/`
// folder, so this resolves to android/key.properties.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "in.sreerajp.contact_sphere"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Was required by flutter_local_notifications (now removed); left on
        // since another plugin may still need it — check before disabling.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "in.sreerajp.contact_sphere"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Telecom InCallService (default phone app) requires API 23+; we floor at
        // 24 and guard API 26/29 features (ANSWER_PHONE_CALLS / RoleManager) at
        // runtime. maxOf keeps us above Flutter's default if it ever rises.
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Built from android/key.properties when present. storeFile is resolved
        // relative to this module (android/app), so `../../keystore.jks` points at
        // the repo root where the keystore lives.
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Use the real release key when key.properties is set up; otherwise
            // fall back to the shared debug key so `flutter run --release` still
            // works for anyone without the production keystore.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"      // -> in.sreerajp.contact_sphere.dev
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "SreerajP Contacts Sphere Dev")
        }
        create("prod") {
            dimension = "env"
            // keeps applicationId = in.sreerajp.contact_sphere
            resValue("string", "app_name", "SreerajP Contacts Sphere")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.zxing:core:3.5.3")
}
