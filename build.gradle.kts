import org.jetbrains.kotlin.gradle.targets.js.nodejs.NodeJsRootExtension
import org.jetbrains.kotlin.gradle.targets.js.nodejs.NodeJsRootPlugin
import org.jetbrains.kotlin.gradle.targets.js.npm.tasks.KotlinNpmInstallTask

plugins {
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.multiplatform) apply false
}

buildscript {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        google()
    }

    dependencies {
        classpath(libs.atomicfu.gradle.plugin)
    }
}

allprojects {
    group = "com.rickclephas.kmp"
    version = "1.0.0-BETA-3-kotlin-2.0.20-Beta1"

    repositories {
        mavenCentral()
        google()
    }
}

// TODO: Remove once default NodeJS version supports wasm
plugins.withType<NodeJsRootPlugin> {
    extensions.configure(NodeJsRootExtension::class) {
        version = "21.0.0-v8-canary20231019bd785be450"
        downloadBaseUrl = "https://nodejs.org/download/v8-canary"
    }
    tasks.withType<KotlinNpmInstallTask> {
        args.add("--ignore-engines")
    }
}
