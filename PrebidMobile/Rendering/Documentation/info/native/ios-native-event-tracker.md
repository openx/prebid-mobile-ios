# PBMNativeEventTracker class

`PBMNativeEventTracker` class is used to setup 'eventtrackers' field for Native OpenRTB request. Event trackers object specifies the types of events the bidder can request to be tracked in the bid response, and which types of tracking are available for each event type, and is included as an array in the request.

## Properties

| Name                 | Description                                                  |
|:---------------------|:-------------------------------------------------------------|
| eventType            | Type of event available for tracking                         |
| eventTrackingMethods | Array of the types of tracking available for the given event |
| ext                  | The custom extension available to the publisher |


## Enums

### PBMNativeEventType
| Name             | ID   | Description                                                                    |
|:-----------------|:-----|:-------------------------------------------------------------------------------|
| Impression       | 1    | Impression                                                                     |
| MRC50            | 2    | Visible impression using MRC definition at 50% in view for 1second             |
| MRC100           | 3    | 100% in view for 1 second (ie GroupM  standard)                                |
| Video50          | 4    | Visible impression for video using MRC definition at 50% in view for 2 seconds |
| ExchangeSpecific | 500+ | Exchange specific                                                              |

### PBMNativeEventTrackingMethod

| Name   | ID   | Description                                                                                                                               |
|:-------|:-----|:------------------------------------------------------------------------------------------------------------------------------------------|
| Image             | 1    | Image-pixel tracking - URL provided will be inserted as a 1x1 pixel at the time of the event                                              |
| JS                | 2    | Javascript-based tracking - URL provided will be inserted as a js tag at the time of the event                                            |
| ExchangeSpecific  | 500+ | Could include custom  measurement companies such as moat, double verify, IAS, etc - in this case additional elements will often be passed |
