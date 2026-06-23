allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround for a broken local SDK install: `platforms;android-35` is missing
// its android.jar, so any module compiling against SDK 35 fails to resolve
// `android.jar`. Force every Android module (app + plugins) to compile against
// the installed android-36 instead. Remove this once android-35 is reinstalled
// via the SDK Manager.
subprojects {
    val forceCompileSdk: Project.() -> Unit = {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                androidExt.javaClass
                    .getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(androidExt, 36)
            } catch (_: Exception) {
                // Module doesn't expose compileSdkVersion(int) — ignore.
            }
        }
    }
    // Some subprojects are already evaluated by the time this runs (the
    // evaluationDependsOn above forces it), so afterEvaluate would throw.
    if (state.executed) {
        forceCompileSdk()
    } else {
        afterEvaluate { forceCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
