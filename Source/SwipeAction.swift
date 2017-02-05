//
//  SwipeAction.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/// Constants that help define the appearance of action buttons.
public enum SwipeActionStyle: Int {
    /// Apply a style that reflects standard non-destructive actions.
    case `default`
    
    /// Apply a style that reflects destructive actions.
    case destructive
}

/**
 The `SwipeAction` object defines a single action to present when the user swipes horizontally in a table row.
 
 This class lets you define one or more custom actions to display for a given row in your table. Each instance of this class represents a single action to perform and includes the text, formatting information, and behavior for the corresponding button.
 */
public class SwipeAction: NSObject {
    /// The title of the action button.
    ///
    /// - note: You must specify a title or an image.
    public var title: String?
    
    /// The style applied to the action button.
    public var style: SwipeActionStyle
    
    /// The font to use for the title of the action button.
    ///
    /// - note: If you do not specify a font, a 15pt system font is used.
    public var font: UIFont?
    
    /// The text color of the action button.
    ///
    /// - note: If you do not specify a color, white is used.
    public var textColor: UIColor?
    
    /// The image used for the action button.
    ///
    /// - note: You must specify a title or an image.
    public var image: UIImage?
    
    /// The highlighted image used for the action button.
    ///
    /// - note: If you do not specify a highlight image, the default `image` is used for the highlighted state.
    public var highlightedImage: UIImage?
    
    /// The closure to execute when the user taps the button associated with this action.
    public var handler: ((SwipeAction, IndexPath) -> Void)?
    
    /// The background color of the action button.
    ///
    /// - note: Use this property to specify the background color for your button. If you do not specify a value for this property, the framework assigns a default color based on the value in the style property.
    public var backgroundColor: UIColor?
    
    /// A Boolean value that determines whether the actions menu is automatically hidden upon selection.
    ///
    /// - note: When set to `true`, the actions menu is automatically hidden when the action is selected. The default value is `false`.
    public var hidesWhenSelected = false
    
    /**
     Constructs a new `SwipeAction` instance.

     - parameter style: The style of the action button.
     - parameter title: The title of the action button.
     - parameter handler: The closure to execute when the user taps the button associated with this action.
    */
    public init(style: SwipeActionStyle, title: String?, handler: ((SwipeAction, IndexPath) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

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
                backgroundColor = UIColor(colorLiteralRed: 1, green: 60/255, blue: 48/255, alpha: 1)
            default:
                backgroundColor = UIColor(colorLiteralRed: 220/255, green: 220/255, blue: 220/255, alpha: 1)
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
