//
//  OnboardingViewController.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/24/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate: class {
    func onboardingFinished(onboardingViewController: UIViewController)
}

class OnboardingViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont(openSansStyle: .bold, size: 24)
        }
    }

    @IBOutlet private weak var detailLabel: UILabel! {
        didSet {
            detailLabel.font = UIFont(openSansStyle: .regular, size: 14)
        }
    }

    @IBOutlet private weak var button: SDButton! {
        didSet {
            button.changeState(to: .normal(title: "I UNDERSTAND"))
        }
    }

    private weak var delegate: OnboardingViewControllerDelegate?

    init(delegate: OnboardingViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: Self.name, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction func onboardingCompleteWasPressed(_ sender: UIButton) {
        delegate?.onboardingFinished(onboardingViewController: self)
    }
}
