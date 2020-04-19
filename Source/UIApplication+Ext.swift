//
//  UIApplication+Ext.swift
//  SwipeCellKit
//
//  Created by Văn Tiến Tú on 4/19/20.
//

import UIKit

extension UIApplication {
    static func topmostViewController()  -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
