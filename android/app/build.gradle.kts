import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // Firebase Analytics (pode adicionar outros aqui)
    implementation("com.google.firebase:firebase-analytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keys.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
} else {
    throw GradleException("Arquivo keys.properties não encontrado.")
}

android {
    namespace = "com.malves.bang_temp"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.malves.bang_temp"
        minSdk = 23
        targetSdk = 35
        versionCode = 4
        versionName = "1.0.2"
    }

    signingConfigs {
        create("release") {
            val path = keystoreProperties["storeFile"] as String?
                ?: throw GradleException("Missing 'storeFile' in keys.properties")
            storeFile = file(path)
            storePassword = keystoreProperties["storePassword"] as String?
                ?: throw GradleException("Missing 'storePassword' in keys.properties")
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: throw GradleException("Missing 'keyAlias' in keys.properties")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: throw GradleException("Missing 'keyPassword' in keys.properties")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
