plugins {
    id("com.android.application")
    // id("com.google.gms.google-services")   // Disabled: needs google-services.json with com.captus.app
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.captus.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.captus.app"
        minSdk = flutter.minSdkVersion            // Required by flutter_local_notifications
        targetSdk = 34         // Android 14 — current stable target
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // TODO: Replace with your own keystore before publishing to Play Store.
            // Configure key.properties and add a signingConfigs block.
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // applicationIdSuffix = ".debug" — removed: google-services.json only
            // registers com.captus.app; adding the suffix breaks processDebugGoogleServices.
            // To re-enable, register com.captus.app.debug in Firebase Console first.
            versionNameSuffix = "-debug"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
