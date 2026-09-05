import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.batkhela.marketplace.mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.batkhela.marketplace.mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Safe fallback placeholder for Google Maps API Key
        manifestPlaceholders["MAPS_API_KEY"] = project.findProperty("MAPS_API_KEY") as? String ?: "AIzaSy_BATKHELA_MARKETPLACE_PLACEHOLDER_KEY"
    }

    signingConfigs {
        create("release") {
            val keyPasswordProp = keystoreProperties.getProperty("keyPassword")
            val storePasswordProp = keystoreProperties.getProperty("storePassword")
            val keyAliasProp = keystoreProperties.getProperty("keyAlias")
            val storeFileProp = keystoreProperties.getProperty("storeFile")

            if (keyPasswordProp != null && storePasswordProp != null && keyAliasProp != null && storeFileProp != null) {
                keyPassword = keyPasswordProp
                storePassword = storePasswordProp
                keyAlias = keyAliasProp
                storeFile = file(storeFileProp)
            }
        }
    }

    buildTypes {
        release {
            val releaseStoreFile = signingConfigs.getByName("release").storeFile
            signingConfig = if (releaseStoreFile != null && releaseStoreFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
