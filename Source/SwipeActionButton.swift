//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

class SwipeActionButton: UIButton {
    var maximumWidth: CGFloat = 100
    var preferredWidth: CGFloat = 0
    var padding: CGFloat = 0
    
    var originalBackgroundColor: UIColor?
    
    convenience init(frame: CGRect, action: SwipeAction, padding: CGFloat = 4) {
        self.init(frame: frame)
        
        self.padding = padding
        
        if let backgroundColor = action.backgroundColor {
            self.backgroundColor = backgroundColor
        } else {
            switch action.style {
            case .destructive:
                backgroundColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
            default:
                backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
            }
        }
        
        originalBackgroundColor = backgroundColor
        
        tintColor = action.textColor ?? .white
        contentHorizontalAlignment = .center
        
        titleLabel?.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        
        setTitle(action.title, for: .normal)
        setImage(action.image, for: .normal)
        setImage(action.highlightedImage ?? action.image, for: .highlighted)
        
        let textWidth = titleLabel?.textRect(forBounds: CGRect(x: 0, y: 0, width: maximumWidth, height: 0), limitedToNumberOfLines: 0).width ?? 0
        let imageWidth = imageView?.image?.size.width ?? 0
        
        preferredWidth = min(maximumWidth, max(textWidth, imageWidth) + (padding * 2))
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? originalBackgroundColor?.darker() : originalBackgroundColor
        }
    }
    
    override func didMoveToSuperview() {
        if let superview = superview as? SwipeActionsView {
            layout(in: superview)
        }
    }
    
    func layout(in actionsView: SwipeActionsView) {
        let orientationPadding = bounds.width - actionsView.minimumButtonWidth + padding
        
        switch actionsView.orientation {
        case .left:
            contentEdgeInsets = UIEdgeInsets(top: 0, left: orientationPadding, bottom: 0, right: padding)
        case .right:
            contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: orientationPadding)
        }
        
        if let width = imageView?.image?.size.width {
            titleEdgeInsets = UIEdgeInsets(top: 42, left: -width, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: -32, left: (actionsView.minimumButtonWidth - (padding * 2) - width) / 2, bottom: 0, right: 0)
        }
    }
}

private extension UIColor {
    func darker() -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        
        return UIColor(red: max(r - 0.1, 0.0), green: max(g - 0.1, 0.0), blue: max(b - 0.1, 0.0), alpha: a)
    }
}
