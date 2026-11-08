plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.islamic.hafizhasnain.hafiz_hasnain_app"
    compileSdk = 35 // Stable Android 15 compileSdk (Never API 36 preview)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.islamic.hafizhasnain.hafiz_hasnain_app"
        minSdk = 21 // Universal Android 5.0+ compatibility
        targetSdk = 34 // Stable Android 14 targetSdk across all consumer devices
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
        jniLibs {
            useLegacyPackaging = true // Critical fix: avoids unaligned mmap parse failures
        }
    }

    signingConfigs {
        create("release") {
            val localKey = file("release.keystore")
            val debugKey = file("${System.getProperty("user.home")}/.android/debug.keystore")
            if (localKey.exists()) {
                storeFile = localKey
                storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "android123"
                keyAlias = System.getenv("KEY_ALIAS") ?: "releasekey"
                keyPassword = System.getenv("KEY_PASSWORD") ?: "android123"
            } else if (debugKey.exists()) {
                storeFile = debugKey
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            } else {
                initWith(getByName("debug"))
            }
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
