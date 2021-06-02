# Google Ad Manager Integration

The integration of Prebid Rendering Module with Google Ad Manager (GAM) assumes that publisher has an account on GAM and has already integrated the Google Mobile Ads SDK (GMA SDK) into the app project.

If you do not have GAM SDK in the app yet, refer the the [Google Integration Documentation](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start).
 
## GAM Integration Overview

<img src="../res/Prebid-In-App-Bidding-Overview-GAM.png" alt="Pipeline Screenshot" align="center">

**Steps 1-2** Prebid Rendering Module makes a bid request. Prebid server runs an auction and returns the winning bid.

**Step 3** Prebid Rendering Module via GAM Event Handler sets up the targeting keywords into the GAM's ad unit.

**Step 4** GMA SDK makes an ad request. GAM returns the winner of the waterfall.

**Step 5** Basing on the ad response Prebid GAM Event Handler decided who won on the GAM - the Prebid bid or another ad source on GAM.

**Step 6** The winner is displayed in the App with the respective rendering engine.
  

Prebid Rendering Module supports these ad formats:

- Display Banner
- Display Interstitial
- Native
- [Native Styles](ios-in-app-bidding-gam-native-integration.md)
- Video Interstitial 
- Rewarded Video
- Outstream Video

They can be integrated using these API categories.

- [**Banner API**](#banner-api) - for *Display Banner* and *Outstream Video*
- [**Interstitial API**](#interstitial-api) - for *Display* and *Video* Interstitials
- [**Rewarded API**](#rewarded-api) - for *Rewarded Video*
- [**Native API**](ios-in-app-bidding-gam-native-integration.md) - for *Native Ads*


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

> **NOTE:** The account ID is an identifier of the **Stored Request**.

### Event Handlers

GAM Event Handlers is a set of classes that wrap the GAM Ad Units and manage them respectively to the In-App Bidding flow. These classes are provided in the form of framework that could be added to the app via CocoaPods:

```
pod 'prebid-mobile-sdk-gam-event-handlers'
```

## Banner API

To integrate a banner ad you have to implement three easy steps:


``` swift
// 1. Create an Event Handler
let eventHandler = PBMBannerEventHandler(adUnitID: GAM_AD_UNIT_ID,
                                            validGADAdSizes: [NSValueFromGADAdSize(adSize)])
       
// 2. Create a Banner View
let banner = BannerView(configId: CONFIG_ID,
                           eventHandler: eventHandler)
banner.delegate = self

addBannerToUI(banner: banner)
        
// 3. Load an Ad
banner.loadAd()
```

#### Step 1: Create Event Handler

GAM event handlers are special containers that wrap GAM Ad Views and help to manage collaboration between GAM and Prebid views.

**Important:** you should create and use a unique event handler for each ad view.

To create the event handler you should provide a GAM Ad Unit Id and the list of available sizes for this ad unit.


#### Step 2: Create Ad View

**BannerView** - is a view that will display the particular ad. It should be added to the UI. To create it you should provide:

- **configId** - an ID of Stored Impression on the Prebid server
- **eventHandler** - the instance of the banner event handler

Also, you should add the instance of `BannerView` to the UI.

#### Step 3: Load the Ad

Simply call the `loadAd()` method to start the [In-App Bidding](../ios-in-app-bidding-getting-started.md) flow. Prebid Rendering Module will start the bidding process right away.

### Outstream Video

For **Outstream Video** you also need to specify the kind of expected ad:

``` swift
banner.adFormat = .video
```

And all the rest code will be the same as for integration of display banner.


## Interstitial API

To integrate interstitial ad you need to implement four easy steps:


``` swift
// 1. Create Event Handler
let eventHandler = GAMInterstitialEventHandler(adUnitID: GAM_AD_UNIT_ID)
    
// 2. Create Interstitial Ad Unit
interstitial = InterstitialAdUnit(configId: CONFIG_ID,
                                     minSizePercentage: CGSize(width: 30, height: 30),
                                     eventHandler: eventHandler)
    
interstitial.delegate = self
    
// 3. Load an Ad
interstitial.loadAd()

/// .......

// 4. Show Ad
if interstitial.isReady {
    interstitial.show(from: self)
}

```

The way of displaying **Video Interstitial Ad** is almost the same with two differences:

- Need to customize the ad unit kind
- No need to set up `minSizePercentage`

``` swift
 // 1. Create Event Handler
let eventHandler = GAMInterstitialEventHandler(adUnitID: GAM_AD_UNIT_ID)
    
// 2. Create Interstitial Ad Unit
interstitial = InterstitialAdUnit(configId: CONFIG_ID,
                                     eventHandler: eventHandler)
    
interstitial.adFormat = .video
interstitial.delegate = self
    
// 3. Load an Ad
interstitial.loadAd()

/// .......

// 4. Show Ad
if interstitial.isReady {
    interstitial.show(from: self)
}

```


#### Step 1: Create Event Handler

GAM's event handlers are special containers that wrap the GAM Ad Views and help to manage collaboration between GAM and Prebid views.

**Important:** you should create and use a unique event handler for each ad view.

To create an event handler you should provide a GAM Ad Unit.

#### Step 2: Create Interstitial Ad Unit

**InterstitialAdUnit** - is an object that will load and display the particular ad. To create it you should provide:

- **configId** - an ID of Stored Impression on the Prebid server
- **minSizePercentage** - specifies the minimum width and height percent an ad may occupy of a device’s real estate.
- **eventHandler** - the instance of the interstitial event handler

> **NOTE:** minSizePercentage - plays an important role in a bidding process for display ads. If provided space is not enough demand partners won't respond with the bids.


#### Step 3: Load the Ad

Simply call the `loadAd()` method to start [In-App Bidding](../ios-in-app-bidding-getting-started.md) flow. The ad unit will load an ad and will wait for explicit instructions to display the Interstitial Ad.


#### Step 4: Show the Ad when it is ready

``` swift
// MARK: PBMInterstitialAdUnitDelegate
    
func interstitialDidReceiveAd(_ interstitial: InterstitialAdUnit) {
    // Now the ad is ready for display
}
```

## Rewarded API

To display an Rewarded Ad need to implement four easy steps:


``` swift
 // 1. Create an Event Handler
let eventHandler = GAMRewardedEventHandler(adUnitID: GAM_AD_UNIT_ID)
    
// 2. Create an Ad Unit
rewardedAd = RewardedAdUnit(configId: CONFIG_ID,
                               eventHandler: eventHandler)
    
rewardedAd.delegate = self
    
// 3. Load an Ad
rewardedAd.loadAd()

/// .......

// 4. Display Ad
if rewardedAd.isReady {
    rewardedAd.show(from: self)
}

```

The way of displaying the **Rewarded Ad** is totally the same as for the Interstitial Ad. 


To be notified when user earns a reward - implement the method of `PBMRewardedAdUnitDelegate`:

``` swift
- (void)rewardedAdUserDidEarnReward:(RewardedAdUnit *)rewardedAd;
```

The actual reward object is stored in the `RewardedAdUnit`:

```
if let reward = rewardedAd.reward as? GADAdReward {
    // ...
}
```

#### Step 1: Create Event Handler

GAM's event handlers are special containers that wrap the GAM Ad Views and help to manage collaboration between GAM and Prebid views.

**Important:** you should create and use a unique event handler for each ad view.

To create an event handler you should provide a GAM Ad Unit.


#### Step 2: Create Rewarded Ad Unit

**RewardedAdUnit** - is an object that will load and display the particular ad. To create it you should provide:

- **configId** - an ID of Stored Impression on the Prebid server
- **eventHandler** - the instance of rewarded event handler

#### Step 3: Load the Ad

Simply call the `loadAd()` method to start [In-App Bidding](../ios-in-app-bidding-getting-started.md) flow. The ad unit will load an ad and will wait for explicit instructions to display the Interstitial Ad.


#### Step 4: Show the Ad when it is ready

``` swift
// MARK: PBMRewardedAdUnitDelegate
    
func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
    // Now the ad is ready for display
}
```
