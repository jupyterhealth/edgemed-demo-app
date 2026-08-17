plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.jupyter.health"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.jupyter.health"
        minSdk = 29
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            // TODO Uncomment and specify you debug key if needed
            // keyAlias = "androiddebugkey"
            // keyPassword = "android"
            // storeFile = file("keystore/debug.keystore")
            // storePassword = "android"
        }

        create("stagingRelease") {
            keyAlias = System.getenv("BITRISEIO_ANDROID_KEYSTORE_STAGING_ALIAS")
            keyPassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_STAGING_PRIVATE_KEY_PASSWORD")
            storeFile = file(System.getenv("HOME") + "/keystores/staging.keystore")
            storePassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_STAGING_PASSWORD")
        }        
        create("preprodRelease") {
            keyAlias = System.getenv("BITRISEIO_ANDROID_KEYSTORE_PREPROD_ALIAS")
            keyPassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_PREPROD_PRIVATE_KEY_PASSWORD")
            storeFile = file(System.getenv("HOME") + "/keystores/preprod.keystore")
            storePassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_PREPROD_PASSWORD")
        }
        create("prodRelease") {
            keyAlias = System.getenv("BITRISEIO_ANDROID_KEYSTORE_ALIAS")
            keyPassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD")
            storeFile = file(System.getenv("HOME") + "/keystores/prod.keystore")
            storePassword = System.getenv("BITRISEIO_ANDROID_KEYSTORE_PASSWORD")
        } 
    }    

    flavorDimensions += "env"

    productFlavors {
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            signingConfig = signingConfigs.getByName("stagingRelease")
        }
        create("preprod") {
            dimension = "env"
            applicationIdSuffix = ".preprod"
            signingConfig = signingConfigs.getByName("preprodRelease")
        }
        create("prod") {
            dimension = "env"
            signingConfig = signingConfigs.getByName("prodRelease")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
  implementation(platform("com.google.firebase:firebase-bom:34.17.0"))
  // AGP 9 R8 full mode: older work-runtime lacks consumer rules for WorkDatabase_Impl.
  implementation("androidx.work:work-runtime:2.11.1")
}

flutter {
    source = "../.."
}
