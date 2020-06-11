//
//  Scanner.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/27/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import Foundation

protocol ScannerDelegate: class {
    func scannerStateDidChange(to state: Scanner.State)
    func nearbyDevicesChanged(total: Int, state: Scanner.State)
    func newDeviceFound()
}

class Scanner {

    private(set) var state: State = .off {
        didSet {
            if oldValue == .scanning && state == .off {
                shouldAutoStartBle = true
            }
        }
    }

    lazy private var bleManager: BleController = {
        return BleController(delegate: self)
    }()

    private var notificationController = NotificationController()
    private weak var delegate: ScannerDelegate?
    private var shouldAutoStartBle: Bool?

    init(delegate: ScannerDelegate) {
        self.delegate = delegate
    }

    func turnOn() {
        let permissionsAreAllowed = bleManager.askUserToTurnOnBluetooth()
        if shouldAutoStartBle == nil {
            shouldAutoStartBle = permissionsAreAllowed
        }
    }

    func start() {
        bleManager.start()
    }

    func stop() {
        bleManager.stop()
    }
}

extension Scanner: BleControllerDelegate {
    func bleStateDidChange(to state: BleController.State) {
        self.state = state.scannerState
        switch state {
            case .poweredOn:
                notificationController.askForPermission { [weak self] isFirstAsk in
                    if isFirstAsk || (self?.shouldAutoStartBle ?? false) {
                        self?.shouldAutoStartBle = false
                        self?.start()
                    }
                    else {
                        self?.delegate?.scannerStateDidChange(to: state.scannerState)
                    }
                }
            case .poweredOff:
                notificationController.fireNotification(type: .bleTurnedOff)
                bleManager.removeAllDiscoveredDevices()
                delegate?.scannerStateDidChange(to: state.scannerState)
            case .scanning:
                notificationController.fireNotification(type: .startedScan)
                delegate?.scannerStateDidChange(to: state.scannerState)
            case .resetting, .unauthorized,. unsupported, .unknown:
                delegate?.scannerStateDidChange(to: state.scannerState)
        }
    }

    func nearbyDevicesChanged(total: Int, state: BleController.State) {
        delegate?.nearbyDevicesChanged(total: total, state: state.scannerState)
    }

    func newDeviceFound() {
        notificationController.fireNotification(type: .deviceFound(total: bleManager.currentDeviceCount))
        delegate?.newDeviceFound()
    }
}

extension Scanner {
    enum State {
        case unknown
        case unsupported
        case unauthorized
        case scanning
        case ready
        case off
    }
}

private extension BleController.State {
    var scannerState: Scanner.State {
        switch self {
            case .scanning:
                return .scanning
            case .poweredOn:
                return .ready
            case .poweredOff, .resetting:
                return .off
            case .unauthorized:
                return .unauthorized
            case .unsupported:
                return .unsupported
            case .unknown:
                return .unknown
        }
    }
}
