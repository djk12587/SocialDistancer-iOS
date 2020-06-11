//
//  Helpers.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/24/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

extension UIViewController {
    static var name: String {
        return String(describing: Self.self)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }

    var isAnimating: Bool {
        return !(layer.animationKeys() ?? []).isEmpty
    }
}

extension Date {
    var currentTime: String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return "\(hour):\(minutes):\(seconds)"
    }
}

extension UIDevice {
    
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    enum Vibration {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        case soft
        case rigid
        case selection
        case oldSchool

        public func vibrate() {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .soft:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .rigid:
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .oldSchool:
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
}
