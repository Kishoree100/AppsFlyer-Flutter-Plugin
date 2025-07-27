plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.AF_Kish.af_kish"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    signingConfigs {
        getByName("debug") {
            storeFile = file("/Users/kishoree.londhe/AF_Kish_release.keystore")
            storePassword = "123456"
            keyAlias = "afkish_key"
            keyPassword = "123456"
        }
        create("release") {
            storeFile = file("/Users/kishoree.londhe/AF_Kish_release.keystore")
            storePassword = "123456"
            keyAlias = "afkish_key"
            keyPassword = "123456"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.AF_Kish.af_kish"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
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
