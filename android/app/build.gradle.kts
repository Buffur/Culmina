import java.util.Properties
import java.security.KeyStore

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// GitHub Releases distributes this APK with the owner's signing key.
// Secrets stay in gitignored android/key.properties; see docs/RELEASE.md.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasUploadKey = listOf("storePassword", "keyPassword", "keyAlias", "storeFile")
    .all { !keystoreProperties.getProperty(it).isNullOrBlank() }

val requireReleaseSigning = tasks.register("requireReleaseSigning") {
    doLast {
        check(hasUploadKey) {
            "Release requires complete android/key.properties. Use debug/profile for local development."
        }
        val store = KeyStore.getInstance(
            file(keystoreProperties.getProperty("storeFile")),
            keystoreProperties.getProperty("storePassword").toCharArray()
        )
        val alias = keystoreProperties.getProperty("keyAlias")
        val certificate = store.getCertificate(alias) as? java.security.cert.X509Certificate
        check(store.isKeyEntry(alias) && certificate != null) { "Release signing key missing." }
        check(!certificate.subjectX500Principal.name.contains("CN=Android Debug", ignoreCase = true)) {
            "Android Debug certificates cannot sign distribution releases."
        }
    }
}

// Guard the artifact-producing tasks as well as the normal signing task.
// There is deliberately no debug-key fallback or bypass for release builds.
tasks.configureEach {
    if (name in listOf("validateSigningRelease", "packageRelease", "packageReleaseBundle")) {
        dependsOn(requireReleaseSigning)
    }
}

android {
    namespace = "io.github.buffur.culmina"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // RA.D ID-3 (S13.2; replaces OD-07's id); permanent from the first public release.
        applicationId = "io.github.buffur.culmina"
        // Flutter's defaults (Flutter 3.47.4: min 24, target 36). Play requires
        // target 36 for new apps and updates from 31 Aug 2026 (TASK 16.2).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            // Native verification uses a separate install and data sandbox.
            if (providers.gradleProperty("CULMINA_VERIFICATION").orNull == "true") {
                applicationIdSuffix = ".verification"
            }
        }
        release {
            signingConfig = if (hasUploadKey) {
                signingConfigs.getByName("release")
            } else {
                null
            }
            // R8 (code shrinking and resource shrinking) is on for release,
            // as the Flutter Gradle plugin sets it (TASK 16.2 decision).
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

dependencies {
    testImplementation("junit:junit:4.13.2")
}
