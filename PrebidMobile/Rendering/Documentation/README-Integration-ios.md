# Prebid Rendering Module iOS

## Quick Start

### CocoaPods integration

To download and integrate the Rendering module into your project using CocoaPods, add the following line to your project’s podfile:

```
pod 'prebid-mobile-sdk-rendering'
```

If you integrate Prebid Rendering Module with GAM or MoPub add these pods respectively

```
# + Google Ad Manager (optional)
pod 'prebid-mobile-sdk-gam-event-handlers'

# + MoPub (optional)
pod 'prebid-mobile-sdk-mopub-adapters'
```

### Init Prebid Rendering Module

Firstly import Rendering Module:

```
import PrebidMobileRenderingSdk
```

Then provide the **Prebid Account ID** of your organization. The best place to do it is the `application:didFinishLaunchingWithOptions` method.
 
```
PrebidRenderingConfig.shared.accountID = YOUR_ACCOUNT_ID
PrebidRenderingConfig.shared.bidServerHost = HOST
```

### Ad Units Integration

Now you are ready to add ad units respectively to your integration scenario:

- [Pure In-App Bidding](info/integration-prebid/ios-in-app-bidding-pb-info.md)
- [Google Ad Manager](info/integration-gam/ios-in-app-bidding-gam-info.md)
- [MoPub](info/integration-mopub/ios-in-app-bidding-mopub-info.md)

## Prebid Rendering Module Overview

For the overview of Rendering Module integration approaces see the [In-App Bidding With Rendering Module](info-modules/in-app-bidding-overview.md) doc.

Here are the key capabilities of the iOS Rendering Module:

- **Support of these ad formats:**
    -   Banner
    -   Display Interstitial
    -   Video Interstitial
    -   [Native](info-modules/in-app-bidding-native-guidelines-info.md)
    -   Rich media and MRAID 3.0 support
    -   Rewarded Video
    -   Outstream Video
- **Open Measurement Support.**
- **Direct SDK integration**. Allows you to pass first-party app data,
    user data, device data, and location data.
-   **Privacy Regulation Compliance**. The In-App Bidding SDK meets **GDPR**, **CCPA**, **COPPA** requirements according to the IAB specifications.
-   **App targeting campaigns**. With the [support of deeplink+](info-modules/in-app-bidding-deeplinkplus.md) SDK is able to manage the ads with premium UX for retargeting campaigns.
-    **Targeting**. Use [custom ad parameters](info/ios-sdk-parameters.md) to increase the chance to win an impression and to improve ad views' UX.
-   **Tracking of render impression**. Prebid Rendering Module tracks [render impressions](info-modules/in-app-bidding-impression-tracking.md) according to the IAB Measurement Guidelines for all managed ads. Ads rendered by Primary Ad Server SDK track an impression beacon according to the internal algorithms.
-   **Fast and seamless integration.**



