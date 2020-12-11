# SocialDistancer-iOS
This is a failed attempt to create an app that detects other phones that are broadcasting the Exposure Notification BLE service.

## The goal?
To save the world! I mean, to create an app that helps a user to safely social distance by scanning for other phones that are broadcasting the Exposure Notification BLE service.

## Screenshots
<img src="https://github.com/djk12587/SocialDistancer-iOS/blob/master/Screenshots/demo.gif" width="240" height="520"><br>
<img src="https://github.com/djk12587/SocialDistancer-iOS/blob/master/Screenshots/intro.PNG" width="240" height="520"> 
<img src="https://github.com/djk12587/SocialDistancer-iOS/blob/master/Screenshots/not_scanning.PNG" height="520"><br>
<img src="https://github.com/djk12587/SocialDistancer-iOS/blob/master/Screenshots/scanning.PNG" width="240" height="520"> 
<img src="https://github.com/djk12587/SocialDistancer-iOS/blob/master/Screenshots/scanning_devices_found.PNG" width="240" height="520">

## What went wrong?
We are not a government health organization or developers who have been endorsed and approved by a government health organization.
https://developer.apple.com/contact/request/exposure-notification-entitlement<br><br>
CoreBluetooth doesn't allow you to scan for the Exposure Notification BLE service's CBUUID.
```swift
// The real CBUUID for the Exposure Notification BLE service.
private let exposureNotificationBleServiceId = CBUUID(string: "FD6F")
manager.scanForPeripherals(withServices: [exposureNotificationBleServiceId], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
```
The only way to detect the above service is to scan for all BLE services. Then connect to each discovered peripheral and decode the advertisement data and match it to the CBUUID `FD6F`.
```swift
// Scan for all devices
manager.scanForPeripherals(withServices: nil, options: nil)
```
However, scanning for `nil` services does not generate call backs to the `didDiscover peripheral` delegate while backgrounded. This severely hinders the main goal of the app.

As of 6/10/2020 inorder for an iOS device to broadcast the Exposure Notification BLE service a user has to allow permissions in the health settings, and download an app that is allowed to broadcast the service.

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](https://github.com/djk12587/SocialDistancer-iOS/blob/master/LICENSE)**
