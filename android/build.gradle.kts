// Project-level build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Updated Kotlin Gradle plugin to 2.1.0
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        
        // Android Gradle Plugin version (ensure compatibility with Gradle)
        classpath("com.android.tools.build:gradle:8.1.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect build directories outside project folder
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure app is evaluated before subprojects
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
