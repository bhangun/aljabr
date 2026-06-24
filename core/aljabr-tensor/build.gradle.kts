plugins {
    java
}

// Add test-time dependency on gollek core if available in the composite project layout
val gollekCoreProject = findProject(":core:gollek-core")

dependencies {
    if (gollekCoreProject != null) {
        // project reference present — add as testImplementation
        add("testImplementation", gollekCoreProject)
    } else {
        // No gollek core in this checkout — skip test-time dependency to allow local publish
        // Intentionally left blank
    }
}
