# MoPub: Native Ads Integration

## Native Ads

TODO Add content

## Native Styles 

[See MoPub Integration page](../integration-mopub/ios-in-app-bidding-mopub-info.md) for more info about MoPub order setup and Adapter integration.

To display an ad you need to implement these easy steps:

``` swift
// 1. Create a MoPub AdView
banner = MPAdView(adUnitId: MOPUB_AD_UNIT_ID)
banner.delegate = self

// 2. Create an Prebid Ad Unit
adUnit = MoPubBannerAdUnit(configId: CONFIG_ID, size: adSize)

// 3. Provide NativeAdConfiguration
adUnit.nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: assets)
    
// 4. Run a Header Bidding auction on Prebid
adUnit.fetchDemand(with: banner!) { [weak self] result in
    
     // 5. Load an Ad
    self?.banner.loadAd()
}
```

#### Step 1: Create Ad View

You have to create and place MoPub's Ad View into the app page.


#### Step 2: Create Ad Unit

Create the **MoPubBannerAdUnit** object with parameters:

- **configId** - an ID of Stored Impression on the Prebid server
- **size** - the size of the ad unit which will be used in the bid request.


#### Step 3: Create and provide Native Assets

To make a proper bid request publishers should provide the needed assets to the NativeAdConfiguration class. Each asset describes the UI element of the ad according to the [OpenRTB standarts](https://www.iab.com/wp-content/uploads/2018/03/OpenRTB-Native-Ads-Specification-Final-1.2.pdf).

``` swift
let assets = [
    {
        let title = NativeAssetTitle(length: 90)
        title.required = true
        return title
    }(),
    {
        let icon = NativeAssetImage()
        icon.widthMin = 50
        icon.heightMin = 50
        icon.required = true
        icon.imageType = NSNumber(value: PBMImageAssetType.icon.rawValue)
        return icon
    }(),
    {
        let image = NativeAssetImage()
        image.widthMin = 150
        image.heightMin = 50
        image.required = true
        image.imageType = NSNumber(value: PBMImageAssetType.main.rawValue)
        return image
    }(),
    {
        let desc = NativeAssetData(dataType: .desc)
        desc.required = true
        return desc
    }(),
    {
        let cta = NativeAssetData(dataType: .ctaText)
        cta.required = true
        return cta
    }(),
    {
        let sponsored = NativeAssetData(dataType: .sponsored)
        sponsored.required = true
        return sponsored
    }(),
]
```

See more NativeAdConfiguration options [here](../native/ios-native-ad-configuration.md).

### Step 4: Fetch Demand

To run an auction on Prebid run the `fetchDemand()` method which performs several actions:

- Makes a bid request to Prebid
- Sets up the targeting keywords to the MoPub's ad unit
- Passes the winning bid to the MoPub's ad unit
- Returns the result of bid request for future processing

### Step 5: Load the Ad

When the bid request has completed, the responsibility of making the Ad Request is passed to the publisher. That is why you have to invoke `loadAd()` on the MoPub's Ad View explicitly in the completion handler of `fetchDemand()`.

