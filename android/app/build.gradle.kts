plugins {
    id("com.android.application")
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    
    id("org.jetbrains.kotlin.android") // ✅ Remove version here
    
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.testadm"
    compileSdk = 36   // ✅ updated

    defaultConfig {
        applicationId = "com.example.testadm"
        minSdk = flutter.minSdkVersion
        targetSdk = 36   // ✅ updated
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
