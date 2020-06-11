//
//  BleController.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/26/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BleDeviceDelegate: class {
    func deviceExpired(device: BleController.Device)
}

extension BleController {
    class Device {
        let peripheral: CBPeripheral
        var rssi: NSNumber
        private weak var delegate: BleDeviceDelegate?

        deinit {
            timer.invalidate()
        }

        private lazy var timer: Timer = {
            return newTimer
        }()

        private var newTimer: Timer {
            return Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(expired), userInfo: nil, repeats: false)
        }

        init(peripheral: CBPeripheral, rssi: NSNumber, delegate: BleDeviceDelegate) {
            self.peripheral = peripheral
            self.rssi = rssi
            self.delegate = delegate
        }

        func wasDiscovered(rssi: NSNumber) {
            resetTimer()
            guard self.rssi != rssi else { return }
            self.rssi = rssi
        }

        func removeDevice() {
            timer.invalidate()
            delegate?.deviceExpired(device: self)
        }

        private func resetTimer() {
            timer.invalidate()
            timer = newTimer
        }

        @objc private func expired() {
            removeDevice()
        }
    }
}

extension BleController.Device: Hashable {
    static func == (lhs: BleController.Device, rhs: BleController.Device) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral.identifier)
    }
}
