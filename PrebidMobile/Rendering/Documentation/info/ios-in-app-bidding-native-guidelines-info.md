# Native Ads Guidelines

## Getting Started

Prebid Rendering Module implements the [OpenRTB Specification](https://www.iab.com/wp-content/uploads/2018/03/OpenRTB-Native-Ads-Specification-Final-1.2.pdf) for the native ads.

The general integration scenario requires these steps from publishers:

1. Prepare the ad layout:
    * HTML and CSS for the Native Styles format.
    * Native components for the Unified Ads format.
1. Configure the Native Ad using [NativeAdConfiguration](native/ios-native-ad-configuration.md).
    * Provide the list of **[Native Assets](#components)** representing the ad's structure.
    * Tune other general properties of the ad.
1. Make a bid request.
1. **OPTIONAL** Bind the data from the bid response with the layout, if it is needed for particular integration.

### Native Styles

Prebid Rendering Module supports the prebid's approach for rendering [native ads](https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-nativeadunit-ios.html). It is similar to the Google's [Native Styles](#native-styles) ad format. In this case publisher should preare the layout of the ad using HTML and CSS and add the universal creative to the ad code.

<img src="res/Native-Styles-Primary-Ad-Server.png" alt="Pipeline Screenshot" align="center">

1. Prebid Rendering Module sends the bid request.
2. Prebid server runs the header bidding auction among preconfigured demand partners.
3. In-App Bidding SDK sets up the targeting keywords of the winning bid to the ad unit of Primary Ad Server SDK.
4. Primary Ad Server SDK sends the ad request to the Ad Server. If Prebid's line item wins the ad response will contain **Prebid Universal Creative** and **Ad Layout**.
5. The received creative will be rendered in the Web View of Primary Ad Server SDK.  

The ad will be rendered in the web view. The rendering engine will be the prebid's universal creative. It will load the winning bid from the prebid cache and substitute assets into the ad markup. For the more detailed info visit the Prebid's instructions about [How Native Ads Work](https://docs.prebid.org/dev-docs/show-native-ads.html#how-native-ads-work).

In order to prepare the valid layout folow the instructions in the Prebid docs for [Mobile in general](https://docs.prebid.org/prebid-mobile/adops-native-setup.html) and for [Google Ad Manager](https://docs.prebid.org/adops/setting-up-prebid-native-in-dfp.html).

In the case of integration of Native Styles ads without Primary Ad Server publishers should provide the Ad Layout to the SDK. And the winning bid will be rendered right after receiving it from Prebid.

<img src="res/Native-Styles-Prebid.png" alt="Pipeline Screenshot" align="center">


1. Setup layout for the Native Styles ad.
2. Prebid Rendering Module sends the bid request.
3. Prebid server runs the header bidding auction among preconfigured demand partners.
3. The received creative will be rendered in the Web View of Prebid Rendering Module.
 

### Unified Native Ads

The general integration scenario requires these steps from publishers:

1. Prepare the ad layout.
2. Create Native Ad Unit.
3. Configure the Native Ad unit using [NativeAdConfiguration](native/ios-native-ad-configuration.md).
    * Provide the list of **[Native Assets](#components)** representing the ad's structure.
    * Tune other general properties of the ad.
4. Make a bid request.
5. Find native ad using `NativeUtils.findNativeAd`.
6. Bind the data from the native ad response with the layout.

``` swift
```

## Components

Prebid Rendering Module supports all Native Ad components proclaimed by the OpenRTB specification: **title**, **image**, **video**, **data**.

We strongly recommend to follow the industry best practices and requirements, especially in the case of integration with Primary Ad Server:

* [OpenRTB Specification](https://www.iab.com/wp-content/uploads/2018/03/OpenRTB-Native-Ads-Specification-Final-1.2.pdf)
* [The Native Advertizing Playbook](https://www.iab.com/wp-content/uploads/2015/06/IAB-Native-Advertising-Playbook2.pdf)
* [Google Guidelines](https://support.google.com/admanager/answer/6075370)
* [MoPub Guidelines](https://developers.mopub.com/publishers/best-practices/native-ads/)

While preparing the layout for Native Ads, account for the **AdChoices** button placed at the **top right corner** with a size of **20x20** points.

## Integration 

Prebid Rendering Module allows to integrate native ads into all supported scenarios:

* [Google Ad Manager](integration-gam/ios-in-app-bidding-gam-native-integration.md)
* [MoPub](integration-mopub/ios-in-app-bidding-mopub-native-integration.md)
* [Pure In-App Bidding](integration-prebid/ios-in-app-bidding-prebid-native-integration.md)
 
