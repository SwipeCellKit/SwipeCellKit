//
//  Swipeable.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Internal 

protocol Swipeable {
    var direction: SwipeDirection { get set }
    
    var state: SwipeState { get set }
    
    var actionsView: SwipeActionsView? { get set }
    
    var frame: CGRect { get }
    
    var scrollView: UIScrollView? { get }
    
    var indexPath: IndexPath? { get }
    
    var panGestureRecognizer: UIGestureRecognizer { get }
}

extension SwipeTableViewCell: Swipeable {}
extension SwipeCollectionViewCell: Swipeable {}

enum SwipeState: Int {
    case center = 0
    case left
    case right
    case dragging
    case animatingToCenter
    
    init(orientation: SwipeActionsOrientation) {
        self = orientation == .left ? .left : .right
    }
    
    var isActive: Bool { return self != .center }
}

/// Describes which swipe direction is allowed for the cell
public struct SwipeDirection: OptionSet {
    
    private enum Options: Int {
        case none
        case rightToLeft
        case leftToRight
    }
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    private init(_ options: Options) {
        self.rawValue = options.rawValue
    }
    
    /// Swipe is not allowed at all on the cell
    public static let None = SwipeDirection(.none)
    
    /// Allows user to swipe the cell from the right to the left
    public static let RightToLeft = SwipeDirection(.rightToLeft)
    
    /// Allows user to swipe the cell from the left to the right
    public static let LeftToRight = SwipeDirection(.leftToRight)
}
