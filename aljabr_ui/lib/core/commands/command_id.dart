enum CommandId {
  // File & Editor
  saveFile,
  newFile,
  goToFile,
  goToSymbol,
  findInFiles,
  formatDocument,
  toggleWordWrap,

  // Agent & AI
  askAgent,
  explainSelection,
  fixWithAgent,
  reviewChanges,
  acceptHunk,
  rejectHunk,
  generateUnitTests,

  // Verification & Testing
  runTests,
  runTargetedTests,
  verifyLadderL0L5,

  // Panels & Views
  toggleTerminal,
  toggleProblems,
  toggleExplorer,
  toggleAgentPanel,
  toggleDiffView,

  // Enterprise & Settings
  openBackendInfrastructure,
  openEnterpriseCompliance,
  openSettings,
  reindexWorkspace,
}
