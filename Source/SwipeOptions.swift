//
//  Options.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/// :nodoc:
public typealias SwipeTableOptions = SwipeOptions

/// The `SwipeOptions` class provides options for transistion and expansion behavior for swiped cell.
public struct SwipeOptions {
    /// The transition style. Transition is the style of how the action buttons are exposed during the swipe.
    public var transitionStyle: SwipeTransitionStyle = .border
    
    /// The expansion style. Expansion is the behavior when the cell is swiped past a defined threshold.
    public var expansionStyle: SwipeExpansionStyle?
    
    /// The object that is notified when expansion changes.
    ///
    /// - note: If an `expansionDelegate` is not provided, and the expanding action is configured with a clear background, the system automatically uses the default `ScaleAndAlphaExpansion` to show/hide underlying actions.
    public var expansionDelegate: SwipeExpanding?
    
    /// The background color behind the action buttons.
    public var backgroundColor: UIColor?
    
    /// The largest allowable button width.
    ///
    /// - note: By default, the value is set to the table/collection view divided by the number of action buttons minus some additional padding. If the value is set to 0, then word wrapping will not occur and the buttons will grow as large as needed to fit the entire title/image.
    public var maximumButtonWidth: CGFloat?
    
    /// The smallest allowable button width.
    ///
    /// - note: By default, the system chooses an appropriate size.
    public var minimumButtonWidth: CGFloat?
    
    /// The vertical alignment mode used for when a button image and title are present.
    public var buttonVerticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    
    /// The amount of space, in points, between the border and the button image or title.
    public var buttonPadding: CGFloat?
    
    /// The amount of space, in points, between the button image and the button title.
    public var buttonSpacing: CGFloat?
    
    /// Constructs a new `SwipeOptions` instance with default options.
    public init() {}
}

/// Describes the transition style. Transition is the style of how the action buttons are exposed during the swipe.
public enum SwipeTransitionStyle {
    /// The visible action area is equally divide between all action buttons.
    case border
    
    /// The visible action area is dragged, pinned to the cell, with each action button fully sized as it is exposed.
    case drag
    
    /// The visible action area sits behind the cell, pinned to the edge of the table/collection view, and is revealed as the cell is dragged aside.
    case reveal
}

/// Describes which side of the cell that the action buttons will be displayed.
public enum SwipeActionsOrientation: CGFloat {
    /// The left side of the cell.
    case left = -1
    
    /// The right side of the cell.
    case right = 1
    
    var scale: CGFloat {
        return rawValue
    }
}

/// Describes the alignment mode used when action button images and titles are provided.
public enum SwipeVerticalAlignment {
    /// All actions will be inspected and the tallest image and first baseline offset of title text will be used to create the alignment rectangle.
    ///
    /// - note: This mode will ensure the image and first line of each button title and consistently aligned across the swipe view.
    case centerFirstBaseline
    
    /// The action button image height and full title height are used to create the aligment rectange.
    ///
    /// - note: Buttons with varying number of lines will not be consistently aligned across the swipe view.
    case center
}
