# Aljabr (الجبر) Product & Architectural Master Blueprint

This document consolidates the complete end-to-end architecture, user experience, and enterprise-grade infrastructure of **Aljabr Studio**, the **Wayang Autonomous Agent Platform**, and the **Gollek Local Neural Engine**.

---

## 1. High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ALJABR STUDIO (FLUTTER GUI)                         │
│  • 3-Column IDE Layout        • Hunk Review UX 2.0   • Universal Command Bus│
│  • Resizable Panels           • Explain Diffs (?)    • Semantic Context UI  │
│  • Design Tokens & Hierarchy  • Audit Log Viewer     • Onboarding Wizard    │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ gRPC / HTTP :8085 / :9000
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 WAYANG PLATFORM / ALJABR AGENT SUBSTRATE                    │
│  • ReAct Agent Loop Engine    • AST Mutation Engine  • Verification Ladder  │
│  • Secret Scrubber & PII Mask • Policy Guardrails    • Chained Audit Ledger │
│  • Muqabalah LSP Kernel       • Resilient Router     • Checkpoint Store     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ ⚡ gRPC Channel (:9090) / HTTP (:8080)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                   GOLLEK LOCAL NEURAL INFERENCE ENGINE                      │
│  • Safetensors / GGUF Runner  • Paged KV Cache Engine• Fast Tokenizer Sub.  │
│  • Apple Silicon Metal Accel. • NVIDIA CUDA Accel.   • Process Isolation    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. The 10 Core Architectural Pillars

### Pillar 1: First-Run Onboarding & Dual-Backend Supervisor (`enhance01`)
- **Ordered Boot Sequence**: Gollek Neural Engine (Port `:8080` / `:9090`) boots first $\to$ Wayang Platform (`:8085` / `:9000`) boots second.
- **Dynamic Path Discovery**: Zero hardcoded paths; auto-discovers projects using upward tree traversal and environment variables (`WAYANG_HOME`, `PROJECT_ROOT`).
- **Onboarding Wizard**: 1-Click Auto Install into `~/.wayang` and `~/.gollek`, copyable terminal commands (`curl -fsSL https://get.wayang.tech | bash`), or custom repo linking.

### Pillar 2: ChangeSet + Review UX 2.0 (`enhance05`)
- **The Core Rule**: *"Aljabr never makes a meaningful code change feel like a surprise."*
- **Hunk-Level Review Controls**: Accept, Reject, or Undo individual diff hunks rather than forcing destructive all-or-nothing file overwrites.
- **"Explain This Change" Inspector**: Detailed cards explaining the **Reasoning**, **Risk Assessment**, and **Verification Ladder** results for any AI edit.

### Pillar 3: IDE Shell & Resizable Layout System (`enhance06`)
- Modular 3-column layout: `SidebarWidget` | `ChatPanel` | `EditorPanelShell`.
- Bounded resizing constraints (`width.clamp(200, 600)`).
- Tabbed editor shell with Code, Diff, Terminal, and Problems & Diagnostics tabs.

### Pillar 4: Workspace Intelligence & Semantic Context Graph (`enhance07`)
- Replaces naive grep searches with an indexed semantic code graph (`WorkspaceSymbol`, `WorkspaceReference`, `DependencyEdge`).
- **Ranked Context Builder**: Assigns relevance scores (`0.0` to `1.0`) to active files, symbols, and tests, displaying transparent *"Context used"* badges.
- **Targeted Test Selection**: Computes AST impact to execute only the unit tests affected by code diffs.

### Pillar 5: Universal Command Bus & Keyboard-First Experience (`enhance08`)
- Centralized `CommandRegistry` mapping commands to standard keyboard shortcuts (`⌘P`, `⌘K`, `⌘S`, `⌘⇧E`, `⌘T`).
- **Universal Command Palette (`⌘P` / `Ctrl+P`)**: Instant fuzzy search dialog for commands, files, symbols, and views.

### Pillar 6: Design Tokens & Semantic Surface Depth (`enhance09`)
- Restrained 4-tier surface elevation: `#101114` (Background) $\to$ `#17181C` (Surface) $\to$ `#1D1F24` (Elevated) $\to$ `#252831` (Active).
- Strict 4px spacing scale (`xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `xl: 24`, `xxl: 32`, `xxxl: 48`).
- Dark and Light mode theme extensions with smooth lerping.

### Pillar 7: Enterprise Security & Zero-Trust PII Redactor
- **Automated Secret Scrubbing**: Identifies and replaces AWS keys, OpenAI/Anthropic tokens, GitHub PATs, RSA private keys, DB passwords, and JWTs with cryptographic SHA-256 digests (`[REDACTED:API_KEY_a3f89b12]`).
- **Policy Guardrails**: Blocks destructive shell commands (`rm -rf /`, `mkfs`, fork bombs, reverse shells) and path traversal outside the project directory.

### Pillar 8: Cryptographically Chained Immutable Audit Ledger
- SHA-256 hash-chained tamper-evident audit trail for SOC 2, ISO 27001, and HIPAA compliance.
- Every tool execution, code patch, and human approval is cryptographically sealed and verifiable via `verifyLedgerIntegrity()`.

### Pillar 9: Resilient Multi-Tier Model Router & Circuit Breaker
- Multi-tier inference routing:
  1. `Tier 1`: Local Hardware Accelerated Gollek (Apple Silicon Metal / CUDA on `:8080`)
  2. `Tier 2`: Local Quantized 4-Bit Substrate (GGUF on `:8082`)
  3. `Tier 3`: Enterprise Remote GPU Worker Pool (`:9090`)
  4. `Tier 4`: Sovereign Cloud Gateway
- Circuit breaker auto-trips on 3 consecutive failures, diverting traffic without UI freeze.

### Pillar 10: Cloud-Native Packaging & Cross-Platform Distribution
- **Kubernetes Helm Charts**: Production resource quotas, Horizontal Pod Autoscaling (HPA), gRPC ingress, and NVIDIA GPU daemonsets.
- **Enterprise Compose**: Bundled stack with Keycloak SSO, PostgreSQL 16 + pgvector HA, Redis Cluster, Prometheus, and Grafana.
- **Universal Installers**: Native scripts for macOS/Linux (`install.sh`), Windows (`install.ps1`), and Homebrew (`brew/wayang.rb`).
