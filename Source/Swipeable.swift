//
//  Swipeable.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Internal 

protocol Swipeable {
    var actionsView: SwipeActionsView? { get set }
    
    var state: SwipeState { get set }
    
    var frame: CGRect { get }
    
    var scrollView: UIScrollView? { get }
    
    var indexPath: IndexPath? { get }
}

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
