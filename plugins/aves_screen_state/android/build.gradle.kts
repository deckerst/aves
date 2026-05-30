group = "deckers.thibault.aves.aves_screen_state"
version = "1.0-SNAPSHOT"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath(libs.gradle)
        classpath(libs.kotlin.gradlePlugin)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // TODO TLAD find how to use `alias(libs.plugins.android.library)` without error:
    // > The request for this plugin could not be satisfied because the plugin is already
    // on the classpath with an unknown version, so compatibility cannot be checked.
    id("com.android.library")
}

android {
    namespace = "deckers.thibault.aves.aves_screen_state"
    compileSdk = 37

    kotlin {
        jvmToolchain(21)
    }

    sourceSets {
        getByName("main") {
            java.directories.add("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}
