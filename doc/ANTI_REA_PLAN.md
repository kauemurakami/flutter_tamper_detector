# Anti-REA and reverse-engineering plan

This document separates controls already present in 1.0.0 from research and tooling planned for later releases. “Anti-REA” means measurable resistance to static/dynamic analysis and tampering; it does not mean prompt injection, analyst deception, or guaranteed prevention of reverse engineering.

## Implemented in 1.0.0

- Android root heuristics based on common root files and executable locations.
- Android modified-system heuristics based on build tags, debuggable system properties, verified-boot state, and bootloader lock state. These are not synonymous with root.
- Android emulator indicators and iOS Simulator identification.
- Android instrumentation indicators from the current process memory map, current-process thread names, known paths, and common Frida TCP ports.
- iOS instrumentation indicators from dynamic images currently loaded into the process.
- Android debugger attachment checks and iOS `P_TRACED` process-state inspection.
- Android developer-options and ADB settings indicators.
- Android installer metadata and Android signing-certificate SHA-256 comparison.
- Configurable runtime polling and foreground-resume checks, with a report callback and pluggable logger.

## Important limits

- A renamed Frida server may evade path-name checks. A custom Frida Gadget may evade name-based dyld/maps checks.
- A service listening on TCP 27042 or 27043 is only a weak indicator; another local service may use those ports. Port-only matches are reported separately and do not block startup by default.
- Inline hooks, patched function prologues, anonymous executable mappings, custom loaders, and modified detector return values are not comprehensively detected.
- Ordinary apps cannot reliably traverse the entire Android filesystem. Recursive filesystem scans are not a substitute for inspecting the current process and would be expensive and noisy.
- A process owner with sufficient control can patch local checks without necessarily obtaining conventional root. Root is not a prerequisite for every instrumentation or repackaging technique.
- iOS public APIs restrict process inspection. Loaded-image inspection is heuristic and cannot detect every inline hook.

## Next milestones

### 1.1 — Instrumentation research and regression coverage

- Add reproducible fixtures for Frida server with renamed executable, custom Gadget name, changed ports, Gadget embedded in the app, and common Xposed/LSPosed/Substrate variants.
- Evaluate process-map, thread-name, dyld-image, and debugger signals independently; record false-positive and false-negative rates.
- Investigate inline-hook indicators that can be collected safely and portably without claiming universal coverage.
- Add rate and performance benchmarks for repeated checks on low-end devices.

### 1.2 — Integrity and build pipeline

- Add developer-owned signing identity profiles for Debug, Profile, and Release variants.
- Support multiple accepted public certificate fingerprints for planned signing-key rotation, with explicit variant selection and no implicit trust expansion.
- Provide a signing-validation debug/test workflow with deterministic positive and negative fixtures. Keep simulated findings behind test-only dependency injection/native test fixtures; do not add a production runtime bypass that can be enabled accidentally.
- Define a signed build manifest for selected app resources/native components.
- Verify the manifest signature and component hashes at runtime where platform packaging permits.
- Add release-artifact audit scripts for exported symbols, debug metadata, sensitive strings, signing identity, and packaging mistakes.
- Preserve symbol files and signing metadata per release in CI.

### 1.3 — Anti-REA evaluation harness

- Run MobSF, JADX, Ghidra, and controlled agent-based analysis against release artifacts.
- Track whether sensitive endpoints, feature flags, route names, embedded endpoints, or implementation details are recoverable.
- Produce evidence-backed reports with tool versions, artifact hashes, findings, and limitations.
- Evaluate agent prompt-injection resistance only as a security property of the analysis tool, never as an app-side security control.

### 1.4 — Remote trust and authorization examples

- Add backend reference implementations for Play Integrity and App Attest.
- Bind proofs to operation-specific hashes/challenges and reject stale or replayed proofs.
- Document risk-based authorization and server-side enforcement patterns.

## Design principles

1. Collect evidence separately from policy decisions.
2. Keep platform-specific checks in Kotlin and Swift.
3. Do not terminate or uninstall the host process from a detector function.
4. Treat local booleans and hashes as untrusted client-side signals.
5. Prefer independent signals and measured coverage over a large list of brittle signatures.
6. Never describe a heuristic as complete protection.
