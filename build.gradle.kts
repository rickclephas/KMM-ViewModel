import org.jetbrains.kotlin.gradle.targets.js.nodejs.NodeJsRootExtension
import org.jetbrains.kotlin.gradle.targets.js.nodejs.NodeJsRootPlugin
import org.jetbrains.kotlin.gradle.targets.js.npm.tasks.KotlinNpmInstallTask

plugins {
    @Suppress("DSL_SCOPE_VIOLATION")
    alias(libs.plugins.android.library) apply false
    @Suppress("DSL_SCOPE_VIOLATION")
    alias(libs.plugins.kotlin.multiplatform) apply false
}

buildscript {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        google()
    }
}

allprojects {
    group = "com.rickclephas.kmm"
    version = "1.0.0-ALPHA-20"

    repositories {
        mavenCentral()
        google()
    }
}

// TODO: Remove once default NodeJS version supports wasm
plugins.withType<NodeJsRootPlugin> {
    extensions.configure(NodeJsRootExtension::class) {
        nodeVersion = "21.0.0-v8-canary20231019bd785be450"
        nodeDownloadBaseUrl = "https://nodejs.org/download/v8-canary"
    }
    tasks.withType<KotlinNpmInstallTask> {
        args.add("--ignore-engines")
    }
}
