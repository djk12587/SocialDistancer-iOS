//
//  NotificationController.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/27/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationController {

    enum `Type` {
        case deviceFound(total: Int)
        case bleTurnedOff
        case startedScan
    }

    private let notificationCenter = UNUserNotificationCenter.current()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func askForPermission(completion: @escaping (Bool) -> Void) {
        checkPermissions { isFirstAsk in
            if isFirstAsk {
                self.requestPermission { completion(true) }
            }
            else {
                completion(false)
            }
        }
    }

    func fireNotification(type: Type) {
        let content = UNMutableNotificationContent()
        switch type {
            case .deviceFound(let total):
                let deviceString = total == 1 ? "device" : "devices"
                content.title = "Scanning"
                content.body = "\(total) \(deviceString) nearby."
            case .bleTurnedOff:
                content.title = "Scanning stopped"
                content.body = "Bluetooth turned off"
            case .startedScan:
                content.title = "Scanning Started"
                content.body = "We are now scanning for nearby devices."
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        notificationCenter.add(request)
    }

    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus == .notDetermined) }
        }
    }

    private func requestPermission(completion: @escaping () -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in
            DispatchQueue.main.async { completion() }
        }
    }

    @objc private func appWillEnterForeground() {
        notificationCenter.getDeliveredNotifications { (delieveredNotifications) in
            let delieveredNotificationIdsToRemove = delieveredNotifications.compactMap {
                $0.date.compare(Date().addingTimeInterval(Constants.fifteenMinutesAgo)) == .orderedAscending ? $0.request.identifier : nil
            }
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers: delieveredNotificationIdsToRemove)
        }
    }
}

private extension NotificationController {
    enum Constants {
        static let fifteenMinutesAgo: TimeInterval = -(15 * 60)
    }
}
