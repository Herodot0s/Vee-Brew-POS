import java.io.File
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import java.util.zip.ZipEntry

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.veebrew.veebrew"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.veebrew.veebrew"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        val customMinSdk = 21
        minSdk = customMinSdk
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

tasks.register("patchFlutterJar") {
    doLast {
        val gradleHome = System.getProperty("user.home") + "/.gradle"
        val cacheDir = File(gradleHome, "caches")
        if (cacheDir.exists()) {
            cacheDir.walkTopDown().forEach { file ->
                if (file.name.contains("flutter_embedding") && file.name.endsWith(".jar")) {
                    removeLocalizationPluginFromJar(file)
                }
            }
        }
    }
}

fun removeLocalizationPluginFromJar(jarFile: File) {
    val tempJar = File(jarFile.parent, jarFile.name + ".tmp")
    var modified = false
    try {
        ZipInputStream(jarFile.inputStream()).use { zis ->
            ZipOutputStream(tempJar.outputStream()).use { zos ->
                var entry = zis.nextEntry
                while (entry != null) {
                    if (entry.name.startsWith("io/flutter/plugin/localization/LocalizationPlugin")) {
                        modified = true
                        entry = zis.nextEntry
                        continue
                    }
                    zos.putNextEntry(ZipEntry(entry.name))
                    zis.copyTo(zos)
                    zos.closeEntry()
                    entry = zis.nextEntry
                }
            }
        }
        if (modified) {
            var deleted = false
            for (i in 1..5) {
                if (jarFile.delete()) {
                    deleted = true
                    break
                }
                Thread.sleep(200)
            }
            if (deleted) {
                tempJar.renameTo(jarFile)
                println("Successfully patched: ${jarFile.absolutePath}")
            } else {
                tempJar.delete()
                println("Could not delete jar (locked by process): ${jarFile.absolutePath}")
            }
        } else {
            tempJar.delete()
        }
    } catch (e: Exception) {
        if (tempJar.exists()) {
            tempJar.delete()
        }
        println("Error patching jar: ${jarFile.absolutePath} - ${e.message}")
    }
}

tasks.matching { it.name.startsWith("compile") || it.name.startsWith("merge") || it.name.startsWith("minify") || it.name.startsWith("dex") }
    .configureEach {
        dependsOn("patchFlutterJar")
    }
