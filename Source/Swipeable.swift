//
//  Swipeable.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Internal 

protocol Swipeable {
    var actionsView: SwipeActionsView? { get }
    
    var state: SwipeState { get }
    
    var frame: CGRect { get }
}

extension SwipeTableViewCell: Swipeable {}

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
