import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    // Built-in Kotlin is disabled in gradle.properties because google_sign_in_android
    // still applies the legacy kotlin-android plugin.
    id("org.jetbrains.kotlin.android")
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kyriez.recally"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.kyriez.recally"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// The Kotlin plugin defaults to the JDK that runs Gradle (25), while the Java
// compile options above target 17. Keep both at 17.
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
