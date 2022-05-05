//
//  UIColor+Highlighted.swift
//  MailExample
//
//  Created by Ilia Sedov on 05.05.2022.
//

import UIKit

extension UIColor {
    func getHighlightedColor() -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        ) {
            return UIColor(
                hue: hue,
                saturation: saturation,
                brightness: brightness - 0.1,
                alpha: alpha
            )
        }
        return withAlphaComponent(0.8)
    }
}
