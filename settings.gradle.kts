rootProject.name = "aljabr-engine"

fun includeOptionalProject(projectPath: String, vararg candidatePaths: String) {
    val projectDir = candidatePaths
        .map { file(it) }
        .firstOrNull { candidate ->
            candidate.resolve("build.gradle.kts").isFile || candidate.resolve("build.gradle").isFile
        }
        ?: return

    include(projectPath)
    project(":$projectPath").projectDir = projectDir
}


includeOptionalProject("core:aljabr-core", "core/aljabr-core")

// Map gollek core (used by some aljabr integration tests) if present in repo
/* val skipGollek = gradle.startParameter.projectProperties["skipGollek"] == "true"
if (!skipGollek) {
    includeOptionalProject("core:gollek-core", "../gollek/core/gollek-core", "../gollek/core/gollek-core")
} else {
    println("[aljabr] skipGollek=true -> not including core:gollek-core in composite build")
}
 */

// Autograd is training-only; exclude from foundational builds
val skipAutograd = gradle.startParameter.projectProperties["skipAutograd"] == "true" ||
                   gradle.startParameter.projectProperties["skipGollek"] == "true"
if (!skipAutograd) {
    include("core:autograd")
}

include("core:aljabr-tensor")
include("core:aljabr-core")
include("core:aljabr-error-code")
include("core:aljabr-nn")

include("core:aljabr-spi-model")

//include("backend:blackwell:aljabr-kernel-blackwell")

include("backend:cpu:aljabr-backend-cpu")
include("backend:cuda:aljabr-backend-cuda")
include("backend:cuda:aljabr-kernel-cuda")
//include("backend:cuda:aljabr-plugin-kernel-cuda")
//include("backend:directml:aljabr-plugin-kernel-directml")
include("backend:metal:aljabr-backend-metal")
//include("backend:metal:aljabr-mlx-binding")
//include("backend:rocm:aljabr-kernel-rocm")
//include("backend:rocm:aljabr-plugin-kernel-rocm")

// Dynamically include model family projects under models/
file("models")
    .listFiles { candidate ->
        candidate.isDirectory &&
                candidate.name.startsWith("aljabr-model-") &&
                (candidate.resolve("build.gradle.kts").isFile || candidate.resolve("build.gradle").isFile)
    }
    ?.sortedBy { it.name }
    ?.forEach { modelProject ->
        include("models:${modelProject.name}")
        project(":models:${modelProject.name}").projectDir = modelProject
    }



include("core:aljabr-rocksdb")
include("core:aljabr-helixdb")
