# iOS App Transport Security (ATS)

App Transport Security (ATS) is an iOS app default setting which prevents apps from making non-secure connections (see [Apple iOS release documentation](https://developer.apple.com/library/content/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html)). 

Due to many network calls, related to the ad, are not secure (HTTP), such as those related to resources and events, it is recommended to allow insecure connections in the app according to he [Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity).


