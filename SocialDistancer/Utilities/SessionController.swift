//
//  SessionController.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/24/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit
import Foundation

class SessionController {

    weak var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func setupInitialViewController() {
        let initialViewController = UserDefaults.standard.hasBeenOnboarded ? scannerViewController : OnboardingViewController(delegate: self)
        window?.setRootViewController(initialViewController, animated: false)
    }

    private var scannerViewController: UIViewController {
        return ScannerViewController()
    }

    private func setupScannerViewController() {
        window?.setRootViewController(scannerViewController, animated: true)
    }
}

extension SessionController: OnboardingViewControllerDelegate {
    func onboardingFinished(onboardingViewController: UIViewController) {
        UserDefaults.standard.hasBeenOnboarded = true
        setupScannerViewController()
    }
}

private extension UserDefaults {

    enum Keys {
        static let hasBeenOnboarded = "OnboardingController.hasBeenOnboarded"
    }

    var hasBeenOnboarded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.hasBeenOnboarded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasBeenOnboarded)
        }
    }
}

private extension UIWindow {
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated else {
            rootViewController = vc
            makeKeyAndVisible()
            return
        }

        rootViewController = vc
        makeKeyAndVisible()
        UIView.transition(with: self,
                          duration: 0.4,
                          options: .transitionFlipFromBottom,
                          animations: nil,
                          completion: nil)
    }
}
