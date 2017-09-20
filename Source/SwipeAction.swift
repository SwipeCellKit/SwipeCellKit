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
    /// An optional unique action identifier.
    public var identifier: String?
    
    /// The title of the action button.
    ///
    /// - note: You must specify a title or an image.
    public var title: String?
    
    /// The style applied to the action button.
    public var style: SwipeActionStyle
    
    /// The object that is notified as transitioning occurs.
    public var transitionDelegate: SwipeActionTransitioning?
    
    /// The font to use for the title of the action button.
    ///
    /// - note: If you do not specify a font, a 15pt system font is used.
    public var font: UIFont?
    
    /// The text color of the action button.
    ///
    /// - note: If you do not specify a color, white is used.
    public var textColor: UIColor?
    
    /// The highlighted text color of the action button.
    ///
    /// - note: If you do not specify a color, `textColor` is used.
    public var highlightedTextColor: UIColor?
    
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
  
    /// The highlighted background color of the action button.
    ///
    /// - note: Use this property to specify the highlighted background color for your button.
    public var highlightedBackgroundColor: UIColor?
    
    /// The visual effect to apply to the action button.
    ///
    /// - note: Assigning a visual effect object to this property adds that effect to the background of the action button.
    public var backgroundEffect: UIVisualEffect?
    
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
    
    /**
     Calling this method performs the configured expansion completion animation including deletion, if necessary. Calling this method more than once has no effect.
 
     You should only call this method from the implementation of your action `handler` method.
     
     - parameter style: The desired style for completing the expansion action.
     */
    public func fulfill(with style: ExpansionFulfillmentStyle) {
        completionHandler?(style)
    }
    
    // MARK: - Internal
    
    internal var completionHandler: ((ExpansionFulfillmentStyle) -> Void)?
}

/// Describes how expansion should be resolved once the action has been fulfilled.
public enum ExpansionFulfillmentStyle {
    /// Implies the item will be deleted upon action fulfillment.
    case delete

    /// Implies the item will be reset and the actions view hidden upon action fulfillment.
    case reset
}

// MARK: - Internal

internal extension SwipeAction {
    var hasBackgroundColor: Bool {
        return backgroundColor != .clear && backgroundEffect == nil
    }
}
