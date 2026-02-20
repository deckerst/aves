pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Settings plugins (`Plugin<Settings>`) must be applied in the settings script.
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
    // define versions
    // TODO TLAD find how to use `alias(libs.plugins.android.application)`
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.3.0" apply false
}

include(":app")
include(":exifinterface")
