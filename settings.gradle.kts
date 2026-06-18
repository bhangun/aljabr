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

//include("aljabr-utils")
/* include("compiler:aljabr-compiler")
include("compiler:aljabr-neural-compiler") */
//include("core:aljabr-adapter")
//include("core:aljabr-distributed")
includeOptionalProject("core:aljabr-core", "core/aljabr-core")

/* include("core:aljabr-multitenancy")
include("core:aljabr-observability")
include("core:aljabr-provider-core")
include("core:aljabr-provider-routing")
 */
include("core:aljabr-tensor")
include("core:aljabr-core")
include("core:aljabr-error-code")

//include("examples:jupyter-deps")
//include("integration:aljabr-jupyter-kernel")
//project(":integration:aljabr-jupyter-kernel").projectDir = file("integration/jupyter/aljabr-jupyter-kernel")
includeOptionalProject("suling", "../extensions/audio/suling", "stubs/suling")
/* include("optimization:aljabr-plugin-elastic-ep")
// include("optimization:aljabr-plugin-evicpress")
include("optimization:aljabr-plugin-fa3")
include("optimization:aljabr-plugin-fa4")
// include("optimization:aljabr-plugin-hybrid-attn")
include("optimization:aljabr-plugin-kv-cache")
include("optimization:aljabr-plugin-paged-attention")
// include("optimization:aljabr-plugin-perfmode")
// include("optimization:aljabr-plugin-prefill-decode")
// include("optimization:aljabr-plugin-prompt-cache")
include("optimization:aljabr-plugin-qlora")
// include("optimization:aljabr-plugin-wait-scheduler")
// include("optimization:aljabr-plugin-weight-offload") */
/* include("plugins:aljabr-plugin-content-safety")
include("plugins:aljabr-plugin-mcp")
include("plugins:aljabr-plugin-model-router") */
// include("plugins:aljabr-plugin-observability")
// include("plugins:aljabr-plugin-pii-redaction")
// include("plugins:aljabr-plugin-prompt")
// include("plugins:aljabr-plugin-quota")
// include("plugins:aljabr-plugin-rag")
// include("plugins:aljabr-plugin-reasoning")
// include("plugins:aljabr-plugin-sampling")
// include("plugins:aljabr-plugin-streaming")
// include("plugins:aljabr-safetensor-rag")

// include("provider:aljabr-plugin-anthropic")
// include("provider:aljabr-plugin-cerebras")
// include("provider:aljabr-plugin-gemini")


/* include("sdk:aljabr-sdk")
include("sdk:aljabr-sdk-agent")
include("sdk:aljabr-sdk-api")
include("sdk:aljabr-sdk-core")
include("sdk:aljabr-sdk-local")
include("sdk:aljabr-sdk-remote")
if (file("sdk/aljabr-sdk-session").isDirectory) {
    include("sdk:aljabr-sdk-session")
} */
// include("spi:aljabr-spi") // root aggregator not present in repo; included specific spi modules below
include("spi:aljabr-spi-model")
    //includeOptionalProject("spi:aljabr-spi-plugin", "spi/aljabr-spi-plugin")
/* include("spi:aljabr-spi-provider")
include("spi:aljabr-spi-runtime") */


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
