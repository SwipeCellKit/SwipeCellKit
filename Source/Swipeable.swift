//
//  Swipeable.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Internal 

protocol Swipeable {
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
