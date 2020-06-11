//
//  Scanner.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/25/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BleControllerDelegate: class {
    func bleStateDidChange(to state: BleController.State)
    func nearbyDevicesChanged(total: Int, state: BleController.State)
    func newDeviceFound()
}

/// `FD6F`Is not scannable in the background
/// I have to pass in a CBUUID into the scanner for it to get callbacks to the discovery function while backgrounded
/// `self.manager.scanForPeripherals(withServices: CBUUID(string: "FD6F"), options: nil)`
/// However, apple blocks scanning for `FD6F`
/// So i have to pass in  nil.
/// `self.manager.scanForPeripherals(withServices: nil, options: nil)`
/// Passing in `nil` results in no callbacks to the `didDiscover:peripheral` function while backgrounded

/// http://www.davidgyoungtech.com/2020/04/24/hacking-with-contact-tracing-beacons
/// As stated in the link above, it might not be possible to detect `FD6F` in the foreground. Apple might block the advertisment data coming back from CoreBluetooth.

class BleController: NSObject {
//  The real UUID that apple will broadcast
    private let exposureNotificationBleServiceId = CBUUID(string: "FD6F")
//  I was able to extract FD6F from the advertisement data using this code below,
//  and a sample android app that broadcasts the Exposure Notification BLE service
//  THIS ONLY WORKS IN THE FOREGROUND
//    if advertisementData["kCBAdvDataServiceUUIDs"] != nil {
//        print(advertisementData["kCBAdvDataServiceUUIDs"])
//    }

    private var discoveredDevices: Set<BleController.Device> = [] {
        didSet {
            let newCount = discoveredDevices.count
            let oldCount = oldValue.count
            guard oldCount != newCount, let state = state else { return }
            delegate?.nearbyDevicesChanged(total: newCount, state: state)
            if newCount > oldValue.count {
                delegate?.newDeviceFound()
            }
        }
    }

    private(set) var state: State? {
        didSet {
            guard let state = state, oldValue != state else { return }
            checkScanningRebootTimer()
            delegate?.bleStateDidChange(to: state)
        }
    }
    private var timer: Timer?

    init(delegate: BleControllerDelegate) {
        self.delegate = delegate
    }

    weak var delegate: BleControllerDelegate?

    lazy private var manager: CBCentralManager = {
        return getManager
    }()

    private var getManager: CBCentralManager {
        return CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey : true])
    }

    private func checkScanningRebootTimer() {
        guard state == .scanning, !(timer?.isValid ?? false) else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (timer) in
            guard self?.state == .scanning else { timer.invalidate(); return }
            self?.rebootScan()
        }
    }

    var currentDeviceCount: Int {
        return discoveredDevices.count
    }

    func start() {
        guard manager.state == .poweredOn else { return }
        scan()
    }

    func stop() {
        manager.stopScan()
        state = manager.state.bleState
        discoveredDevices.removeAllDevices()
    }

    ///Returns a bool to let you know permissions are already allowed
    func askUserToTurnOnBluetooth() -> Bool {
        //creating a centralManager with the option CBCentralManagerOptionShowPowerAlertKey prompts the user to turn on Bluetooth
        manager = getManager
        return CBManager.authorization == .allowedAlways
    }

    func removeAllDiscoveredDevices() {
        discoveredDevices.removeAllDevices()
    }

    private func scan() {
        state = .scanning
        manager.scanForPeripherals(withServices: [exposureNotificationBleServiceId], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }

    //On my test device the manager would only discover a peripheral ONCE while locked. restarting the scan would allow you to discover it over and over again while locked
    private func rebootScan() {
        guard self.state == .scanning else { return }
        manager.stopScan()
        start()
    }
}

extension BleController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        state = central.state.bleState
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard RSSI.intValue < BleController.RSSI.max, RSSI.intValue >= BleController.RSSI.threshold else { return }
        let deviceInsertionResult = discoveredDevices.insert(Device(peripheral: peripheral, rssi: RSSI, delegate: self))
        deviceInsertionResult.memberAfterInsert.wasDiscovered(rssi: RSSI)
        print("Found: \(Unmanaged.passUnretained(peripheral).toOpaque()) • \(peripheral.identifier) • \(RSSI) • \(Date().currentTime)")
    }
}

extension BleController: BleDeviceDelegate {
    func deviceExpired(device: Device) {
        discoveredDevices.remove(device)
        print("Removed: \(Unmanaged.passUnretained(device.peripheral).toOpaque()) • \(device.peripheral.identifier) • \(device.rssi) • \(Date().currentTime)")
    }
}

extension BleController {
    enum State {
        case unknown
        case resetting
        case unsupported
        case unauthorized
        case poweredOff
        case poweredOn
        case scanning
    }
}

private extension CBManagerState {
    var bleState: BleController.State {
        switch self {
            case .poweredOff:
                return .poweredOff
            case .poweredOn:
                return .poweredOn
            case .resetting:
                return .resetting
            case .unauthorized:
                return .unauthorized
            case .unknown:
                return .unknown
            case .unsupported:
                return .unsupported
            @unknown default:
                return .unknown
        }
    }
}

private extension BleController {
    enum RSSI {
        static let threshold = -80
        ///I got this value back sometimes from the peripheral's RSSI and need to disregard it as its the max rssi value and is not valid
        static let max = 127
    }
}

private extension Set where Element == BleController.Device {
    mutating func removeAllDevices() {
        forEach { $0.removeDevice() }
        removeAll()
    }
}
