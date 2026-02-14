import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.devtools.ksp")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val packageName = "deckers.thibault.aves"

// Keys

val keystoreProperties = Properties()
val keystorePropertiesFile: File = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    println("Load keystore props from file=$keystorePropertiesFile")
    // for release using credentials stored in a local file
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} else {
    println("Load keystore props from system environment")
    // for release using credentials in environment variables set up by GitHub Actions
    // warning: in property file, single quotes should be escaped with a backslash
    // but they should not be escaped when stored in env variables
    keystoreProperties["storeFile"] = System.getenv("AVES_STORE_FILE") ?: "<NONE>"
    keystoreProperties["storePassword"] = System.getenv("AVES_STORE_PASSWORD") ?: "<NONE>"
    keystoreProperties["keyAlias"] = System.getenv("AVES_KEY_ALIAS") ?: "<NONE>"
    keystoreProperties["keyPassword"] = System.getenv("AVES_KEY_PASSWORD") ?: "<NONE>"
    keystoreProperties["googleApiKey"] = System.getenv("AVES_GOOGLE_API_KEY") ?: "<NONE>"
}

android {
    namespace = "deckers.thibault.aves"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // enable support for the new language APIs on older devices
        // e.g. `java/util/function/Supplier` on Android 5.0 (API 21)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = packageName
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleApiKey"] = keystoreProperties["googleApiKey"] ?: "<NONE>"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    flavorDimensions += "store"

    productFlavors {
        create("play") {
            // Google Play
            dimension = "store"
        }

        create("izzy") {
            // IzzyOnDroid
            // check offending libraries with `scanapk`
            // cf https://android.izzysoft.de/articles/named/app-modules-2
            dimension = "store"
        }

        create("libre") {
            // F-Droid
            // check offending libraries with `fdroidserver`
            // cf https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/
            dimension = "store"
            applicationIdSuffix = ".libre"
        }

        create("libre_rom") {
            // integration in custom ROM
            dimension = "store"
            applicationIdSuffix = ".libre"

            packaging {
                // disable compression for native libraries (.so files)
                jniLibs.useLegacyPackaging = false
            }
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
        }

        getByName("profile") {
            applicationIdSuffix = ".profile"
        }

        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // NDK ABI filters are incompatible with split APK generation,
            // but filters are necessary to exclude x86 native libs from universal APKs
            // cf https://github.com/flutter/flutter/issues/37566#issuecomment-640879500
            var useNdkAbiFilters = true
            if (rootProject.extra.has("split-per-abi")) {
                val splitPerAbi = rootProject.extra["split-per-abi"]
                if (splitPerAbi == "true" || splitPerAbi == true) {
                    useNdkAbiFilters = false
                }
            }
            if (useNdkAbiFilters) {
                ndk {
                    //noinspection ChromeOsAbiSupport
                    abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
                }
            }
        }

        val abiCodes = mapOf(
            "armeabi-v7a" to 1,
            "arm64-v8a" to 2,
            "x86" to 3,
            "x86_64" to 4
        )

        applicationVariants.all {
            println("Application variant applicationId=$applicationId name=$name")

            resValue("string", "screen_saver_settings_activity", "${applicationId}/${packageName}.ScreenSaverSettingsActivity")
            resValue("string", "search_provider", "${applicationId}.search_provider")

            outputs.forEach { output ->
                val abi = output.filters.find { it.filterType == "ABI" }?.identifier
                val baseAbiVersionCode = abiCodes[abi]
                if (baseAbiVersionCode != null) {
                    val versionCodeOverride = versionCode * 100 + baseAbiVersionCode
                    println("  output versionCodeOverride=$versionCodeOverride for abi=$abi")
                    (output as ApkVariantOutputImpl).versionCodeOverride = versionCodeOverride
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

repositories {
    maven {
        url = uri("https://jitpack.io")
        content {
            includeGroup("com.github.deckerst")
            includeGroup("com.github.deckerst.mp4parser")
        }
    }
    maven {
        url = uri("https://s3.amazonaws.com/repo.commonsware.com")
        content {
            excludeGroupByRegex("com\\.github\\.deckerst.*")
        }
    }
}

dependencies {
    // cf https://developer.android.com/studio/write/java8-support#library-desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")

    implementation("androidx.annotation:annotation:1.9.1")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.lifecycle:lifecycle-process:2.10.0")
    implementation("androidx.media:media:1.7.1")
    implementation("androidx.multidex:multidex:2.0.1")
    // Jetpack `security-crypto` library is deprecated:
    // https://developer.android.com/privacy-and-security/cryptography#security-crypto-jetpack-deprecated
    implementation("androidx.security:security-crypto:1.1.0")
    implementation("androidx.work:work-runtime:2.11.1")

    val glideVersion = "5.0.5"
    implementation("com.commonsware.cwac:document:0.5.0")
    implementation("com.drewnoakes:metadata-extractor:2.19.0")
    implementation("com.github.bumptech.glide:glide:$glideVersion")
    implementation("com.google.android.material:material:1.13.0")
    // SLF4J implementation for `mp4parser`
    implementation("org.slf4j:slf4j-simple:2.0.17")

    // forked, built by JitPack:
    // - https://jitpack.io/p/deckerst/Android-TiffBitmapFactory
    // - https://jitpack.io/p/deckerst/androidsvg
    // - https://jitpack.io/p/deckerst/mp4parser
    // - https://jitpack.io/p/deckerst/pixymeta-android
    implementation("com.github.deckerst:Android-TiffBitmapFactory:424b18a4ae")
    implementation("com.github.deckerst:androidsvg:c7e58e8e59")
    implementation("com.github.deckerst.mp4parser:isoparser:c2898f1832")
    implementation("com.github.deckerst.mp4parser:muxer:c2898f1832")
    implementation("com.github.deckerst:pixymeta-android:f4513291b7")
    implementation(project(":exifinterface"))

    testImplementation("org.junit.jupiter:junit-jupiter-engine:6.0.2")

    ksp("com.github.bumptech.glide:ksp:$glideVersion")

    compileOnly(rootProject.findProject(":streams_channel")!!)
}

if (rootProject.extra["aves.useCrashlytics"] as Boolean) {
    println("Building flavor with Crashlytics plugin")
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
} else {
    println("Building flavor without reporting plugin")
}
