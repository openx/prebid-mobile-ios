# GAM: Native Ads Integration

## Unified Native Ads

The general integration scenario requires these steps from publishers:

1. Prepare the ad layout.
2. Create Native Ad Unit and appropriate GAM ad loader.
3. Configure the Native Ad unit using [NativeAdConfiguration](../native/ios-native-ad-configuration.md).
    * Provide the list of **[Native Assets](../ios-in-app-bidding-native-guidelines-info.md#components)** representing the ad's structure.
    * Tune other general properties of the ad.
4. Make a bid request.
5. Prepare publisherAdRequest using `GamUtils.prepare`
6. After receiving response from GAM  - check if prebid has won and find native ad using `GamUtils`
7. Bind the winner data from the native ad response with the layout.

``` swift
func loadAd() {
    guard let nativeAdConfig = nativeAdConfig else {
        return
    }
    adUnit = NativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
    
    if let adUnitContext = AppConfiguration.shared.adUnitContext {
        for dataPair in adUnitContext {
            adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
        }
    }
    
    adUnit?.fetchDemand { [weak self] demandResponseInfo in
        guard let self = self else {
            return
        }
        let dfpRequest = GAMRequest()
        GAMUtils.shared.prepareRequest(dfpRequest, demandResponseInfo: demandResponseInfo)
        
        self.adLoader = GADAdLoader(adUnitID: self.gamAdUnitId,
                                    rootViewController: self.rootController,
                                    adTypes: self.adTypes,
                                    options: [])
        self.adLoader?.delegate = self
        self.adLoader?.load(dfpRequest)
    }
}
```

Example of handling NativeAd response (the same applies to Custom):

``` swift
GAMUtils.shared.findNativeAd(for: nativeAd, nativeAdDetectionListener: nativeAdDetectionListener)
```

## Native Styles 

[See Google Ad Manager Integration page](ios-in-app-bidding-gam-info.md) for more info about GAM order setup and GAM Event Handler integration.

To integrate a banner ad you need to implement three easy steps:

``` swift
// 1. Create an Event Handler
let eventHandler = PBMBannerEventHandler(adUnitID: GAM_AD_UNIT_ID,
                                            validGADAdSizes: [NSValueFromGADAdSize(adSize)])
       
// 2. Create a Banner View
let banner = BannerView(configId: CONFIG_ID,
                           eventHandler: eventHandler)
banner.delegate = self

// 3. Setup Native Ad Configuration
banner.nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: assets)
        
// 4. Load an Ad
banner.loadAd()
```


#### Step 1: Create Event Handler

GAM's event handlers are special containers that wrap GAM Ad Views and help to manage collaboration between GAM and Prebid views.

**Important:** you should create and use a unique event handler for each ad view.

To create the event handler you should provide a GAM Ad Unit Id and the list of available sizes for this ad unit.


#### Step 2: Create Ad View

**BannerView** - is a view that will display the particular ad. It should be added to the UI. To create it you should provide:

- **configId** - an ID of Stored Impression on the Prebid server
- **eventHandler** - the instance of the banner event handler

Also, you should add the instance of `BannerView` to the UI.

#### Step 3: Create and provide Native Assets

The make a proper bid request publishers should provide the needed assets to the NativeAdConfiguration class. Each asset describes the UI element of the ad according to the [OpenRTB standarts](https://www.iab.com/wp-content/uploads/2018/03/OpenRTB-Native-Ads-Specification-Final-1.2.pdf).

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

See the full description of NativeAdConfiguration options [here](../native/ios-native-ad-configuration.md).

#### Step 4: Load the Ad

Simply call the `loadAd()` method to start [In-App Bidding](../ios-in-app-bidding-getting-started.md) flow.