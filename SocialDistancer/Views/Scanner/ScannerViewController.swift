//
//  ScannerViewController.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/24/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit
import SafariServices

class ScannerViewController: UIViewController {

    private let animationDuration = 0.4

    @IBOutlet private weak var statusTitleLabel: UILabel! {
        didSet { statusTitleLabel.font = UIFont(openSansStyle: .regular, size: 16) }
    }

    @IBOutlet private weak var statusLabel: UILabel! {
        didSet { statusLabel.font = UIFont(openSansStyle: .bold, size: 24) }
    }

    @IBOutlet private weak var detailTextContainerView: UIView! {
        didSet {
            detailTextContainerView.layer.borderWidth = 1
            detailTextContainerView.layer.cornerRadius = 8
            detailTextContainerView.layer.borderColor = UIColor.Theme.grayColor.cgColor
        }
    }

    @IBOutlet private weak var moreButton: UIButton! {
        didSet {
            moreButton.tintColor = UIColor.label
        }
    }

    @IBOutlet private weak var detailTextLabel: UILabel! {
        didSet { detailTextLabel.font = UIFont(openSansStyle: .regular, size: 16) }
    }

    @IBOutlet private weak var scanningAnimationView: GrowingCircularView! {
        didSet {
            scanningAnimationView.layer.borderWidth = 1
            scanningAnimationView.layer.borderColor = UIColor.Theme.primaryColor.cgColor
            scanningAnimationView.layer.cornerRadius = scanningAnimationView.bounds.height / 2
        }
    }

    @IBOutlet private weak var statusIconBackgroundCircleImageView: UIImageView!
    @IBOutlet private weak var statusIconScanningDevicesFoundImageView: UIImageView!
    @IBOutlet private weak var statusIconScanningOffImageView: UIImageView!
    @IBOutlet private weak var statusIconScanningZeroDevicesImageView: UIImageView!
    @IBOutlet private weak var scanButton: SDButton!

    lazy private var scanner: Scanner = {
        return Scanner(delegate: self)
    }()

    init() {
        super.init(nibName: Self.name, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(for: .ready)

        if let scanButton = scanButton {
            scanButton.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: scanButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -148))
        }
    }

    @IBAction private func moreWasPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Intro", style: .default) { _ in
            self.present(OnboardingViewController(delegate: self), animated: true)
        })
        alertController.addAction(UIAlertAction(title: "More information on Covid-19", style: .default) { _ in
            guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-nCoV/index.html") else { return }
            let viewController = SFSafariViewController(url: url)
            self.present(viewController, animated: true)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    @IBAction private func scanButtonWasPressed(_ sender: SDButton) {
        switch scanner.state {
            case .scanning:
                scanner.stop()
            case .ready:
                scanner.start()
            case .off:
                scanner.turnOn()
            case .unauthorized:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsUrl)
            case .unsupported, .unknown:
                let alert = UIAlertController(title: "Bluetooth is not supported.",
                                              message: "This device does not support bluetooth. We cannot help you more. Please keep 6 feet from other people!",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
        }
    }

    private func updateUI(for state: Scanner.State, deviceCount: Int? = nil) {
        let isScanning = state == .scanning
        let deviceCount = deviceCount ?? 0
        let hasDevices = deviceCount > 0

        statusLabel.fadeTransition(animationDuration)
        statusLabel.text = isScanning ? "ON" : "OFF"

        detailTextLabel.fadeTransition(animationDuration)
        switch (isScanning, hasDevices) {
            case (true, false):
                detailTextLabel.text = "0 devices nearby"
            case (true, true):
                let deviceString = deviceCount == 1 ? "device" : "devices"
                detailTextLabel.text = "\(deviceCount) \(deviceString) nearby. Try to keep a distance of at least 6 feet."
            default:
                detailTextLabel.text = "Start scanning to see nearby devices"
        }

        UIView.animate(withDuration: animationDuration, animations: {
            self.detailTextContainerView.backgroundColor = hasDevices ? UIColor.Theme.primaryColor : .clear
            self.detailTextContainerView.layer.borderColor = hasDevices ? UIColor.Theme.primaryColor.cgColor : UIColor.Theme.grayColor.cgColor
            self.detailTextLabel.textColor = hasDevices ? .white : .detailTextLabelColor

            self.statusIconScanningOffImageView.alpha = isScanning ? 0 : 1
            self.statusIconBackgroundCircleImageView.alpha = isScanning ? 1 : 0
            if !self.scanningAnimationView.isAnimating {
                self.scanningAnimationView.alpha = isScanning ? 1 : 0
            }
            self.statusIconScanningDevicesFoundImageView.alpha = isScanning && hasDevices ? 1 : 0
            self.statusIconScanningZeroDevicesImageView.alpha = isScanning && !hasDevices ? 1 : 0
        }) { _ in
            guard self.scanner.state == .scanning, !self.scanningAnimationView.isAnimating else { return }
            self.scanningAnimationView.startAnimation(containerWidth: self.view.bounds.width)
        }

        if !isScanning {
            scanningAnimationView.stopAnimation()
        }

        switch state {
            case .scanning:
                scanButton.changeState(to: .selected(title: "STOP SCANNING"))
            case .ready:
                scanButton.changeState(to: .normal(title: "START SCANNING"))
            case .off:
                scanButton.changeState(to: .normal(title: "Turn on Bluetooth"))
            case .unauthorized:
                scanButton.changeState(to: .normal(title: "Authorize Bluetooth"))
            case .unsupported, .unknown:
                scanButton.changeState(to: .normal(title: "Bluetooth is not supported"))
        }
    }
}

extension ScannerViewController: ScannerDelegate {
    func nearbyDevicesChanged(total: Int, state: Scanner.State) {
        updateUI(for: state, deviceCount: total)
    }

    func newDeviceFound() {
        UIDevice.Vibration.oldSchool.vibrate()
    }

    func scannerStateDidChange(to state: Scanner.State) {
        updateUI(for: state)
    }
}

extension ScannerViewController: OnboardingViewControllerDelegate {
    func onboardingFinished(onboardingViewController: UIViewController) {
        onboardingViewController.dismiss(animated: true)
    }
}

private extension UIColor {
    static var detailTextLabelColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            guard case .dark = traitCollection.userInterfaceStyle else { return .black }
            return .white
        }
    }
}
