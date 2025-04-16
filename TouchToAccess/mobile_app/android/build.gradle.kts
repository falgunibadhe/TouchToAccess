plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Remove the firebase plugin entry
    // id("com.google.gms.google-services")  version "4.4.2" apply false
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mobileapp"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.mobileapp"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    classpath 'com.android.tools.build:gradle:7.2.1'

    // Remove any firebase-related dependencies
    // implementation(platform("com.google.firebase:firebase-bom:32.7.3"))
    // implementation("com.google.firebase:firebase-messaging")
}
