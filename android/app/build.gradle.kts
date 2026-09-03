import java.io.File
import java.io.FileInputStream
import java.time.LocalDate
import java.util.Properties
import org.gradle.api.GradleException

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

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use(localProperties::load)
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException(
        "Flutter SDK path not found. Set flutter.sdk in android\\local.properties or FLUTTER_ROOT."
    )

val isWindowsHost = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
val dartExecutable = File(
    flutterSdkPath,
    if (isWindowsHost) "bin\\dart.bat" else "bin/dart",
)
val projectRootDir = rootProject.projectDir.parentFile

val generateBuildMetadata = tasks.register("generateBuildMetadata") {
    group = "build setup"
    description = "Generates About-screen build metadata before Android builds."

    inputs.file(projectRootDir.resolve("pubspec.yaml"))
    inputs.file(projectRootDir.resolve("tool/generate_app_version.dart"))
    inputs.file(projectRootDir.resolve("tool/generate_build_date.dart"))
    inputs.property("metadataBuildDate", LocalDate.now().toString())
    outputs.file(projectRootDir.resolve("lib/core/constants/app_version.g.dart"))
    outputs.file(projectRootDir.resolve("lib/core/constants/build_date.g.dart"))

    doLast {
        if (!dartExecutable.exists()) {
            throw GradleException(
                "Could not find Dart executable at ${dartExecutable.absolutePath}. " +
                    "Check android\\local.properties flutter.sdk or FLUTTER_ROOT."
            )
        }

        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_app_version.dart")
        }
        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_build_date.dart")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(generateBuildMetadata)
}

tasks.matching { task ->
    task.name.startsWith("compileFlutterBuild")
}.configureEach {
    dependsOn(generateBuildMetadata)
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
                val releaseConfig = signingConfigs.getByName("release")
                val resolvedStore = releaseConfig.storeFile
                if (resolvedStore == null || !resolvedStore.exists()) {
                    throw GradleException(
                        "Release signing error: keystore file not found at ${resolvedStore?.absolutePath ?: "unspecified"}. " +
                            "Check storeFile in android/key.properties."
                    )
                }
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }

            // R8 code minification and resource shrinking for hardened release builds:
            isMinifyEnabled = true
            isShrinkResources = true

            // R8 needs proguard-rules.pro: the ML Kit text recognizer plugin
            // references script recognizers this app does not bundle, which
            // otherwise fails the release build.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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

    // JVM unit tests for the native call layer (android/app/src/test). Covers the
    // pure logic only — RingerPolicy, number match keys, quiet hours — so plain
    // JUnit is enough and no Robolectric/instrumentation is needed. The app has
    // dev/prod flavors, so the task is flavored:
    //     cd android && ./gradlew :app:testDevDebugUnitTest
    testImplementation("junit:junit:4.13.2")
}
