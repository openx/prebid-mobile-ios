# Getting started with In-App Bidding

## Integration Scenarios

There are two integration scenarios supported by Rendering Module.

- **With Primary Ad Server** when the winning bid is rendered by Prebid SDK but other ads are rendered by Primary Ad Server SDK.
- **Pure In-App Bidding** when there is no Primary ad server and the winning bid is rendered right after an auction by Prebid SDK.

Below you can find their description and select the most suitable for your application.

  
### Prebid Rendering Module with Primary Ad Server

<img src="res/Pure-In-App-Bidding-Overview-Prebid-with-Primary-Ad-Server.png" alt="Pipeline Screenshot" align="center">

1. Prebid Rendering Module sends the bid request to the Prebid server.
2. Prebid server runs the header bidding auction among preconfigured demand partners.
3. Prebid Server responses with the winning bid that contains targeting keywords.
4. Prebid Rendering Module sets up the targeting keywords of the winning bid to the ad unit of Primary Ad Server SDK.
5. Primary Ad Server SDK sends the ad request to the primary Ad Server
6. Primary Ad Server responds with an ad
7. The info about the winning ad is passed to the Prebid Rendering Module
8. Depending on the ad response Prebid Rendering Module renders the winning bid or allows Primary Ad Server SDK to show its own winning ad.

### Pure In-App Bidding

<img src="res/Prebid-In-App-Bidding-Overview-Pure-Prebid.png" alt="Pipeline Screenshot" align="center">

1. Prebid Rendering Module sends the bid request to the Prebid server.
2. Prebid server runs the header bidding auction among preconfigured demand partners.
3. Prebid Server responses with the winning bid that contains targeting keywords.
4. Prebid Rendering Module renders the winning bid.

## Supported Ad Formats

Prebid Rendering Module supports next ad formats:

 - Display Banner
 - Display Interstitial
 - Video Interstitial
 - Rewarded Video
 - Outstream Video (for GAM and Pure In-App Bidding)
 - Native Styles Ads
 - Native Ads

## Prebid Setup

To start running header bidding auction you should have hosted Prebid Server with predefined auction configurations - **Stored Request** and **Stored Impression**.

Before integrating the Prebid Rendering Module you will need next keys:

- **Prebid Account ID** - an identifier of the **Stored Request**.
- **Configuration ID** - an identifier of the **Stored Impression** which contains information about bidders for a particular ad unit. You need as many ids as many different ad units you want to integrate.

## Init Prebid Rendering Module

Firstly import Rendering Module:

```
import PrebidMobileRenderingSdk
```

Then provide the **Prebid Account ID** of your organization. The best place to do it is the `application:didFinishLaunchingWithOptions` method.
 
```
PrebidRenderingConfig.shared.accountID = YOUR_ACCOUNT_ID
PrebidRenderingConfig.shared.bidServerHost = HOST
```

Now you are ready to integrate ad units.


## Integration Scenarios and Tips

Depending on Primary Ad Server used, In-App Bidding SDK supports these kinds of integration:

- With [Google Ad Manager (GAM)](integration-gam/ios-in-app-bidding-gam-info.md) as a Primary Ad Server
- With [MoPub](integration-mopub/ios-in-app-bidding-mopub-info.md) as a Primary Ad Server
- [Pure In-App Bidding](integration-prebid/ios-in-app-bidding-pb-info.md) as an integration without Primary Ad Server