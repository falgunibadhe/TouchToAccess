plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Removed the Firebase plugin
    // id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mobileapp" // Replace as needed
    compileSdk = 32

    defaultConfig {
        applicationId = "com.example.mobileapp"
        minSdk = 21
        targetSdk = 32
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    // Removed Firebase BOM and Analytics dependencies
    // implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
    // implementation("com.google.firebase:firebase-analytics")
}
