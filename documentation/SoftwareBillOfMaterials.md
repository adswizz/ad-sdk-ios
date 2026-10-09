# Software Bill of Materials

AdsWizz publishes a Software Bill of Materials (SBOM) for every release of **_AdswizzSDK_**. This page explains
what the SDK contains, under which licences, and how to obtain the machine-readable document.

---

## Scope

The SBOM covers the four distributable components of the AdsWizz iOS SDK:

| Component | Distributed as |
|---|---|
| `AdswizzSDK` | `AdswizzSDK.xcframework` + `AdswizzSDKCore.xcframework` |
| `AdswizzSDKPinpointAnalytics` | `AdswizzSDKPinpointAnalytics.xcframework` |
| `AdswizzWatchSDK` | `AdswizzWatchSDK.xcframework` |
| `AdswizzSDKPrivacyDataKit` | `AdswizzSDKPrivacyDataCore.xcframework` + optional subspecs |

The four components are installed independently. A single SBOM lists all of them, and its dependency graph
shows which third-party and embedded components belong to which, so you can read off the inventory for
just the components you actually integrate.

---

## Obtaining the SBOM

| | |
|---|---|
| **Format** | CycloneDX 1.5, JSON |
| **Filename** | `bom.json`, one per release |
| **Produced** | Automatically, for every release |
| **Availability** | Alongside the release artifacts in the official release repository ([github.com/adswizz/ad-sdk-ios](https://github.com/adswizz/ad-sdk-ios)), as `sbom/bom.json` |

CycloneDX 1.5 is chosen for broad tool compatibility: it is accepted by Dependency-Track, GitLab, and the
common SBOM tooling.

If you require a different format, or an SBOM for a specific historical version, contact us.

---

## Third-party components

### `AdswizzSDK`

| Component | Licence |
|---|---|
| IAB Open Measurement SDK (iOS) | Open Measurement License for Native-App Measurement, V 1.1 |
| Apple SwiftProtobuf | Apache-2.0 |

The SDK additionally contains AdsWizz-authored modules, which appear in the SBOM as first-party components
under the **Adswizz SDK License** (see [Licences and attributions](#licences-and-attributions)).

### `AdswizzSDKPinpointAnalytics`

| Component | Licence | Notes |
|---|---|---|
| AWSCore (AWS SDK for iOS) | Apache-2.0, with the AWSLex/Bluefront directory under the [AWS Customer Agreement](https://aws.amazon.com/agreement/) | Declared as a pod dependency and resolved by your project, not embedded in AdswizzSDK binary |

The SBOM records the AWSCore version the SDK is built and tested with. Because it is declared as a
dependency rather than embedded, the version your project resolves is determined by your own dependency
constraints.

### `AdswizzWatchSDK`

Contains no third-party components. AdsWizz-authored code and Apple system frameworks only.

### `AdswizzSDKPrivacyDataKit`

Contains no third-party components. AdsWizz-authored code and Apple system frameworks only.

---

## Licences and attributions

**Apple SwiftProtobuf** is used under the Apache License 2.0.
Source: <https://github.com/apple/swift-protobuf> · Licence: <https://github.com/apple/swift-protobuf/blob/main/LICENSE.txt>

**IAB Open Measurement SDK** is used under the *Open Measurement License for
Native-App Measurement, V 1.1*, published by the IAB Technology Laboratory:
<https://iabtechlab.com/standards/open-measurement-sdk/>

Please note this licence has **no SPDX identifier**. Automated licence classifiers will typically report it
as unknown or unrecognised rather than as a policy violation. The full licence text ships with the SDK and
is available from the IAB.

**AWSCore** is used under the Apache License 2.0, with the exception noted under [Third-party components](#third-party-components).

**AdsWizz-authored components** — the released podspecs themselves, and the first-party OMSDK-Plugin,
MercuryAnalytics-Plugin and sonar-protobuf modules — are used under the **Adswizz SDK License**:
<https://raw.githubusercontent.com/adswizz/ad-sdk-ios/master/LICENSE>

---

## Out of scope

The SBOM describes **only what is distributed to you**. Apple platform frameworks and OS-provided libraries
are excluded, per normal SBOM convention, as they are supplied by the operating system rather than
distributed by AdsWizz.

---

## Update cadence and retention

A new SBOM is generated automatically for each SDK release and published alongside that release's
artifacts. SBOMs for previous versions remain available for as long as those versions do, so an SBOM is
always retrievable for the exact version you have integrated.

---

## Reporting a vulnerability

To report a suspected vulnerability in the AdsWizz iOS SDK or in a component it distributes, contact
**sdk@adswizz.com**.

Please include the SDK version, the affected component and version, and the advisory identifier (CVE or
equivalent) if one exists. We will confirm receipt and advise on remediation or mitigation.

For vulnerabilities in a third-party component, please note whether you have already contacted that
component's maintainers, so we can coordinate rather than duplicate.
