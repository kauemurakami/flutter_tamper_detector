# Remote attestation integration guide

The package does not currently request or validate Play Integrity or App Attest tokens. This document describes the recommended integration boundary: the mobile client obtains a platform proof, while the backend validates it and authorizes the protected operation.

## Android — Play Integrity and `requestHash`

1. The client constructs a canonical representation of the operation being requested. Include all fields whose integrity matters, such as operation name, account/resource reference, amount/currency, and a server-issued one-time transaction nonce.
2. Serialize the representation deterministically and calculate its SHA-256 digest.
3. Supply that digest as `requestHash` when requesting a Standard Integrity token.
4. Send the token and the original operation to the backend over TLS.
5. The backend independently reconstructs the canonical request, calculates the expected digest, asks Google to decode/verify the token using the supported server integration, and compares the returned request hash.
6. Validate package name, app recognition, signing certificate verdict, device integrity verdicts, token freshness, and the transaction nonce according to risk policy.
7. Consume the nonce and authorize the operation server-side. Reject mismatched, stale, reused, or invalid proofs.

`requestHash` binds the integrity token to request data. It is not a secret, not a signature, and not a replacement for TLS or backend authorization. Do not place passwords, access tokens, or unnecessary personal data in the unhashed request payload. The backend must recompute the hash rather than trusting a client-provided expected value.

Official documentation: https://developer.android.com/google/play/integrity/standard

## iOS — App Attest

1. Generate an App Attest key on the client and send its key identifier to the backend.
2. Have the backend issue a unique, unpredictable challenge for the operation.
3. Create the client-data hash from the challenge and canonical request data.
4. Attest the key during enrollment and validate the attestation object on the backend.
5. For subsequent operations, generate an assertion over the client-data hash.
6. Validate the assertion, key association, app identity, challenge, and monotonic counter on the backend.
7. Consume challenges once and make authorization decisions server-side.

App Attest is not a universal jailbreak detector and does not prove that every runtime check is untampered. Treat it as a platform-backed signal in a broader risk policy.

Official documentation: https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity

## Operational guidance

- Keep attestation verification and private server credentials on the backend.
- Use one-time challenges/nonces and enforce expiration.
- Bind the proof to the exact operation, not merely to app startup.
- Make authorization decisions on the server; do not trust a client-side `shouldLaunch` value.
- Provide graceful recovery for unsupported devices and transient service failures.
