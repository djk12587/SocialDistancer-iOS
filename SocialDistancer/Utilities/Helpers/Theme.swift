//
//  Theme.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/25/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit

extension UIColor {
    enum Theme {

        static func apply() {
            UIApplication.shared.windows.forEach { $0.tintColor = Theme.primaryColor }
        }

        static let primaryColor: UIColor = UIColor(red: 191/255, green: 14/255, blue: 120/255, alpha: 1)
        static let grayColor: UIColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
    }
}
