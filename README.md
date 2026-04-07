[![](https://jitpack.io/v/zkmopro/OpenACKotlin.svg)](https://jitpack.io/#zkmopro/OpenACKotlin)

# OpenACKotlin

A Kotlin/Android library for generating and verifying zero-knowledge proofs for the RS256 (OpenAC) circuit using native Rust code via UniFFI and JNI.

## Getting OpenACKotlin via JitPack

To get this library from GitHub using [JitPack](https://jitpack.io/#zkmopro/OpenACKotlin):

**Step 1.** Add the JitPack repository to your `settings.gradle.kts` at the end of repositories:

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

**Step 2.** Add the dependency to your `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.github.zkmopro:OpenACKotlin:0.2.0")
}
```

Checkout the [JitPack page](https://jitpack.io/#zkmopro/OpenACKotlin) for more available versions.

**Note:** If you're using an Android template from `mopro create`, comment out these UniFFI dependencies in your build file to prevent duplicate class errors.

```kotlin
// // Uniffi
// implementation("net.java.dev.jna:jna:5.13.0@aar")
// implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
```

## API Reference

All functions are in the `uniffi.mopro` package. Each function takes a `documentsPath` (path to the directory where keys and proof files are stored) and an optional `inputPath` (path to a JSON input file).

### Import the package

```kotlin
import uniffi.mopro.setupKeys
import uniffi.mopro.prove
import uniffi.mopro.verify
import uniffi.mopro.runCompleteBenchmark
import uniffi.mopro.BenchmarkResults
import uniffi.mopro.ProofResult
import uniffi.mopro.ZkProofException
```

### `setupKeys`

Generates proving and verifying keys for the RS256 circuit and writes them to `documentsPath`.

```kotlin
val documentsPath: String = context.filesDir.absolutePath
val inputPath: String? = null  // optional path to input JSON

val result: String = setupKeys(documentsPath, inputPath)
```

Returns a status string on success. Throws `ZkProofException` on failure.

### `prove`

Generates a ZK proof using the previously set up keys.

```kotlin
val result: ProofResult = prove(documentsPath, inputPath)
println("Prove time: ${result.proveMs} ms")
println("Proof size: ${result.proofSizeBytes} bytes")
```

**`ProofResult` fields:**

| Field | Type | Description |
|---|---|---|
| `proveMs` | `ULong` | Time to generate the proof in milliseconds |
| `proofSizeBytes` | `ULong` | Size of the proof in bytes |

Throws `ZkProofException.SetupRequired` if keys have not been set up yet.

### `verify`

Verifies the proof stored in `documentsPath`.

```kotlin
val isValid: Boolean = verify(documentsPath)
```

Returns `true` if the proof is valid, `false` otherwise. Throws `ZkProofException` on error.

### `runCompleteBenchmark`

Runs the full pipeline (setup → prove → verify) and returns timing and size metrics.

```kotlin
val results: BenchmarkResults = runCompleteBenchmark(documentsPath, inputPath)
println("Setup:    ${results.setupMs} ms")
println("Prove:    ${results.proveMs} ms")
println("Verify:   ${results.verifyMs} ms")
println("Proving key:   ${results.provingKeyBytes} bytes")
println("Verifying key: ${results.verifyingKeyBytes} bytes")
println("Proof:         ${results.proofBytes} bytes")
println("Witness:       ${results.witnessBytes} bytes")
```

**`BenchmarkResults` fields:**

| Field | Type | Description |
|---|---|---|
| `setupMs` | `ULong` | Time for key setup in milliseconds |
| `proveMs` | `ULong` | Time for proof generation in milliseconds |
| `verifyMs` | `ULong` | Time for verification in milliseconds |
| `provingKeyBytes` | `ULong` | Size of the proving key in bytes |
| `verifyingKeyBytes` | `ULong` | Size of the verifying key in bytes |
| `proofBytes` | `ULong` | Size of the proof in bytes |
| `witnessBytes` | `ULong` | Size of the witness in bytes |

### Error Handling

All functions (except `verify`) throw `ZkProofException` on failure. The sealed class variants are:

| Variant | Description |
|---|---|
| `ZkProofException.FileNotFound` | A required file could not be found |
| `ZkProofException.ProofGenerationFailed` | Proof generation encountered an error |
| `ZkProofException.VerificationFailed` | Proof verification encountered an error |
| `ZkProofException.InvalidInput` | The provided input is invalid |
| `ZkProofException.SetupRequired` | Keys must be set up before proving |
| `ZkProofException.IoException` | An I/O error occurred |

```kotlin
try {
    val proof = prove(documentsPath, inputPath)
} catch (e: ZkProofException.SetupRequired) {
    // Run setupKeys first
} catch (e: ZkProofException) {
    println("ZK error: ${e.message}")
}
```

## Usage Example

```kotlin
import uniffi.mopro.*

val documentsPath = context.filesDir.absolutePath
val inputPath: String? = null

// 1. Setup keys (only needed once)
setupKeys(documentsPath, inputPath)

// 2. Generate proof
val proofResult = prove(documentsPath, inputPath)
println("Proved in ${proofResult.proveMs} ms (${proofResult.proofSizeBytes} bytes)")

// 3. Verify proof
val valid = verify(documentsPath)
println("Proof valid: $valid")
```

## How to Build the Package

This package relies on bindings generated by the Mopro CLI.
To learn how to build Mopro bindings, refer to the [Getting Started](https://zkmopro.org/docs/getting-started) section.

Use `mopro-cli` and choose the appropriate circuit:

```sh
mopro init
mopro build
```

Choose `android` and build for `aarch64-linux-android` and `x86_64-linux-android` architectures.

Then replace the bindings in:

- `lib/src/main/java/uniffi`
- `lib/src/main/jniLibs`

Or copy them with:

```sh
cp -r MoproAndroidBindings/uniffi lib/src/main/java
cp -r MoproAndroidBindings/jniLibs lib/src/main
```

## Community

- X account: <a href="https://twitter.com/zkmopro"><img src="https://img.shields.io/twitter/follow/zkmopro?style=flat-square&logo=x&label=zkmopro"></a>
- Telegram group: <a href="https://t.me/zkmopro"><img src="https://img.shields.io/badge/telegram-@zkmopro-blue.svg?style=flat-square&logo=telegram"></a>

## Acknowledgements

This work was initially sponsored by a joint grant from [PSE](https://pse.dev/) and [0xPARC](https://0xparc.org/). It is currently incubated by PSE.
