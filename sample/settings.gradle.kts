pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        google()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven("https://androidx.dev/storage/compose-compiler/repository/")
    }
}

rootProject.name = "sample"

include(":androidApp")
include(":shared")

includeBuild("..") {
    dependencySubstitution {
        substitute(module("com.rickclephas.kmm:kmm-viewmodel-core"))
            .using(project(":kmm-viewmodel-core"))
    }
}

dependencyResolutionManagement {
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}
