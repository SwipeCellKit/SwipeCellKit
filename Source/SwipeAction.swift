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


