# Code signing

Following Apple recommendation that third party frameworks should digitally sign their code, as of `v7.9.0`, **_AdswizzSDK_** added digital signature for all its binary frameworks. See [Verifying the origin of XCFrameworks](https://developer.apple.com/documentation/xcode/verifying-the-origin-of-your-xcframeworks) for more details on digital signatures.

Next, let's explore how Xcode can automatically verify **_AdswizzSDK_** signed XCFrameworks included within your app, how code signatures work, and the benefits they provide to help protect **_AdswizzSDK_** software supply chain.
Lastly, we describe how **_AdswizzSDK_** XCFrameworks are signed to help keep integrating apps more secure in the context of Privacy Manifests.

## What is a digital signature

Signature verification of binary frameworks is a new feature in `Xcode 15` that provides security for app developers based on code signing done by SDK authors such as **_AdswizzSDK_** developers team.
Although **_AdswizzSDK_** is not required to be signed, Apple highly encourages SDK authors to sign their XCFrameworks.

> "It is important for SDK authors to cryptographically sign SDKs because it allows an app developer to confirm the identity and guarantees that the code has not been altered or tampered with after it was signed."

## How it works

**_AdswizzSDK_** uses the **Adswizz Apple Developer Program** identity for signing. For different developer identities, Xcode provides different levels of features based on the trust in the identity that was used for signing.
The signature resides within the `_CodeSignature` directory of **_AdswizzSDK_** XCFramework and protects the integrity of all the files inside the final binary framework.

## What changed
The **_AdswizzSDK_** `v7.9.0` has brought support for code signing so that you can be confident that the **_AdswizzSDK_** framework you use in your app is the original, validated version and have not been tampered with.

In Xcode you will see a new section in the Inspector that displays the signature status for the xcframeworks included in your app.
This section includes information about the signature, such as the **_AdswizzSDK_**'s identity as author. In **_AdswizzSDK_**'s case, it will show that the xcframework is signed by an Apple Developer Program identity.

> Note that for **_AdswizzSDK_** versions up to `7.9.0`, it shows that the status is currently **unsigned**.

Xcode will keep track of the identity the first time the **_AdswizzSDK_** XCframework is used and verifies that it does not change during later builds or releases. How it looks like before and after signing:

<div class="container">
  <img src="../img/unsignedCodeExample.png" alt="Missing signature example" class="image">
</div>

<div class="container">
  <img src="../img/signedCodeExample.png" alt="Valid signature example" class="image">
</div>

<br clear="left"/>

Note that if the signature changes, your app will fail to build with an appropriate error message.
However, selecting the error offers an alert explaining that the **_AdswizzSDK_** identity has changed, showing how the expected identity compares to what is present in the new version.

<div style="max-width: 600px;" class="container">
  <img src="../img/invalidCodeSignatureExample.png" alt="Signature changed example" class="image">
</div>

<br clear="left"/>

*This is an example of updating the **_AdswizzSDK_** to a newer version which is not signed anymore. 
In this case, Xcode expected a valid signature because previous versions were signed.*

Your app then has the option to either:
* proceed with the integration (might be a legitimate change in the identity such as changes to the Adswizz’s own **Apple Development Program** account) 
* cancel the embedding process for the SDK

In such cases where the integrity of the **_AdswizzSDK_** is unclear, you can always contact us for clarification through Adswizz’s verified public channel(s) if necessary (i.e: your Adswizz Technical Account Manager).

## (Optional) Verify AdswizzSDK signature

To manually verify the signature status for your **_AdswizzSDK_** binary frameworks, open the Terminal and use the `codesign` tool (the `-dv` flag stands for the `--display` and `--verbose` options) with the following syntax:
```bash
codesign -dv AdswizzSDK.xcframework
```
If the XCframework is signed, you will see a similar output to this:
```bash
Executable=<path to the XCFramework Info.plist>
Identifier=AdswizzSDK
Format=bundle
CodeDirectory v=20200 size=202 flags=0x0(none) hashes=1+3 location=embedded
Signature size=9166
Timestamp=3 Apr 2024 at 11:18:29
Info.plist entries=3
TeamIdentifier=**********
Sealed Resources version=2 rules=10 files=78
Internal requirements count=1 size=172
```
