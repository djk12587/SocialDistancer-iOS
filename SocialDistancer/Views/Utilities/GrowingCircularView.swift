//
//  GrowingCircularView.swift
//  SocialDistancer
//
//  Created by Dan_Koza on 4/28/20.
//  Copyright © 2020 Dan_Koza. All rights reserved.
//

import UIKit

class GrowingCircularView: ViewWithPersistentAnimations {

    func startAnimation(containerWidth: CGFloat) {
        transform = CGAffineTransform(scaleX: 1, y: 1)

        UIView.animate(withDuration: 2.5, delay: 0, options: [.repeat], animations: {
            let scale = containerWidth / self.bounds.width
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.alpha = 0
        })
    }

    func stopAnimation() {
        layer.removeAllAnimations()
        transform = CGAffineTransform(scaleX: 0, y: 0)
    }
}
