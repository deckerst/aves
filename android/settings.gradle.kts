pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version ("0.4.0")
}

include(":app")

val localPropertiesFile = File(rootProject.projectDir, "local.properties")
val properties = java.util.Properties()

assert(localPropertiesFile.exists())
localPropertiesFile.reader(Charsets.UTF_8).also { reader -> properties.load(reader) }

val flutterSdkPath: String? = properties.getProperty("flutter.sdk")
assert(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }

apply {
    from("$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}