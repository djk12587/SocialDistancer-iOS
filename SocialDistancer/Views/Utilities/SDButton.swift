//
//  SDButton.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/25/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit

class SDButton: UIButton {

    enum State {
        case normal(title: String)
        case selected(title: String)
        case loading
    }

    private(set) var buttonState: State? {
        didSet {
            guard let state = buttonState else { return }
            switch state {
                case .normal(let title):
                    setTitleColor(.white, for: .normal)
                    backgroundColor = UIColor.Theme.primaryColor
                    activityIndicator.stopAnimating()
                    setTitle(title, for: .normal)
                case .loading:
                    setTitleColor(UIColor.Theme.primaryColor, for: .normal)
                    backgroundColor = UIColor.Theme.primaryColor
                    activityIndicator.startAnimating()
                case .selected(let title):
                    setTitleColor(UIColor.Theme.primaryColor, for: .normal)
                    backgroundColor = .systemBackground
                    activityIndicator.stopAnimating()
                    setTitle(title, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont(openSansStyle: .semiBold, size: 14)
        layer.borderWidth = 1
        layer.borderColor = UIColor.Theme.primaryColor.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 15, left: 22, bottom: 15, right: 22)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBackground
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraints([xCenterConstraint, yCenterConstraint])
        return activityIndicator
    }()

    func changeState(to state: State) {
        self.buttonState = state
    }
}
