//
//  Options.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import Foundation

/// The `SwipeTableOptions` class provides options for transistion and expansion behavior for swiped cell.
public struct SwipeTableOptions {
    /// The expansion style. Expansion is the behavior when the cell is swiped past a defined threshold.
    public var expansionStyle: SwipeExpansionStyle = .none
    
    /// The transition style. Transition is the style of how the action buttons are exposed during the swipe.
    public var transitionStyle: SwipeTransitionStyle = .border
    
    /// The background color behind the action buttons.
    public var backgroundColor: UIColor?
    
    /// Constructs a new `SwipeTableOptions` instance with default options.
    public init() {}
}

/// Describes the expansion style.  Expansion is the behavior when the cell is swiped past a defined threshold.
public enum SwipeExpansionStyle {
    /// No expansion. Elasticity is applied once all action buttons have been exposed.
    case none
    
    /// The default action performs a selection-type behavior. The cell bounces back to its unopened state upon selection and the row remains in the table view.
    case selection
    
    /// The default action performs a destructive behavior. The cell is removed from the table view in an animated fashion.
    ///
    /// - warning: The `SwipeAction` handler must update the table view's backing data model to remove the item respresenting the row.
    case destructive
}

/// Describes the transition style. Transition is the style of how the action buttons are exposed during the swipe.
public enum SwipeTransitionStyle {
    /// The visible action area is equally divide between all action buttons.
    case border
    
    /// The visible action area is dragged, pinned to the cell, with each action button fully sized as it is exposed.
    case drag
    
    /// The visible action area sits behind the cell, pinned to the edge of the table view, and is revealed as the cell is dragged aside.
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
