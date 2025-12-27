plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.reciept_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.reciept_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (System.getenv("CI") == "true") {
                // Codemagic CI environment - uses CM_* prefixed environment variables
                val keystorePath = System.getenv("CM_KEYSTORE_PATH")
                val keystorePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                val keyAlias = System.getenv("CM_KEY_ALIAS")
                val keyPassword = System.getenv("CM_KEY_PASSWORD")
                
                // Validate that all required signing variables are present
                if (keystorePath.isNullOrBlank()) {
                    throw GradleException("CM_KEYSTORE_PATH environment variable is not set. Please configure it in Codemagic environment variables.")
                }
                if (keystorePassword.isNullOrBlank()) {
                    throw GradleException("CM_KEYSTORE_PASSWORD environment variable is not set. Please configure it in Codemagic environment variables.")
                }
                if (keyAlias.isNullOrBlank()) {
                    throw GradleException("CM_KEY_ALIAS environment variable is not set. Please configure it in Codemagic environment variables.")
                }
                print("my keys are $keyAlias, $keystorePassword")
                if (keyPassword.isNullOrBlank()) {
                   print("my keys are $keyAlias, $keystorePassword but keyPassword is missing")
                    throw GradleException("CM_KEY_PASSWORD environment variable is not set. Please configure it in Codemagic environment variables.")
                }
                
                storeFile = project.file(keystorePath)
                storePassword = keystorePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            } else {
                // Local development - use key.properties file
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { project.file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
