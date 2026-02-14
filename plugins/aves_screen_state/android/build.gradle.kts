group = "deckers.thibault.aves.aves_screen_state"
version = "1.0-SNAPSHOT"

buildscript {
    val agp_version = "8.13.2"
    val kotlin_version = "2.3.0"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:$agp_version")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "deckers.thibault.aves.aves_screen_state"
    compileSdk = 36

    kotlin {
        jvmToolchain(17)
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}
