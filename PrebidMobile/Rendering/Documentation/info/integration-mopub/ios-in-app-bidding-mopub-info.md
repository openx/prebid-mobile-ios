# MoPub Integration

The integration of Prebid Rendering Module with MoPub assumes that publisher has an account on MoPub and has already integrated the MoPub SDK into the app project.

If you do not have MoPub SDK in the app yet, refer the [MoPub's Documentation](https://github.com/mopub/mopub-ios-sdk).

⚠️⚠️⚠️ **WARNING**: MoPub Adapters for the Prebid Rendering Module are compatible with **MoPub 5.13** and above. The ads won't be shown with earlier versions of MoPub SDK.

## MoPub Integration Overview

The integration of header bidding into MoPub monetization is based on MoPub's Mediation feature. 

<img src="../res/Prebid-In-App-Bidding-Overview-MoPub.png" alt="Pipeline Screenshot" align="center">

**Steps 1-2** Prebid Rendering Module makes a bid request. Prebid server runs an auction and returns the winning bid to the SDK.

**Step 3** Prebid Rendering Module via MoPub Adapters Framework sets up targeting keywords into the MoPub's ad unit.

**Step 4** MoPub SDK makes an ad request. MoPub returns the winner of the waterfall.

**Step 5** If Prebid's creative won then the MoPub SDK will instantiate respective Prebid Adapter which will render the winning bid.

**Step 6** The winner is displayed in the App with the respective rendering engine.

Prebid Rendering Module provides ability to integrate header bidding for these ad kinds:

- Display Banner
- Display Interstitial
- Native
- [Native Styles](../integration-mopub/ios-in-app-bidding-mopub-native-integration.md)
- Video Interstitial 
- Rewarded Video

They can be integrated using these API categories.

- [**Banner API**](#banner-api) - for **Display Banner**
- [**Interstitial API**](#interstitial-api) - for **Display** and **Video** Interstitials
- [**Rewarded API**](#rewarded-api) - for **Rewarded Video**
- [**Native API**](ios-in-app-bidding-mopub-native-integration.md)


## Init Prebid Rendering Module

Add the following line to your project’s podfile and install the pod:

```
pod 'prebid-mobile-sdk-rendering'
```

Provide an **Account Id** of your organization on Prebid server:

```
PrebidRenderingConfig.shared.accountID = YOUR_ACCOUNT_ID
PrebidRenderingConfig.shared.bidServerHost = HOST
```

The best place to do it is the `application:didFinishLaunchingWithOptions` method.


The account ID is an identifier of the **Stored Request**.

### Prebid Adapters

Adapters for Prebid Rendering Module are classes that serve like proxies between MoPub SDK and any other one. For more details about Mediation and Adapters read the [MoPub's Documentation](https://developers.mopub.com/networks/integrate/mopub-network-mediation-guidelines/).

The framework could be added to the app via CocoaPods:

```
pod 'prebid-mobile-sdk-mopub-adapters'
```

## Banner API

To display an ad you need to implement three easy steps:

``` swift
// 1. Create an AdView
banner = MPAdView(adUnitId: MOPUB_AD_UNIT_ID)
banner.delegate = self

// 2. Create an In-App Bidding Ad Unit
adUnit = MoPubBannerAdUnit(configId: CONFIG_ID, size: adSize)
    
// 3. Run an Header Bidding auction on Prebid
adUnit.fetchDemand(with: banner!) { [weak self] result in
    
     // 4. Load an Ad
    self?.banner.loadAd()
}
```

#### Step 1: Create Ad View

In the scenario with MoPub integration the MoPub's SDK plays the central role in managing ad views in the application's UI. You have to create and place MoPub's Ad View into the app page. If a winning bid on Prebid wins in the MoPub waterfall it will be rendered via Mediation in the place of original MoPub's Ad View by Prebid Rendering Module.

#### Step 2: Create Ad Unit

Create the **MoPubBannerAdUnit** object with parameters:

- **configId** - an ID of Stored Impression on the Prebid server
- **size** - the size of the ad unit which will be used in the bid request.

#### Step 3: Fetch Demand

To run an auction on Prebid run the `fetchDemand()` method which performs several actions:

- Makes a bid request to Prebid
- Sets up the targeting keywords to the MoPub's ad unit
- Passes the winning bid to the MoPub's ad unit
- Returns the result of bid request for future processing

#### Step 4: Load the Ad

When the bid request has completed, the responsibility of making the Ad Request is passed to the publisher. That is why you have to invoke `loadAd()` on the MoPub's Ad View explicitly in the completion handler of `fetchDemand()`.

#### Step 5: Rendering

If the Prebid bid wins on MoPub it will be rendered by `PrebidBannerAdapter`. You don't have to do anything for this.  Just make sure that your order had been set up correctly and an adapter is added.

## Interstitial API

To display an ad you need to implement these easy steps:

``` swift
// 1. Create an MoPub's Interstitial Controller
interstitialController = MPInterstitialAdController.init(forAdUnitId: MOPUB_AD_UNIT_ID)
interstitialController.delegate = self

// 2. Create an In-App Bidding Interstitial Ad Unit
interstitialAdUnit = MoPubInterstitialAdUnit(configId: CONFIG_ID,
                                                minSizePercentage: CGSize(width: 30, height: 30))
    
// 3. Run an Header Bidding auction on Prebid
interstitialAdUnit.fetchDemand(with: interstitialController!) { [weak self] result in
    
    // 4. Load an Ad
    self?.interstitialController.loadAd()
}

// .....

// 5. Show the ad
if interstitialController.ready {
    interstitialController.show(from: self)
}
```

The way of displaying **Video Interstitial Ad** is almost the same with two differences:

- Need customize the ad unit kind
- No need to set up `minSizePercentage`

``` swift
// 1. Create an MoPub's Interstitial Controller
interstitialController = MPInterstitialAdController.init(forAdUnitId: MOPUB_AD_UNIT_ID)
interstitialController.delegate = self

// 2. Create an In-App Bidding Interstitial Ad Unit
interstitialAdUnit = MoPubInterstitialAdUnit(configId: CONFIG_ID,
                                                minSizePercentage: CGSize(width: 30, height: 30))
interstitialAdUnit.adFormat = .video
    
// 3. Run an Header Bidding auction on Prebid
interstitialAdUnit.fetchDemand(with: interstitialController!) { [weak self] result in
    
    // 4. Load an Ad
    self?.interstitialController.loadAd()
}
// .....

// 5. Show the ad
if interstitialController.ready {
        interstitialController?.show(from: self)
}
```

#### Step 1: Create Ad View

In the scenario with MoPub integration the MoPub SDK plays the central role in managing ad views in the application's UI. If a winning bid on Prebid wins in the MoPub waterfall it will be rendered via Mediation by Prebid Rendering Module.

#### Step 2: Create Ad Unit

Create the **MoPubInterstitialAdUnit** object with parameters:

- **configId** - an ID of Stored Impression on the Prebid server

#### Step 3: Fetch Demand

To run an auction on Prebid run the `fetchDemand()` method which performs several actions:

- Makes a bid request to Prebid
- Sets up the targeting keywords to the MoPub's ad unit
- Passes the winning bid to the MoPub's ad unit
- Returns the result of bid request for future processing

#### Step 4: Load the Ad

When the bid request has been completed the responsibility of making the Ad Request is passed on the publisher. That is why you have to invoke the `loadAd()` on the MoPub Ad View explicitly in the completion handler of the `fetchDemand()`.

#### Step 5: Rendering

If the Prebid bid wins on MoPub it will be rendered by `OXAMoPubInterstitialAdapter`. You do not have to do anything for this.  Just make sure that your order had been set up correctly and an adapter is added to the application target in the Xcode project

However, due to the expiration, the ad could become invalid with time. So it is always useful to check it with `interstitialController?.isReady` before display.

## Rewarded API

To display an ad you need to implement these easy steps:

``` swift
// 1. Create an In-App Bidding Interstitial Ad Unit
rewardedAdUnit = MoPubRewardedAdUnit(configId: CONFIG_ID)
    
// 2. Run an Header Bidding auction on Prebid
let bidInfoWrapper = MoPubBidInfoWrapper()
rewardedAdUnit.fetchDemand(with: bidInfoWrapper) { [weak self] result in
    guard let self = self else {
        return
    }
    
    // 3. Load an Ad
    MPRewardedVideo.setDelegate(self, forAdUnitId: self.MOPUB_AD_UNIT_ID)
    MPRewardedVideo.loadAd(withAdUnitID: self.MOPUB_AD_UNIT_ID,
                           keywords: bidInfoWrapper.keywords as String?,
                           userDataKeywords: nil,
                           customerId: "testCustomerId",
                           mediationSettings: [],
                           localExtras: bidInfoWrapper.localExtras)
}

/// .......

// 4. Try to Display an Ad
if MPRewardedVideo.hasAdAvailable(forAdUnitID: MOPUB_AD_UNIT_ID) {
    let rewards = MPRewardedVideo.availableRewards(forAdUnitID: MOPUB_AD_UNIT_ID)
    guard let reward = rewards?.first as? MPRewardedVideoReward else {
        return
    }
    
    // 5. Present Ad
    MPRewardedVideo.presentAd(forAdUnitID: MOPUB_AD_UNIT_ID, from: self, with: reward, customData: nil)
}
```

#### Step 1: Create an Rewarded Ad Unit

Create the **RewardedAdUnit** object with parameter:

- **configId** - an ID of Stored Impression on the Prebid server

#### Step 2: Fetch Demand

To run an auction on Prebid run the `fetchDemand()` method which does several things:

- Makes a bid request to Prebid server
- Sets up the targeting keywords to auxiliary class `MoPubBidInfoWrapper`
- Returns the result of bid request for future processing

#### Step 3: Load the Ad

When the bid request has completed, the responsibility of making the Ad Request is passed to the publisher. That is why you have to invoke the `loadAd()` of the MoPub's Ad View explicitly in the completion handler of the `fetchDemand()`.

#### Step 5: Present the Rewarded Ad

If the Prebid bid wins on MoPub it will be rendered by `OXAMoPubRewardedVideoAdapter`. You do not have to do anything for this.  Just make sure that your order had been set up correctly and an adapter is added to the application target in the Xcode project
