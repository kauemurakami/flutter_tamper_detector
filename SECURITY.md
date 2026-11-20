# Security policy and threat model

## Scope

Flutter Tamper Detector collects native indicators that may help an application identify rooted/jailbroken devices, modified Android boot states, emulators, runtime instrumentation, debuggers, installation sources, and Android signing-certificate mismatches.

## What this package does not guarantee

- It does not guarantee detection of all root, jailbreak, Frida, Xposed/LSPosed, Substrate/Substitute, Gadget, inline hooks, or debugger implementations.
- It cannot prove that its own Dart/Kotlin/Swift checks have not been patched by an attacker controlling the process.
- It does not recursively scan the entire device filesystem; ordinary applications are sandboxed and such scans would be unreliable and expensive.
- It does not validate Play Integrity or App Attest tokens on a server. The consuming application must implement backend verification.
- A signing-certificate fingerprint identifies a signing certificate; it does not prove memory integrity or prevent runtime patching.
- An App Store receipt file's presence is not cryptographic receipt validation.
- iOS does not provide a public API for third-party apps to reliably prevent screenshots.

## Recommended deployment

1. Use release signing and Flutter/R8 obfuscation appropriate to the app.
2. Treat local detector results as risk signals, not authorization.
3. Validate Play Integrity or App Attest on your backend for sensitive operations.
4. Bind attestation to a unique request/challenge and reject replayed or stale assertions.
5. Avoid storing secrets in Dart or native client code.
6. Keep security logs free of credentials, personal information, and stable device identifiers.
7. Test on real devices and release builds; do not infer production coverage from emulator-only tests.

## Reporting

Report security issues through the repository's private security contact or a private GitHub vulnerability report when enabled. Include affected package version, platform/OS version, reproduction steps, and impact. Do not publish exploit details before maintainers have had a reasonable opportunity to investigate.
