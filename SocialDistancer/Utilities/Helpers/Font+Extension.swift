//
//  Font+Extension.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/25/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit

extension UIFont {
    enum OpenSans: String {
        case regular
        case bold
        case semiBoldItalic
        case extraBoldItalic
        case lightItalic
        case boldItalic
        case light
        case semiBold
        case italic
        case extraBold

        var name: String {
            return "OpenSans-\(rawValue.capitalized)"
        }
    }

    convenience init(openSansStyle style: OpenSans, size: CGFloat) {
        self.init(name: style.name, size: size)!
    }
}
