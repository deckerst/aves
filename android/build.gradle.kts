buildscript {
    extra.apply {
        set("aves.agp_version", "8.13.2")
        set("aves.useCrashlytics", gradle.startParameter.taskNames.any { it.contains("play", ignoreCase = true) })
    }
    println("Tasks=${gradle.startParameter.taskNames}")
    println("Extra=\n${extra.properties.entries.map { kv -> "  ${kv.key}=${kv.value}" }.sorted().joinToString("\n")}")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:${rootProject.extra["aves.agp_version"]}")

        if (rootProject.extra["aves.useCrashlytics"] as Boolean) {
            // GMS & Firebase Crashlytics (used by some flavors only)
            classpath("com.google.gms:google-services:4.4.4")
            classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.6")
        }
    }
}

plugins {
    id("org.gradlex.reproducible-builds") version "1.1"
}

allprojects {
    apply(plugin = "org.gradlex.reproducible-builds")

    repositories {
        google()
        mavenCentral()
    }

//    gradle.projectsEvaluated {
//        tasks.withType(JavaCompile) {
//            options.compilerArgs << "-Xlint:unchecked" << "-Xlint:deprecation"
//        }
//    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
