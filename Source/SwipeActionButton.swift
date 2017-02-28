//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

class SwipeActionButton: UIButton {
    var contentRect: CGRect = .zero
    var originalBackgroundColor: UIColor?
    
    var spacing: CGFloat = 8
    var padding: CGFloat = 8
    
    var maximumImageHeight: CGFloat = 0
    var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    
    convenience init(frame: CGRect, action: SwipeAction) {
        self.init(frame: frame)
        
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
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0
        
        setTitle(action.title, for: .normal)
        setImage(action.image, for: .normal)
        setImage(action.highlightedImage ?? action.image, for: .highlighted)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? originalBackgroundColor?.darker() : originalBackgroundColor
        }
    }
        
    func updateContentEdgeInsets(withContentWidth contentWidth: CGFloat, for orientation: SwipeActionsOrientation) {
        switch orientation {
        case .left:
            contentRect = CGRect(x: bounds.width - contentWidth, y: 0, width: contentWidth, height: bounds.height)
        case .right:
            contentRect = CGRect(x: 0, y: 0, width: contentWidth, height: bounds.height)
        }
        
        contentRect = contentRect.insetBy(dx: padding, dy: padding)
        
        contentEdgeInsets = UIEdgeInsets(top: contentRect.minY,
                                         left: contentRect.minX,
                                         bottom: bounds.height - contentRect.maxY,
                                         right: bounds.width - contentRect.maxX)
    }
    
    func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let containingBounds = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let textWidth = titleLabel?.textRect(forBounds: containingBounds, limitedToNumberOfLines: 0).width ?? 0
        let imageWidth = imageView?.image?.size.width ?? 0
        
        return min(width, max(textWidth, imageWidth) + padding * 2)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        guard let currentImage = currentImage else { return .zero }
        
        return CGRect(origin: .zero, size: currentImage.size)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        guard let title = currentTitle, let font = titleLabel?.font else { return .zero }
        
        return title.boundingRect(with: contentRect.size,
                                  options: [.usesLineFragmentOrigin],
                                  attributes: [NSFontAttributeName: font],
                                  context: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel, let imageView = imageView else { return }
        
        let spacing = (currentTitle?.isEmpty == false && maximumImageHeight > 0) ? self.spacing : 0
        let totalHeight = maximumImageHeight + titleHeightForAlignment + spacing
        let alignmentRect = contentRect.center(size: CGSize(width: contentRect.width, height: totalHeight))
        
        imageView.center.x = contentRect.midX
        imageView.frame.origin.y = alignmentRect.minY + (maximumImageHeight - imageView.bounds.height) / 2

        titleLabel.center.x = contentRect.midX
        titleLabel.frame.origin.y = alignmentRect.minY + maximumImageHeight + spacing
    }
    
    var titleHeightForAlignment: CGFloat {
        guard let titleLabel = titleLabel else { return 0 }
        guard currentTitle?.isEmpty == false else { return 0 }
        
        if verticalAlignment == .centerFirstBaseline {
            return titleLabel.font.ascender
        } else {
            return titleLabel.frame.height + (titleLabel.frame.height > 0 ? titleLabel.font.descender : 0)
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

extension CGRect {
    func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: origin.x + dx * 0.5, y: origin.y + dy * 0.5, width: size.width, height: size.height)
    }
}
