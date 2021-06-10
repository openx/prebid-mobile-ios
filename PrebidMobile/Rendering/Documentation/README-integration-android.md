# Prebid Rendering Module Android

## Quick Start

#### Gradle Integration

To add the Prebid Rendering Module dependency, open your project and update the app module’s build.gradle to have the following repositories and dependencies:

```
allprojects {
    repositories {
      ...
      mavenCentral()
      ...
    }
}

// ...

dependencies {
    ...
    implementation('org.prebid:prebid-mobile-sdk-rendering:x.x.x')
    implementation('org.prebid:prebid-mobile-sdk-gamEventHandlers:x.x.x') // For integration with Google Ad Manager
    implementation('org.prebid:prebid-mobile-sdk-mopubAdapters:x.x.x') // For integration with MoPub
    ...
}
```

## Init Prebid Rendering Module

Firstly [integrate](info-android/android-sdk-integration.md) the Prebid Rendering Module.

Then provide the **Prebid Account ID** of your organization. The best place to do it is the `onCreate()` method of your Application class.

```
PrebidRenderingSettings.setBidServerHost(HOST)
PrebidRenderingSettings.setAccountId(YOUR_ACCOUNT_ID)
```

- **Ad Units Integration**
   Now you are ready to add ad units respectively to your integration scenario:
    - [Pure In-App Bidding](info-android/integration-prebid/android-in-app-bidding-pb-info.md)
    - [Google Ad Manager](info-android/integration-gam/android-in-app-bidding-gam-info.md)
    - [MoPub](info-android/integration-mopub/android-in-app-bidding-mopub-info.md)

## Prebid Rendering Module Overview

For requirements and integration overview, see [Getting started with In-App Bidding](info-modules/in-app-bidding-overview.md).

Here are key capabilities of the Rendering Module:

- **Support of these ad formats:**
    -   Banner
    -   Interstitial
    -   [Native](info-modules/in-app-bidding-native-guidelines-info.md)
    -   Rich media and MRAID 3.0 support
    -   Video Interstitial
    -   Rewarded Video
    -   Outstream Video
- **Open Measurement Support.**
- **Direct SDK integration**. Allows you to pass first-party app data,
    user data, device data, and location data.  
- **Privacy Regulation Compliance**. The In-App Bidding SDK meets **GDPR**, **CCPA**, **COPPA** requirements according to the IAB specifications.
- **App targeting campaigns**. With the [support of deeplink+](info-modules/in-app-bidding-deeplinkplus.md) SDK is able to manage the ads with premium UX for retargeting campaigns.
- **Targeting**. Use [custom ad parameters](info-android/android-sdk-parameters.md) to increase the chance to win an impression and to improve ad views' UX.
- **Tracking of render impression**. Prebid In-App Bidding SDK tracks [render impressions](info-modules/in-app-bidding-impression-tracking.md) according to the IAB Measurement Guidelines for all managed ads. Ads rendered by Primary Ad Server SDK track an impression beacon according to the internal algorithms.
- **Fast and seamless integration.**